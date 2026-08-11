part of 'commissioning_operation_view.dart';

extension CommissioningIdentificationActions
    on _CommissioningOperationViewState {
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
      setState(
        () => _availableLocations = glns.where((g) => g.active).toList(),
      );
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
}
