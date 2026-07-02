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
import 'package:traqtrace_app/data/models/operations/cancel_receiving/cancel_receiving_request_model.dart';
import 'package:traqtrace_app/data/models/operations/cancel_receiving/cancel_receiving_status.dart';
import 'package:traqtrace_app/data/services/operations/cancel_receiving/cancel_receiving_operation_service.dart';
import 'package:traqtrace_app/features/barcode/services/epc_uri_converter.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/screens/aggregation_event_form/widgets/aggregation_pharma_issues_dialog.dart';
import 'package:traqtrace_app/features/operations/cancel_receiving/cubit/cancel_receiving_operations_cubit.dart';
import 'package:traqtrace_app/features/operations/cancel_receiving/screens/cancel_receiving_operation/utils/cancel_receiving_operation_step_validator.dart';
import 'package:traqtrace_app/features/operations/cancel_receiving/screens/cancel_receiving_operation/utils/cancel_receiving_pharma_readiness_checker.dart';
import 'package:traqtrace_app/features/operations/cancel_receiving/screens/cancel_receiving_operation/widgets/cancel_receiving_item_scan_step.dart';
import 'package:traqtrace_app/features/operations/cancel_receiving/screens/cancel_receiving_operation/widgets/cancel_receiving_operation_desktop_layout.dart';
import 'package:traqtrace_app/features/operations/cancel_receiving/screens/cancel_receiving_operation/widgets/cancel_receiving_operation_mobile_layout.dart';
import 'package:traqtrace_app/features/operations/cancel_receiving/screens/cancel_receiving_operation/widgets/cancel_receiving_reference_details_step.dart';
import 'package:traqtrace_app/features/operations/cancel_receiving/screens/cancel_receiving_operation/widgets/cancel_receiving_review_step.dart';
import 'package:traqtrace_app/features/operations/shared/operation_epc_scan_validator.dart';

class CancelReceivingOperationScreen extends StatefulWidget {
  const CancelReceivingOperationScreen({
    super.key,
    this.embedded = false,
    this.onEmbeddedActionSuccess,
  });

  final bool embedded;
  final VoidCallback? onEmbeddedActionSuccess;

  @override
  State<CancelReceivingOperationScreen> createState() =>
      _CancelReceivingOperationScreenState();
}

class _CancelReceivingOperationScreenState extends State<CancelReceivingOperationScreen> {
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
  GLN? _receivingGln;
  String? _sourceGlnError;
  String? _receivingGlnError;
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

  CancelReceivingReferenceDetailsStep _referenceDetailsStep({
    bool embeddedInPanel = false,
  }) {
    return CancelReceivingReferenceDetailsStep(
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
      cancelReasonController: _cancelReasonController,
      originalReferenceController: _originalReferenceController,
      commentsController: _commentsController,
      eventTime: _eventTime,
      onEventTimeChanged: (dt) => setState(() => _eventTime = dt),
      showPageHeader: !embeddedInPanel,
    );
  }

  CancelReceivingItemScanStep _itemScanStep({
    bool embeddedInPanel = false,
    bool? fillHeight,
  }) {
    return CancelReceivingItemScanStep(
      scannedEpcs: _scannedEpcs,
      onItemAdded: _onItemAdded,
      onRemoveItem: (index) => setState(() => _scannedEpcs.removeAt(index)),
      onClearAll: () => setState(() => _scannedEpcs.clear()),
      fillHeight: fillHeight ?? embeddedInPanel,
      showPageHeader: !embeddedInPanel,
    );
  }

  CancelReceivingReviewStep _reviewStep({bool embeddedInPanel = false}) {
    return CancelReceivingReviewStep(
      sourceGln: _sourceGln,
      receivingGln: _receivingGln,
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
      _receivingGln != null &&
      _sourceGln?.glnCode != _receivingGln?.glnCode &&
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
      _receivingGlnError = null;
    });

    switch (_currentStep) {
      case 0:
        final referenceError = CancelReceivingOperationStepValidator.validateReferenceStep(
          sourceGln: _sourceGln,
          receivingGln: _receivingGln,
          cancelReason: _cancelReasonController.text,
        );
        if (referenceError != null) {
          if (referenceError.contains('Sender (Ship-From)')) {
            setState(() => _sourceGlnError = referenceError);
          } else if (referenceError.contains('Receive-At')) {
            setState(() => _receivingGlnError = referenceError);
          } else {
            context.showError(referenceError);
          }
          return false;
        }
        return true;
      case 1:
        final itemsError =
            CancelReceivingOperationStepValidator.validateItemsStep(_scannedEpcs);
        if (itemsError != null) {
          context.showError(itemsError);
          return false;
        }
        return true;
      default:
        return true;
    }
  }

  Future<void> _submitCancelReceivingOperation() async {
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

      final pharmaIssues = CancelReceivingPharmaReadinessChecker.findIssues(
        sourceGln: _sourceGln,
        receivingGln: _receivingGln,
        epcs: epcUris,
        cancelReason: _cancelReasonController.text.trim(),
        originalReceivingReference: _originalReferenceController.text.trim(),
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

      final request = CancelReceivingRequest(
        epcs: epcUris,
        sourceGLN: _sourceGln!.glnCode,
        receivingGLN: _receivingGln!.glnCode,
        cancelReason: _cancelReasonController.text.trim(),
        originalReceivingReference:
            _originalReferenceController.text.trim().isNotEmpty
                ? _originalReferenceController.text.trim()
                : null,
        comments: _commentsController.text.trim().isNotEmpty
            ? _commentsController.text.trim()
            : null,
        eventTime: _eventTime,
      );

      final response = await getIt<CancelReceivingOperationService>()
          .createCancelReceivingOperation(request);

      if (response.isSuccessOrPartial) {
        if (response.status == CancelReceivingStatus.partialSuccess) {
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
                .read<CancelReceivingOperationsCubit>()
                .setCreatedId(response.navigableOperationId);
          }
          widget.onEmbeddedActionSuccess!();
        } else {
          if (!context.isDesktop && response.navigableOperationId != null) {
            context.go(
              '${Constants.opCancelReceivingRoute}/${response.navigableOperationId}',
            );
          } else {
            context.go(Constants.opCancelReceivingRoute);
          }
        }
      } else {
        final errorMessage = response.messages?.isNotEmpty == true
            ? response.messages!.first
            : 'The cancel receiving operation could not be completed. Check your inputs and try again.';
        context.showError(errorMessage);
      }
    } on ApiException catch (e) {
      context.showError(e.getUserFriendlyMessage());
    } catch (_) {
      context.showError(
        'An unexpected error occurred while submitting the cancel receiving operation.',
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onItemAdded(EPCParseResult result) {
    final epc = result.epc;
    if (epc.startsWith('urn:epc:class:lgtin:')) {
      context.showError(
        'Lot-based GTINs are not valid for a pharma cancel receiving event. '
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
          return CancelReceivingOperationDesktopLayout(
            isLoading: _isLoading,
            step1Complete: _validateStep0Silent(),
            step2Complete: _scannedEpcs.isNotEmpty,
            detailsStep: _referenceDetailsStep(embeddedInPanel: true),
            itemsStep: _itemScanStep(embeddedInPanel: true, fillHeight: false),
            reviewStep: _reviewStep(embeddedInPanel: true),
            onSubmit: _submitCancelReceivingOperation,
          );
        }

        return CancelReceivingOperationMobileLayout(
          isLoading: _isLoading,
          currentStep: _currentStep,
          steps: _wizardSteps,
          pageController: _pageController,
          onPageChanged: (page) => setState(() => _currentStep = page),
          onPrevious: _previousStep,
          onNext: _nextStep,
          onSubmit: _submitCancelReceivingOperation,
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
