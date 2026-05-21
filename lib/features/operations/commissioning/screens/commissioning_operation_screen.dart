import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/data/models/gs1/gtin/gtin_model.dart';
import 'package:traqtrace_app/data/models/operations/commissioning/commissioning_models.dart';
import 'package:traqtrace_app/features/operations/commissioning/cubit/commissioning_operation_cubit.dart';
import 'package:traqtrace_app/features/gs1/gtin/cubit/gtin_cubit.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/shared/layout/layout_manager.dart';
import 'package:traqtrace_app/shared/widgets/loading_overlay.dart';
import 'package:traqtrace_app/shared/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/shared/widgets/custom_button_widget.dart';
import 'package:traqtrace_app/shared/models/scan_result.dart';
import 'package:traqtrace_app/features/operations/commissioning/utils/commissioning_field_validators.dart';
import 'package:traqtrace_app/features/operations/commissioning/widgets/commissioning_stepper_header.dart';
import 'package:traqtrace_app/features/operations/commissioning/widgets/commissioning_step1_product_details.dart';
import 'package:traqtrace_app/features/operations/commissioning/widgets/commissioning_step2_serial_numbers.dart';
import 'package:traqtrace_app/features/operations/commissioning/widgets/commissioning_step3_review.dart';
import 'package:traqtrace_app/features/operations/commissioning/widgets/commissioning_navigation_buttons.dart';
import 'package:traqtrace_app/features/operations/commissioning/widgets/partial_success_dialog.dart';

import '../../../../core/theme/traq_theme.dart';
import '../../../../core/widgets/traq_app_bar.dart';

/// Multi-step commissioning wizard.
///
/// - **Desktop (≥ 1200 px)**: all three steps displayed side-by-side;
///   steps 2 and 3 are locked behind visual overlays until their prerequisites
///   are met.
/// - **Tablet / mobile**: one step at a time, navigated by [CommissioningNavigationButtons].
class CommissioningOperationScreen extends StatefulWidget {
  const CommissioningOperationScreen({super.key});

  @override
  State<CommissioningOperationScreen> createState() =>
      _CommissioningOperationScreenState();
}

class _CommissioningOperationScreenState
    extends State<CommissioningOperationScreen> {
  final _pageController = PageController();
  int _currentStep = 0;

  // Step 1 controllers
  final _gtinController = TextEditingController();
  final _batchLotController = TextEditingController();
  final _referenceController = TextEditingController();

  // Step 1 optional / ILMD controllers
  final _countryOfOriginController = TextEditingController();
  final _productionOrderController = TextEditingController();
  final _productionLineController = TextEditingController();
  final _regulatoryMarketController = TextEditingController();
  final _regulatoryStatusController = TextEditingController();
  final _operatorIdController = TextEditingController();
  final _notesController = TextEditingController();

  // Form key for step 1 — enables inline validation on Gs1ValidatedField widgets.
  final _step1FormKey = GlobalKey<FormState>();

  // Step 2 controllers
  final _manualSerialController = TextEditingController();
  final _wiredScannerController = TextEditingController();
  final _wiredScannerFocusNode = FocusNode();

  // Step 1 state
  List<GTIN> _availableGTINs = [];
  GTIN? _selectedGTIN;
  bool _isLoadingGTINs = false;
  String? _gtinError;
  GLN? _commissioningLocationGLN;
  String? _locationError;
  DateTime? _expiryDate;
  DateTime? _productionDate;
  DateTime? _bestBeforeDate;

  // Step 2 state
  final List<String> _serialNumbers = [];
  ScanningMode _scanningMode =
      kIsWeb ? ScanningMode.wired : ScanningMode.camera;
  bool _isWiredScannerActive = false;

  // Submission state
  bool _isLoading = false;

  // ---------------------------------------------------------------------------
  // Step completion getters (used by desktop layout to unlock panels)
  // ---------------------------------------------------------------------------

  bool get _isStep1Valid =>
      (_selectedGTIN != null || _gtinController.text.trim().isNotEmpty) &&
      _batchLotController.text.trim().isNotEmpty &&
      _commissioningLocationGLN != null;

  bool get _isStep2Valid => _serialNumbers.isNotEmpty;

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

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

  // ---------------------------------------------------------------------------
  // Data loading
  // ---------------------------------------------------------------------------

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

  // ---------------------------------------------------------------------------
  // Navigation (mobile only — desktop has no prev/next)
  // ---------------------------------------------------------------------------

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
        // Trigger inline validation on all Gs1ValidatedField / form fields.
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
    // Only animate the PageView when in mobile/tablet mode.
    if (!context.layout.isDesktopUp) {
      _pageController.jumpToPage(0);
    }
  }

  // ---------------------------------------------------------------------------
  // Serial number management
  // ---------------------------------------------------------------------------

  void _onScanResult(ScanResult result) {
    if (result.isValid) _addSerial(result.data);
  }

  void _addSerial(String serial) {
    final trimmed = serial.trim();
    if (trimmed.isEmpty) {
      context.showError('Please enter a serial number');
      return;
    }
    if (_serialNumbers.contains(trimmed)) {
      context.showError('Serial number already added: $trimmed');
      return;
    }
    setState(() => _serialNumbers.add(trimmed));
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

  // ---------------------------------------------------------------------------
  // Date selection
  // ---------------------------------------------------------------------------

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

  // ---------------------------------------------------------------------------
  // Submission
  // ---------------------------------------------------------------------------

  Future<void> _submit() async {
    if (!_validateCurrentStep()) return;
    setState(() => _isLoading = true);

    try {
      final cubit = getIt<CommissioningOperationCubit>();
      final gtinCode = _selectedGTIN?.gtinCode ?? _gtinController.text.trim();

      debugPrint(
          'Commissioning: submitting ${_serialNumbers.length} serials for GTIN $gtinCode');

      final request = CommissioningRequest(
        gtinCode: gtinCode,
        serialNumbers: _serialNumbers,
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
          await showPartialSuccessDialog(context, response);
          if (mounted) context.go('/operations/commissioning');
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

  // ---------------------------------------------------------------------------
  // Step widget (shared between both layouts)
  // ---------------------------------------------------------------------------

  Form get _step1Widget =>
      Form(
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
        onScanningModeChanged: (mode) => setState(() => _scanningMode = mode),
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

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

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

  // ---------------------------------------------------------------------------
  // Mobile / tablet layout — one step at a time with PageView
  // ---------------------------------------------------------------------------

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: [
        CommissioningStepperHeader(currentStep: _currentStep),
        Expanded(
          child: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (page) => setState(() => _currentStep = page),
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

  // ---------------------------------------------------------------------------
  // Desktop layout — three panels side by side
  // ---------------------------------------------------------------------------

  Widget _buildDesktopLayout(BuildContext context) {
    final step2Locked = !_isStep1Valid;
    final step3Locked = !_isStep1Valid || !_isStep2Valid;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Step 1: Product Details ──────────────────────────────────────────
        Expanded(
          child: _CommissioningStepPanel(
            stepNumber: 1,
            title: 'Product Details',
            isComplete: _isStep1Valid,
            isLocked: false,
            lockedMessage: '',
            child: _step1Widget,
          ),
        ),
        const VerticalDivider(width: 1, thickness: 1),

        // ── Step 2: Serial Numbers ───────────────────────────────────────────
        Expanded(
          child: _CommissioningStepPanel(
            stepNumber: 2,
            title: 'Serial Numbers',
            isComplete: _isStep2Valid,
            isLocked: step2Locked,
            lockedMessage: 'Complete Step 1 first',
            child: _step2Widget,
          ),
        ),
        const VerticalDivider(width: 1, thickness: 1),

        // ── Step 3: Review & Submit ──────────────────────────────────────────
        Expanded(
          child: _CommissioningStepPanel(
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

// =============================================================================
// Desktop step panel
// =============================================================================

/// A column panel used in the desktop layout for each wizard step.
///
/// When [isLocked] is true, the content is covered by a semi-transparent
/// overlay with a lock icon so the user cannot interact with it.
class _CommissioningStepPanel extends StatelessWidget {
  const _CommissioningStepPanel({
    required this.stepNumber,
    required this.title,
    required this.isComplete,
    required this.isLocked,
    required this.lockedMessage,
    required this.child,
    this.footer,
  });

  final int stepNumber;
  final String title;
  final bool isComplete;
  final bool isLocked;
  final String lockedMessage;
  final Widget child;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final headerColor = isLocked
        ? cs.surfaceContainerHighest
        : isComplete
            ? Colors.green.shade50
            : cs.primaryContainer.withOpacity(0.3);

    final badgeColor = isLocked
        ? cs.onSurface.withOpacity(0.3)
        : isComplete
            ? Colors.green
            : cs.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Panel header ─────────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: headerColor,
            border: Border(
              bottom: BorderSide(
                color: cs.outlineVariant,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                height: 38,
                width: 38,

            decoration: BoxDecoration(
              shape: BoxShape.circle,
                  color: badgeColor,
            ),

                child: isComplete
                    ? Center(child: const Icon(Icons.check, size: 16, color: Colors.white))
                    : Center(
                      child: Text(
                          '$stepNumber',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isLocked
                        ? cs.onSurface.withOpacity(0.4)
                        : cs.onSurface,
                  ),
                ),
              ),
              if (isLocked)
                Icon(
                  Icons.lock_outline,
                  size: 18,
                  color: cs.onSurface.withOpacity(0.35),
                ),
            ],
          ),
        ),

        // ── Panel content (with optional lock overlay) ───────────────────────
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              child,
              if (isLocked)
                Positioned.fill(
                  child: AbsorbPointer(
                    child: Container(
                      color: cs.surface.withOpacity(0.75),

                    ),
                  ),
                ),
            ],
          ),
        ),

        if (footer != null) footer!,
      ],
    );
  }
}
