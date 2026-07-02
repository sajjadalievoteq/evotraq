import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/layout/layout_manager.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/core/widgets/epc_input_widget/epc_types.dart';
import 'package:traqtrace_app/core/widgets/operation_wizard/operation_step_config.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/data/models/operations/cancel_shipping/cancel_shipping_request_model.dart';
import 'package:traqtrace_app/data/models/operations/shared/operation_gln_display.dart';
import 'package:traqtrace_app/data/models/operations/cancel_shipping/cancel_shipping_status.dart';
import 'package:traqtrace_app/data/services/operations/cancel_shipping/cancel_shipping_operation_service.dart';
import 'package:traqtrace_app/features/barcode/services/epc_uri_converter.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/screens/aggregation_event_form/widgets/aggregation_pharma_issues_dialog.dart';
import 'package:traqtrace_app/features/operations/cancel_shipping/cubit/cancel_shipping_operations_cubit.dart';
import 'package:traqtrace_app/features/operations/cancel_shipping/screens/cancel_shipping_operation/utils/cancel_shipping_operation_step_validator.dart';
import 'package:traqtrace_app/features/operations/cancel_shipping/screens/cancel_shipping_operation/utils/cancel_shipping_pharma_readiness_checker.dart';
import 'package:traqtrace_app/features/operations/cancel_shipping/screens/cancel_shipping_operation/widgets/cancel_shipping_item_scan_step.dart';
import 'package:traqtrace_app/features/operations/cancel_shipping/screens/cancel_shipping_operation/widgets/cancel_shipping_operation_desktop_layout.dart';
import 'package:traqtrace_app/features/operations/cancel_shipping/screens/cancel_shipping_operation/widgets/cancel_shipping_operation_mobile_layout.dart';
import 'package:traqtrace_app/features/operations/cancel_shipping/screens/cancel_shipping_operation/widgets/cancel_shipping_reference_details_step.dart';
import 'package:traqtrace_app/features/operations/cancel_shipping/screens/cancel_shipping_operation/widgets/cancel_shipping_review_step.dart';
import 'package:traqtrace_app/features/operations/shared/operation_epc_scan_validator.dart';

class CancelShippingOperationScreen extends StatefulWidget {
  const CancelShippingOperationScreen({
    super.key,
    this.embedded = false,
    this.onEmbeddedActionSuccess,
  });

  final bool embedded;
  final VoidCallback? onEmbeddedActionSuccess;

  @override
  State<CancelShippingOperationScreen> createState() =>
      _CancelShippingOperationScreenState();
}

class _CancelShippingOperationScreenState extends State<CancelShippingOperationScreen> {
  static const _wizardSteps = [
    OperationStepConfig.details,
    OperationStepConfig.items,
    OperationStepConfig.review,
  ];

  final PageController _pageController = PageController();
  int _currentStep = 0;

  final _cancelReasonController = TextEditingController();
  final _originalReferenceController = TextEditingController();
  final _commentsController = TextEditingController();

  GLN? _sourceGln;
  GLN? _destinationGln;
  String? _sourceGlnError;
  String? _destinationGlnError;
  DateTime? _eventTime;
  final List<String> _scannedEpcs = [];
  bool _isLoading = false;

  late final VoidCallback _onReferenceFieldChanged = () {
    if (mounted) setState(() {});
  };

  @override
  void initState() {
    super.initState();
    _cancelReasonController.addListener(_onReferenceFieldChanged);
    _originalReferenceController.addListener(_onReferenceFieldChanged);
    _commentsController.addListener(_onReferenceFieldChanged);
  }

  CancelShippingReferenceDetailsStep _referenceDetailsStep({
    bool embeddedInPanel = false,
  }) {
    return CancelShippingReferenceDetailsStep(
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
      cancelReasonController: _cancelReasonController,
      originalReferenceController: _originalReferenceController,
      commentsController: _commentsController,
      eventTime: _eventTime,
      onEventTimeChanged: (dt) => setState(() => _eventTime = dt),
      showPageHeader: !embeddedInPanel,
    );
  }

  CancelShippingItemScanStep _itemScanStep({
    bool embeddedInPanel = false,
    bool? fillHeight,
  }) {
    return CancelShippingItemScanStep(
      scannedEpcs: _scannedEpcs,
      onItemAdded: _onItemAdded,
      onRemoveItem: (index) => setState(() => _scannedEpcs.removeAt(index)),
      onClearAll: () => setState(() => _scannedEpcs.clear()),
      fillHeight: fillHeight ?? embeddedInPanel,
      showPageHeader: !embeddedInPanel,
    );
  }

  CancelShippingReviewStep _reviewStep({bool embeddedInPanel = false}) {
    return CancelShippingReviewStep(
      sourceGln: _sourceGln,
      destinationGln: _destinationGln,
      cancelReason: _cancelReasonController.text,
      originalReference: _originalReferenceController.text,
      comments: _commentsController.text,
      eventTime: _eventTime,
      scannedEpcs: _scannedEpcs,
      showPageHeader: !embeddedInPanel,
    );
  }

  @override
  void dispose() {
    _cancelReasonController.removeListener(_onReferenceFieldChanged);
    _originalReferenceController.removeListener(_onReferenceFieldChanged);
    _commentsController.removeListener(_onReferenceFieldChanged);
    _pageController.dispose();
    _cancelReasonController.dispose();
    _originalReferenceController.dispose();
    _commentsController.dispose();
    super.dispose();
  }

  bool _validateStep0Silent() =>
      _sourceGln != null &&
      _destinationGln != null &&
      _sourceGln?.glnCode != _destinationGln?.glnCode &&
      _cancelReasonController.text.trim().isNotEmpty;

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
        final referenceError = CancelShippingOperationStepValidator.validateReferenceStep(
          sourceGln: _sourceGln,
          destinationGln: _destinationGln,
          cancelReason: _cancelReasonController.text,
        );
        if (referenceError != null) {
          if (referenceError.contains('Ship-From')) {
            setState(() => _sourceGlnError = referenceError);
          } else if (referenceError.contains('Ship-To')) {
            setState(() => _destinationGlnError = referenceError);
          } else {
            context.showError(referenceError);
          }
          return false;
        }
        return true;
      case 1:
        final itemsError =
            CancelShippingOperationStepValidator.validateItemsStep(_scannedEpcs);
        if (itemsError != null) {
          context.showError(itemsError);
          return false;
        }
        return true;
      default:
        return true;
    }
  }

  Future<void> _submitCancelShippingOperation() async {
    if (!_validateCurrentStep()) return;

    setState(() => _isLoading = true);

    try {
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

      final pharmaIssues = CancelShippingPharmaReadinessChecker.findIssues(
        sourceGln: _sourceGln,
        destinationGln: _destinationGln,
        epcs: epcUris,
        cancelReason: _cancelReasonController.text.trim(),
        originalShippingReference: _originalReferenceController.text.trim(),
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

      final request = CancelShippingRequest(
        epcs: epcUris,
        sourceGLN: _sourceGln!.glnCode,
        destinationGLN: _destinationGln!.glnCode,
        sourceLocation: OperationGlnDisplay.fromGln(_sourceGln),
        destinationLocation: OperationGlnDisplay.fromGln(_destinationGln),
        cancelReason: _cancelReasonController.text.trim(),
        originalShippingReference:
            _originalReferenceController.text.trim().isNotEmpty
                ? _originalReferenceController.text.trim()
                : null,
        comments: _commentsController.text.trim().isNotEmpty
            ? _commentsController.text.trim()
            : null,
        eventTime: _eventTime,
      );

      final response = await getIt<CancelShippingOperationService>()
          .createCancelShippingOperation(request);

      if (response.isSuccessOrPartial) {
        if (response.status == CancelShippingStatus.partialSuccess) {
          context.showSuccess(
            'Cancel shipping submitted with warnings. Open the record for details.',
          );
        } else {
          context.showSuccess('Cancel shipping completed successfully.');
        }
        if (!mounted) return;

        if (widget.embedded && widget.onEmbeddedActionSuccess != null) {
          if (response.navigableOperationId != null) {
            context
                .read<CancelShippingOperationsCubit>()
                .setCreatedId(response.navigableOperationId);
          }
          widget.onEmbeddedActionSuccess!();
        } else {
          if (!context.isDesktop && response.navigableOperationId != null) {
            context.go(
              '${Constants.opCancelShippingRoute}/${response.navigableOperationId}',
            );
          } else {
            context.go(Constants.opCancelShippingRoute);
          }
        }
      } else {
        final errorMessage = response.messages?.isNotEmpty == true
            ? response.messages!.first
            : 'The cancel shipping operation could not be completed. Check your inputs and try again.';
        context.showError(errorMessage);
      }
    } on ApiException catch (e) {
      context.showError(e.getUserFriendlyMessage());
    } catch (_) {
      context.showError(
        'An unexpected error occurred while submitting the cancel shipping operation.',
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onItemAdded(EPCParseResult result) {
    final epc = result.epc;
    if (epc.startsWith('urn:epc:class:lgtin:')) {
      context.showError(
        'Lot-based GTINs are not valid for a pharma cancel shipping event. '
        'Scan a serialized SGTIN (GTIN + serial number) or SSCC instead.',
      );
      return;
    }
    final duplicate = OperationEpcScanValidator.checkDuplicate(epc, _scannedEpcs);
    if (duplicate != null) {
      context.showError('This EPC is already in the list.');
      return;
    }
    setState(() => _scannedEpcs.add(epc));
  }

  @override
  Widget build(BuildContext context) {
    return AppLayoutBuilder(
      builder: (context, layout) {
        final usePanelLayout = widget.embedded || layout.isDesktopUp;
        if (usePanelLayout) {
          return CancelShippingOperationDesktopLayout(
            isLoading: _isLoading,
            step1Complete: _validateStep0Silent(),
            step2Complete: _scannedEpcs.isNotEmpty,
            detailsStep: _referenceDetailsStep(embeddedInPanel: true),
            itemsStep: _itemScanStep(embeddedInPanel: true, fillHeight: false),
            reviewStep: _reviewStep(embeddedInPanel: true),
            onSubmit: _submitCancelShippingOperation,
          );
        }

        return CancelShippingOperationMobileLayout(
          isLoading: _isLoading,
          currentStep: _currentStep,
          steps: _wizardSteps,
          pageController: _pageController,
          onPageChanged: (page) => setState(() => _currentStep = page),
          onPrevious: _previousStep,
          onNext: _nextStep,
          onSubmit: _submitCancelShippingOperation,
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
