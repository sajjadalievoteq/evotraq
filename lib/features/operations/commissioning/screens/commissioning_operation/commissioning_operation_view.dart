import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/navigation/pop_or_go.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/core/utils/barcode_utils.dart';
import 'package:traqtrace_app/core/utils/gs1/gs1_converter.dart';
import 'package:traqtrace_app/core/widgets/epc_input_widget/epc_types.dart';
import 'package:traqtrace_app/data/models/gs1/gtin/gtin_batch.dart';
import 'package:traqtrace_app/data/models/gs1/gtin/gtin_model.dart';
import 'package:traqtrace_app/data/models/operations/commissioning/commissioning_models.dart';
import 'package:traqtrace_app/data/services/gs1/gtin/gtin_service.dart';
import 'package:traqtrace_app/data/services/gs1/serialization/sgtin/sgtin_service.dart';
import 'package:traqtrace_app/data/services/gs1/serialization/sscc/sscc_service.dart';
import 'package:traqtrace_app/features/operations/commissioning/cubit/commissioning_batch_lookup_status.dart';
import 'package:traqtrace_app/features/operations/commissioning/cubit/commissioning_operation_cubit.dart';
import 'package:traqtrace_app/features/operations/commissioning/cubit/commissioning_operation_state.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/core/layout/layout_manager.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/features/operations/commissioning/models/commissioning_epc_item.dart';
import 'package:traqtrace_app/features/operations/commissioning/utils/commissioning_epc_resolver.dart';
import 'package:traqtrace_app/features/operations/commissioning/utils/commissioning_field_validators.dart';
import 'package:traqtrace_app/features/operations/commissioning/utils/commissioning_serial_pool_checker.dart';
import 'package:traqtrace_app/features/operations/commissioning/utils/commissioning_serial_pool_status.dart';
import 'package:traqtrace_app/core/widgets/operation_wizard/operation_step_config.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation/widgets/commissioning_clear_serials_dialog.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation/widgets/commissioning_epc_disambiguation_dialog.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/operation/operation_desktop_layout.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/operation/operation_mobile_layout.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation/widgets/commissioning_step1_product_details.dart';
import 'package:traqtrace_app/features/operations/commissioning/utils/commissioning_submit_error_message.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation/widgets/commissioning_step2_serial_numbers.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation/widgets/commissioning_step3_review.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation/widgets/commissioning_partial_success_choice.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation/widgets/commissioning_partial_success_result.dart';
import 'package:traqtrace_app/features/gs1/gtin/utils/gtin_format.dart';
import 'package:traqtrace_app/features/gs1/sscc/utils/sscc_format.dart';
import 'package:traqtrace_app/features/gs1/gln/services/gln_picker_catalog.dart';
import 'widgets/commissioning_partial_success_dialog.dart';

class CommissioningOperationView extends StatefulWidget {
  const CommissioningOperationView({super.key});

  @override
  State<CommissioningOperationView> createState() =>
      _CommissioningOperationViewState();
}

class _CommissioningOperationViewState extends State<CommissioningOperationView> {
  static const _wizardSteps = [
    OperationStepConfig.details,
    OperationStepConfig.items,
    OperationStepConfig.review,
  ];

  final _pageController = PageController();
  int _currentStep = 0;

  final _batchLotController = TextEditingController();
  final _registrationQuantityController = TextEditingController();
  final _referenceController = TextEditingController();
  final _readPointGlnController = TextEditingController();

  final _countryOfOriginController = TextEditingController();
  final _productionOrderController = TextEditingController();
  final _productionLineController = TextEditingController();
  final _regulatoryMarketController = TextEditingController();
  final _regulatoryStatusController = TextEditingController();
  final _operatorIdController = TextEditingController();
  final _notesController = TextEditingController();

  final _step1FormKey = GlobalKey<FormState>();
  final _step2FormKey = GlobalKey<FormState>();

  late final CommissioningEpcResolver _epcResolver;
  late final CommissioningSerialPoolChecker _poolChecker;
  late final GTINService _gtinService;

  GTIN? _selectedGTIN;
  String? _gtinLoadInFlightFor;
  String? _pharmaGtinIdentifiedFor;
  final Map<String, CommissioningPoolCheckResult> _poolCheckCache = {};

  EPCType? _identifiedType;
  EPCParseResult? _primaryParsed;
  String? _guessabilityWarning;

  bool _isPharmaGtin = false;
  List<GLN> _availableLocations = [];
  GLN? _commissioningLocationGLN;
  String? _locationError;
  DateTime? _expiryDate;
  DateTime? _productionDate;
  DateTime? _bestBeforeDate;
  bool _expiryManuallySet = false;
  bool _productionDateManuallySet = false;

  final List<CommissioningEpcItem> _commissionItems = [];

  bool _isLoading = false;

  bool get _isPharmaSgtin =>
      _identifiedType == EPCType.sgtin && _isPharmaGtin;

  bool get _isDetailsStepValid => _commissioningLocationGLN != null;

  bool get _isStep2Valid =>
      _commissionItems.isNotEmpty &&
      !_commissionItems.any((i) => i.poolStatus.blocksCommissioning) &&
      !_commissionItems.any(
        (i) => i.poolStatus == CommissioningSerialPoolStatus.checking,
      );

  String? _resolvedGtinCode() {
    final fromParsed = _primaryParsed?.gtin;
    if (fromParsed != null && fromParsed.trim().isNotEmpty) {
      final trimmed = fromParsed.trim();
      if (GtinFormat.isValidGtin(trimmed)) {
        return GtinFormat.normalizeGtinTo14(trimmed);
      }
      return trimmed;
    }
    final epc = _primaryParsed?.epc;
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

  @override
  void initState() {
    super.initState();
    _poolChecker = getIt<CommissioningSerialPoolChecker>();
    _epcResolver = CommissioningEpcResolver(
      sgtinService: getIt<SGTINService>(),
      ssccService: getIt<SSCCService>(),
      poolChecker: _poolChecker,
    );    _gtinService = getIt<GTINService>();
    _batchLotController.addListener(_onBatchLotTextChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadLocations());
  }

  @override
  void dispose() {
    _pageController.dispose();
    _batchLotController.dispose();
    _registrationQuantityController.dispose();
    _referenceController.dispose();
    _readPointGlnController.dispose();
    _countryOfOriginController.dispose();
    _productionOrderController.dispose();
    _productionLineController.dispose();
    _regulatoryMarketController.dispose();
    _regulatoryStatusController.dispose();
    _operatorIdController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onBatchLotTextChanged() {
    if (!mounted) return;
    context.read<CommissioningOperationCubit>().onBatchLotInputChanged(
          gtinCode: _resolvedGtinCode(),
          isPharmaGtin: _isPharmaGtin,
          batchLot: _batchLotController.text,
        );
    setState(() {});
  }

  Future<void> _loadLocations() async {
    try {
      final catalog = getIt<GlnPickerCatalog>();
      final glns = await catalog.ensureLoaded();
      if (!mounted) return;
      setState(() => _availableLocations = glns.where((g) => g.active).toList());
    } catch (e) {
      debugPrint('Error loading GLNs for commissioning picker: $e');
    }
  }

  Future<void> _onScanItemAdded(EPCParseResult result) async {
    if (_commissionItems.isEmpty) {
      await _processResolvedEpc(result, isPrimary: true);
      return;
    }
    if (_identifiedType != null && result.type != _identifiedType) {
      context.showError(
        'Expected ${_identifiedType!.name.toUpperCase()} — got ${result.typeLabel}',
      );
      return;
    }
    if (_commissionItems.any((i) => i.epc == result.epc)) {
      context.showError('EPC already queued for commissioning');
      return;
    }
    await _processResolvedEpc(result, isPrimary: false);
  }

  void _applyApiRejectionResults(ApiException exception) {
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
        _commissionItems.replaceRange(
          0,
          _commissionItems.length,
          _commissionItems.map((item) {
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

    if (!isPrimary && _primaryParsed != null && parsed.type == EPCType.sgtin) {
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
      setState(() => _commissionItems.add(item));
      _applyGuessabilityWarning(parsed);
      if (_guessabilityWarning != null) {
        context.showWarning(_guessabilityWarning!);
      }
    }
  }

  Future<void> _applyPrimaryIdentification(CommissioningEpcItem item) async {
    final parsed = item.parsed;
    setState(() {
      _guessabilityWarning = null;
      _identifiedType = parsed.type;
      _primaryParsed = parsed;
      _commissionItems
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
        _batchLotController.text = details.batchLot!;
      }
      if (details.expiry != null && !_expiryManuallySet) {
        _expiryDate = details.expiry;
      }
      if (details.productionDate != null && !_productionDateManuallySet) {
        _productionDate = details.productionDate;
      }
    }

    if (parsed.type == EPCType.sscc) {
      _isPharmaGtin = false;
      context.read<CommissioningOperationCubit>().clearBatchState();
    }

    if (!mounted) return;
    setState(() {});
    _applyGuessabilityWarning(parsed);
    if (_guessabilityWarning != null) {
      context.showWarning(_guessabilityWarning!);
    }
  }

  Future<void> _onPharmaGtinIdentified(String gtinCode) async {
    final normalized = GtinFormat.normalizeGtinTo14(gtinCode);
    if (_pharmaGtinIdentifiedFor == normalized) return;
    _pharmaGtinIdentifiedFor = normalized;

    final cubit = context.read<CommissioningOperationCubit>();
    final isPharma = await cubit.onPharmaGtinIdentified(gtinCode);
    if (!mounted) return;
    setState(() => _isPharmaGtin = isPharma);
    if (isPharma && _batchLotController.text.trim().isNotEmpty) {
      cubit.triggerBatchLookupNow(
        gtinCode: gtinCode,
        isPharmaGtin: true,
        batchLot: _batchLotController.text,
      );
    }
  }

  Future<void> _loadGtinForCode(String gtinCode) async {
    final normalized = GtinFormat.normalizeGtinTo14(gtinCode);
    if (_selectedGTIN?.gtinCode == normalized) return;
    if (_gtinLoadInFlightFor == normalized) return;

    _gtinLoadInFlightFor = normalized;
    try {
      final gtin = await _gtinService.getGTIN(normalized);
      if (!mounted || _gtinLoadInFlightFor != normalized) return;
      setState(() {
        _selectedGTIN = gtin;
        _gtinLoadInFlightFor = null;
      });
    } catch (_) {
      if (!mounted || _gtinLoadInFlightFor != normalized) return;
      setState(() => _gtinLoadInFlightFor = null);
    }
  }

  CommissioningPoolCheckResult? _cachedPoolCheck(EPCParseResult parsed) {
    final cached = _poolCheckCache[parsed.epc];
    if (cached != null) return cached;

    for (final item in _commissionItems) {
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

    final result = await _poolChecker.check(parsed);
    _poolCheckCache[parsed.epc] = result;
    return result;
  }

  Map<String, String> get _itemProductNames {
    final gtin = _selectedGTIN;
    final name = gtin?.tradeItemDescription?.trim().isNotEmpty == true
        ? gtin!.tradeItemDescription
        : gtin?.productName;
    if (name == null || name.trim().isEmpty) return const {};
    return {for (final item in _commissionItems) item.epc: name};
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
    final primaryGtin = _primaryParsed?.gtin;
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
    if (!_isPharmaSgtin || parsed.serial == null) return;
    final serial = parsed.serial!;
    if (RegExp(r'^[A-Z]{3}\d{8,}$').hasMatch(serial)) {
      _guessabilityWarning =
          'Serial $serial looks like an internal reference, not an FMD-compliant unpredictable serial.';
      return;
    }
    final details = extractBarcodeDetails(parsed.raw);
    if (details.type == Gs1BarcodeType.unknown) {
      _guessabilityWarning =
          'Not a GS1 product barcode. Pharmaceutical serials must be unpredictable '
          '(FMD/DSCSA). Scan the pack label or enter a pool-allocated serial.';
    }
  }

  Future<EPCParseResult?> _epcFallbackResolve(String input) async {
    final outcome = await _epcResolver.resolve(input);
    if (!mounted) return null;
    return switch (outcome) {
      CommissioningEpcResolved(:final parsed, :final poolCheck) => () {
          if (poolCheck != null) {
            _poolCheckCache[parsed.epc] = poolCheck;
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
            _poolCheckCache[m!.parsed.epc] = m.poolCheck!;
          }
          return m?.parsed;
        }),
      CommissioningEpcResolveError(:final message) => () {
          context.showError(message);
          return null;
        }(),
    };
  }

  void _triggerBatchLookupNow() {
    context.read<CommissioningOperationCubit>().triggerBatchLookupNow(
          gtinCode: _resolvedGtinCode(),
          isPharmaGtin: _isPharmaGtin,
          batchLot: _batchLotController.text,
        );
  }

  DateTime? _parseBatchDate(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return DateTime.tryParse(value.trim());
  }

  void _applyBatchDatesFromResolved(GtinBatch batch) {
    final expiry = _parseBatchDate(batch.expiryDate);
    final manufacture = _parseBatchDate(batch.manufactureDate);
    setState(() {
      if (expiry != null && !_expiryManuallySet) _expiryDate = expiry;
      if (manufacture != null && !_productionDateManuallySet) {
        _productionDate = manufacture;
      }
    });
  }

  Future<void> _registerBatch() async {
    final cubit = context.read<CommissioningOperationCubit>();
    final gtinCode = _resolvedGtinCode();
    final dbId = cubit.state.gtinDbId;
    if (gtinCode == null || dbId == null) return;

    final qtyText = _registrationQuantityController.text.trim();
    cubit.setRegistrationQuantityManufactured(
      qtyText.isEmpty ? null : int.tryParse(qtyText),
    );

    final ok = await cubit.registerBatch(
      gtinDbId: dbId,
      gtinCode: gtinCode,
      batchLot: _batchLotController.text,
    );
    if (!mounted) return;
    if (ok) {
      context.showSuccess('Batch registered successfully');
      final batch = cubit.state.resolvedBatch;
      if (batch != null) _applyBatchDatesFromResolved(batch);
    }
  }

  Future<void> _selectRegistrationDate(String dateType) async {
    final cubit = context.read<CommissioningOperationCubit>();
    final now = DateTime.now();
    final initialDate = switch (dateType) {
      'registrationExpiry' =>
        cubit.state.registrationExpiryDate ?? now.add(const Duration(days: 365)),
      _ => cubit.state.registrationManufactureDate ?? now,
    };
    final label = switch (dateType) {
      'registrationExpiry' => 'Expiry',
      _ => 'Manufacture',
    };

    final selected = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: dateType == 'registrationExpiry' ? now : DateTime(now.year - 2),
      lastDate: DateTime(now.year + 10),
      helpText: 'Select $label Date',
    );
    if (selected == null || !mounted) return;

    switch (dateType) {
      case 'registrationExpiry':
        cubit.setRegistrationExpiryDate(selected);
      case 'registrationManufacture':
        cubit.setRegistrationManufactureDate(selected);
    }
  }

  void _clearRegistrationDate(String dateType) {
    final cubit = context.read<CommissioningOperationCubit>();
    switch (dateType) {
      case 'registrationExpiry':
        cubit.setRegistrationExpiryDate(null);
      case 'registrationManufacture':
        cubit.setRegistrationManufactureDate(null);
    }
  }

  bool _isPharmaBatchReady(CommissioningOperationState batchState) {
    if (!_isPharmaSgtin) return true;
    if (batchState.isBatchBusy) return false;
    if (batchState.requiresBatchRegistration) return false;
    if (_batchLotController.text.trim().isEmpty) return false;

    return switch (batchState.batchLookupStatus) {
      CommissioningBatchLookupStatus.found ||
      CommissioningBatchLookupStatus.registered =>
        true,
      CommissioningBatchLookupStatus.error => true,
      CommissioningBatchLookupStatus.idle ||
      CommissioningBatchLookupStatus.lookingUp ||
      CommissioningBatchLookupStatus.notFound ||
      CommissioningBatchLookupStatus.registering =>
        false,
    };
  }

  Future<void> _nextStep() async {
    if (_currentStep < 2 && await _validateCurrentStep()) {
      await _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _previousStep() async {
    if (_currentStep > 0) {
      await _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<bool> _validateDetailsStep() async {
    setState(() => _locationError = null);
    final formValid = _step1FormKey.currentState?.validate() ?? false;
    var isValid = formValid;
    if (_commissioningLocationGLN == null) {
      setState(() => _locationError = 'Commissioning Location is required');
      isValid = false;
    }
    return isValid;
  }

  Future<bool> _validateItemsStep() async {
    if (_commissionItems.isEmpty) {
      context.showError('At least one EPC is required');
      return false;
    }
    final blocking = _commissionItems
        .where((i) => i.poolStatus.blocksCommissioning)
        .map((i) => i.displayKey)
        .toList();
    if (blocking.isNotEmpty) {
      context.showError(
        'Remove blocked EPC(s): ${blocking.take(3).join(', ')}',
      );
      return false;
    }
    final checking = _commissionItems
        .where((i) => i.poolStatus == CommissioningSerialPoolStatus.checking)
        .length;
    if (checking > 0) {
      context.showWarning('Pool check still running — wait and retry.');
      return false;
    }
    if (_identifiedType == EPCType.sgtin) {
      final gtinCode = _resolvedGtinCode();
      if (gtinCode == null || gtinCode.isEmpty) {
        context.showError(
          'Could not determine GTIN from the scanned identifier',
        );
        return false;
      }
      final formValid = _step2FormKey.currentState?.validate() ?? true;
      if (!formValid) return false;
      final batchErr = CommissioningFieldValidators.validateBatchLotNumberRequired(
        _batchLotController.text,
      );
      if (batchErr != null) {
        context.showError(batchErr);
        return false;
      }
      if (_isPharmaSgtin && _expiryDate == null) {
        context.showError(
          'Expiry Date is required for pharmaceutical commissioning',
        );
        return false;
      }
    }
    final batchCubit = context.read<CommissioningOperationCubit>();
    final batchState = batchCubit.state;
    if (_isPharmaSgtin) {
      if (batchState.isBatchBusy) {
        context.showWarning(
          'Wait for batch lookup or registration to finish.',
        );
        return false;
      }
      if (batchState.requiresBatchRegistration) {
        context.showError(
          'Register the batch in Batch Master before continuing.',
        );
        return false;
      }
      if (batchState.batchLookupStatus == CommissioningBatchLookupStatus.idle) {
        context.showInfo('Verifying batch in Batch Master…');
        batchCubit.triggerBatchLookupNow(
          gtinCode: _resolvedGtinCode(),
          isPharmaGtin: _isPharmaGtin,
          batchLot: _batchLotController.text,
        );
        return false;
      }
    }
    return true;
  }

  Future<bool> _validateCurrentStep() async {
    switch (_currentStep) {
      case 0:
        return _validateDetailsStep();
      case 1:
        return _validateItemsStep();
      default:
        return true;
    }
  }

  void _removeItem(int index) {
    setState(() {
      if (index == 0 && _commissionItems.length == 1) {
        _resetIdentification();
      } else {
        _poolCheckCache.remove(_commissionItems[index].epc);
        _commissionItems.removeAt(index);
      }
    });
  }

  void _resetIdentification() {
    _identifiedType = null;
    _primaryParsed = null;
    _isPharmaGtin = false;
    _guessabilityWarning = null;
    _selectedGTIN = null;
    _gtinLoadInFlightFor = null;
    _pharmaGtinIdentifiedFor = null;
    _poolCheckCache.clear();
    _commissionItems.clear();
    context.read<CommissioningOperationCubit>().clearBatchState();
  }

  Future<void> _clearAllItems() async {
    final confirmed = await CommissioningClearSerialsDialog.show(
      context,
      _commissionItems.length,
    );
    if (confirmed == true) {
      setState(_resetIdentification);
    }
  }

  Future<void> _selectDate(String dateType) async {
    final now = DateTime.now();
    final initialDate = switch (dateType) {
      'production' => _productionDate ?? now,
      'expiry' => _expiryDate ?? now.add(const Duration(days: 365)),
      _ => _bestBeforeDate ?? now.add(const Duration(days: 180)),
    };
    final label = switch (dateType) {
      'production' => 'Production',
      'expiry' => 'Expiry',
      _ => 'Best Before',
    };

    final selected = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: dateType == 'production' ? DateTime(now.year - 2) : now,
      lastDate: DateTime(now.year + 10),
      helpText: 'Select $label Date',
    );

    if (selected != null) {
      setState(() {
        switch (dateType) {
          case 'production':
            _productionDate = selected;
            _productionDateManuallySet = true;
          case 'expiry':
            _expiryDate = selected;
            _expiryManuallySet = true;
          case 'bestBefore':
            _bestBeforeDate = selected;
        }
      });
    }
  }

  void _clearDate(String dateType) {
    setState(() {
      switch (dateType) {
        case 'production':
          _productionDate = null;
          _productionDateManuallySet = false;
        case 'expiry':
          _expiryDate = null;
          _expiryManuallySet = false;
        case 'bestBefore':
          _bestBeforeDate = null;
      }
    });
  }

  SsccCommissioningRequest _buildSsccCommissioningRequest() {
    final readPoint = _readPointGlnController.text.trim();
    return SsccCommissioningRequest(
      commissioningReference: _referenceController.text.trim().isNotEmpty
          ? _referenceController.text.trim()
          : null,
      epcUris: _commissionItems.map((i) => i.epc).toList(),
      commissioningLocationGLN: _commissioningLocationGLN!.glnCode,
      readPointGLN: readPoint.isNotEmpty ? readPoint : null,
      operatorId: _operatorIdController.text.trim().isNotEmpty
          ? _operatorIdController.text.trim()
          : null,
      notes: _notesController.text.trim().isNotEmpty
          ? _notesController.text.trim()
          : null,
      countryOfOrigin: _countryOfOriginController.text.trim().isNotEmpty
          ? _countryOfOriginController.text.trim().toUpperCase()
          : null,
      
      childEpcUris: null,
    );
  }

  CommissioningRequest _buildCommissioningRequest() {
    final serials = _commissionItems
        .where((i) => i.type == EPCType.sgtin)
        .map((i) => i.parsed.serial!)
        .toList();
    final gtinCode = _resolvedGtinCode() ?? '';
    final readPoint = _readPointGlnController.text.trim();

    return CommissioningRequest(
      gtinCode: gtinCode,
      serialNumbers: serials,
      batchLotNumber: _batchLotController.text.trim(),
      commissioningLocationGLN: _commissioningLocationGLN!.glnCode,
      expiryDate: _expiryDate,
      productionDate: _productionDate,
      bestBeforeDate: _bestBeforeDate,
      commissioningReference: _referenceController.text.trim().isNotEmpty
          ? _referenceController.text.trim()
          : null,
      operatorId: _operatorIdController.text.trim().isNotEmpty
          ? _operatorIdController.text.trim()
          : null,
      comments: _notesController.text.trim().isNotEmpty
          ? _notesController.text.trim()
          : null,
      countryOfOrigin: _countryOfOriginController.text.trim().isNotEmpty
          ? _countryOfOriginController.text.trim().toUpperCase()
          : null,
      productionOrder: _productionOrderController.text.trim().isNotEmpty
          ? _productionOrderController.text.trim()
          : null,
      productionLine: _productionLineController.text.trim().isNotEmpty
          ? _productionLineController.text.trim()
          : null,
      regulatoryMarket: _regulatoryMarketController.text.trim().isNotEmpty
          ? _regulatoryMarketController.text.trim()
          : null,
      regulatoryStatus: _regulatoryStatusController.text.trim().isNotEmpty
          ? _regulatoryStatusController.text.trim()
          : null,
      readPointGLN: readPoint.isNotEmpty ? readPoint : null,
      identifierType: _identifiedType?.name,
      canonicalIdentifiers: _commissionItems.map((i) => i.epc).toList(),
    );
  }

  void _syncItemsAfterPartialSuccess(
    CommissioningResponse response,
    CommissioningPartialSuccessResult dialogResult,
  ) {
    final results = response.itemResults ?? [];
    final successfulSerials = results
        .where((r) => r.success)
        .map((r) => r.serialNumber)
        .toSet();

    setState(() {
      _commissionItems.removeWhere(
        (i) =>
            i.parsed.serial != null &&
            successfulSerials.contains(i.parsed.serial),
      );

      if (dialogResult.choice ==
          CommissioningPartialSuccessChoice.removeSelectedAndRetry) {
        _commissionItems.removeWhere(
          (i) =>
              i.parsed.serial != null &&
              dialogResult.serialsMarkedForRemoval.contains(i.parsed.serial),
        );
      }
    });
  }

  Future<void> _handlePartialSuccess(CommissioningResponse response) async {
    final dialogResult = await showPartialSuccessDialog(context, response);
    if (!mounted || dialogResult == null) return;

    _syncItemsAfterPartialSuccess(response, dialogResult);

    final commissioned = response.commissionedCount ?? 0;
    final failed = response.failedCount ?? 0;

    switch (dialogResult.choice) {
      case CommissioningPartialSuccessChoice.acceptPartialSuccess:
        context.showSuccess(
          'Partial success: $commissioned commissioned, $failed failed',
        );
        if (mounted) popOrGo(context, Constants.opCommissioningRoute);
      case CommissioningPartialSuccessChoice.continueWithoutRemoving:
        context.showInfo(
          '${_commissionItems.length} failed EPC(s) remain — review and submit again.',
        );
        setState(() => _currentStep = 1);
        _pageController.jumpToPage(1);
      case CommissioningPartialSuccessChoice.removeSelectedAndRetry:
        if (_commissionItems.isEmpty) {
          context.showWarning('All failed EPCs were removed.');
          setState(() => _currentStep = 1);
          _pageController.jumpToPage(1);
          break;
        }
        context.showInfo('Retrying for ${_commissionItems.length} EPC(s)...');
        await _submit(isRetry: true);
    }
  }

  Future<void> _submit({bool isRetry = false}) async {
    if (!await _validateDetailsStep()) return;
    if (!await _validateItemsStep()) return;

    setState(() => _isLoading = true);

    try {
      final cubit = context.read<CommissioningOperationCubit>();
      final CommissioningResponse? response;

      if (_identifiedType == EPCType.sscc) {
        response = await cubit.commissionSscc(_buildSsccCommissioningRequest());
      } else {
        response = await cubit.commissionBulk(_buildCommissioningRequest());
      }

      if (response == null) {
        context.showError(
          cubit.state.error ?? 'Failed to create commissioning operation',
        );
        return;
      }

      if (response.status == CommissioningStatus.success) {
        context.showSuccess(
          'Successfully commissioned ${response.commissionedCount} items',
        );
        if (mounted) popOrGo(context, Constants.opCommissioningRoute);
      } else if (response.status == CommissioningStatus.partialSuccess) {
        await _handlePartialSuccess(response);
      } else {
        context.showError(commissioningSubmitErrorMessage(response));
      }
    } on ApiException catch (e) {
      if (e.statusCode == 422) {
        _applyApiRejectionResults(e);
        context.showError(e.getUserFriendlyMessage());
      } else {
        context.showError(e.getUserFriendlyMessage());
      }
    } catch (e) {
      context.showError('Error creating commissioning operation: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Form _buildStep1(
    CommissioningOperationState batchState, {
    bool embeddedInPanel = false,
  }) =>
      Form(
        key: _step1FormKey,
        child: CommissioningStep1ProductDetails(
          commissioningLocationGLN: _commissioningLocationGLN,
          locationError: _locationError,
          onLocationChanged: (gln) => setState(() {
            _commissioningLocationGLN = gln;
            _locationError = null;
          }),
          pickerCatalog:
              _availableLocations.isEmpty ? null : _availableLocations,
          referenceController: _referenceController,
          countryOfOriginController: _countryOfOriginController,
          productionOrderController: _productionOrderController,
          productionLineController: _productionLineController,
          regulatoryMarketController: _regulatoryMarketController,
          regulatoryStatusController: _regulatoryStatusController,
          operatorIdController: _operatorIdController,
          notesController: _notesController,
          readPointGlnController: _readPointGlnController,
          showPageHeader: !embeddedInPanel,
        ),
      );

  CommissioningStep2SerialNumbers _buildStep2(
    CommissioningOperationState batchState, {
    bool embeddedInPanel = false,
    bool fillHeight = false,
  }) =>
      CommissioningStep2SerialNumbers(
        scannedEpcs: _commissionItems.map((i) => i.epc).toList(),
        onItemAdded: _onScanItemAdded,
        onRemoveItem: _removeItem,
        onClearAll: _clearAllItems,
        onParseFallback: _epcFallbackResolve,
        embeddedInPanel: embeddedInPanel,
        fillHeight: fillHeight,
        identifiedType: _identifiedType,
        stepFormKey: _step2FormKey,
        batchLotController: _batchLotController,
        expiryDate: _expiryDate,
        productionDate: _productionDate,
        bestBeforeDate: _bestBeforeDate,
        onSelectDate: _selectDate,
        onClearDate: _clearDate,
        onBatchLotEditingComplete: _triggerBatchLookupNow,
        onBatchLotFocusLost: _triggerBatchLookupNow,
        showPharmaBatchLookup: _isPharmaSgtin,
        batchLookupStatus: batchState.batchLookupStatus,
        resolvedBatch: batchState.resolvedBatch,
        batchLookupError: batchState.batchLookupError,
        registrationPanelExpanded: batchState.registrationPanelExpanded,
        registrationExpiryDate: batchState.registrationExpiryDate,
        registrationManufactureDate: batchState.registrationManufactureDate,
        registrationQuantityController: _registrationQuantityController,
        onSelectRegistrationDate: _selectRegistrationDate,
        onClearRegistrationDate: _clearRegistrationDate,
        onRegisterBatch: _registerBatch,
        onToggleRegistrationPanel: (expanded) => context
            .read<CommissioningOperationCubit>()
            .setRegistrationPanelExpanded(expanded),
        isBatchRegistering: batchState.batchLookupStatus ==
            CommissioningBatchLookupStatus.registering,
        itemProductNames: _itemProductNames,
      );

  CommissioningStep3Review _buildStep3() => CommissioningStep3Review(
        identifiedType: _identifiedType,
        primaryParsed: _primaryParsed,
        batchLotController: _batchLotController,
        referenceController: _referenceController,
        commissioningLocationGLN: _commissioningLocationGLN,
        readPointGln: _readPointGlnController.text.trim().isNotEmpty
            ? _readPointGlnController.text.trim()
            : null,
        productionDate: _productionDate,
        expiryDate: _expiryDate,
        bestBeforeDate: _bestBeforeDate,
        items: _commissionItems,
        countryOfOrigin: _countryOfOriginController.text.trim(),
        productionOrder: _productionOrderController.text.trim(),
        productionLine: _productionLineController.text.trim(),
        regulatoryMarket: _regulatoryMarketController.text.trim(),
        regulatoryStatus: _regulatoryStatusController.text.trim(),
        operatorId: _operatorIdController.text.trim(),
      );

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CommissioningOperationCubit, CommissioningOperationState>(
      listenWhen: (previous, current) =>
          previous.resolvedBatch != current.resolvedBatch,
      listener: (context, state) {
        final batch = state.resolvedBatch;
        if (batch != null) _applyBatchDatesFromResolved(batch);
      },
      builder: (context, batchState) {
        final submitLabel = 'Commission ${_commissionItems.length} Items';
        final isBusy = _isLoading || batchState.loading;

        return AppLayoutBuilder(
          builder: (context, layout) {
            final isDesktop = layout.isDesktopUp;
            final step1 = _buildStep1(batchState, embeddedInPanel: isDesktop);
            final step2 = _buildStep2(
              batchState,
              embeddedInPanel: isDesktop,
              fillHeight: !isDesktop,
            );
            final step3 = _buildStep3();

            return isDesktop
                ? OperationDesktopLayout(
                    isLoading: isBusy,
                    appBarTitle: 'New Commissioning Operation',
                    submitLabel: submitLabel,
                    step1Title: 'Details',
                    step2Title: 'Items',
                    step1Complete: _isDetailsStepValid,
                    step2Complete:
                        _isStep2Valid && _isPharmaBatchReady(batchState),
                    detailsStep: step1,
                    itemsStep: step2,
                    reviewStep: step3,
                    onSubmit: _submit,
                  )
                : OperationMobileLayout(
                    isLoading: isBusy,
                    appBarTitle: 'Commissioning',
                    submitLabel: submitLabel,
                    currentStep: _currentStep,
                    steps: _wizardSteps,
                    pageController: _pageController,
                    onPageChanged: (page) => setState(() => _currentStep = page),
                    onPrevious: _previousStep,
                    onNext: _nextStep,
                    onSubmit: _submit,
                    stepPages: [step1, step2, step3],
                  );
          },
        );
      },
    );
  }
}