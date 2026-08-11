part of 'sscc_detail_screen.dart';

extension SSCCDetailEditActions on _SSCCDetailScreenState {
  void _setFieldError(String fieldName, String? error) {
    if (_validationCubit.getFieldError(fieldName) == error) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _validationCubit.setFieldError(fieldName, error);
    });
  }

  Future<void> _savePharmaExtensionIfNeeded(
    int? ssccId,
    String ssccCode,
  ) async {
    final pharmaState = _pharmaExtensionKey.currentState;
    debugPrint(
      'SSCC Pharma extension check - state: ${pharmaState != null}, hasData: ${pharmaState?.hasData}',
    );

    if (pharmaState == null) {
      debugPrint(
        'Pharma extension widget not in tree (probably not in pharmaceutical mode)',
      );
      return;
    }

    if (!pharmaState.hasData) {
      debugPrint('No pharmaceutical extension data to save');
      return;
    }

    try {
      final extension = pharmaState.buildExtension(
        ssccId: ssccId,
        ssccCode: ssccCode,
      );
      debugPrint('Built pharma extension: ${extension != null}');
      if (extension != null) {
        final pharmaService = getIt<SSCCPharmaceuticalExtensionService>();
        await pharmaService.createBySsccCode(ssccCode, extension);
        debugPrint('SSCC Pharmaceutical extension saved for SSCC: $ssccCode');
      }
    } catch (e) {
      debugPrint('Error saving SSCC pharmaceutical extension: $e');
    }
  }

  void _populateFormFields(SSCC sscc) {
    _sscc = sscc;
    hydrateSsccDetailFields(sscc);

    _issuingGln = sscc.issuingGLN;
    _issuingGlnError = null;

    _containedExpiry = sscc.containedExpiry;
    _shipFromGln = _glnFromStoredCode(sscc.shipFromGln);
    _shipToGln = _glnFromStoredCode(sscc.shipToGln);
    _billToGln = _glnFromStoredCode(sscc.billToGln);
    _shipForGln = _glnFromStoredCode(sscc.shipForGln);
    _custodianGln = _glnFromStoredCode(sscc.currentCustodianGln);

    setState(() {
      _unitType = sscc.unitType;
      _status = sscc.status;
      _contentHomogeneity = sscc.contentHomogeneity;
      _serverTransitions = sscc.availableTransitions ?? const [];
      _packingDate = sscc.packingDate;
      _formFieldsHydrated = true;
    });

    if (sscc.id != null && _serverTransitions.isEmpty) {
      _loadTransitions(sscc.id!);
    }
    _loadAggregationLinks(sscc.ssccCode);
    _loadedSsccKey = _requestedSsccKey;
    _applyGlnCatalogToFields();
    _ensureGlnPickerCatalog();
    _enforceEditRouteIfNeeded(sscc);
  }

  void _enforceEditRouteIfNeeded(SSCC sscc) {
    if (_editRedirectHandled || widget.isCreating || !widget.isEditing) {
      return;
    }
    if (edit_rules.canEditSsccRecord(sscc.status)) {
      return;
    }
    _editRedirectHandled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.showInfo(edit_rules.readOnlyLifecycleMessage(sscc.status));
      if (widget.embedded) {
        return;
      }
      final code = sscc.ssccCode;
      if (code.isNotEmpty) {
        context.go(SsccRouteConstants.pathForSsccCode(code));
      }
    });
  }

  void _applyGlnCatalogToFields() {
    if (_glnPickerCatalog.isEmpty) return;
    setState(() {
      _issuingGln = resolveGlnForPicker(
        code: _issuingGln?.glnCode ?? _sscc?.issuingGLN?.glnCode,
        fallback: _issuingGln ?? _sscc?.issuingGLN,
        catalog: _glnPickerCatalog,
      );
      _shipFromGln = resolveGlnForPicker(
        code: _shipFromGln?.glnCode ?? _sscc?.shipFromGln,
        fallback: _shipFromGln,
        catalog: _glnPickerCatalog,
      );
      _shipToGln = resolveGlnForPicker(
        code: _shipToGln?.glnCode ?? _sscc?.shipToGln,
        fallback: _shipToGln,
        catalog: _glnPickerCatalog,
      );
      _billToGln = resolveGlnForPicker(
        code: _billToGln?.glnCode ?? _sscc?.billToGln,
        fallback: _billToGln,
        catalog: _glnPickerCatalog,
      );
      _shipForGln = resolveGlnForPicker(
        code: _shipForGln?.glnCode ?? _sscc?.shipForGln,
        fallback: _shipForGln,
        catalog: _glnPickerCatalog,
      );
      _custodianGln = resolveGlnForPicker(
        code: _custodianGln?.glnCode ?? _sscc?.currentCustodianGln,
        fallback: _custodianGln,
        catalog: _glnPickerCatalog,
      );
    });
  }

  Future<void> _loadAggregationLinks(String ssccCode) {
    if (_aggregationLinksRequestedCode == ssccCode &&
        _aggregationLinksFuture != null) {
      return _aggregationLinksFuture!;
    }
    _aggregationLinksRequestedCode = ssccCode;
    final future = () async {
      final links = await _cubit.fetchAggregationLinks(ssccCode);
      if (!mounted || _aggregationLinksRequestedCode != ssccCode) return;
      setState(() => _aggregationLinks = links);
    }();
    _aggregationLinksFuture = future;
    return future;
  }

  Future<bool> _addAggregationChild({
    required String childEpc,
    required String childKind,
    required String aggregationEventId,
  }) async {
    final ssccId = _sscc?.id;
    if (ssccId == null) return false;

    final link = await _cubit.addAggregationChild(
      ssccId: ssccId,
      childEpc: childEpc,
      childKind: childKind,
      aggregationEventId: aggregationEventId,
    );
    if (link != null && mounted) {
      await _loadAggregationLinks(_sscc!.ssccCode);
      context.showSuccess('Child aggregated successfully');
      return true;
    }
    return false;
  }

  Future<bool> _disaggregateChild({
    required int linkId,
    required String disaggregationEventId,
  }) async {
    final ok = await _cubit.disaggregateChild(
      linkId: linkId,
      disaggregationEventId: disaggregationEventId,
    );
    if (ok && mounted) {
      await _loadAggregationLinks(_sscc!.ssccCode);
      context.showSuccess('Child disaggregated');
    }
    return ok;
  }

  Future<void> _loadTransitions(String id) async {
    final transitions = await _cubit.fetchAvailableTransitions(id);
    if (mounted && transitions.isNotEmpty) {
      setState(() => _serverTransitions = transitions);
    }
  }

  Future<void> _saveSSCC() async {
    if (widget.awaitingListSelection) return;

    if (!_forceMountAllSections) {
      setState(() => _forceMountAllSections = true);
      await Future<void>.delayed(Duration.zero);
      if (!mounted) return;
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted) return;
    }

    setState(() {
      _issuingGlnError = validateIssuingGlnRequired(_issuingGln?.glnCode);
    });

    final validationErrors = SsccCreateFormValidation.collectErrors(
      isCreating: widget.isCreating,
      issuingGlnCode: _issuingGln?.glnCode,
      extensionDigit: extensionDigitText(),
      ssccCodeRaw: ssccCodeText(),
      ssccMissingMessage: _ssccCodeMissingMessage(),
      contentHomogeneity: _contentHomogeneity,
      containedGtin: containedGtinText(),
      containedQuantity: containedQuantityText(),
      gsin: gsinText(),
      purchaseOrder: poText(),
    );

    _formKey.currentState?.validate();

    validationErrors.addAll(
      SsccCreateFormValidation.collectFormFieldErrors(_formKey),
    );

    if (validationErrors.isNotEmpty) {
      _scrollToFormTop();
      context.showValidationErrors(
        validationErrors,
        title: 'Cannot save SSCC — fix these fields',
      );
      return;
    }

    final now = DateTime.now();

    setState(() {
      _hasSubmittedForm = true;
    });

    String gs1CompanyPrefix = '';
    String serialReference = '';
    String checkDigit = '';
    if (ssccCodeText().isNotEmpty) {
      var ssccCode =
          SsccInputParser.parseToSsccCode(ssccCodeText()) ??
          ssccCodeText().trim();

      if (ssccCode.length != 18) {
        final fixedSSCC = GS1Utils.validateAndFixSSCC(ssccCode);
        if (fixedSSCC != null) {
          ssccCode = fixedSSCC;
          setSsccFieldSeedOrController('ssccCode', ssccCode);
        } else {
          context.showValidationErrors([
            'SSCC Code: must be 18 digits or a valid GS1 (00) barcode (current: ${ssccCode.length} digits)',
          ], title: 'Cannot save SSCC — fix these fields');
          return;
        }
      }

      _syncExtensionDigitFromSscc(ssccCode);

      gs1CompanyPrefix = ssccCode.substring(1, 8);
      serialReference = ssccCode.substring(8, 17);
      checkDigit = ssccCode.substring(17);
    } else {
      context.showValidationErrors([
        'SSCC Code: ${_ssccCodeMissingMessage()}',
      ], title: 'Cannot save SSCC — fix these fields');
      return;
    }

    final containedQty = int.tryParse(containedQuantityText().trim());
    final identityLocked =
        !widget.isCreating &&
        _sscc != null &&
        edit_rules.isSsccIdentityLocked(_sscc!.status);
    final persistedStatus = _sscc?.status ?? _status;
    final saveStatus =
        edit_rules.canManuallyEditSsccStatus(
          persistedStatus,
          isCreating: widget.isCreating,
        )
        ? _status
        : persistedStatus;

    final sscc = SSCC(
      id: widget.isCreating ? null : _sscc?.id,
      ssccCode: identityLocked ? _sscc!.ssccCode : ssccCodeText(),
      unitType: _unitType,
      status: saveStatus,
      contentHomogeneity: _contentHomogeneity,
      containedGtin: containedGtinText().trim().isEmpty
          ? null
          : containedGtinText().trim(),
      containedQuantity: containedQty,
      containedBatch: containedBatchText().trim().isEmpty
          ? null
          : containedBatchText().trim(),
      containedExpiry: _containedExpiry,
      packingDate: _packingDate,
      shipFromGln: _glnCodeOrNull(_shipFromGln),
      shipToGln: _glnCodeOrNull(_shipToGln),
      billToGln: _glnCodeOrNull(_billToGln),
      shipForGln: _glnCodeOrNull(_shipForGln),
      currentCustodianGln: _glnCodeOrNull(_custodianGln),
      gsin: _trimOrNull(gsinText()),
      ginc: _trimOrNull(gincText()),
      purchaseOrderNumber: _trimOrNull(poText()),
      carrierRoutingCode: _trimOrNull(carrierRoutingText()),
      parentSsccCode: _sscc?.parentSsccCode,
      extensionDigit: identityLocked
          ? (_sscc!.extensionDigit ?? '0')
          : (extensionDigitText().isEmpty ? '0' : extensionDigitText()),
      gs1CompanyPrefix: identityLocked
          ? (_sscc!.gs1CompanyPrefix ?? gs1CompanyPrefix)
          : gs1CompanyPrefix,
      serialReference: identityLocked
          ? (_sscc!.serialReference ?? serialReference)
          : serialReference,
      checkDigit: identityLocked
          ? (_sscc!.checkDigit ?? checkDigit)
          : checkDigit,
      issuingGLN: _issuingGln,
      createdAt: _sscc?.createdAt ?? now,
      updatedAt: now,
    );

    if (widget.isCreating) {
      _cubit.createSSCC(sscc);
    } else if (widget.isEditing &&
        _sscc?.id != null &&
        edit_rules.canEditSsccRecord(_sscc!.status)) {
      _cubit.updateSSCC(_sscc!.id!, sscc);
    }
  }

  void _scrollToFormTop() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _generateSSCCCode() {
    context.dismissSnackBar();

    final issuingError = validateIssuingGlnRequired(_issuingGln?.glnCode);
    if (issuingError != null) {
      setState(() => _issuingGlnError = issuingError);
      context.showError(issuingError);
      return;
    }

    if (extensionDigitText().isEmpty) {
      context.showError('Extension Digit is required to generate SSCC');
      return;
    }

    final extensionError = validateExtensionDigit(extensionDigitText());
    if (extensionError != null) {
      context.showError(extensionError);
      return;
    }

    context.showInfo(
      'Generating SSCC code...',
      duration: const Duration(seconds: 2),
    );

    _cubit.generateSSCCFromGLN(_issuingGln!.glnCode, extensionDigitText());
  }

  Future<void> _scanSSCCCode() async {
    final result = await GS1BarcodeScanDialog.show(
      context,
      title: 'Scan SSCC Barcode',
      allowedFormats: const ['SSCC', 'CODE_128'],
    );
    if (result == null || !mounted) return;

    if (!result.isValid) {
      context.showError(result.error ?? 'Invalid barcode scan');
      return;
    }

    final parsed = SsccInputParser.parseToSsccCode(result.data);
    if (parsed == null) {
      context.showError(
        'Could not read an SSCC from the scan. Use a GS1 (00) barcode or 18-digit SSCC.',
      );
      return;
    }

    setState(() {
      setSsccFieldSeedOrController('ssccCode', parsed);
      syncExtensionDigitFromSsccCode(parsed);
    });
    context.showSuccess('SSCC captured: $parsed');
  }

  String _ssccCodeMissingMessage() {
    switch (_ssccInputMode) {
      case SsccInputMode.generate:
        return 'Generate an SSCC code using the button, or switch to Manual or Scan';
      case SsccInputMode.scan:
        return 'Scan an SSCC barcode using the scan button';
      case SsccInputMode.manual:
        return 'Enter an 18-digit SSCC code or paste a GS1 (00) barcode';
    }
  }

  void _syncExtensionDigitFromSscc(String ssccCode) {
    syncExtensionDigitFromSsccCode(ssccCode);
  }

  String? _trimOrNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  GLN? _glnFromStoredCode(String? code) {
    if (code == null || code.trim().isEmpty) return null;
    return GLN.fromCode(code.trim());
  }

  int? _parseSsccId(String? id) {
    if (id == null || id.trim().isEmpty) return null;
    return int.tryParse(id.trim());
  }

  String? _glnCodeOrNull(GLN? gln) {
    final code = gln?.glnCode.trim();
    if (code == null || code.isEmpty) return null;
    return code;
  }

  Future<void> _selectDate(
    BuildContext context,
    Function(DateTime) onDateSelected, {
    DateTime? initialDate,
  }) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      onDateSelected(picked);
    }
  }
}
