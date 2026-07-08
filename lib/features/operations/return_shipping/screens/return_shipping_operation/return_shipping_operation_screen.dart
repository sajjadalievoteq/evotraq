import 'package:traqtrace_app/data/models/operations/shared/operation_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/layout/layout_manager.dart';
import 'package:traqtrace_app/core/utils/gs1/gs1_converter.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/epc_input_widget/epc_types.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/core/widgets/operation_wizard/operation_step_config.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/data/models/operations/return_shipping/return_shipping_request_model.dart';
import 'package:traqtrace_app/data/models/operations/shared/operation_gln_display.dart';
import 'package:traqtrace_app/data/services/operations/return_shipping/return_shipping_operation_service.dart';
import 'package:traqtrace_app/data/services/operations/shared/operation_epc_status_service.dart';
import 'package:traqtrace_app/features/operations/shared/operation_epc_scan_validator.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/screens/aggregation_event_form/widgets/aggregation_pharma_issues_dialog.dart';
import 'package:traqtrace_app/features/operations/shared/cubit/operation_split_cubit.dart';
import 'package:traqtrace_app/features/operations/return_shipping/screens/return_shipping_operation/utils/return_shipping_pharma_readiness_checker.dart';
import 'package:traqtrace_app/features/operations/return_shipping/screens/return_shipping_operation/utils/return_shipping_operation_step_validator.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/operation/operation_item_scan_step.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/operation/operation_desktop_layout.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/operation/operation_mobile_layout.dart';
import 'package:traqtrace_app/features/operations/return_shipping/screens/return_shipping_operation/widgets/return_shipping_reference_details_step.dart';
import 'package:traqtrace_app/features/operations/return_shipping/screens/return_shipping_operation/widgets/return_shipping_review_step.dart';
import 'package:traqtrace_app/core/utils/operation_error_translator.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/features/operations/shared/models/pharma_return_context.dart';
import 'package:traqtrace_app/features/operations/shared/models/pharma_return_reason.dart';
import 'package:traqtrace_app/features/operations/shared/utils/pharma_return_context_builder.dart';
import 'package:traqtrace_app/core/storage/operational_gln_store.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';

class ReturnShippingOperationScreen extends StatefulWidget {
  const ReturnShippingOperationScreen({
    super.key,
    this.embedded = false,
    this.onEmbeddedActionSuccess,
    this.pharmaReturnContext,
  });

  final bool embedded;

  final VoidCallback? onEmbeddedActionSuccess;

  final PharmaReturnContext? pharmaReturnContext;

  @override
  State<ReturnShippingOperationScreen> createState() => _ReturnShippingOperationScreenState();
}

class _ReturnShippingOperationScreenState extends State<ReturnShippingOperationScreen> {
  static const _wizardSteps = [
    OperationStepConfig.details,
    OperationStepConfig.items,
    OperationStepConfig.review,
  ];

  final PageController _pageController = PageController();
  int _currentStep = 0;

  final _returnAuthorizationController = TextEditingController();
  final _purchaseOrderController = TextEditingController();
  final _despatchAdviceController = TextEditingController();
  final _billOfLadingController = TextEditingController();
  final _carrierController = TextEditingController();
  final _trackingController = TextEditingController();
  final _gincNumberController = TextEditingController();

  GLN? _sourceGln;
  GLN? _destinationGln;
  String? _sourceGlnError;
  String? _destinationGlnError;
  DateTime? _eventTime;
  final List<String> _scannedEpcs = [];
  final Map<String, String> _itemWarnings = {};
  bool _isLoading = false;
  PharmaReturnContext? _pharmaContext;
  PharmaReturnReason? _selectedReturnReason;
  bool get _isPrefilled => _pharmaContext != null && _pharmaContext!.isValid;

  @override
  void initState() {
    super.initState();
    _pharmaContext = widget.pharmaReturnContext;
    _bootstrapPharmaPrefill();
  }

  Future<void> _bootstrapPharmaPrefill() async {
    final ctx = _pharmaContext;
    if (ctx == null || !ctx.isValid) return;

    final builder = PharmaReturnContextBuilder();
    final source = await builder.loadGln(ctx.returnShippingSourceGln);
    final destination = await builder.loadGln(ctx.returnShippingDestinationGln);

    if (!mounted) return;
    setState(() {
      _scannedEpcs
        ..clear()
        ..addAll(ctx.epcs);
      _sourceGln = source ?? GLN.fromCode(ctx.returnShippingSourceGln);
      _destinationGln =
          destination ?? GLN.fromCode(ctx.returnShippingDestinationGln);
    });
  }

  bool _validateStep0Silent() =>
      _sourceGln != null &&
      _destinationGln != null &&
      _sourceGln?.glnCode != _destinationGln?.glnCode &&
      (!_isPrefilled || _selectedReturnReason != null);

  ReturnShippingReferenceDetailsStep _referenceDetailsStep({
    bool embeddedInPanel = false,
    bool showReferenceSection = true,
    bool showLocationSection = true,
    bool showDocumentSection = true,
  }) {
    return ReturnShippingReferenceDetailsStep(
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
      returnAuthorizationController: _returnAuthorizationController,
      purchaseOrderController: _purchaseOrderController,
      despatchAdviceController: _despatchAdviceController,
      billOfLadingController: _billOfLadingController,
      carrierController: _carrierController,
      trackingController: _trackingController,
      gincNumberController: _gincNumberController,
      eventTime: _eventTime,
      onEventTimeChanged: (dt) => setState(() => _eventTime = dt),
      showPageHeader: !embeddedInPanel,
      showReferenceSection: showReferenceSection,
      showLocationSection: showLocationSection,
      showDocumentSection: _isPrefilled ? false : showDocumentSection,
      readOnlyLocations: _isPrefilled,
      showReturnReasonField: _isPrefilled,
      selectedReturnReason: _selectedReturnReason,
      onReturnReasonChanged: (reason) =>
          setState(() => _selectedReturnReason = reason),
      productGtin: _pharmaContext?.gtin,
      productLotNumber: _pharmaContext?.lotNumber,
      productExpiryDate: _pharmaContext?.expiryDate,
      productQuantity: _pharmaContext?.quantity,
      productDescription: _pharmaContext?.productDescription,
      productEpcs: _pharmaContext?.epcs ?? const [],
    );
  }

  OperationItemScanStep _itemScanStep({
    bool embeddedInPanel = false,
    bool? fillHeight,
  }) {
    return OperationItemScanStep(
      scannedEpcs: _scannedEpcs,
      onItemAdded: _onItemAdded,
      onRemoveItem: (index) => setState(() {
        final removed = _scannedEpcs.removeAt(index);
        _itemWarnings.remove(removed);
      }),
      onClearAll: () => setState(() {
        _scannedEpcs.clear();
        _itemWarnings.clear();
      }),
      groupCardTitle: 'Add EPCs to Shipment',
      pageHeaderTitle:
          _isPrefilled ? 'Returned Items' : 'Scan Items to Return',
      pageHeaderSubtitle: _isPrefilled
          ? 'Serial numbers from the return shipment (read-only).'
          : 'Scan SGTIN or SSCC labels for this return shipment.',
      scannedListTitle: 'Items to Ship',
      scannedQueuedLabel: 'queued for shipping',
      hierarchyScreenTitle: 'Return Shipment Hierarchy',
      fillHeight: fillHeight ?? embeddedInPanel,
      showPageHeader: !embeddedInPanel,
      showScanInput: !_isPrefilled,
      itemWarnings: _itemWarnings,
    );
  }

  ReturnShippingReviewStep _reviewStep({bool embeddedInPanel = false}) {
    return ReturnShippingReviewStep(
      sourceGln: _sourceGln,
      destinationGln: _destinationGln,
      returnAuthorizationNumber: _returnAuthorizationController.text,
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
    _returnAuthorizationController.dispose();
    _purchaseOrderController.dispose();
    _despatchAdviceController.dispose();
    _billOfLadingController.dispose();
    _carrierController.dispose();
    _trackingController.dispose();
    _gincNumberController.dispose();
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
        final referenceError = ReturnShippingOperationStepValidator.validateReferenceStep(
          sourceGln: _sourceGln,
          destinationGln: _destinationGln,
        );
        if (referenceError != null) {
          if (referenceError.contains('Ship From')) {
            setState(() => _sourceGlnError = referenceError);
          } else if (referenceError.contains('Ship To')) {
            setState(() => _destinationGlnError = referenceError);
          } else {
            context.showError(referenceError);
          }
          return false;
        }
        if (_isPrefilled && _selectedReturnReason == null) {
          context.showError(
            'Select a reason for return before continuing.',
          );
          return false;
        }
        return true;
      case 1:
        final itemsError = ReturnShippingOperationStepValidator.validateItemsStep(_scannedEpcs);
        if (itemsError != null) {
          context.showError(itemsError);
          return false;
        }
        return true;
      default:
        return true;
    }
  }

  Future<void> _submitReturnShippingOperation() async {
    if (!_validateCurrentStep()) return;

    setState(() => _isLoading = true);

    try {
      final shippingService = getIt<ReturnShippingOperationService>();
      final conversionResult = Gs1Converter.barcodeBatchToEpc(_scannedEpcs);
      final epcUris = List<String>.from(conversionResult['successful'] ?? []);
      final failedConversions = List<String>.from(conversionResult['failed'] ?? []);

      if (failedConversions.isNotEmpty) {
          context.showError(
          '${failedConversions.length} EPC(s) could not be converted. Remove invalid scans and try again.\n${failedConversions.join('\n')}',
        );
        return;
      }

      if (epcUris.isEmpty) {
          context.showError(
          'No valid EPCs were captured. Scan at least one SGTIN or SSCC.',
        );
        return;
      }

      final pharmaIssues = ReturnShippingPharmaReadinessChecker.findIssues(
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

      final shippingRequest = ReturnShippingRequest(
        epcs: epcUris,
        sourceGLN: _sourceGln!.glnCode,
        destinationGLN: _destinationGln!.glnCode,
        sourceLocation: OperationGlnDisplay.fromGln(_sourceGln),
        destinationLocation: OperationGlnDisplay.fromGln(_destinationGln),
        returnAuthorizationNumber:
            _returnAuthorizationController.text.trim().isNotEmpty
                ? _returnAuthorizationController.text.trim()
                : null,
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
        gincNumber: _gincNumberController.text.trim().isNotEmpty
            ? _gincNumberController.text.trim()
            : null,
        eventTime: _eventTime,
        sourceEventId: _pharmaContext?.sourceEventId,
        returnReason: _selectedReturnReason?.code,
        actingGln: _isPrefilled
            ? await OperationalGlnStore.getGln(
                context.read<AuthCubit>().state.user?.id ?? 0,
              )
            : null,
      );

      final response = await shippingService.createReturnShippingOperation(shippingRequest);

      if (response.isSuccessOrPartial) {
        if (response.status == OperationStatus.partialSuccess) {
          context.showSuccess(
            'Return shipping submitted with warnings. Open the record for details.',
          );
        } else {
          context.showSuccess(
            'Return shipping completed successfully.',
          );
        }
        if (!mounted) return;

        if (widget.embedded && widget.onEmbeddedActionSuccess != null) {
          if (response.navigableOperationId != null) {
            context
                .read<OperationSplitCubit>()
                .setCreatedId(response.navigableOperationId);
          }
          widget.onEmbeddedActionSuccess!();
        } else {
          if (!context.isDesktop && response.navigableOperationId != null) {
            context.go(
                '${Constants.opReturnShippingRoute}/${response.navigableOperationId}');
          } else {
            context.go(Constants.opReturnShippingRoute);
          }
        }
      } else {
        context.showError(OperationErrorTranslator.translateMessages(
          response.messages,
          fallback:
              'The shipping operation could not be completed. Check your inputs and try again.',
        ));
      }
    } on ApiException catch (e) {
      context.showError(e.getUserFriendlyMessage());
    } catch (_) {
          context.showError(
        'An unexpected error occurred while submitting the shipping operation.',
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _onItemAdded(EPCParseResult result) async {
    await _addEpc(result.epc, showSuccessToast: true);
  }

  Future<bool> _addEpc(String barcode, {bool showSuccessToast = false}) async {
    final duplicate = OperationEpcScanValidator.checkDuplicate(barcode, _scannedEpcs);
    if (duplicate != null) {
          context.showError(
        'This EPC is already in the list.',
      );
      return false;
    }

    final type = OperationEpcScanValidator.resolveEpcType(barcode);
    if (isRejectedOperationScanType(type)) {
      context.showError(kSerializedEpcRequiredMessage);
      return false;
    }

    setState(() => _scannedEpcs.add(barcode));
    await _checkEpcStatus(barcode);
    if (showSuccessToast) {
      context.showSuccess('Item added');
    }
    return true;
  }

  Future<void> _checkEpcStatus(String epc) async {
    try {
      final statusService = getIt<OperationEpcStatusService>();
      final status = await statusService.getEpcStatus(epc);
      if (!mounted || status == null) return;
      if (!status.compatibleWithReceiving) {
        setState(() => _itemWarnings[epc] = status.status);
      } else {
        setState(() => _itemWarnings.remove(epc));
      }
    } catch (_) {
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppLayoutBuilder(
      builder: (context, layout) {
        final usePanelLayout = widget.embedded || layout.isDesktopUp;
        if (usePanelLayout) {
          return OperationDesktopLayout(
            isLoading: _isLoading,
            step1Complete: _validateStep0Silent(),
            step2Complete: _scannedEpcs.isNotEmpty,
            detailsStep: _referenceDetailsStep(embeddedInPanel: true),
            itemsStep: _itemScanStep(embeddedInPanel: true, fillHeight: false),
            reviewStep: _reviewStep(embeddedInPanel: true),
            onSubmit: _submitReturnShippingOperation,
            appBarTitle: 'New Return Shipping',
            submitLabel: 'Create Return Shipping',
          );
        }

        return OperationMobileLayout(
          isLoading: _isLoading,
          currentStep: _currentStep,
          steps: _wizardSteps,
          pageController: _pageController,
          onPageChanged: (page) => setState(() => _currentStep = page),
          onPrevious: _previousStep,
          onNext: _nextStep,
          onSubmit: _submitReturnShippingOperation,
          appBarTitle: 'Return Shipping',
          submitLabel: 'Create Return Shipping',
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
