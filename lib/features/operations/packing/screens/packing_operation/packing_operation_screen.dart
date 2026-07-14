import 'package:traqtrace_app/data/models/operations/shared/operation_status.dart';
import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/layout/layout_manager.dart';
import 'package:traqtrace_app/core/navigation/pop_or_go.dart';
import 'package:traqtrace_app/core/utils/gs1/gs1_converter.dart';
import 'package:traqtrace_app/core/models/scan_result.dart';
import 'package:traqtrace_app/core/widgets/epc_input_widget/epc_parser.dart';
import 'package:traqtrace_app/core/widgets/epc_input_widget/epc_types.dart';
import 'package:traqtrace_app/core/widgets/operation_wizard/operation_step_config.dart';
import 'package:traqtrace_app/data/models/operations/packing/packing_request_model.dart';
import 'package:traqtrace_app/data/models/operations/shared/operation_gln_display.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/data/services/operations/packing/packing_operation_service.dart';
import 'package:traqtrace_app/data/services/operations/shared/operation_epc_status_service.dart';
import 'package:traqtrace_app/data/services/gs1/gln/gln_service.dart';
import 'package:traqtrace_app/data/services/gs1/serialization/sgtin/sgtin_service.dart';
import 'package:traqtrace_app/data/services/gs1/serialization/sscc/sscc_service.dart';
import 'package:traqtrace_app/data/services/reference_data_validation_service.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/screens/aggregation_event_form/utils/aggregation_event_form_validators.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/screens/aggregation_event_form/utils/aggregation_pharma_readiness_checker.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/screens/aggregation_event_form/widgets/aggregation_pharma_issues_dialog.dart';
import 'package:traqtrace_app/features/operations/packing/screens/packing_operation/utils/packing_operation_step_validator.dart';
import 'package:traqtrace_app/features/operations/packing/utils/packing_step_validation_messages.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/operation/operation_item_scan_step.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/operation/operation_desktop_layout.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/operation/operation_items_step_content.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/operation/operation_mobile_layout.dart';
import 'package:traqtrace_app/features/operations/packing/screens/packing_operation/widgets/packing_reference_details_step.dart';
import 'package:traqtrace_app/features/operations/packing/screens/packing_operation/widgets/packing_review_step.dart';
import 'package:traqtrace_app/features/operations/shared/utils/operation_parent_container_epc.dart';
import 'package:traqtrace_app/features/operations/shared/utils/operation_scanning_mode.dart';
import 'package:traqtrace_app/features/operations/packing/utils/packing_submit_error_message.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/features/operations/shared/operation_epc_scan_validator.dart';

class PackingOperationScreen extends StatefulWidget {
  const PackingOperationScreen({super.key});

  @override
  State<PackingOperationScreen> createState() => _PackingOperationScreenState();
}

class _PackingOperationScreenState extends State<PackingOperationScreen> {
  static const _wizardSteps = [
    OperationStepConfig.details,
    OperationStepConfig.items,
    OperationStepConfig.review,
  ];

  final PageController _pageController = PageController();
  int _currentStep = 0;

  final _workOrderController = TextEditingController();
  final _batchNumberController = TextEditingController();
  final _productionOrderController = TextEditingController();

  GLN? _packingLocationGLN;
  String? _packingLocationGLNError;
  String? _parentContainerId;
  final List<String> _scannedEPCs = [];
  final Map<String, String> _itemWarnings = {};
  bool _isLoading = false;
  bool _closeContainer = false;
  DateTime? _eventTime;

  OperationScanningMode _containerScanningMode = OperationScanningMode.scanner;

  AggregationPharmaReadinessChecker? _pharmaReadinessChecker;
  late final OperationEpcScanValidator _epcScanValidator =
      OperationEpcScanValidator(getIt<ReferenceDataValidationService>());

  bool _validateStep0Silent() => _packingLocationGLN != null;

  PackingReferenceDetailsStep _referenceDetailsStep({
    bool embeddedInPanel = false,
    bool showReferenceSection = true,
    bool showLocationSection = true,
    bool showContainerSection = true,
    bool showProductionSection = true,
  }) {
    return PackingReferenceDetailsStep(
      workOrderController: _workOrderController,
      batchNumberController: _batchNumberController,
      productionOrderController: _productionOrderController,
      packingLocationGln: _packingLocationGLN,
      packingLocationGlnError: _packingLocationGLNError,
      onPackingLocationChanged: (gln) => setState(() {
        _packingLocationGLN = gln;
        _packingLocationGLNError = null;
      }),
      parentContainerId: _parentContainerId,
      scanningMode: _containerScanningMode,
      onScanningModeChanged: (mode) =>
          setState(() => _containerScanningMode = mode),
      onContainerScanResult: _onContainerScanResult,
      onContainerAdded: _onManualContainerAdded,
      onClearContainer: () => setState(() => _parentContainerId = null),
      eventTime: _eventTime,
      onEventTimeChanged: (dt) => setState(() => _eventTime = dt),
      showPageHeader: !embeddedInPanel,
      showReferenceSection: showReferenceSection,
      showLocationSection: showLocationSection,
      showContainerSection: showContainerSection,
      showProductionSection: showProductionSection,
    );
  }

  OperationItemScanStep _itemScanStep({
    bool embeddedInPanel = false,
    bool? fillHeight,
  }) {
    return OperationItemScanStep(
      scannedEpcs: _scannedEPCs,
      onItemAdded: _onItemAdded,
      onRemoveItem: (index) => setState(() {
        final removed = _scannedEPCs.removeAt(index);
        _itemWarnings.remove(removed);
      }),
      onClearAll: () => setState(() {
        _scannedEPCs.clear();
        _itemWarnings.clear();
      }),
      groupCardTitle: 'Add Items to Pack',
      pageHeaderTitle: 'Scan Items to Pack',
      pageHeaderSubtitle:
      'Scan the items to be packed into container: ${_parentContainerId ?? 'Unknown'}',
      scannedListTitle: 'Scanned Items (${_scannedEPCs.length})',
      scannedQueuedLabel: 'to pack',
      hierarchyScreenTitle: 'Packing Hierarchy',
      fillHeight: fillHeight ?? embeddedInPanel,
      showPageHeader: !embeddedInPanel,
      itemWarnings: _itemWarnings,
    );
  }

  PackingReviewStep _reviewStep({bool embeddedInPanel = false}) {
    return PackingReviewStep(
      packingLocationGln: _packingLocationGLN,
      eventTime: _eventTime,
      workOrder: _workOrderController.text,
      batchNumber: _batchNumberController.text,
      productionOrder: _productionOrderController.text,
      parentContainerId: _parentContainerId,
      scannedEpcs: _scannedEPCs,
      closeContainer: _closeContainer,
      onCloseContainerChanged: (value) =>
          setState(() => _closeContainer = value),
      showPageHeader: !embeddedInPanel,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _workOrderController.dispose();
    _batchNumberController.dispose();
    _productionOrderController.dispose();
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
    setState(() => _packingLocationGLNError = null);

    switch (_currentStep) {
      case 0:
        final referenceError = PackingOperationStepValidator.validateReferenceStep(
          packingLocationGln: _packingLocationGLN,
        );
        if (referenceError != null) {
          if (referenceError.contains('GLN')) {
            setState(() => _packingLocationGLNError = referenceError);
          } else {
            context.showError(referenceError);
          }
          return false;
        }
        final containerError =
        PackingOperationStepValidator.validateContainerStep(_parentContainerId);
        if (containerError != null) {
          context.showError(containerError);
          return false;
        }
        return true;
      case 1:
        final itemsError =
        PackingOperationStepValidator.validateItemsStep(_scannedEPCs);
        if (itemsError != null) {
          context.showError(itemsError);
          return false;
        }
        return true;
      default:
        return true;
    }
  }

  Future<void> _submitPackingOperation() async {
    if (!_validateCurrentStep()) return;

    setState(() => _isLoading = true);

    try {
      final packingService = getIt<PackingOperationService>();
      final conversionResult =
      Gs1Converter.barcodeBatchToEpc(_scannedEPCs);
      final epcUris = List<String>.from(conversionResult['successful'] ?? []);
      final failedConversions =
      List<String>.from(conversionResult['failed'] ?? []);

      if (failedConversions.isNotEmpty) {
        context.showError(
          PackingSubmitErrorMessage.epcConversionFailures(failedConversions),
        );
        setState(() => _isLoading = false);
        return;
      }

      if (epcUris.isEmpty) {
        context.showError(PackingSubmitErrorMessage.emptyEpcList());
        setState(() => _isLoading = false);
        return;
      }

      final containerEpc =
          Gs1Converter.barcodeToEpc(_parentContainerId!) ??
              _parentContainerId!;

      _pharmaReadinessChecker ??= AggregationPharmaReadinessChecker(
        glnService: getIt<GLNService>(),
        sgtinService: getIt<SGTINService>(),
        ssccService: getIt<SSCCService>(),
      );

      final pharmaIssues = await _pharmaReadinessChecker!.findIssues(
        eventLocationGln: _packingLocationGLN!.glnCode,
        action: 'ADD',
        parentEpcUri: containerEpc,
        childEpcUris: epcUris,
      );

      if (pharmaIssues.isNotEmpty && mounted) {
        setState(() => _isLoading = false);
        await AggregationPharmaIssuesDialog.show(context, pharmaIssues);
        return;
      }

      final packingRequest = PackingRequest(
        parentContainerId: containerEpc,
        childEpcs: epcUris,
        packingLocationGLN: _packingLocationGLN!.glnCode,
        operationLocation: OperationGlnDisplay.fromGln(_packingLocationGLN),
        // Pharma packing auto-commissions ALLOCATED SSCCs; mirror location as read point.
        readPointGLN: _packingLocationGLN!.glnCode,
        closeContainer: _closeContainer,
        workOrderNumber: _workOrderController.text.trim().isNotEmpty
            ? _workOrderController.text.trim()
            : null,
        batchNumber: _batchNumberController.text.trim().isNotEmpty
            ? _batchNumberController.text.trim()
            : null,
        productionOrder: _productionOrderController.text.trim().isNotEmpty
            ? _productionOrderController.text.trim()
            : null,
        eventTime: _eventTime,
      );

      final response =
      await packingService.createPackingOperation(packingRequest);

      if (response.isSuccessOrPartial) {
        if (response.status == OperationStatus.partialSuccess) {
          context.showSuccess(
            'Packing submitted with warnings — some items were not processed. '
                'Open the operation record to see which items need attention.',
          );
        } else {
          context.showSuccess(
            'Packing operation completed successfully.',
          );
        }
        if (mounted) {
          popOrGo(context, Constants.opPackingRoute);
        }
      } else {
        context.showError(PackingSubmitErrorMessage.fromResponse(response));
      }
    } on ApiException catch (e) {
      context.showError(PackingSubmitErrorMessage.fromApiException(e));
    } catch (e) {
      context.showError(PackingSubmitErrorMessage.unexpected(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onContainerScanResult(ScanResult result) {
    if (!result.isValid) return;

    final barcode = result.data;
    try {
      final parsed = parseToEPC(barcode);
      if (parsed.type != EPCType.sscc && parsed.type != EPCType.sgtin) {
        context.showError(PackingStepValidationMessages.invalidParentType);
        return;
      }
      _onManualContainerAdded(parsed);
      final label = parsed.type == EPCType.sscc
          ? 'SSCC: ${parsed.sscc ?? parsed.raw}'
          : 'SGTIN: ${parsed.epc}';
      context.showSuccess('Container ready — $label');
    } on EPCParseException catch (e) {
      context.showError(e.message);
    }
  }

  Future<void> _onItemAdded(EPCParseResult result) async {
    await _addEpc(result.epc, showSuccessToast: true);
  }

  Future<bool> _addEpc(String barcode, {bool showSuccessToast = false}) async {
    final result = await _epcScanValidator.validateAndAddWithStatus(
      barcode,
      alreadyScanned: _scannedEPCs,
      operationLabel: 'packing',
      loadStatus: (epc) => getIt<OperationEpcStatusService>().getEpcStatus(epc),
    );
    final outcome = result.outcome;
    if (!outcome.success) {
      context.showError(
        outcome.errorMessage ??
            PackingStepValidationMessages.itemAddFallback,
      );
      return false;
    }

    final epcError =
        AggregationEventFormValidators.validateChildEpcEntry(outcome.rawBarcode);
    if (epcError != null) {
      context.showError(PackingStepValidationMessages.invalidItemEpc);
      return false;
    }

    if (!mounted) return false;
    setState(() {
      _scannedEPCs.add(outcome.rawBarcode);
      final status = result.status;
      if (status != null && !status.compatibleWithShipping) {
        _itemWarnings[outcome.rawBarcode] = status.status;
      } else {
        _itemWarnings.remove(outcome.rawBarcode);
      }
    });
    if (showSuccessToast) {
      context.showSuccess('Item added');
    }
    return true;
  }

  void _onManualContainerAdded(EPCParseResult result) {
    final validationError = validateParentContainerEpc(result);
    if (validationError != null) {
      context.showError(validationError);
      return;
    }

    setState(
      () => _parentContainerId = parentContainerIdFromParsed(result),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppLayoutBuilder(
      builder: (context, layout) {
        if (layout.isDesktopUp) {
          return OperationDesktopLayout(
            isLoading: _isLoading,
            step1Complete: _validateStep0Silent(),
            step2Complete: _scannedEPCs.isNotEmpty,
            detailsStep: _referenceDetailsStep(
              embeddedInPanel: true,
              showContainerSection: false,
            ),
            itemsStep: OperationItemsStepContent(
              detailsStep: _referenceDetailsStep(
                embeddedInPanel: true,
                showReferenceSection: false,
                showLocationSection: false,
                showProductionSection: false,
              ),
              itemsStep: _itemScanStep(embeddedInPanel: true, fillHeight: false),
            ),
            reviewStep: _reviewStep(embeddedInPanel: true),
            onSubmit: _submitPackingOperation,
            appBarTitle: 'New Packing Operation',
            submitLabel: 'Create Packing Operation',
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
          onSubmit: _submitPackingOperation,
          appBarTitle: 'Packing Operation',
          submitLabel: 'Create Packing Operation',
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
