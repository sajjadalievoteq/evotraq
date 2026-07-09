import 'package:traqtrace_app/data/models/operations/shared/operation_status.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/layout/layout_manager.dart';
import 'package:traqtrace_app/core/utils/gs1/gs1_converter.dart';
import 'package:traqtrace_app/core/models/scan_result.dart';
import 'package:traqtrace_app/core/widgets/epc_input_widget/epc_parser.dart';
import 'package:traqtrace_app/core/widgets/epc_input_widget/epc_types.dart';
import 'package:traqtrace_app/core/widgets/operation_wizard/operation_step_config.dart';
import 'package:traqtrace_app/data/models/operations/hierarchy/hierarchy_node.dart';
import 'package:traqtrace_app/data/models/operations/unpacking/unpacking_request_model.dart';
import 'package:traqtrace_app/data/models/operations/shared/operation_gln_display.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/data/services/operations/hierarchy/hierarchy_service.dart';
import 'package:traqtrace_app/data/services/operations/unpacking/unpacking_operation_service.dart';
import 'package:traqtrace_app/data/services/gs1/gln/gln_service.dart';
import 'package:traqtrace_app/data/services/gs1/serialization/sgtin/sgtin_service.dart';
import 'package:traqtrace_app/data/services/gs1/serialization/sscc/sscc_service.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/screens/aggregation_event_form/utils/aggregation_event_form_validators.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/screens/aggregation_event_form/utils/aggregation_pharma_readiness_checker.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/screens/aggregation_event_form/widgets/aggregation_pharma_issues_dialog.dart';
import 'package:traqtrace_app/features/operations/unpacking/screens/unpacking_operation/utils/unpacking_container_contents_loader.dart';
import 'package:traqtrace_app/features/operations/unpacking/screens/unpacking_operation/utils/unpacking_operation_step_validator.dart';
import 'package:traqtrace_app/features/operations/unpacking/screens/unpacking_operation/widgets/unpacking_item_scan_step.dart';
import 'package:traqtrace_app/features/operations/shared/utils/operation_parent_container_epc.dart';
import 'package:traqtrace_app/features/operations/shared/utils/operation_scanning_mode.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/operation/operation_desktop_layout.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/operation/operation_items_step_content.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/operation/operation_mobile_layout.dart';
import 'package:traqtrace_app/features/operations/unpacking/screens/unpacking_operation/widgets/unpacking_reference_details_step.dart';
import 'package:traqtrace_app/features/operations/unpacking/screens/unpacking_operation/widgets/unpacking_review_step.dart';
import 'package:traqtrace_app/features/operations/unpacking/utils/unpacking_scope.dart';
import 'package:traqtrace_app/features/shared/hierarchy/utils/hierarchy_epc_utils.dart';
import 'package:traqtrace_app/core/utils/operation_error_translator.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';

class UnpackingOperationScreen extends StatefulWidget {
  const UnpackingOperationScreen({super.key});

  @override
  State<UnpackingOperationScreen> createState() => _UnpackingOperationScreenState();
}

class _UnpackingOperationScreenState extends State<UnpackingOperationScreen> {
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

  GLN? _unpackingLocationGLN;
  String? _unpackingLocationGLNError;
  String? _parentContainerId;
  final Set<String> _selectedEpcs = {};
  List<HierarchyNode> _containerContents = [];
  bool _isLoadingContents = false;
  String? _contentsLoadError;
  UnpackingScope _unpackingScope = UnpackingScope.partial;
  bool _isLoading = false;
  DateTime? _eventTime;

  OperationScanningMode _containerScanningMode = OperationScanningMode.scanner;
  OperationScanningMode _itemScanningMode = OperationScanningMode.scanner;

  AggregationPharmaReadinessChecker? _pharmaReadinessChecker;

  bool _validateStep0Silent() => _unpackingLocationGLN != null;

  List<String> get _scannedEPCs => _selectedEpcs.toList();

  bool get _hasItemsToUnpack => _selectedEpcs.isNotEmpty;

  UnpackingReferenceDetailsStep _referenceDetailsStep({
    bool embeddedInPanel = false,
    bool showReferenceSection = true,
    bool showLocationSection = true,
    bool showContainerSection = true,
    bool showProductionSection = true,
  }) {
    return UnpackingReferenceDetailsStep(
      workOrderController: _workOrderController,
      batchNumberController: _batchNumberController,
      productionOrderController: _productionOrderController,
      unpackingLocationGln: _unpackingLocationGLN,
      unpackingLocationGlnError: _unpackingLocationGLNError,
      onUnpackingLocationChanged: (gln) => setState(() {
        _unpackingLocationGLN = gln;
        _unpackingLocationGLNError = null;
      }),
      parentContainerId: _parentContainerId,
      scanningMode: _containerScanningMode,
      onScanningModeChanged: (mode) =>
          setState(() => _containerScanningMode = mode),
      onContainerScanResult: _onContainerScanResult,
      onContainerAdded: _onManualContainerAdded,
      onClearContainer: () => setState(() {
        _parentContainerId = null;
        _containerContents = [];
        _selectedEpcs.clear();
        _contentsLoadError = null;
      }),
      eventTime: _eventTime,
      onEventTimeChanged: (dt) => setState(() => _eventTime = dt),
      showPageHeader: !embeddedInPanel,
      showReferenceSection: showReferenceSection,
      showLocationSection: showLocationSection,
      showContainerSection: showContainerSection,
      showProductionSection: showProductionSection,
    );
  }

  UnpackingItemScanStep _itemScanStep({
    bool embeddedInPanel = false,
    bool? fillHeight,
  }) {
    return UnpackingItemScanStep(
      parentContainerId: _parentContainerId,
      scope: _unpackingScope,
      onScopeChanged: _onUnpackingScopeChanged,
      containerContents: _containerContents,
      selectedEpcs: _selectedEpcs,
      onItemSelectionChanged: _onItemSelectionChanged,
      itemScanningMode: _itemScanningMode,
      onItemScanningModeChanged: (mode) =>
          setState(() => _itemScanningMode = mode),
      onItemAdded: _onItemAdded,
      isLoadingContents: _isLoadingContents,
      contentsLoadError: _contentsLoadError,
      onRetryLoadContents: _loadContainerContents,
      fillHeight: fillHeight ?? embeddedInPanel,
      showPageHeader: !embeddedInPanel,
    );
  }

  UnpackingReviewStep _reviewStep({bool embeddedInPanel = false}) {
    return UnpackingReviewStep(
      unpackingLocationGln: _unpackingLocationGLN,
      eventTime: _eventTime,
      workOrder: _workOrderController.text,
      batchNumber: _batchNumberController.text,
      productionOrder: _productionOrderController.text,
      parentContainerId: _parentContainerId,
      scannedEpcs: _scannedEPCs,
      unpackingScope: _unpackingScope,
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
    if (_currentStep == 0 && _validateCurrentStep()) {
      await _loadContainerContents();
    }
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
    setState(() => _unpackingLocationGLNError = null);

    switch (_currentStep) {
      case 0:
        final referenceError = UnpackingOperationStepValidator.validateReferenceStep(
          unpackingLocationGln: _unpackingLocationGLN,
        );
        if (referenceError != null) {
          if (referenceError.contains('GLN')) {
            setState(() => _unpackingLocationGLNError = referenceError);
          } else {
            context.showError(referenceError);
          }
          return false;
        }
        final containerError =
            UnpackingOperationStepValidator.validateContainerStep(_parentContainerId);
        if (containerError != null) {
          context.showError(containerError);
          return false;
        }
        return true;
      case 1:
        final itemsError = UnpackingOperationStepValidator.validateItemsStep(
          selectedEpcs: _selectedEpcs,
          scope: _unpackingScope,
          containerContents: _containerContents,
        );
        if (itemsError != null) {
          context.showError(itemsError);
          return false;
        }
        return true;
      default:
        return true;
    }
  }

  Future<void> _submitUnpackingOperation() async {
    if (!_validateCurrentStep()) return;

    setState(() => _isLoading = true);

    try {
      final unpackingService = getIt<UnpackingOperationService>();
      final conversionResult =
          Gs1Converter.barcodeBatchToEpc(_scannedEPCs);
      final epcUris = List<String>.from(conversionResult['successful'] ?? []);
      final failedConversions =
          List<String>.from(conversionResult['failed'] ?? []);

      if (failedConversions.isNotEmpty) {
        context.showError(
          '${failedConversions.length} item(s) could not be processed — their barcodes are not in a valid GS1 format. '
          'Remove them from the list, check the labels, and re-scan:\n${failedConversions.join('\n')}',
        );
        setState(() => _isLoading = false);
        return;
      }

      if (epcUris.isEmpty) {
        context.showError(
          'None of the scanned items could be converted to valid EPCs. '
          'Remove all items and re-scan using product labels that include a GTIN and serial number.',
        );
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
        eventLocationGln: _unpackingLocationGLN!.glnCode,
        action: 'DELETE',
        parentEpcUri: containerEpc,
        childEpcUris: epcUris,
      );

      if (pharmaIssues.isNotEmpty && mounted) {
        setState(() => _isLoading = false);
        await AggregationPharmaIssuesDialog.show(context, pharmaIssues);
        return;
      }

      final unpackingRequest = UnpackingRequest(
        parentContainerId: containerEpc,
        childEpcs: epcUris,
        unpackingLocationGLN: _unpackingLocationGLN!.glnCode,
        operationLocation: OperationGlnDisplay.fromGln(_unpackingLocationGLN),
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
          await unpackingService.createUnpackingOperation(unpackingRequest);

      if (response.isSuccessOrPartial) {
        if (response.status == OperationStatus.partialSuccess) {
          context.showSuccess(
            'Unpacking submitted with warnings — some items were not processed. '
            'Open the operation record to see which items need attention.',
          );
        } else {
          context.showSuccess(
            'Unpacking operation completed successfully.',
          );
        }
        if (mounted && response.operationId != null) {
          context.go(
            '${Constants.opUnpackingRoute}?selected=${response.operationId}',
          );
        } else if (mounted) {
          context.go(Constants.opUnpackingRoute);
        }
      } else {
        context.showError(OperationErrorTranslator.translateMessages(
          response.messages,
          fallback:
              'The unpacking operation could not be completed. Check your inputs and try again. '
              'If the problem persists, contact your system administrator.',
        ));
      }
    } on ApiException catch (e) {
      context.showError(e.getUserFriendlyMessage());
    } catch (e) {
      context.showError(
        'An unexpected error occurred while submitting the unpacking operation. '
        'Please try again. If the problem continues, contact support.',
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onContainerScanResult(ScanResult result) {
    if (!result.isValid) return;

    try {
      final parsed = parseToEPC(result.data);
      if (parsed.type != EPCType.sscc && parsed.type != EPCType.sgtin) {
        context.showError(
          'Parent container must be an SSCC (carton/pallet) or SGTIN (product serial).',
        );
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

  Future<void> _loadContainerContents() async {
    if (_parentContainerId == null || _parentContainerId!.isEmpty) return;

    setState(() {
      _isLoadingContents = true;
      _contentsLoadError = null;
    });

    try {
      final contents = await UnpackingContainerContentsLoader.loadDirectChildren(
        getIt<HierarchyService>(),
        _parentContainerId!,
      );
      if (!mounted) return;
      setState(() {
        _containerContents = contents;
        _isLoadingContents = false;
        _applyScopeSelection();
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoadingContents = false;
        _contentsLoadError =
            'Could not load container contents. Check your connection and try again.';
        _containerContents = [];
        _selectedEpcs.clear();
      });
    }
  }

  void _onUnpackingScopeChanged(UnpackingScope scope) {
    setState(() {
      _unpackingScope = scope;
      _applyScopeSelection();
    });
  }

  void _applyScopeSelection() {
    if (_unpackingScope == UnpackingScope.wholeContainer) {
      _selectedEpcs
        ..clear()
        ..addAll(_containerContents.map((node) => node.epc));
    } else {
      _selectedEpcs.removeWhere(
        (epc) => !_containerContents.any((node) => node.epc == epc),
      );
    }
  }

  void _onItemSelectionChanged(String epc, bool selected) {
    setState(() {
      if (_unpackingScope == UnpackingScope.wholeContainer) {
        _unpackingScope = UnpackingScope.partial;
      }
      if (selected) {
        _selectedEpcs.add(epc);
      } else {
        _selectedEpcs.remove(epc);
      }
    });
  }

  String? _resolveContainerMemberEpc(String barcode) {
    final uri = Gs1Converter.barcodeToEpc(barcode) ?? barcode;
    final normalized = normalizeHierarchyEpc(uri);
    for (final node in _containerContents) {
      if (normalizeHierarchyEpc(node.epc) == normalized) {
        return node.epc;
      }
    }
    return null;
  }

  void _onItemAdded(EPCParseResult result) {
    _tryAddItemByBarcode(result.epc);
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
    _loadContainerContents();
  }

  void _tryAddItemByBarcode(String barcode) {
    final memberEpc = _resolveContainerMemberEpc(barcode);
    if (memberEpc == null) {
      context.showError(
        'This item is not packed in the selected container. '
        'Choose it from the table above or enter an EPC that belongs to '
        'container $_parentContainerId.',
      );
      return;
    }

    if (_selectedEpcs.contains(memberEpc)) {
      context.showError('This item is already selected for unpacking.');
      return;
    }

    final epcError =
        AggregationEventFormValidators.validateChildEpcEntry(barcode);
    if (epcError != null) {
      context.showError(
        'This barcode is not a valid child EPC. '
        'Scan a product serial (SGTIN), lot-based GTIN, or nested SSCC label.',
      );
      return;
    }

    setState(() {
      if (_unpackingScope == UnpackingScope.wholeContainer) {
        _unpackingScope = UnpackingScope.partial;
      }
      _selectedEpcs.add(memberEpc);
    });
    context.showSuccess('Item added ✓');
  }

  @override
  Widget build(BuildContext context) {
    return AppLayoutBuilder(
      builder: (context, layout) {
        if (layout.isDesktopUp) {
          return OperationDesktopLayout(
            isLoading: _isLoading,
            step1Complete: _validateStep0Silent(),
            step2Complete: _hasItemsToUnpack,
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
            onSubmit: _submitUnpackingOperation,
            appBarTitle: 'New Unpacking Operation',
            submitLabel: 'Create Unpacking Operation',
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
          onSubmit: _submitUnpackingOperation,
          appBarTitle: 'Unpacking Operation',
          submitLabel: 'Create Unpacking Operation',
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
