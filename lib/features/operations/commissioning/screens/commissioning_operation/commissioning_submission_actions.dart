part of 'commissioning_operation_view.dart';

extension CommissioningSubmissionActions on _CommissioningOperationViewState {
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

  Form _buildStep1({bool embeddedInPanel = false}) => Form(
    key: _step1FormKey,
    child: CommissioningStep1ProductDetails(
      commissioningLocationGLN: _commissioningLocationGLN,
      locationError: _locationError,
      onLocationChanged: (gln) => setState(() {
        _commissioningLocationGLN = gln;
        _locationError = null;
      }),
      pickerCatalog: _availableLocations.isEmpty ? null : _availableLocations,
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

  CommissioningStep2SerialNumbers _buildStep2({
    bool embeddedInPanel = false,
    bool fillHeight = false,
  }) => CommissioningStep2SerialNumbers(
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
    requireExpiry: _isPharmaSgtin,
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
}
