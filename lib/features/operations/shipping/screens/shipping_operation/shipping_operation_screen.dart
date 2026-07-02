import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/layout/layout_manager.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/epc_input_widget/epc_types.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/core/widgets/operation_wizard/operation_step_config.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/data/models/operations/shipping/shipping_request_model.dart';
import 'package:traqtrace_app/data/models/operations/shared/operation_gln_display.dart';
import 'package:traqtrace_app/data/models/operations/shipping/shipping_status.dart';
import 'package:traqtrace_app/data/services/reference_data_validation_service.dart';
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
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/features/operations/shipping/utils/shipping_submit_error_message.dart';

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
    OperationStepConfig.details,
    OperationStepConfig.items,
    OperationStepConfig.review,
  ];

  void _showOperationError(String message) {
    context.showError(
      message,
      duration: message.contains('\n')
          ? const Duration(seconds: 12)
          : const Duration(seconds: 5),
    );
  }

  final PageController _pageController = PageController();
  int _currentStep = 0;

  final _purchaseOrderController = TextEditingController();
  final _despatchAdviceController = TextEditingController();
  final _billOfLadingController = TextEditingController();
  final _carrierController = TextEditingController();
  final _trackingController = TextEditingController();

  GLN? _sourceGln;
  GLN? _destinationGln;
  String? _sourceGlnError;
  String? _destinationGlnError;
  DateTime? _eventTime;
  final List<String> _scannedEpcs = [];
  bool _isLoading = false;
  bool _isAddingEpc = false;

  late final OperationEpcScanValidator _epcScanValidator =
      OperationEpcScanValidator(getIt<ReferenceDataValidationService>());

  @override
  void initState() {
    super.initState();
  }

  bool _validateStep0Silent() =>
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
      scannedEpcs: _scannedEpcs,
      onItemAdded: _onItemAdded,
      onRemoveItem: (index) => setState(() => _scannedEpcs.removeAt(index)),
      onClearAll: () => setState(() => _scannedEpcs.clear()),
      fillHeight: fillHeight ?? embeddedInPanel,
      showPageHeader: !embeddedInPanel,
    );
  }

  ShippingReviewStep _reviewStep({bool embeddedInPanel = false}) {
    return ShippingReviewStep(
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
    _purchaseOrderController.dispose();
    _despatchAdviceController.dispose();
    _billOfLadingController.dispose();
    _carrierController.dispose();
    _trackingController.dispose();
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
          sourceGln: _sourceGln,
          destinationGln: _destinationGln,
        );
        if (referenceError != null) {
          if (referenceError.contains('Ship From')) {
            setState(() => _sourceGlnError = referenceError);
          } else if (referenceError.contains('Ship To')) {
            setState(() => _destinationGlnError = referenceError);
          } else {
            _showOperationError(referenceError);
          }
          return false;
        }
        return true;
      case 1:
        final itemsError = ShippingOperationStepValidator.validateItemsStep(_scannedEpcs);
        if (itemsError != null) {
          _showOperationError(itemsError);
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
_showOperationError(
          ShippingSubmitErrorMessage.epcConversionFailures(failedConversions),
        );
        return;
      }

      if (epcUris.isEmpty) {
_showOperationError(
          ShippingSubmitErrorMessage.emptyEpcList(),
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
        epcs: epcUris,
        sourceGLN: _sourceGln!.glnCode,
        destinationGLN: _destinationGln!.glnCode,
        sourceLocation: OperationGlnDisplay.fromGln(_sourceGln),
        destinationLocation: OperationGlnDisplay.fromGln(_destinationGln),
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
          context.showSuccess(
            'Shipping submitted with warnings. Open the record for details.',
          );
        } else {
          context.showSuccess(
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
_showOperationError(
          ShippingSubmitErrorMessage.fromResponse(response),
        );
      }
    } on ApiException catch (e) {
      _showOperationError(
        ShippingSubmitErrorMessage.fromApiException(e),
      );
    } catch (e) {
      _showOperationError(
        ShippingSubmitErrorMessage.unexpected(e),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _onItemAdded(EPCParseResult result) async {
    await _addEpc(result.epc, showSuccessToast: true);
  }

  Future<bool> _addEpc(String barcode, {bool showSuccessToast = false}) async {
    if (_isAddingEpc) return false;

    setState(() => _isAddingEpc = true);
    try {
      final outcome = await _epcScanValidator.validateAndAdd(
        barcode,
        alreadyScanned: _scannedEpcs,
        operationLabel: 'shipping',
        allowGtin: true,
      );
      if (!outcome.success) {
_showOperationError(
          outcome.errorMessage ??
              'This scan is not valid for shipping. Use SGTIN, SSCC, or lot-based GTIN.',
        );
        return false;
      }

      if (!mounted) return false;
      setState(() => _scannedEpcs.add(outcome.rawBarcode));
      if (showSuccessToast) {
        context.showSuccess('Item added');
      }
      return true;
    } finally {
      if (mounted) setState(() => _isAddingEpc = false);
    }
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
