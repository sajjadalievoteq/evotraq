part of 'commissioning_operation_view.dart';

extension CommissioningWorkflowActions on _CommissioningOperationViewState {
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
        cubit.state.registrationExpiryDate ??
            now.add(const Duration(days: 365)),
      _ => cubit.state.registrationManufactureDate ?? now,
    };
    final label = switch (dateType) {
      'registrationExpiry' => 'Expiry',
      _ => 'Manufacture',
    };

    final selected = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: dateType == 'registrationExpiry'
          ? now
          : DateTime(now.year - 2),
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
      CommissioningBatchLookupStatus.registered => true,
      CommissioningBatchLookupStatus.error => true,
      CommissioningBatchLookupStatus.idle ||
      CommissioningBatchLookupStatus.lookingUp ||
      CommissioningBatchLookupStatus.notFound ||
      CommissioningBatchLookupStatus.registering => false,
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
    final batchCubit = context.read<CommissioningOperationCubit>();
    final batchState = batchCubit.state;
    if (_isPharmaSgtin) {
      if (batchState.isBatchBusy) {
        context.showWarning('Wait for batch lookup or registration to finish.');
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
}
