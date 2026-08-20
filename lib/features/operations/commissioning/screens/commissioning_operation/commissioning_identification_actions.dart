import 'dart:async';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/core/utils/barcode_utils.dart';
import 'package:traqtrace_app/core/utils/gs1/gs1_converter.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_presenter.dart';
import 'package:traqtrace_app/core/widgets/epc_input_widget/epc_types.dart';
import 'package:traqtrace_app/data/models/barcode/barcode_details.dart';
import 'package:traqtrace_app/data/models/operations/commissioning/commissioning_models.dart';
import 'package:traqtrace_app/data/services/gs1/gln/gln_picker_catalog.dart';
import 'package:traqtrace_app/features/gs1/gtin/utils/gtin_format.dart';
import 'package:traqtrace_app/features/gs1/sscc/utils/sscc_format.dart';
import 'package:traqtrace_app/features/operations/commissioning/cubit/commissioning_operation_cubit.dart';
import 'package:traqtrace_app/features/operations/commissioning/models/commissioning_epc_item.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation/commissioning_operation_view.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation/widgets/commissioning_epc_disambiguation_dialog.dart';
import 'package:traqtrace_app/features/operations/commissioning/utils/commissioning_epc_resolver.dart';
import 'package:traqtrace_app/features/operations/commissioning/utils/commissioning_serial_pool_checker.dart';
import 'package:traqtrace_app/features/operations/commissioning/utils/commissioning_serial_pool_status.dart';

extension CommissioningIdentificationActions
    on CommissioningOperationViewState {
  String? resolvedGtinCode() {
    final fromParsed = primaryParsed?.gtin;
    if (fromParsed != null && fromParsed.trim().isNotEmpty) {
      final trimmed = fromParsed.trim();
      if (GtinFormat.isValidGtin(trimmed)) {
        return GtinFormat.normalizeGtinTo14(trimmed);
      }
      return trimmed;
    }
    final epc = primaryParsed?.epc;
    if (epc != null) {
      final fromEpc = Gs1Converter.epcToGTIN(epc);
      if (fromEpc != null &&
          fromEpc.isNotEmpty &&
          GtinFormat.isValidGtin(fromEpc)) {
        return GtinFormat.normalizeGtinTo14(fromEpc);
      }
    }
    return null;
  }

  void onBatchLotTextChanged() {
    if (!mounted) return;
    setState(() {});
  }

  Future<void> loadLocations() async {
    try {
      final catalog = getIt<GlnPickerCatalog>();
      final glns = await catalog.ensureLoaded();
      if (!mounted) return;
      setState(
        () => availableLocations = glns.where((g) => g.active).toList(),
      );
    } catch (e) {
      debugPrint('Error loading GLNs for commissioning picker: $e');
    }
  }

  Future<void> onScanItemAdded(EPCParseResult result) async {
    if (commissionItems.isEmpty) {
      await _processResolvedEpc(result, isPrimary: true);
      return;
    }
    if (identifiedType != null && result.type != identifiedType) {
      context.showError(
        'Expected ${identifiedType!.name.toUpperCase()} — got ${result.typeLabel}',
      );
      return;
    }
    if (commissionItems.any((i) => i.epc == result.epc)) {
      context.showError('EPC already queued for commissioning');
      return;
    }
    await _processResolvedEpc(result, isPrimary: false);
  }

  void applyApiRejectionResults(ApiException exception) {
    final body = exception.responseBody;
    if (body == null || body.isEmpty) return;
    try {
      final decoded = json.decode(body);
      if (decoded is! Map<String, dynamic>) return;
      final raw = decoded['itemResults'] as List<dynamic>? ?? [];
      final results = raw
          .whereType<Map<String, dynamic>>()
          .map(CommissioningItemResult.fromJson)
          .toList();
      if (results.isEmpty) return;

      setState(() {
        commissionItems.replaceRange(
          0,
          commissionItems.length,
          commissionItems.map((item) {
            final match = results.where((r) {
              if (r.canonicalIdentifier != null &&
                  r.canonicalIdentifier == item.epc) {
                return true;
              }
              final serial = item.parsed.serial;
              return serial != null && r.serialNumber == serial;
            }).firstOrNull;
            if (match == null || match.success) return item;
            return item.copyWith(
              poolStatus: CommissioningSerialPoolStatus.notTransitionable,
              blockReason: match.errorMessage ?? 'Rejected by server',
            );
          }).toList(),
        );
      });
    } catch (_) {}
  }

  Future<void> _processResolvedEpc(
    EPCParseResult parsed, {
    required bool isPrimary,
  }) async {
    final checkDigitError = _validateCheckDigits(parsed);
    if (checkDigitError != null) {
      context.showError(checkDigitError);
      return;
    }

    if (!isPrimary && primaryParsed != null && parsed.type == EPCType.sgtin) {
      final mismatch = _gtinMismatchMessageFor(parsed);
      if (mismatch != null) {
        context.showError(mismatch);
        return;
      }
    }

    final pool = await _resolvePoolCheck(parsed);
    if (!mounted) return;

    if (pool.status.blocksCommissioning) {
      context.showError(pool.blockReason ?? 'Serial cannot be commissioned');
      return;
    }

    final item = CommissioningEpcItem(
      parsed: parsed,
      poolStatus: pool.status,
      sourceStatus: pool.sourceStatus,
      targetStatus: pool.targetStatus,
      blockReason: pool.blockReason,
    );

    if (isPrimary) {
      await _applyPrimaryIdentification(item);
    } else {
      setState(() => commissionItems.add(item));
      _applyGuessabilityWarning(parsed);
      if (guessabilityWarning != null) {
        context.showWarning(guessabilityWarning!);
      }
    }
  }

  Future<void> _applyPrimaryIdentification(CommissioningEpcItem item) async {
    final parsed = item.parsed;
    setState(() {
      guessabilityWarning = null;
      identifiedType = parsed.type;
      primaryParsed = parsed;
      commissionItems
        ..clear()
        ..add(item);
    });

    if (parsed.type == EPCType.sgtin && parsed.gtin != null) {
      await Future.wait([
        _onPharmaGtinIdentified(parsed.gtin!),
        _loadGtinForCode(parsed.gtin!),
      ]);
      if (parsed.serial != null) {
        _applyGuessabilityWarning(parsed);
      }
      final details = extractBarcodeDetails(parsed.raw);
      if (details.batchLot != null && details.batchLot!.isNotEmpty) {
        batchLotController.text = details.batchLot!;
      }
      if (details.expiry != null && !expiryManuallySet) {
        expiryDate = details.expiry;
      }
      if (details.productionDate != null && !productionDateManuallySet) {
        productionDate = details.productionDate;
      }
    }

    if (parsed.type == EPCType.sscc) {
      isPharmaGtin = false;
    }

    if (!mounted) return;
    setState(() {});
    _applyGuessabilityWarning(parsed);
    if (guessabilityWarning != null) {
      context.showWarning(guessabilityWarning!);
    }
  }

  Future<void> _onPharmaGtinIdentified(String gtinCode) async {
    final normalized = GtinFormat.normalizeGtinTo14(gtinCode);
    if (pharmaGtinIdentifiedFor == normalized) return;
    pharmaGtinIdentifiedFor = normalized;

    final cubit = context.read<CommissioningOperationCubit>();
    final isPharma = await cubit.onPharmaGtinIdentified(gtinCode);
    if (!mounted) return;
    setState(() => isPharmaGtin = isPharma);
  }

  Future<void> _loadGtinForCode(String gtinCode) async {
    final normalized = GtinFormat.normalizeGtinTo14(gtinCode);
    if (selectedGTIN?.gtinCode == normalized) return;
    if (gtinLoadInFlightFor == normalized) return;

    gtinLoadInFlightFor = normalized;
    try {
      final gtin = await gtinService.getGTIN(normalized);
      if (!mounted || gtinLoadInFlightFor != normalized) return;
      setState(() {
        selectedGTIN = gtin;
        gtinLoadInFlightFor = null;
      });
    } catch (_) {
      if (!mounted || gtinLoadInFlightFor != normalized) return;
      setState(() => gtinLoadInFlightFor = null);
    }
  }

  CommissioningPoolCheckResult? _cachedPoolCheck(EPCParseResult parsed) {
    final cached = poolCheckCache[parsed.epc];
    if (cached != null) return cached;

    for (final item in commissionItems) {
      if (item.epc != parsed.epc) continue;
      if (item.poolStatus == CommissioningSerialPoolStatus.checking) {
        return null;
      }
      return CommissioningPoolCheckResult(
        status: item.poolStatus,
        sourceStatus: item.sourceStatus,
        targetStatus: item.targetStatus,
        blockReason: item.blockReason,
      );
    }
    return null;
  }

  Future<CommissioningPoolCheckResult> _resolvePoolCheck(
    EPCParseResult parsed,
  ) async {
    final cached = _cachedPoolCheck(parsed);
    if (cached != null) return cached;

    final result = await poolChecker.check(parsed);
    poolCheckCache[parsed.epc] = result;
    return result;
  }

  Map<String, String> get itemProductNames {
    final gtin = selectedGTIN;
    final name = gtin?.tradeItemDescription?.trim().isNotEmpty == true
        ? gtin!.tradeItemDescription
        : gtin?.productName;
    if (name == null || name.trim().isEmpty) return const {};
    return {for (final item in commissionItems) item.epc: name};
  }

  String? _validateCheckDigits(EPCParseResult parsed) {
    if (parsed.gtin != null && !GtinFormat.isValidGtin(parsed.gtin!)) {
      return 'GTIN ${parsed.gtin} has an invalid check digit';
    }
    if (parsed.sscc != null && !SsccFormat.isValidSscc(parsed.sscc!)) {
      return 'SSCC ${parsed.sscc} has an invalid check digit';
    }
    return null;
  }

  String? _gtinMismatchMessageFor(EPCParseResult parsed) {
    final primaryGtin = primaryParsed?.gtin;
    final scannedGtin = parsed.gtin;
    if (primaryGtin == null || scannedGtin == null) return null;
    String norm(String v) => v.replaceAll(RegExp(r'\D'), '').padLeft(14, '0');
    if (norm(scannedGtin) != norm(primaryGtin)) {
      return 'GTIN mismatch: barcode contains $scannedGtin '
          'but identified product is $primaryGtin';
    }
    return null;
  }

  void _applyGuessabilityWarning(EPCParseResult parsed) {
    if (!isPharmaSgtin || parsed.serial == null) return;
    final serial = parsed.serial!;
    if (RegExp(r'^[A-Z]{3}\d{8,}$').hasMatch(serial)) {
      guessabilityWarning =
          'Serial $serial looks like an internal reference, not an FMD-compliant unpredictable serial.';
      return;
    }
    final details = extractBarcodeDetails(parsed.raw);
    if (details.type == Gs1BarcodeType.unknown) {
      guessabilityWarning =
          'Not a GS1 product barcode. Pharmaceutical serials must be unpredictable '
          '(FMD/DSCSA). Scan the pack label or enter a pool-allocated serial.';
    }
  }

  Future<EPCParseResult?> epcFallbackResolve(String input) async {
    final outcome = await epcResolver.resolve(input);
    if (!mounted) return null;
    return switch (outcome) {
      CommissioningEpcResolved(:final parsed, :final poolCheck) => () {
        if (poolCheck != null) {
          poolCheckCache[parsed.epc] = poolCheck;
        }
        return parsed;
      }(),
      CommissioningEpcResolveAmbiguous(:final matches) =>
        await CommissioningEpcDisambiguationDialog.show(
          context,
          serial: input,
          matches: matches,
        ).then((m) {
          if (m?.poolCheck != null) {
            poolCheckCache[m!.parsed.epc] = m.poolCheck!;
          }
          return m?.parsed;
        }),
      CommissioningEpcResolveError(:final message) => () {
        context.showError(message);
        return null;
      }(),
    };
  }
}
