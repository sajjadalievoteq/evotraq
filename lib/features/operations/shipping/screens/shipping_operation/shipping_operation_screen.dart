import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/layout/layout_manager.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/models/scan_result.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/core/widgets/operation_wizard/operation_step_config.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/data/models/operations/shipping/shipping_request_model.dart';
import 'package:traqtrace_app/data/models/operations/shipping/shipping_status.dart';
import 'package:traqtrace_app/data/services/operations/shipping/shipping_operation_service.dart';
import 'package:traqtrace_app/features/barcode/services/epc_uri_converter.dart';
import 'package:traqtrace_app/features/operations/shared/operation_epc_scan_validator.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/screens/aggregation_event_form/widgets/aggregation_pharma_issues_dialog.dart';
import 'package:traqtrace_app/features/operations/shipping/cubit/shipping_operations_cubit.dart';
import 'package:traqtrace_app/features/operations/shipping/screens/shipping_operation/utils/shipping_pharma_readiness_checker.dart';
import 'package:traqtrace_app/features/operations/shipping/screens/shipping_operation/utils/shipping_operation_step_validator.dart';
import 'package:traqtrace_app/features/operations/shipping/screens/shipping_operation/widgets/shipping_item_scan_step.dart';
import 'package:traqtrace_app/features/operations/shipping/screens/shipping_operation/widgets/shipping_operation_desktop_layout.dart';
import 'package:traqtrace_app/features/operations/shipping/screens/shipping_operation/widgets/shipping_operation_mobile_layout.dart';
import 'package:traqtrace_app/features/operations/shipping/screens/shipping_operation/widgets/shipping_reference_details_step.dart';
import 'package:traqtrace_app/features/operations/shipping/screens/shipping_operation/widgets/shipping_review_step.dart';
import 'package:traqtrace_app/features/operations/shipping/utils/shipping_scanning_mode.dart';
import 'package:traqtrace_app/features/operations/shipping/utils/shipping_snackbar.dart';

class ShippingOperationScreen extends StatefulWidget {
  const ShippingOperationScreen({
    super.key,
    this.embedded = false,
    this.onEmbeddedActionSuccess,
  });

  /// True when rendered inside [Gs1SplitViewScreen]'s create panel.
  final bool embedded;

  /// Called after successful submission in embedded mode instead of navigating.
  final VoidCallback? onEmbeddedActionSuccess;

  @override
  State<ShippingOperationScreen> createState() => _ShippingOperationScreenState();
}

class _ShippingOperationScreenState extends State<ShippingOperationScreen> {
  static const _wizardSteps = [
    OperationStepConfig(label: 'Details', icon: Icons.tag),
    OperationStepConfig(label: 'Items', icon: Icons.list_alt),
    OperationStepConfig(label: 'Review', icon: Icons.checklist),
  ];

  final PageController _pageController = PageController();
  int _currentStep = 0;

  final _referenceController = TextEditingController();
  final _purchaseOrderController = TextEditingController();
  final _despatchAdviceController = TextEditingController();
  final _billOfLadingController = TextEditingController();
  final _carrierController = TextEditingController();
  final _trackingController = TextEditingController();
  final _manualEntryController = TextEditingController();

  GLN? _sourceGln;
  GLN? _destinationGln;
  String? _sourceGlnError;
  String? _destinationGlnError;
  DateTime? _eventTime;
  final List<String> _scannedEpcs = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Rebuild on every keystroke so _validateStep0Silent() re-evaluates
    // and the desktop step-2 panel unlocks as soon as all fields are filled.
    _referenceController.addListener(_onReferenceChanged);
  }

  void _onReferenceChanged() => setState(() {});

  ShippingScanningMode _scanningMode = ShippingScanningMode.scanner;

  bool _validateStep0Silent() =>
      _referenceController.text.trim().isNotEmpty &&
      _sourceGln != null &&
      _destinationGln != null &&
      _sourceGln?.glnCode != _destinationGln?.glnCode;

  ShippingReferenceDetailsStep _referenceDetailsStep({
    bool embeddedInPanel = false,
    bool showReferenceSection = true,
    bool showLocationSection = true,
    bool showDocumentSection = true,
  }) {
    return ShippingReferenceDetailsStep(
      referenceController: _referenceController,
      sourceGln: _sourceGln,
      destinationGln: _destinationGln,
      sourceGlnError: _sourceGlnError,
      destinationGlnError: _destinationGlnError,
      onSourceGlnChanged: (gln) => setState(() {
        _sourceGln = gln;
        _sourceGlnError = null;
      }),
      onDestinationGlnChanged: (gln) => setState(() {
        _destinationGln = gln;
        _destinationGlnError = null;
      }),
      purchaseOrderController: _purchaseOrderController,
      despatchAdviceController: _despatchAdviceController,
      billOfLadingController: _billOfLadingController,
      carrierController: _carrierController,
      trackingController: _trackingController,
      eventTime: _eventTime,
      onEventTimeChanged: (dt) => setState(() => _eventTime = dt),
      showPageHeader: !embeddedInPanel,
      showReferenceSection: showReferenceSection,
      showLocationSection: showLocationSection,
      showDocumentSection: showDocumentSection,
    );
  }

  ShippingItemScanStep _itemScanStep({
    bool embeddedInPanel = false,
    bool? fillHeight,
  }) {
    return ShippingItemScanStep(
      shippingReference: _referenceController.text,
      scannedEpcs: _scannedEpcs,
      scanningMode: _scanningMode,
      manualEntryController: _manualEntryController,
      onScanningModeChanged: (mode) => setState(() => _scanningMode = mode),
      onItemScanResult: _onItemScanResult,
      onAddManualItem: _addManualItem,
      onRemoveItem: (index) => setState(() => _scannedEpcs.removeAt(index)),
      onClearAll: () => setState(() => _scannedEpcs.clear()),
      fillHeight: fillHeight ?? embeddedInPanel,
      showPageHeader: !embeddedInPanel,
    );
  }

  ShippingReviewStep _reviewStep({bool embeddedInPanel = false}) {
    return ShippingReviewStep(
      shippingReference: _referenceController.text,
      sourceGln: _sourceGln,
      destinationGln: _destinationGln,
      purchaseOrder: _purchaseOrderController.text,
      despatchAdvice: _despatchAdviceController.text,
      billOfLading: _billOfLadingController.text,
      carrier: _carrierController.text,
      trackingNumber: _trackingController.text,
      eventTime: _eventTime,
      scannedEpcs: _scannedEpcs,
      showPageHeader: !embeddedInPanel,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _referenceController.removeListener(_onReferenceChanged);
    _referenceController.dispose();
    _purchaseOrderController.dispose();
    _despatchAdviceController.dispose();
    _billOfLadingController.dispose();
    _carrierController.dispose();
    _trackingController.dispose();
    _manualEntryController.dispose();
    super.dispose();
  }

  Future<void> _nextStep() async {
    final lastStepIndex = _wizardSteps.length - 1;
    if (_currentStep < lastStepIndex && _validateCurrentStep()) {
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
      _sourceGlnError = null;
      _destinationGlnError = null;
    });

    switch (_currentStep) {
      case 0:
        final referenceError = ShippingOperationStepValidator.validateReferenceStep(
          shippingReference: _referenceController.text,
          sourceGln: _sourceGln,
          destinationGln: _destinationGln,
        );
        if (referenceError != null) {
          if (referenceError.contains('Ship From')) {
            setState(() => _sourceGlnError = referenceError);
          } else if (referenceError.contains('Ship To')) {
            setState(() => _destinationGlnError = referenceError);
          } else {
            ShippingSnackbar.showError(context, referenceError);
          }
          return false;
        }
        return true;
      case 1:
        final itemsError = ShippingOperationStepValidator.validateItemsStep(_scannedEpcs);
        if (itemsError != null) {
          ShippingSnackbar.showError(context, itemsError);
          return false;
        }
        return true;
      default:
        return true;
    }
  }

  Future<void> _submitShippingOperation() async {
    if (!_validateCurrentStep()) return;

    setState(() => _isLoading = true);

    try {
      final shippingService = getIt<ShippingOperationService>();
      final conversionResult = EPCURIConverter.convertBatchToEPCUri(_scannedEpcs);
      final epcUris = List<String>.from(conversionResult['successful'] ?? []);
      final failedConversions = List<String>.from(conversionResult['failed'] ?? []);

      if (failedConversions.isNotEmpty) {
        ShippingSnackbar.showError(
          context,
          '${failedConversions.length} EPC(s) could not be converted. Remove invalid scans and try again.\n${failedConversions.join('\n')}',
        );
        return;
      }

      if (epcUris.isEmpty) {
        ShippingSnackbar.showError(
          context,
          'No valid EPCs were captured. Scan at least one SGTIN or SSCC.',
        );
        return;
      }

      final pharmaIssues = ShippingPharmaReadinessChecker.findIssues(
        sourceGln: _sourceGln,
        destinationGln: _destinationGln,
        epcs: epcUris,
      );
      if (pharmaIssues.isNotEmpty && mounted) {
        setState(() => _isLoading = false);
        final proceed = await AggregationPharmaIssuesDialog.show(
          context,
          pharmaIssues,
          allowProceed: true,
        );
        if (proceed != true || !mounted) return;
        setState(() => _isLoading = true);
      }

      final shippingRequest = ShippingRequest(
        shippingReference: _referenceController.text.trim(),
        epcs: epcUris,
        sourceGLN: _sourceGln!.glnCode,
        destinationGLN: _destinationGln!.glnCode,
        purchaseOrderNumber: _purchaseOrderController.text.trim().isNotEmpty
            ? _purchaseOrderController.text.trim()
            : null,
        despatchAdviceNumber: _despatchAdviceController.text.trim().isNotEmpty
            ? _despatchAdviceController.text.trim()
            : null,
        billOfLadingNumber: _billOfLadingController.text.trim().isNotEmpty
            ? _billOfLadingController.text.trim()
            : null,
        carrier: _carrierController.text.trim().isNotEmpty
            ? _carrierController.text.trim()
            : null,
        trackingNumber: _trackingController.text.trim().isNotEmpty
            ? _trackingController.text.trim()
            : null,
        eventTime: _eventTime,
      );

      final response = await shippingService.createShippingOperation(shippingRequest);

      if (response.isSuccessOrPartial) {
        if (response.status == ShippingStatus.partialSuccess) {
          ShippingSnackbar.showSuccess(
            context,
            'Shipping submitted with warnings. Open the record for details.',
          );
        } else {
          ShippingSnackbar.showSuccess(
            context,
            'Shipping operation completed successfully.',
          );
        }
        if (!mounted) return;

        if (widget.embedded && widget.onEmbeddedActionSuccess != null) {
          if (response.navigableOperationId != null) {
            context
                .read<ShippingOperationsCubit>()
                .setCreatedId(response.navigableOperationId);
          }
          widget.onEmbeddedActionSuccess!();
        } else {
          if (!context.isDesktop && response.navigableOperationId != null) {
            context.go(
                '${Constants.opShippingRoute}/${response.navigableOperationId}');
          } else {
            context.go(Constants.opShippingRoute);
          }
        }
      } else {
        final errorMessage = response.messages?.isNotEmpty == true
            ? response.messages!.first
            : 'The shipping operation could not be completed. Check your inputs and try again.';
        ShippingSnackbar.showError(context, errorMessage);
      }
    } on ApiException catch (e) {
      ShippingSnackbar.showError(context, e.getUserFriendlyMessage());
    } catch (_) {
      ShippingSnackbar.showError(
        context,
        'An unexpected error occurred while submitting the shipping operation.',
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onItemScanResult(ScanResult result) {
    if (!result.isValid) return;
    _addEpc(result.data, showSuccessToast: true);
  }

  void _addManualItem() {
    final barcode = _manualEntryController.text.trim();
    if (barcode.isEmpty) {
      ShippingSnackbar.showError(context, 'Please type or paste an EPC before tapping Add.');
      return;
    }
    final added = _addEpc(barcode);
    if (added) {
      _manualEntryController.clear();
    }
  }

  bool _addEpc(String barcode, {bool showSuccessToast = false}) {
    final duplicate = OperationEpcScanValidator.checkDuplicate(barcode, _scannedEpcs);
    if (duplicate != null) {
      ShippingSnackbar.showError(
        context,
        'This EPC is already in the list.',
      );
      return false;
    }

    final type = OperationEpcScanValidator.resolveEpcType(barcode);
    if (type == OperationScanItemType.unknown) {
      ShippingSnackbar.showError(
        context,
        'Only SGTIN and SSCC values are allowed for shipping.',
      );
      return false;
    }

    setState(() => _scannedEpcs.add(barcode));
    if (showSuccessToast) {
      ShippingSnackbar.showSuccess(context, 'Item added');
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return AppLayoutBuilder(
      builder: (context, layout) {
        final usePanelLayout = widget.embedded || layout.isDesktopUp;
        if (usePanelLayout) {
          return ShippingOperationDesktopLayout(
            isLoading: _isLoading,
            step1Complete: _validateStep0Silent(),
            step2Complete: _scannedEpcs.isNotEmpty,
            detailsStep: _referenceDetailsStep(embeddedInPanel: true),
            itemsStep: _itemScanStep(embeddedInPanel: true, fillHeight: false),
            reviewStep: _reviewStep(embeddedInPanel: true),
            onSubmit: _submitShippingOperation,
          );
        }

        return ShippingOperationMobileLayout(
          isLoading: _isLoading,
          currentStep: _currentStep,
          steps: _wizardSteps,
          pageController: _pageController,
          onPageChanged: (page) => setState(() => _currentStep = page),
          onPrevious: _previousStep,
          onNext: _nextStep,
          onSubmit: _submitShippingOperation,
          stepPages: [
            _referenceDetailsStep(),
            _itemScanStep(),
            _reviewStep(),
          ],
        );
      },
    );
  }
}
