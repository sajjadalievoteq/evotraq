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
import 'package:traqtrace_app/data/models/operations/receiving/receiving_request_model.dart';
import 'package:traqtrace_app/data/models/operations/receiving/receiving_status.dart';
import 'package:traqtrace_app/data/services/operations/receiving/receiving_operation_service.dart';
import 'package:traqtrace_app/features/barcode/services/epc_uri_converter.dart';
import 'package:traqtrace_app/features/operations/shared/operation_epc_scan_validator.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/screens/aggregation_event_form/widgets/aggregation_pharma_issues_dialog.dart';
import 'package:traqtrace_app/features/operations/receiving/cubit/receiving_operations_cubit.dart';
import 'package:traqtrace_app/features/operations/receiving/screens/receiving_operation/utils/receiving_pharma_readiness_checker.dart';
import 'package:traqtrace_app/features/operations/receiving/screens/receiving_operation/utils/receiving_operation_step_validator.dart';
import 'package:traqtrace_app/features/operations/receiving/screens/receiving_operation/widgets/receiving_item_scan_step.dart';
import 'package:traqtrace_app/features/operations/receiving/screens/receiving_operation/widgets/receiving_operation_desktop_layout.dart';
import 'package:traqtrace_app/features/operations/receiving/screens/receiving_operation/widgets/receiving_operation_mobile_layout.dart';
import 'package:traqtrace_app/features/operations/receiving/screens/receiving_operation/widgets/receiving_reference_details_step.dart';
import 'package:traqtrace_app/features/operations/receiving/screens/receiving_operation/widgets/receiving_review_step.dart';
import 'package:traqtrace_app/features/operations/receiving/utils/receiving_scanning_mode.dart';
import 'package:traqtrace_app/features/operations/receiving/utils/receiving_snackbar.dart';

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
    OperationStepConfig(label: 'Details', icon: Icons.tag),
    OperationStepConfig(label: 'Items', icon: Icons.list_alt),
    OperationStepConfig(label: 'Review', icon: Icons.checklist),
  ];

  final PageController _pageController = PageController();
  int _currentStep = 0;

  final _referenceController = TextEditingController();
  final _purchaseOrderController = TextEditingController();
  final _despatchAdviceController = TextEditingController();
  final _receivingAdviceController = TextEditingController();
  final _invoiceController = TextEditingController();
  final _billOfLadingController = TextEditingController();
  final _carrierController = TextEditingController();
  final _trackingController = TextEditingController();
  final _notesController = TextEditingController();
  final _manualEntryController = TextEditingController();

  GLN? _sourceGln;
  GLN? _receivingGln;
  String? _sourceGlnError;
  String? _receivingGlnError;
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

  ReceivingScanningMode _scanningMode = ReceivingScanningMode.scanner;

  bool _validateStep0Silent() =>
      _referenceController.text.trim().isNotEmpty &&
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
      referenceController: _referenceController,
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

  ReceivingItemScanStep _itemScanStep({
    bool embeddedInPanel = false,
    bool? fillHeight,
  }) {
    return ReceivingItemScanStep(
      receivingReference: _referenceController.text,
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

  ReceivingReviewStep _reviewStep({bool embeddedInPanel = false}) {
    return ReceivingReviewStep(
      receivingReference: _referenceController.text,
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
    _referenceController.removeListener(_onReferenceChanged);
    _referenceController.dispose();
    _purchaseOrderController.dispose();
    _despatchAdviceController.dispose();
    _receivingAdviceController.dispose();
    _invoiceController.dispose();
    _billOfLadingController.dispose();
    _carrierController.dispose();
    _trackingController.dispose();
    _notesController.dispose();
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
      _receivingGlnError = null;
    });

    switch (_currentStep) {
      case 0:
        final referenceError = ReceivingOperationStepValidator.validateReferenceStep(
          receivingReference: _referenceController.text,
          sourceGln: _sourceGln,
          receivingGln: _receivingGln,
        );
        if (referenceError != null) {
          if (referenceError.contains('Ship From')) {
            setState(() => _sourceGlnError = referenceError);
          } else if (referenceError.contains('Receiving')) {
            setState(() => _receivingGlnError = referenceError);
          } else {
            ReceivingSnackbar.showError(context, referenceError);
          }
          return false;
        }
        return true;
      case 1:
        final itemsError = ReceivingOperationStepValidator.validateItemsStep(_scannedEpcs);
        if (itemsError != null) {
          ReceivingSnackbar.showError(context, itemsError);
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
        ReceivingSnackbar.showError(
          context,
          '${failedConversions.length} EPC(s) could not be converted. Remove invalid scans and try again.\n${failedConversions.join('\n')}',
        );
        return;
      }

      if (epcUris.isEmpty) {
        ReceivingSnackbar.showError(
          context,
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
        receivingReference: _referenceController.text.trim(),
        epcs: epcUris,
        sourceGLN: _sourceGln!.glnCode,
        receivingGLN: _receivingGln!.glnCode,
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
        if (response.status == ReceivingStatus.partialSuccess) {
          ReceivingSnackbar.showSuccess(
            context,
            'Receiving submitted with warnings. Open the record for details.',
          );
        } else {
          ReceivingSnackbar.showSuccess(
            context,
            'Receiving operation completed successfully.',
          );
        }
        if (!mounted) return;

        if (widget.embedded && widget.onEmbeddedActionSuccess != null) {
          if (response.navigableOperationId != null) {
            context
                .read<ReceivingOperationsCubit>()
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
        ReceivingSnackbar.showError(context, errorMessage);
      }
    } on ApiException catch (e) {
      ReceivingSnackbar.showError(context, e.getUserFriendlyMessage());
    } catch (_) {
      ReceivingSnackbar.showError(
        context,
        'An unexpected error occurred while submitting the Receiving operation.',
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
      ReceivingSnackbar.showError(context, 'Please type or paste an EPC before tapping Add.');
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
      ReceivingSnackbar.showError(
        context,
        'This EPC is already in the list.',
      );
      return false;
    }

    final type = OperationEpcScanValidator.resolveEpcType(barcode);
    if (type == OperationScanItemType.unknown) {
      ReceivingSnackbar.showError(
        context,
        'Only SGTIN and SSCC values are allowed for receiving.',
      );
      return false;
    }

    setState(() => _scannedEpcs.add(barcode));
    if (showSuccessToast) {
      ReceivingSnackbar.showSuccess(context, 'Item added');
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return AppLayoutBuilder(
      builder: (context, layout) {
        final usePanelLayout = widget.embedded || layout.isDesktopUp;
        if (usePanelLayout) {
          return ReceivingOperationDesktopLayout(
            isLoading: _isLoading,
            step1Complete: _validateStep0Silent(),
            step2Complete: _scannedEpcs.isNotEmpty,
            detailsStep: _referenceDetailsStep(embeddedInPanel: true),
            itemsStep: _itemScanStep(embeddedInPanel: true, fillHeight: false),
            reviewStep: _reviewStep(embeddedInPanel: true),
            onSubmit: _submitReceivingOperation,
          );
        }

        return ReceivingOperationMobileLayout(
          isLoading: _isLoading,
          currentStep: _currentStep,
          steps: _wizardSteps,
          pageController: _pageController,
          onPageChanged: (page) => setState(() => _currentStep = page),
          onPrevious: _previousStep,
          onNext: _nextStep,
          onSubmit: _submitReceivingOperation,
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
