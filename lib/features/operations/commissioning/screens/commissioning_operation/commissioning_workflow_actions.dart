part of 'commissioning_operation_view.dart';

extension CommissioningWorkflowActions on _CommissioningOperationViewState {
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
      final batchErr =
          CommissioningFieldValidators.validateBatchLotNumberRequired(
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
}
