import 'package:traqtrace_app/data/models/operations/shared/operation_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/layout/layout_manager.dart';
import 'package:traqtrace_app/core/utils/gs1/gs1_converter.dart';
import 'package:traqtrace_app/core/widgets/epc_input_widget/epc_types.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/operation_wizard/operation_step_config.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/data/models/operations/update_status/update_status_request_model.dart';
import 'package:traqtrace_app/data/models/operations/shared/operation_gln_display.dart';
import 'package:traqtrace_app/data/services/operations/update_status/update_status_operation_service.dart';
import 'package:traqtrace_app/data/services/reference_data_validation_service.dart';
import 'package:traqtrace_app/features/operations/shared/cubit/operation_split_cubit.dart';
import 'package:traqtrace_app/features/operations/update_status/screens/update_status_operation/utils/update_status_disposition.dart';
import 'package:traqtrace_app/features/operations/update_status/screens/update_status_operation/utils/update_status_operation_step_validator.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/operation/operation_item_scan_step.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/operation/operation_desktop_layout.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/operation/operation_mobile_layout.dart';
import 'package:traqtrace_app/features/operations/update_status/screens/update_status_operation/widgets/update_status_reference_details_step.dart';
import 'package:traqtrace_app/features/operations/update_status/screens/update_status_operation/widgets/update_status_review_step.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/features/operations/update_status/utils/update_status_submit_error_message.dart';
import 'package:traqtrace_app/features/operations/shared/operation_epc_scan_validator.dart';

class UpdateStatusOperationScreen extends StatefulWidget {
  const UpdateStatusOperationScreen({
    super.key,
    this.embedded = false,
    this.onEmbeddedActionSuccess,
  });

  final bool embedded;
  final VoidCallback? onEmbeddedActionSuccess;

  @override
  State<UpdateStatusOperationScreen> createState() =>
      _UpdateStatusOperationScreenState();
}

class _UpdateStatusOperationScreenState
    extends State<UpdateStatusOperationScreen> {
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

  final _reasonController = TextEditingController();
  final _commentsController = TextEditingController();

  GLN? _locationGln;
  String? _locationGlnError;
  UpdateStatusDisposition? _selectedDisposition;
  String? _selectedReason;
  DateTime? _eventTime;
  final List<String> _scannedEpcs = [];
  bool _isLoading = false;
  bool _isAddingEpc = false;

  late final OperationEpcScanValidator _epcScanValidator =
      OperationEpcScanValidator(getIt<ReferenceDataValidationService>());

  bool _validateStep0Silent() =>
      _locationGln != null && _selectedDisposition != null;

  @override
  void dispose() {
    _pageController.dispose();
    _reasonController.dispose();
    _commentsController.dispose();
    super.dispose();
  }

  UpdateStatusReferenceDetailsStep _referenceDetailsStep({
    bool embeddedInPanel = false,
  }) {
    return UpdateStatusReferenceDetailsStep(
      locationGln: _locationGln,
      locationGlnError: _locationGlnError,
      onLocationGlnChanged: (gln) => setState(() {
        _locationGln = gln;
        _locationGlnError = null;
      }),
      selectedDisposition: _selectedDisposition,
      onDispositionChanged: (value) => setState(() {
        _selectedDisposition = value;
        _selectedReason = null;
        _reasonController.clear();
      }),
      reasonController: _reasonController,
      selectedReason: _selectedReason,
      onReasonChanged: (value) => setState(() => _selectedReason = value),
      commentsController: _commentsController,
      eventTime: _eventTime,
      onEventTimeChanged: (dt) => setState(() => _eventTime = dt),
      showPageHeader: !embeddedInPanel,
    );
  }

  OperationItemScanStep _itemScanStep({
    bool embeddedInPanel = false,
    bool? fillHeight,
  }) {
    return OperationItemScanStep(
      scannedEpcs: _scannedEpcs,
      onItemAdded: _onItemAdded,
      onRemoveItem: (index) => setState(() => _scannedEpcs.removeAt(index)),
      onClearAll: () => setState(() => _scannedEpcs.clear()),
      groupCardTitle: 'Add EPCs to Update',
      pageHeaderTitle: 'Scan Items to Update',
      pageHeaderSubtitle:
          'Scan SGTIN or SSCC labels for items to update status.',
      scannedListTitle: 'Items to Update',
      scannedQueuedLabel: 'queued for status update',
      hierarchyScreenTitle: 'Update Status Hierarchy',
      allowedTypes: const [EPCType.sgtin, EPCType.sscc],
      fillHeight: fillHeight ?? embeddedInPanel,
      showPageHeader: !embeddedInPanel,
    );
  }

  UpdateStatusReviewStep _reviewStep({bool embeddedInPanel = false}) {
    return UpdateStatusReviewStep(
      locationGln: _locationGln,
      disposition: _selectedDisposition,
      reason: _resolveReason(),
      comments: _commentsController.text,
      eventTime: _eventTime,
      scannedEpcs: _scannedEpcs,
      showPageHeader: !embeddedInPanel,
    );
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
    setState(() => _locationGlnError = null);

    switch (_currentStep) {
      case 0:
        final detailsError = UpdateStatusOperationStepValidator.validateDetailsStep(
          locationGln: _locationGln,
          disposition: _selectedDisposition,
          selectedReason: _selectedReason,
          freeTextReason: _reasonController.text.trim(),
        );
        if (detailsError != null) {
          if (detailsError.contains('GLN')) {
            setState(() => _locationGlnError = detailsError);
          } else {
            _showOperationError(detailsError);
          }
          return false;
        }
        return true;
      case 1:
        final itemsError =
            UpdateStatusOperationStepValidator.validateItemsStep(_scannedEpcs);
        if (itemsError != null) {
          _showOperationError(itemsError);
          return false;
        }
        return true;
      default:
        return true;
    }
  }

  Future<void> _submitUpdateStatusOperation() async {
    if (!_validateCurrentStep()) return;

    setState(() => _isLoading = true);

    try {
      final service = getIt<UpdateStatusOperationService>();
      final conversionResult = Gs1Converter.barcodeBatchToEpc(_scannedEpcs);
      final epcUris = List<String>.from(conversionResult['successful'] ?? []);
      final failedConversions = List<String>.from(conversionResult['failed'] ?? []);

      if (failedConversions.isNotEmpty) {
        _showOperationError(
          UpdateStatusSubmitErrorMessage.epcConversionFailures(failedConversions),
        );
        return;
      }

      if (epcUris.isEmpty) {
        _showOperationError(
          UpdateStatusSubmitErrorMessage.emptyEpcList(),
        );
        return;
      }

      final resolvedReason = _resolveReason();
      final request = UpdateStatusRequest(
        epcs: epcUris,
        locationGLN: _locationGln!.glnCode,
        operationLocation: OperationGlnDisplay.fromGln(_locationGln),
        disposition: _selectedDisposition!.code,
        reason: resolvedReason.isNotEmpty ? resolvedReason : null,
        comments: _commentsController.text.trim().isNotEmpty
            ? _commentsController.text.trim()
            : null,
        eventTime: _eventTime,
      );

      final response = await service.createUpdateStatusOperation(request);

      if (response.isSuccessOrPartial) {
          context.showSuccess(
          response.status == OperationStatus.partialSuccess
              ? 'Update Status submitted with warnings. Open the record for details.'
              : 'Status updated successfully.',
        );
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
              '${Constants.opUpdateStatusRoute}/${response.navigableOperationId}',
            );
          } else {
            context.go(Constants.opUpdateStatusRoute);
          }
        }
      } else {
        _showOperationError(
          UpdateStatusSubmitErrorMessage.fromResponse(response),
        );
      }
    } on ApiException catch (e) {
      _showOperationError(
        UpdateStatusSubmitErrorMessage.fromApiException(e),
      );
    } catch (e) {
      _showOperationError(
        UpdateStatusSubmitErrorMessage.unexpected(e),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _resolveReason() {
    if (_selectedDisposition == UpdateStatusDisposition.sample ||
        _selectedDisposition == UpdateStatusDisposition.damaged) {
      return _selectedReason ?? '';
    }
    return _reasonController.text.trim();
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
        operationLabel: 'Update Status',
        allowGtin: false,
      );
      if (!outcome.success) {
        _showOperationError(
          outcome.errorMessage ??
              'This scan is not valid for Update Status. Use SGTIN serials.',
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
          return OperationDesktopLayout(
            isLoading: _isLoading,
            step1Complete: _validateStep0Silent(),
            step2Complete: _scannedEpcs.isNotEmpty,
            detailsStep: _referenceDetailsStep(embeddedInPanel: true),
            itemsStep: _itemScanStep(embeddedInPanel: true, fillHeight: false),
            reviewStep: _reviewStep(embeddedInPanel: true),
            onSubmit: _submitUpdateStatusOperation,
            appBarTitle: 'New Update Status Operation',
            submitLabel: 'Create Update Status Operation',
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
          onSubmit: _submitUpdateStatusOperation,
          appBarTitle: 'Update Status Operation',
          submitLabel: 'Create Update Status Operation',
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
