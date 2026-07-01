import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/debug/operation_api_debug_console.dart';
import 'package:traqtrace_app/core/debug/operation_api_debug_trace.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/layout/layout_manager.dart';
import 'package:traqtrace_app/core/widgets/epc_input_widget/epc_types.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/operation_wizard/operation_step_config.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/data/models/operations/decommissioning/decommissioning_request_model.dart';
import 'package:traqtrace_app/data/models/operations/decommissioning/decommissioning_status.dart';
import 'package:traqtrace_app/data/services/operations/decommissioning/decommissioning_operation_service.dart';
import 'package:traqtrace_app/data/services/reference_data_validation_service.dart';
import 'package:traqtrace_app/features/barcode/services/epc_uri_converter.dart';
import 'package:traqtrace_app/features/operations/decommissioning/cubit/decommissioning_operations_cubit.dart';
import 'package:traqtrace_app/features/operations/decommissioning/screens/decommissioning_operation/utils/decommissioning_disposition.dart';
import 'package:traqtrace_app/features/operations/decommissioning/screens/decommissioning_operation/utils/decommissioning_operation_step_validator.dart';
import 'package:traqtrace_app/features/operations/decommissioning/screens/decommissioning_operation/widgets/decommissioning_item_scan_step.dart';
import 'package:traqtrace_app/features/operations/decommissioning/screens/decommissioning_operation/widgets/decommissioning_operation_desktop_layout.dart';
import 'package:traqtrace_app/features/operations/decommissioning/screens/decommissioning_operation/widgets/decommissioning_operation_mobile_layout.dart';
import 'package:traqtrace_app/features/operations/decommissioning/screens/decommissioning_operation/widgets/decommissioning_reference_details_step.dart';
import 'package:traqtrace_app/features/operations/decommissioning/screens/decommissioning_operation/widgets/decommissioning_review_step.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/features/operations/decommissioning/utils/decommissioning_request_debug.dart';
import 'package:traqtrace_app/features/operations/decommissioning/utils/decommissioning_submit_error_message.dart';
import 'package:traqtrace_app/features/operations/shared/operation_epc_scan_validator.dart';

class DecommissioningOperationScreen extends StatefulWidget {
  const DecommissioningOperationScreen({
    super.key,
    this.embedded = false,
    this.onEmbeddedActionSuccess,
  });

  final bool embedded;
  final VoidCallback? onEmbeddedActionSuccess;

  @override
  State<DecommissioningOperationScreen> createState() =>
      _DecommissioningOperationScreenState();
}

class _DecommissioningOperationScreenState
    extends State<DecommissioningOperationScreen> {
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
  DecommissioningDisposition? _selectedDisposition;
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

  DecommissioningReferenceDetailsStep _referenceDetailsStep({
    bool embeddedInPanel = false,
  }) {
    return DecommissioningReferenceDetailsStep(
      locationGln: _locationGln,
      locationGlnError: _locationGlnError,
      onLocationGlnChanged: (gln) => setState(() {
        _locationGln = gln;
        _locationGlnError = null;
      }),
      selectedDisposition: _selectedDisposition,
      onDispositionChanged: (value) =>
          setState(() => _selectedDisposition = value),
      reasonController: _reasonController,
      commentsController: _commentsController,
      eventTime: _eventTime,
      onEventTimeChanged: (dt) => setState(() => _eventTime = dt),
      showPageHeader: !embeddedInPanel,
    );
  }

  DecommissioningItemScanStep _itemScanStep({
    bool embeddedInPanel = false,
    bool? fillHeight,
  }) {
    return DecommissioningItemScanStep(
      scannedEpcs: _scannedEpcs,
      onItemAdded: _onItemAdded,
      onRemoveItem: (index) => setState(() => _scannedEpcs.removeAt(index)),
      onClearAll: () => setState(() => _scannedEpcs.clear()),
      fillHeight: fillHeight ?? embeddedInPanel,
      showPageHeader: !embeddedInPanel,
    );
  }

  DecommissioningReviewStep _reviewStep({bool embeddedInPanel = false}) {
    return DecommissioningReviewStep(
      locationGln: _locationGln,
      disposition: _selectedDisposition,
      reason: _reasonController.text,
      comments: _commentsController.text,
      eventTime: _eventTime,
      scannedEpcs: _scannedEpcs,
      showPageHeader: !embeddedInPanel,
      onPreviewApiPayload: kDebugMode ? _previewDecommissioningApiPayload : null,
    );
  }

  Future<void> _previewDecommissioningApiPayload() async {
    final conversionResult = EPCURIConverter.convertBatchToEPCUri(_scannedEpcs);
    final epcUris = List<String>.from(conversionResult['successful'] ?? []);
    final request = DecommissioningRequest(
      epcs: epcUris,
      locationGLN: _locationGln?.glnCode ?? '',
      disposition: _selectedDisposition?.code ?? '',
      reason: _reasonController.text.trim(),
      comments: _commentsController.text.trim().isNotEmpty
          ? _commentsController.text.trim()
          : null,
      eventTime: _eventTime,
    );
    final dio = getIt<DioService>();
    final trace = OperationApiDebugTrace(
      operation: 'Decommissioning create (preview — not sent)',
      method: 'POST',
      url: '${dio.baseUrl}/operations/decommissioning',
      timestamp: DateTime.now(),
      requestBody: jsonEncode(request.toJson()),
      validationNotes: DecommissioningRequestDebug.validateRequest(request),
      extra: {
        'epcCount': request.epcs.length.toString(),
        'failedConversions':
            (conversionResult['failed'] as List?)?.length.toString() ?? '0',
      },
    );
    await OperationApiDebugConsole.show(
      context,
      trace,
      title: 'Decommissioning API Preview',
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
        final detailsError = DecommissioningOperationStepValidator.validateDetailsStep(
          locationGln: _locationGln,
          disposition: _selectedDisposition,
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
            DecommissioningOperationStepValidator.validateItemsStep(_scannedEpcs);
        if (itemsError != null) {
          _showOperationError(itemsError);
          return false;
        }
        return true;
      default:
        return true;
    }
  }

  Future<void> _submitDecommissioningOperation() async {
    if (!_validateCurrentStep()) return;

    setState(() => _isLoading = true);

    try {
      final service = getIt<DecommissioningOperationService>();
      final conversionResult = EPCURIConverter.convertBatchToEPCUri(_scannedEpcs);
      final epcUris = List<String>.from(conversionResult['successful'] ?? []);
      final failedConversions = List<String>.from(conversionResult['failed'] ?? []);

      if (failedConversions.isNotEmpty) {
        _showOperationError(
          DecommissioningSubmitErrorMessage.epcConversionFailures(failedConversions),
        );
        return;
      }

      if (epcUris.isEmpty) {
        _showOperationError(
          DecommissioningSubmitErrorMessage.emptyEpcList(),
        );
        return;
      }

      final request = DecommissioningRequest(
        epcs: epcUris,
        locationGLN: _locationGln!.glnCode,
        disposition: _selectedDisposition!.code,
        reason: _reasonController.text.trim(),
        comments: _commentsController.text.trim().isNotEmpty
            ? _commentsController.text.trim()
            : null,
        eventTime: _eventTime,
      );

      final response = await service.createDecommissioningOperation(request);

      if (response.isSuccessOrPartial) {
          context.showSuccess(
          response.status == DecommissioningStatus.partialSuccess
              ? 'Decommissioning submitted with warnings. Open the record for details.'
              : 'Decommissioning operation completed successfully.',
        );
        if (!mounted) return;

        if (widget.embedded && widget.onEmbeddedActionSuccess != null) {
          if (response.navigableOperationId != null) {
            context
                .read<DecommissioningOperationsCubit>()
                .setCreatedId(response.navigableOperationId);
          }
          widget.onEmbeddedActionSuccess!();
        } else {
          if (!context.isDesktop && response.navigableOperationId != null) {
            context.go(
              '${Constants.opDecommissioningRoute}/${response.navigableOperationId}',
            );
          } else {
            context.go(Constants.opDecommissioningRoute);
          }
        }
      } else {
        _showOperationError(
          DecommissioningSubmitErrorMessage.fromResponse(response),
        );
      }
    } on ApiException catch (e) {
      final trace = e.debugTrace ?? OperationApiDebugTrace.last;
      if (trace != null && mounted) {
        await OperationApiDebugConsole.show(
          context,
          trace,
          title: 'Decommissioning API Debug',
        );
      }
      if (!mounted) return;
      _showOperationError(
        DecommissioningSubmitErrorMessage.fromApiException(e),
      );
    } catch (e) {
      _showOperationError(
        DecommissioningSubmitErrorMessage.unexpected(e),
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
        operationLabel: 'decommissioning',
        allowGtin: false,
      );
      if (!outcome.success) {
        _showOperationError(
          outcome.errorMessage ??
              'This scan is not valid for decommissioning. Use SGTIN serials.',
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
          return DecommissioningOperationDesktopLayout(
            isLoading: _isLoading,
            step1Complete: _validateStep0Silent(),
            step2Complete: _scannedEpcs.isNotEmpty,
            detailsStep: _referenceDetailsStep(embeddedInPanel: true),
            itemsStep: _itemScanStep(embeddedInPanel: true, fillHeight: false),
            reviewStep: _reviewStep(embeddedInPanel: true),
            onSubmit: _submitDecommissioningOperation,
          );
        }

        return DecommissioningOperationMobileLayout(
          isLoading: _isLoading,
          currentStep: _currentStep,
          steps: _wizardSteps,
          pageController: _pageController,
          onPageChanged: (page) => setState(() => _currentStep = page),
          onPrevious: _previousStep,
          onNext: _nextStep,
          onSubmit: _submitDecommissioningOperation,
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
