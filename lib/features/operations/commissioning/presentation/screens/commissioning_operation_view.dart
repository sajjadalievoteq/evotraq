import 'package:flutter/foundation.dart' show debugPrint, kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/utils/barcode_utils.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/data/models/gs1/gtin/gtin_model.dart';
import 'package:traqtrace_app/data/models/operations/commissioning/commissioning_models.dart';
import 'package:traqtrace_app/features/operations/commissioning/cubit/commissioning_operation_cubit.dart';
import 'package:traqtrace_app/features/gs1/gtin/cubit/gtin_cubit.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/core/layout/layout_manager.dart';
import 'package:traqtrace_app/core/widgets/loading_overlay.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/core/widgets/custom_button_widget.dart';
import 'package:traqtrace_app/core/models/scan_result.dart';
import 'package:traqtrace_app/features/operations/commissioning/utils/commissioning_field_validators.dart';
import 'package:traqtrace_app/features/operations/commissioning/presentation/widgets/stepper/commissioning_stepper_header.dart';
import 'package:traqtrace_app/features/operations/commissioning/presentation/widgets/step1/commissioning_step1_product_details.dart';
import 'package:traqtrace_app/features/operations/commissioning/presentation/models/commissioning_scanning_mode.dart';
import 'package:traqtrace_app/features/operations/commissioning/presentation/widgets/step2/commissioning_step2_serial_numbers.dart';
import 'package:traqtrace_app/features/operations/commissioning/presentation/widgets/step3/commissioning_step3_review.dart';
import 'package:traqtrace_app/features/operations/commissioning/presentation/widgets/wizard/commissioning_navigation_buttons.dart';
import 'package:traqtrace_app/features/operations/commissioning/presentation/widgets/operation/commissioning_step_panel.dart';
import 'package:traqtrace_app/features/operations/commissioning/presentation/widgets/operation/product_barcode_scanner_dialog.dart';
import 'package:traqtrace_app/features/operations/commissioning/presentation/widgets/partial_success/commissioning_partial_success_choice.dart';
import 'package:traqtrace_app/features/operations/commissioning/presentation/widgets/partial_success/commissioning_partial_success_result.dart';
import 'package:traqtrace_app/features/operations/commissioning/presentation/widgets/partial_success/partial_success_dialog.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/traq_app_bar.dart';

class CommissioningOperationView extends StatefulWidget {
  const CommissioningOperationView({super.key});

  @override
  State<CommissioningOperationView> createState() =>
      _CommissioningOperationViewState();
}

class _CommissioningOperationViewState extends State<CommissioningOperationView> {
  final _pageController = PageController();
  int _currentStep = 0;

  final _gtinController = TextEditingController();
  final _batchLotController = TextEditingController();
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
  GLN? _commissioningLocationGLN;
  String? _locationError;
  DateTime? _expiryDate;
  DateTime? _productionDate;
  DateTime? _bestBeforeDate;

  final List<String> _serialNumbers = [];
  CommissioningScanningMode _scanningMode = CommissioningScanningMode.manual;
  bool _isWiredScannerActive = false;

  bool _isLoading = false;

  bool get _isStep1Valid =>
      (_selectedGTIN != null || _gtinController.text.trim().isNotEmpty) &&
      _batchLotController.text.trim().isNotEmpty &&
      _commissioningLocationGLN != null &&
      _expiryDate != null;

  bool get _isStep2Valid => _serialNumbers.isNotEmpty;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadGTINs());
    _wiredScannerFocusNode.addListener(() {
      setState(() => _isWiredScannerActive = _wiredScannerFocusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _gtinController.dispose();
    _batchLotController.dispose();
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

  Future<void> _loadGTINs() async {
    setState(() => _isLoadingGTINs = true);
    try {
      final gtins = await context.read<GTINCubit>().fetchGtinsForPicker();
      setState(() {
        _availableGTINs = gtins;
        _isLoadingGTINs = false;
      });
    } catch (e) {
      debugPrint('Error loading GTINs: $e');
      setState(() => _isLoadingGTINs = false);
    }
  }

  Future<void> _nextStep() async {
    if (_currentStep < 2 && _validateCurrentStep()) {
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

  bool _validateCurrentStep() {
    setState(() {
      _gtinError = null;
      _locationError = null;
    });

    switch (_currentStep) {
      case 0:
        final formValid = _step1FormKey.currentState?.validate() ?? false;
        bool isValid = formValid;
        if (_selectedGTIN == null && _gtinController.text.trim().isEmpty) {
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

  void _resetForm() {
    setState(() {
      _currentStep = 0;
      _selectedGTIN = null;
      _gtinController.clear();
      _batchLotController.clear();
      _referenceController.clear();
      _commissioningLocationGLN = null;
      _expiryDate = null;
      _productionDate = null;
      _bestBeforeDate = null;
      _serialNumbers.clear();
    });
    if (!context.layout.isDesktopUp) {
      _pageController.jumpToPage(0);
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
    final normalise = (String v) => v.replaceAll(RegExp(r'\D'), '').padLeft(14, '0');
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
        final selectedCode = _selectedGTIN?.gtinCode ?? _gtinController.text.trim();
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
    setState(() => _serialNumbers.add(extracted));
    _manualSerialController.clear();
    _wiredScannerController.clear();
  }

  void _removeSerial(int index) =>
      setState(() => _serialNumbers.removeAt(index));

  void _clearAllSerials() {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All Serials?'),
        content: Text(
            'This will remove all ${_serialNumbers.length} serial numbers.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          CustomButtonWidget(
            onTap: () => Navigator.of(ctx).pop(true),
            title: 'Clear All',
            backgroundColor: Colors.red,
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true) setState(() => _serialNumbers.clear());
    });
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
          case 'expiry':
            _expiryDate = selected;
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
        case 'expiry':
          _expiryDate = null;
        case 'bestBefore':
          _bestBeforeDate = null;
      }
    });
  }

  Future<void> _scanProductBarcode() async {
    final bool useCameraScanner = !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogCtx) => CommissioningProductBarcodeScannerDialog(
        useCameraScanner: useCameraScanner,
        onBarcodeDetected: (rawBarcode) {
          Navigator.of(dialogCtx).pop();
          _applyBarcodeDetails(rawBarcode);
        },
      ),
    );
  }

  void _applyBarcodeDetails(String rawBarcode) {
    final details = extractBarcodeDetails(rawBarcode);

    if (!details.isValid) {
      context.showError('Could not decode barcode ? please enter details manually');
      return;
    }

    if (details.gtin == null) {
      context.showError('Barcode does not contain a GTIN ? please enter details manually');
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
      if (details.expiry != null) _expiryDate = details.expiry;
      if (details.productionDate != null) _productionDate = details.productionDate;
      if (details.bestBeforeDate != null) _bestBeforeDate = details.bestBeforeDate;
      if (details.countryOfOrigin != null && details.countryOfOrigin!.isNotEmpty) {
        _countryOfOriginController.text = details.countryOfOrigin!;
      }
    });

    context.showSuccess(
      'Barcode scanned ? ${details.displayRows.length} field(s) filled',
    );
  }

  void _showGtinNotFoundDialog(String gtinCode) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.qr_code, size: 40),
        title: const Text('GTIN Not Registered'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'GTIN $gtinCode is not registered in the system.',
            ),
            const SizedBox(height: 8),
            const Text(
              'You must add this GTIN before commissioning products with it.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            icon: const Icon(Icons.arrow_forward, size: 16),
            label: const Text('Go to GTINs'),
            onPressed: () {
              Navigator.of(ctx).pop();
              context.go(Constants.gs1GtinsRoute);
            },
          ),
        ],
      ),
    );
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
    if (!_validateCurrentStep()) return;
    setState(() => _isLoading = true);

    try {
      final cubit = getIt<CommissioningOperationCubit>();

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
        final errorMessage = response.messages?.isNotEmpty == true
            ? response.messages!.first
            : 'Failed to create commissioning operation';
        context.showError(errorMessage);
      }
    } catch (e) {
      context.showError('Error creating commissioning operation: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Form get _step1Widget => Form(
        key: _step1FormKey,
        autovalidateMode: AutovalidateMode.disabled,
        child: CommissioningStep1ProductDetails(
          availableGTINs: _availableGTINs,
          selectedGTIN: _selectedGTIN,
          gtinError: _gtinError,
          isLoadingGTINs: _isLoadingGTINs,
          gtinController: _gtinController,
          batchLotController: _batchLotController,
          referenceController: _referenceController,
          commissioningLocationGLN: _commissioningLocationGLN,
          locationError: _locationError,
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
          onGtinChanged: (gtin) => setState(() {
            _selectedGTIN = gtin;
            _gtinError = null;
          }),
          onLocationChanged: (gln) => setState(() {
            _commissioningLocationGLN = gln;
            _locationError = null;
          }),
          onSelectDate: _selectDate,
          onClearDate: _clearDate,
          onScanProductBarcode: _scanProductBarcode,
        ),
      );

  CommissioningStep2SerialNumbers get _step2Widget =>
      CommissioningStep2SerialNumbers(
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

  CommissioningStep3Review get _step3Widget => CommissioningStep3Review(
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
    return Scaffold(
      appBar: TraqAppBar(
        context,
        title: Text(
          'Commissioning',
          style: context.text.body.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
      ),
      drawer: const AppDrawer(),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: AppLayoutBuilder(
          builder: (context, layout) => layout.isDesktopUp
              ? _buildDesktopLayout(context)
              : _buildMobileLayout(context),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: [
        CommissioningStepperHeader(currentStep: _currentStep),
        Expanded(
          child: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (page) {
              setState(() => _currentStep = page);
              if (page == 1 && _scanningMode == CommissioningScanningMode.wired) {
                WidgetsBinding.instance.addPostFrameCallback(
                    (_) => _wiredScannerFocusNode.requestFocus());
              }
            },
            children: [_step1Widget, _step2Widget, _step3Widget],
          ),
        ),
        CommissioningNavigationButtons(
          currentStep: _currentStep,
          serialNumbersCount: _serialNumbers.length,
          onPrevious: _previousStep,
          onNext: _nextStep,
          onSubmit: _submit,
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    final step2Locked = !_isStep1Valid;
    final step3Locked = !_isStep1Valid || !_isStep2Valid;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: CommissioningStepPanel(
            stepNumber: 1,
            title: 'Product Details',
            isComplete: _isStep1Valid,
            isLocked: false,
            lockedMessage: '',
            child: _step1Widget,
          ),
        ),
        const VerticalDivider(width: 1, thickness: 1),
        Expanded(
          child: CommissioningStepPanel(
            stepNumber: 2,
            title: 'Serial Numbers',
            isComplete: _isStep2Valid,
            isLocked: step2Locked,
            lockedMessage: 'Complete Step 1 first',
            child: _step2Widget,
          ),
        ),
        const VerticalDivider(width: 1, thickness: 1),
        Expanded(
          child: CommissioningStepPanel(
            stepNumber: 3,
            title: 'Review & Submit',
            isComplete: false,
            isLocked: step3Locked,
            lockedMessage:
                _isStep1Valid ? 'Add serial numbers first' : 'Complete Step 1 first',
            footer: CommissioningNavigationButtons(
              currentStep: 2,
              serialNumbersCount: _serialNumbers.length,
              onPrevious: () {},
              onNext: () {},
              onSubmit: _submit,
            ),
            child: _step3Widget,
          ),
        ),
      ],
    );
  }
}
