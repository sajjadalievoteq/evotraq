import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/utils/barcode_utils.dart';
import 'package:traqtrace_app/data/models/gs1/gtin/gtin_model.dart';
import 'package:traqtrace_app/data/models/gs1/gtin/gtin_batch.dart';
import 'package:traqtrace_app/data/models/operations/commissioning/commissioning_models.dart';
import 'package:traqtrace_app/features/gs1/gtin/cubit/gtin_cubit.dart';
import 'package:traqtrace_app/features/gs1/gln/services/gln_picker_catalog.dart';
import 'package:traqtrace_app/features/operations/commissioning/cubit/commissioning_batch_lookup_status.dart';
import 'package:traqtrace_app/features/operations/commissioning/cubit/commissioning_operation_cubit.dart';
import 'package:traqtrace_app/features/operations/commissioning/cubit/commissioning_operation_state.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/core/layout/layout_manager.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/core/models/scan_result.dart';
import 'package:traqtrace_app/features/operations/commissioning/utils/commissioning_field_validators.dart';
import 'package:traqtrace_app/core/widgets/operation_wizard/operation_step_config.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation/widgets/commissioning_clear_serials_dialog.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation/widgets/commissioning_gtin_not_found_dialog.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/operation/operation_desktop_layout.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/operation/operation_mobile_layout.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation/widgets/commissioning_step1_product_details.dart';
import 'package:traqtrace_app/features/operations/commissioning/utils/commissioning_scanning_mode.dart';
import 'package:traqtrace_app/features/operations/commissioning/utils/commissioning_submit_error_message.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation/widgets/commissioning_step2_serial_numbers.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation/widgets/commissioning_step3_review.dart';
import 'package:traqtrace_app/features/barcode/widgets/gs1_barcode_scan_dialog.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation/widgets/commissioning_partial_success_choice.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation/widgets/commissioning_partial_success_result.dart';
import 'widgets/commissioning_partial_success_dialog.dart';

class CommissioningOperationView extends StatefulWidget {
  const CommissioningOperationView({super.key});

  @override
  State<CommissioningOperationView> createState() =>
      _CommissioningOperationViewState();
}

class _CommissioningOperationViewState extends State<CommissioningOperationView> {
  static const _wizardSteps = [
    OperationStepConfig.product,
    OperationStepConfig.serials,
    OperationStepConfig.review,
  ];

  final _pageController = PageController();
  int _currentStep = 0;

  final _gtinController = TextEditingController();
  final _batchLotController = TextEditingController();
  final _registrationQuantityController = TextEditingController();
  final _referenceController = TextEditingController();

  final _countryOfOriginController = TextEditingController();
  final _productionOrderController = TextEditingController();
  final _productionLineController = TextEditingController();
  final _regulatoryMarketController = TextEditingController();
  final _regulatoryStatusController = TextEditingController();
  final _operatorIdController = TextEditingController();
  final _notesController = TextEditingController();

  final _step1FormKey = GlobalKey<FormState>();

  final _manualSerialController = TextEditingController();
  final _wiredScannerController = TextEditingController();
  final _wiredScannerFocusNode = FocusNode();

  List<GTIN> _availableGTINs = [];
  GTIN? _selectedGTIN;
  bool _isLoadingGTINs = false;
  String? _gtinError;
  List<GLN> _availableLocations = [];
  GLN? _commissioningLocationGLN;
  String? _locationError;
  DateTime? _expiryDate;
  DateTime? _productionDate;
  DateTime? _bestBeforeDate;
  bool _expiryManuallySet = false;
  bool _productionDateManuallySet = false;
  bool _bestBeforeDateManuallySet = false;

  final List<String> _serialNumbers = [];
  CommissioningScanningMode _scanningMode = CommissioningScanningMode.manual;
  bool _isWiredScannerActive = false;

  bool _isLoading = false;

  bool get _isStep1Valid =>
      _selectedGTIN != null &&
      _batchLotController.text.trim().isNotEmpty &&
      _commissioningLocationGLN != null &&
      _expiryDate != null;

  bool get _isStep2Valid => _serialNumbers.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _batchLotController.addListener(_onBatchLotTextChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadGTINs();
      _loadLocations();
    });
    _wiredScannerFocusNode.addListener(() {
      setState(() => _isWiredScannerActive = _wiredScannerFocusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _gtinController.dispose();
    _batchLotController.dispose();
    _registrationQuantityController.dispose();
    _referenceController.dispose();
    _countryOfOriginController.dispose();
    _productionOrderController.dispose();
    _productionLineController.dispose();
    _regulatoryMarketController.dispose();
    _regulatoryStatusController.dispose();
    _operatorIdController.dispose();
    _notesController.dispose();
    _manualSerialController.dispose();
    _wiredScannerController.dispose();
    _wiredScannerFocusNode.dispose();
    super.dispose();
  }

  bool _isPharmaProduct(GTIN? gtin) => gtin?.isPharmaceuticalProduct == true;

  void _onBatchLotTextChanged() {
    if (!mounted) return;
    context.read<CommissioningOperationCubit>().onBatchLotInputChanged(
          gtin: _selectedGTIN,
          batchLot: _batchLotController.text,
        );
    setState(() {});
  }

  void _onGtinChanged(GTIN? gtin) {
    setState(() {
      _selectedGTIN = gtin;
      _gtinError = null;
    });
    _registrationQuantityController.clear();
    final cubit = context.read<CommissioningOperationCubit>();
    cubit.clearBatchState();
    unawaited(cubit.onPharmaGtinSelected(gtin));
    if (_isPharmaProduct(gtin) && _batchLotController.text.trim().isNotEmpty) {
      cubit.triggerBatchLookupNow(
        gtin: gtin,
        batchLot: _batchLotController.text,
      );
    }
  }

  void _triggerBatchLookupNow() {
    context.read<CommissioningOperationCubit>().triggerBatchLookupNow(
          gtin: _selectedGTIN,
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
      if (expiry != null && !_expiryManuallySet) {
        _expiryDate = expiry;
      }
      if (manufacture != null && !_productionDateManuallySet) {
        _productionDate = manufacture;
      }
    });
  }

  Future<void> _registerBatch() async {
    final cubit = context.read<CommissioningOperationCubit>();
    final gtin = _selectedGTIN;
    final dbId = cubit.state.gtinDbId;
    if (gtin == null || dbId == null) return;

    final qtyText = _registrationQuantityController.text.trim();
    cubit.setRegistrationQuantityManufactured(
      qtyText.isEmpty ? null : int.tryParse(qtyText),
    );

    final ok = await cubit.registerBatch(
      gtinDbId: dbId,
      gtinCode: gtin.gtinCode,
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
    if (!_isPharmaProduct(_selectedGTIN)) return true;
    if (batchState.isBatchBusy) return false;
    if (batchState.requiresBatchRegistration) return false;
    if (_batchLotController.text.trim().isEmpty) return false;

    return switch (batchState.batchLookupStatus) {
      CommissioningBatchLookupStatus.found ||
      CommissioningBatchLookupStatus.registered =>
        true,
      CommissioningBatchLookupStatus.error =>
        true,
      CommissioningBatchLookupStatus.idle ||
      CommissioningBatchLookupStatus.lookingUp ||
      CommissioningBatchLookupStatus.notFound ||
      CommissioningBatchLookupStatus.registering =>
        false,
    };
  }

  Future<void> _loadGTINs() async {
    setState(() => _isLoadingGTINs = true);
    try {
      final gtins = await context.read<GTINCubit>().fetchGtinsForPicker();
      if (!mounted) return;
      setState(() {
        _availableGTINs = gtins;
        _isLoadingGTINs = false;
      });
    } catch (e) {
      debugPrint('Error loading GTINs for commissioning picker: $e');
      if (!mounted) return;
      setState(() => _isLoadingGTINs = false);
    }
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

  Future<bool> _validateCurrentStep() async {
    setState(() {
      _gtinError = null;
      _locationError = null;
    });
    switch (_currentStep) {
      case 0:
        final formValid = _step1FormKey.currentState?.validate() ?? false;
        bool isValid = formValid;
        if (_selectedGTIN == null) {
          setState(() => _gtinError = 'GTIN is required');
          isValid = false;
        }
        final batchErr = CommissioningFieldValidators
            .validateBatchLotNumberRequired(_batchLotController.text);
        if (batchErr != null) {
          context.showError(batchErr);
          isValid = false;
        }
        if (_commissioningLocationGLN == null) {
          setState(() => _locationError = 'Commissioning Location is required');
          isValid = false;
        }
        if (_expiryDate == null) {
          context.showError('Expiry Date is required for pharmaceutical commissioning');
          isValid = false;
        }
        final batchCubit = context.read<CommissioningOperationCubit>();
        final batchState = batchCubit.state;
        if (_isPharmaProduct(_selectedGTIN)) {
          if (batchState.isBatchBusy) {
            context.showWarning(
              'Wait for batch lookup or registration to finish.',
            );
            isValid = false;
          } else if (batchState.requiresBatchRegistration) {
            context.showError(
              'Register the batch in Batch Master before continuing.',
            );
            isValid = false;
          } else if (batchState.batchLookupStatus ==
              CommissioningBatchLookupStatus.idle) {
            context.showInfo('Verifying batch in Batch Master…');
            batchCubit.triggerBatchLookupNow(
              gtin: _selectedGTIN,
              batchLot: _batchLotController.text,
            );
            isValid = false;
          }
        }
        return isValid;
      case 1:
        if (_serialNumbers.isEmpty) {
          context.showError('At least one serial number is required');
          return false;
        }
        return true;
      default:
        return true;
    }
  }

  String _extractSerial(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return trimmed;
    final details = extractBarcodeDetails(trimmed);
    if (details.serial != null && details.serial!.isNotEmpty) {
      return details.serial!;
    }
    return trimmed;
  }

  void _onScanResult(ScanResult result) {
    if (result.isValid) _addSerial(result.data);
  }

  bool _gtinMatches(String scannedGtin) {
    final selected = _selectedGTIN?.gtinCode ?? _gtinController.text.trim();
    if (selected.isEmpty) return true;
    String normalise(String v) =>
        v.replaceAll(RegExp(r'\D'), '').padLeft(14, '0');
    return normalise(scannedGtin) == normalise(selected);
  }

  void _addSerial(String serial) {
    final trimmed = serial.trim();
    if (trimmed.isEmpty) {
      context.showError('Please enter a serial number');
      return;
    }

    final details = extractBarcodeDetails(trimmed);
    if (details.gtin != null && details.gtin!.isNotEmpty) {
      if (!_gtinMatches(details.gtin!)) {
        final selectedCode =
            _selectedGTIN?.gtinCode ?? _gtinController.text.trim();
        context.showError(
          'GTIN mismatch: barcode contains ${details.gtin} '
          'but selected product is $selectedCode',
        );
        return;
      }
    }

    final extracted = _extractSerial(trimmed);
    if (extracted.isEmpty) {
      context.showError('Please enter a serial number');
      return;
    }

    if (details.type == Gs1BarcodeType.unknown && details.serial == null) {
      if (RegExp(r'^[A-Z]{3}\d{8,}$').hasMatch(extracted)) {
        context.showError(
          'This scan looks like an internal operation reference ($extracted), '
          'not a product serial. Scan the GS1 pack label with GTIN (01) and serial (21), '
          'or type only the serial number.',
        );
        return;
      }
      if (_selectedGTIN?.isPharmaceuticalProduct == true) {
        context.showWarning(
          'Not a GS1 product barcode. Pharmaceutical serials must be unpredictable '
          '(FMD/DSCSA). Scan the pack label or enter a random serial — not a date-based code.',
        );
      }
    }

    final serialError =
        CommissioningFieldValidators.validateSerialNumberRequired(extracted);
    if (serialError != null) {
      context.showError(serialError);
      return;
    }
    if (_serialNumbers.contains(extracted)) {
      context.showError('Serial number already added: $extracted');
      return;
    }
    setState(() {
      _serialNumbers.add(extracted);
      if (details.batchLot != null && details.batchLot!.isNotEmpty) {
        final existingLot = _batchLotController.text.trim();
        final scannedLot = details.batchLot!.trim();
        if (existingLot.isEmpty) {
          _batchLotController.text = scannedLot;
        } else if (existingLot != scannedLot) {
          context.showWarning(
            'Serial barcode lot ($scannedLot) differs from entered lot '
            '($existingLot). Keeping the lot from step 1.',
          );
        }
      }
      if (details.expiry != null && !_expiryManuallySet) {
        _expiryDate = details.expiry;
      }
      if (details.productionDate != null && !_productionDateManuallySet) {
        _productionDate = details.productionDate;
      }
      if (details.bestBeforeDate != null && !_bestBeforeDateManuallySet) {
        _bestBeforeDate = details.bestBeforeDate;
      }
    });
    _manualSerialController.clear();
    _wiredScannerController.clear();
  }

  void _removeSerial(int index) {
    setState(() => _serialNumbers.removeAt(index));
  }

  Future<void> _clearAllSerials() async {
    final confirmed = await CommissioningClearSerialsDialog.show(
      context,
      _serialNumbers.length,
    );
    if (confirmed == true) {
      setState(() => _serialNumbers.clear());
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
            _bestBeforeDateManuallySet = true;
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
          _bestBeforeDateManuallySet = false;
      }
    });
  }

  Future<void> _scanProductBarcode() async {
    final raw = await GS1BarcodeScanDialog.showRaw(
      context,
      title: 'Scan Product Barcode',
    );
    if (raw != null && mounted) _applyBarcodeDetails(raw);
  }

  Future<void> _applyBarcodeDetails(String rawBarcode) async {
    final details = extractBarcodeDetails(rawBarcode);

    if (!details.isValid) {
      context.showError('Could not decode barcode — please enter details manually');
      return;
    }

    if (details.gtin == null) {
      context.showError(
        'Barcode does not contain a GTIN — please enter details manually',
      );
      return;
    }

    final matched = _availableGTINs.cast<GTIN?>().firstWhere(
      (g) => g?.gtinCode == details.gtin,
      orElse: () => null,
    );
    if (matched == null) {
      _showGtinNotFoundDialog(details.gtin!);
      return;
    }

    setState(() {
      _selectedGTIN = matched;
      _gtinController.text = matched.gtinCode;
      _gtinError = null;

      if (details.batchLot != null && details.batchLot!.isNotEmpty) {
        _batchLotController.text = details.batchLot!;
      }
      if (details.expiry != null && !_expiryManuallySet) {
        _expiryDate = details.expiry;
      }
      if (details.productionDate != null && !_productionDateManuallySet) {
        _productionDate = details.productionDate;
      }
      if (details.bestBeforeDate != null && !_bestBeforeDateManuallySet) {
        _bestBeforeDate = details.bestBeforeDate;
      }
      if (details.countryOfOrigin != null &&
          details.countryOfOrigin!.isNotEmpty) {
        _countryOfOriginController.text = details.countryOfOrigin!;
      }
    });

    final cubit = context.read<CommissioningOperationCubit>();
    unawaited(cubit.onPharmaGtinSelected(matched));
    if (matched.isPharmaceuticalProduct &&
        details.batchLot != null &&
        details.batchLot!.isNotEmpty) {
      cubit.triggerBatchLookupNow(
        gtin: matched,
        batchLot: details.batchLot!,
      );
    }

    context.showSuccess(
      'Barcode scanned — ${details.displayRows.length} field(s) filled',
    );
  }

  void _showGtinNotFoundDialog(String gtinCode) {
    CommissioningGtinNotFoundDialog.show(context, gtinCode);
  }

  CommissioningRequest _buildCommissioningRequest() {
    final gtinCode = _selectedGTIN?.gtinCode ?? _gtinController.text.trim();
    return CommissioningRequest(
      gtinCode: gtinCode,
      serialNumbers: List<String>.from(_serialNumbers),
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
    );
  }

  void _syncSerialListAfterPartialSuccess(
    CommissioningResponse response,
    CommissioningPartialSuccessResult dialogResult,
  ) {
    final results = response.itemResults ?? [];
    final successfulSerials = results
        .where((r) => r.success)
        .map((r) => r.serialNumber)
        .toSet();

    setState(() {
      _serialNumbers.removeWhere(successfulSerials.contains);

      if (dialogResult.choice ==
          CommissioningPartialSuccessChoice.removeSelectedAndRetry) {
        _serialNumbers.removeWhere(
          dialogResult.serialsMarkedForRemoval.contains,
        );
      }
    });
  }

  Future<void> _handlePartialSuccess(CommissioningResponse response) async {
    final dialogResult = await showPartialSuccessDialog(context, response);
    if (!mounted || dialogResult == null) return;

    _syncSerialListAfterPartialSuccess(response, dialogResult);

    final commissioned = response.commissionedCount ?? 0;
    final failed = response.failedCount ?? 0;

    switch (dialogResult.choice) {
      case CommissioningPartialSuccessChoice.acceptPartialSuccess:
        context.showSuccess(
          'Partial success: $commissioned commissioned, $failed failed',
        );
        if (mounted) context.go('/operations/commissioning');
        break;

      case CommissioningPartialSuccessChoice.continueWithoutRemoving:
        context.showInfo(
          'Successful serials were removed from the list. '
          '${_serialNumbers.length} failed serial(s) remain ? review and submit again when ready.',
        );
        setState(() => _currentStep = 1);
        if (_pageController.hasClients) {
          _pageController.jumpToPage(1);
        }
        break;

      case CommissioningPartialSuccessChoice.removeSelectedAndRetry:
        if (_serialNumbers.isEmpty) {
          context.showWarning(
            'All failed serials were removed. Add serials or accept the partial batch.',
          );
          setState(() => _currentStep = 1);
          if (_pageController.hasClients) {
            _pageController.jumpToPage(1);
          }
          break;
        }
        context.showInfo(
          'Retrying commissioning for ${_serialNumbers.length} serial(s)...',
        );
        await _submit(isRetry: true);
        break;
    }
  }

  Future<void> _submit({bool isRetry = false}) async {
    if (!await _validateCurrentStep()) return;
    setState(() => _isLoading = true);

    try {
      final cubit = context.read<CommissioningOperationCubit>();

      debugPrint(
          'Commissioning: submitting ${_serialNumbers.length} serials for GTIN '
          '${_selectedGTIN?.gtinCode ?? _gtinController.text.trim()}'
          '${isRetry ? ' (retry)' : ''}');

      final request = _buildCommissioningRequest();
      final response = await cubit.commissionBulk(request);

      if (response == null) {
        context.showError(
            cubit.state.error ?? 'Failed to create commissioning operation');
        return;
      }

      if (response.status == CommissioningStatus.success) {
        context.showSuccess(
            'Successfully commissioned ${response.commissionedCount} items');
        if (mounted) context.go('/operations/commissioning');
      } else if (response.status == CommissioningStatus.partialSuccess) {
        if (mounted) {
          await _handlePartialSuccess(response);
        }
      } else {
        context.showError(commissioningSubmitErrorMessage(response));
      }
    } catch (e) {
      context.showError('Error creating commissioning operation: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Form _buildStep1(CommissioningOperationState batchState) => Form(
        key: _step1FormKey,
        autovalidateMode: AutovalidateMode.disabled,
        child: CommissioningStep1ProductDetails(
          gtinController: _gtinController,
          availableGTINs: _availableGTINs,
          selectedGTIN: _selectedGTIN,
          gtinError: _gtinError,
          isLoadingGTINs: _isLoadingGTINs,
          onGtinChanged: _onGtinChanged,
          commissioningLocationGLN: _commissioningLocationGLN,
          locationError: _locationError,
          onLocationChanged: (gln) => setState(() {
            _commissioningLocationGLN = gln;
            _locationError = null;
          }),
          availableLocations: _availableLocations,
          batchLotController: _batchLotController,
          referenceController: _referenceController,
          expiryDate: _expiryDate,
          productionDate: _productionDate,
          bestBeforeDate: _bestBeforeDate,
          countryOfOriginController: _countryOfOriginController,
          productionOrderController: _productionOrderController,
          productionLineController: _productionLineController,
          regulatoryMarketController: _regulatoryMarketController,
          regulatoryStatusController: _regulatoryStatusController,
          operatorIdController: _operatorIdController,
          notesController: _notesController,
          onSelectDate: _selectDate,
          onClearDate: _clearDate,
          onBatchLotEditingComplete: _triggerBatchLookupNow,
          onBatchLotFocusLost: _triggerBatchLookupNow,
          showPharmaBatchLookup: _isPharmaProduct(_selectedGTIN),
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
          onScanProductBarcode: _scanProductBarcode,
        ),
      );

  CommissioningStep2SerialNumbers _buildStep2({required bool fillHeight}) =>
      CommissioningStep2SerialNumbers(
        fillHeight: fillHeight,
        selectedGTIN: _selectedGTIN,
        gtinController: _gtinController,
        batchLotController: _batchLotController,
        serialNumbers: _serialNumbers,
        scanningMode: _scanningMode,
        wiredScannerController: _wiredScannerController,
        wiredScannerFocusNode: _wiredScannerFocusNode,
        manualSerialController: _manualSerialController,
        isWiredScannerActive: _isWiredScannerActive,
        onScanningModeChanged: (mode) {
          setState(() => _scanningMode = mode);
          if (mode == CommissioningScanningMode.wired) {
            WidgetsBinding.instance.addPostFrameCallback(
                (_) => _wiredScannerFocusNode.requestFocus());
          }
        },
        onAddSerial: _addSerial,
        onRemoveSerial: _removeSerial,
        onClearAll: _clearAllSerials,
        onScanResult: _onScanResult,
      );

  CommissioningStep3Review _buildStep3() => CommissioningStep3Review(
        selectedGTIN: _selectedGTIN,
        gtinController: _gtinController,
        batchLotController: _batchLotController,
        referenceController: _referenceController,
        commissioningLocationGLN: _commissioningLocationGLN,
        productionDate: _productionDate,
        expiryDate: _expiryDate,
        bestBeforeDate: _bestBeforeDate,
        serialNumbers: _serialNumbers,
      );

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CommissioningOperationCubit, CommissioningOperationState>(
      listenWhen: (previous, current) =>
          previous.resolvedBatch != current.resolvedBatch,
      listener: (context, state) {
        final batch = state.resolvedBatch;
        if (batch != null) {
          _applyBatchDatesFromResolved(batch);
        }
      },
      builder: (context, batchState) {
        final submitLabel = 'Commission ${_serialNumbers.length} Items';
        final isBusy = _isLoading || batchState.loading;
        final step1Complete =
            _isStep1Valid && _isPharmaBatchReady(batchState);

        return AppLayoutBuilder(
          builder: (context, layout) {
            final isDesktop = layout.isDesktopUp;
            final step1 = _buildStep1(batchState);
            final step2 = _buildStep2(fillHeight: !isDesktop);
            final step3 = _buildStep3();

            return isDesktop
                ? OperationDesktopLayout(
                    isLoading: isBusy,
                    appBarTitle: 'New Commissioning Operation',
                    submitLabel: submitLabel,
                    step1Title: 'Product Details',
                    step2Title: 'Serial Numbers',
                    step1Complete: step1Complete,
                    step2Complete: _isStep2Valid,
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
                    onPageChanged: (page) {
                      setState(() => _currentStep = page);
                      if (page == 1 &&
                          _scanningMode == CommissioningScanningMode.wired) {
                        WidgetsBinding.instance.addPostFrameCallback(
                          (_) => _wiredScannerFocusNode.requestFocus(),
                        );
                      }
                    },
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
