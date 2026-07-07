import 'package:traqtrace_app/data/models/operations/shared/operation_status.dart';
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
import 'package:traqtrace_app/data/models/operations/receiving/receiving_request_model.dart';
import 'package:traqtrace_app/data/models/operations/shared/operation_gln_display.dart';
import 'package:traqtrace_app/data/services/operations/receiving/receiving_operation_service.dart';
import 'package:traqtrace_app/data/services/operations/shared/operation_epc_status_service.dart';
import 'package:traqtrace_app/features/barcode/services/epc_uri_converter.dart';
import 'package:traqtrace_app/features/operations/shared/operation_epc_scan_validator.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/screens/aggregation_event_form/widgets/aggregation_pharma_issues_dialog.dart';
import 'package:traqtrace_app/features/operations/shared/cubit/operation_split_cubit.dart';
import 'package:traqtrace_app/features/operations/receiving/screens/receiving_operation/utils/receiving_pharma_readiness_checker.dart';
import 'package:traqtrace_app/features/operations/receiving/screens/receiving_operation/utils/receiving_operation_step_validator.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/operation/operation_item_scan_step.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/operation/operation_desktop_layout.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/operation/operation_mobile_layout.dart';
import 'package:traqtrace_app/features/operations/receiving/screens/receiving_operation/widgets/receiving_reference_details_step.dart';
import 'package:traqtrace_app/features/operations/receiving/screens/receiving_operation/widgets/receiving_review_step.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';

class ReceivingOperationScreen extends StatefulWidget {
  const ReceivingOperationScreen({
    super.key,
    this.embedded = false,
    this.onEmbeddedActionSuccess,
  });

  /// True when rendered inside [Gs1SplitViewScreen]'s create panel.
  final bool embedded;

  /// Called after successful submission in embedded mode instead of navigating.
  final VoidCallback? onEmbeddedActionSuccess;

  @override
  State<ReceivingOperationScreen> createState() => _ReceivingOperationScreenState();
}

class _ReceivingOperationScreenState extends State<ReceivingOperationScreen> {
  static const _wizardSteps = [
    OperationStepConfig.details,
    OperationStepConfig.items,
    OperationStepConfig.review,
  ];

  final PageController _pageController = PageController();
  int _currentStep = 0;

  final _purchaseOrderController = TextEditingController();
  final _despatchAdviceController = TextEditingController();
  final _receivingAdviceController = TextEditingController();
  final _invoiceController = TextEditingController();
  final _billOfLadingController = TextEditingController();
  final _carrierController = TextEditingController();
  final _trackingController = TextEditingController();
  final _notesController = TextEditingController();
  GLN? _sourceGln;
  GLN? _receivingGln;
  String? _sourceGlnError;
  String? _receivingGlnError;
  DateTime? _eventTime;
  final List<String> _scannedEpcs = [];
  final Map<String, String> _itemWarnings = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  bool _validateStep0Silent() =>
      _sourceGln != null &&
      _receivingGln != null &&
      _sourceGln?.glnCode != _receivingGln?.glnCode;

  ReceivingReferenceDetailsStep _referenceDetailsStep({
    bool embeddedInPanel = false,
    bool showReferenceSection = true,
    bool showLocationSection = true,
    bool showDocumentSection = true,
  }) {
    return ReceivingReferenceDetailsStep(
      sourceGln: _sourceGln,
      receivingGln: _receivingGln,
      sourceGlnError: _sourceGlnError,
      receivingGlnError: _receivingGlnError,
      onSourceGlnChanged: (gln) => setState(() {
        _sourceGln = gln;
        _sourceGlnError = null;
      }),
      onReceivingGlnChanged: (gln) => setState(() {
        _receivingGln = gln;
        _receivingGlnError = null;
      }),
      purchaseOrderController: _purchaseOrderController,
      despatchAdviceController: _despatchAdviceController,
      receivingAdviceController: _receivingAdviceController,
      invoiceController: _invoiceController,
      billOfLadingController: _billOfLadingController,
      carrierController: _carrierController,
      trackingController: _trackingController,
      notesController: _notesController,
      eventTime: _eventTime,
      onEventTimeChanged: (dt) => setState(() => _eventTime = dt),
      showPageHeader: !embeddedInPanel,
      showReferenceSection: showReferenceSection,
      showLocationSection: showLocationSection,
      showDocumentSection: showDocumentSection,
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
      groupCardTitle: 'Add EPCs to Receive',
      pageHeaderTitle: 'Scan Items to Ship',
      pageHeaderSubtitle: 'Scan SGTIN or SSCC labels for this receipt.',
      scannedListTitle: 'Items to Receive',
      scannedQueuedLabel: 'queued for receiving',
      hierarchyScreenTitle: 'Receiving Hierarchy',
      fillHeight: fillHeight ?? embeddedInPanel,
      showPageHeader: !embeddedInPanel,
      itemWarnings: _itemWarnings,
    );
  }

  ReceivingReviewStep _reviewStep({bool embeddedInPanel = false}) {
    return ReceivingReviewStep(
      sourceGln: _sourceGln,
      receivingGln: _receivingGln,
      purchaseOrder: _purchaseOrderController.text,
      despatchAdvice: _despatchAdviceController.text,
      receivingAdvice: _receivingAdviceController.text,
      invoiceNumber: _invoiceController.text,
      billOfLading: _billOfLadingController.text,
      carrier: _carrierController.text,
      trackingNumber: _trackingController.text,
      notes: _notesController.text,
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
    _receivingAdviceController.dispose();
    _invoiceController.dispose();
    _billOfLadingController.dispose();
    _carrierController.dispose();
    _trackingController.dispose();
    _notesController.dispose();
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
      _receivingGlnError = null;
    });

    switch (_currentStep) {
      case 0:
        final referenceError = ReceivingOperationStepValidator.validateReferenceStep(
          sourceGln: _sourceGln,
          receivingGln: _receivingGln,
        );
        if (referenceError != null) {
          if (referenceError.contains('Ship From')) {
            setState(() => _sourceGlnError = referenceError);
          } else if (referenceError.contains('Receiving')) {
            setState(() => _receivingGlnError = referenceError);
          } else {
            context.showError(referenceError);
          }
          return false;
        }
        return true;
      case 1:
        final itemsError = ReceivingOperationStepValidator.validateItemsStep(_scannedEpcs);
        if (itemsError != null) {
          context.showError(itemsError);
          return false;
        }
        return true;
      default:
        return true;
    }
  }

  Future<void> _submitReceivingOperation() async {
    if (!_validateCurrentStep()) return;

    setState(() => _isLoading = true);

    try {
      final receivingService = getIt<ReceivingOperationService>();
      final conversionResult = EPCURIConverter.convertBatchToEPCUri(_scannedEpcs);
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

      final pharmaIssues = ReceivingPharmaReadinessChecker.findIssues(
        sourceGln: _sourceGln,
        receivingGln: _receivingGln,
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

      final receivingRequest = ReceivingRequest(
        epcs: epcUris,
        sourceGLN: _sourceGln!.glnCode,
        receivingGLN: _receivingGln!.glnCode,
        sourceLocation: OperationGlnDisplay.fromGln(_sourceGln),
        receivingLocation: OperationGlnDisplay.fromGln(_receivingGln),
        purchaseOrderNumber: _purchaseOrderController.text.trim().isNotEmpty
            ? _purchaseOrderController.text.trim()
            : null,
        despatchAdviceNumber: _despatchAdviceController.text.trim().isNotEmpty
            ? _despatchAdviceController.text.trim()
            : null,
        receivingAdviceNumber:
            _receivingAdviceController.text.trim().isNotEmpty
                ? _receivingAdviceController.text.trim()
                : null,
        invoiceNumber: _invoiceController.text.trim().isNotEmpty
            ? _invoiceController.text.trim()
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
        comments: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
        eventTime: _eventTime,
      );

      final response =
          await receivingService.createReceivingOperation(receivingRequest);

      if (response.isSuccessOrPartial) {
        if (response.status == OperationStatus.partialSuccess) {
          context.showSuccess(
            'Receiving submitted with warnings. Open the record for details.',
          );
        } else {
          context.showSuccess(
            'Receiving operation completed successfully.',
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
                '${Constants.opReceivingRoute}/${response.navigableOperationId}');
          } else {
            context.go(Constants.opReceivingRoute);
          }
        }
      } else {
        final errorMessage = response.messages?.isNotEmpty == true
            ? response.messages!.first
            : 'The Receiving operation could not be completed. Check your inputs and try again.';
        context.showError(errorMessage);
      }
    } on ApiException catch (e) {
      context.showError(e.getUserFriendlyMessage());
    } catch (_) {
      context.showError(
        'An unexpected error occurred while submitting the Receiving operation.',
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
    await _loadSoftWarning(barcode);
    if (showSuccessToast) {
      context.showSuccess('Item added');
    }
    return true;
  }

  Future<void> _loadSoftWarning(String epc) async {
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
      // Soft warning is best-effort only.
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
            onSubmit: _submitReceivingOperation,
            appBarTitle: 'New Receiving Operation',
            submitLabel: 'Create Receiving Operation',
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
          onSubmit: _submitReceivingOperation,
          appBarTitle: 'Receiving Operation',
          submitLabel: 'Create Receiving Operation',
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
