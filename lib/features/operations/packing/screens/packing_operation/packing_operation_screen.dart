import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/layout/layout_manager.dart';
import 'package:traqtrace_app/core/models/scan_result.dart';
import 'package:traqtrace_app/core/widgets/operation_wizard/operation_step_config.dart';
import 'package:traqtrace_app/data/models/operations/packing/packing_request_model.dart';
import 'package:traqtrace_app/data/models/operations/packing/packing_status.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/data/services/operations/packing/packing_operation_service.dart';
import 'package:traqtrace_app/data/services/gs1/gln/gln_service.dart';
import 'package:traqtrace_app/data/services/gs1/serialization/sgtin/sgtin_service.dart';
import 'package:traqtrace_app/data/services/gs1/serialization/sscc/sscc_service.dart';
import 'package:traqtrace_app/features/barcode/services/epc_uri_converter.dart';
import 'package:traqtrace_app/features/barcode/services/gs1_barcode_parser.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/screens/aggregation_event_form/utils/aggregation_event_form_validators.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/screens/aggregation_event_form/utils/aggregation_pharma_readiness_checker.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/screens/aggregation_event_form/widgets/aggregation_pharma_issues_dialog.dart';
import 'package:traqtrace_app/features/operations/packing/screens/packing_operation/utils/packing_operation_step_validator.dart';
import 'package:traqtrace_app/features/operations/packing/screens/packing_operation/widgets/packing_item_scan_step.dart';
import 'package:traqtrace_app/features/operations/packing/screens/packing_operation/widgets/packing_operation_desktop_layout.dart';
import 'package:traqtrace_app/features/operations/packing/screens/packing_operation/widgets/packing_operation_items_step_content.dart';
import 'package:traqtrace_app/features/operations/packing/screens/packing_operation/widgets/packing_operation_mobile_layout.dart';
import 'package:traqtrace_app/features/operations/packing/screens/packing_operation/widgets/packing_reference_details_step.dart';
import 'package:traqtrace_app/features/operations/packing/screens/packing_operation/widgets/packing_review_step.dart';
import 'package:traqtrace_app/features/operations/packing/utils/packing_scanning_mode.dart';
import 'package:traqtrace_app/features/operations/packing/utils/packing_snackbar.dart';
import 'package:traqtrace_app/features/operations/shared/operation_epc_scan_validator.dart';

/// Multi-step packing operations screen.
class PackingOperationScreen extends StatefulWidget {
  const PackingOperationScreen({super.key});

  @override
  State<PackingOperationScreen> createState() => _PackingOperationScreenState();
}

class _PackingOperationScreenState extends State<PackingOperationScreen> {
  static const _wizardSteps = [
    OperationStepConfig(label: 'Details', icon: Icons.tag),
    OperationStepConfig(label: 'Items', icon: Icons.list_alt),
    OperationStepConfig(label: 'Review', icon: Icons.checklist),
  ];

  final PageController _pageController = PageController();
  int _currentStep = 0;

  final _referenceController = TextEditingController();
  final _workOrderController = TextEditingController();
  final _batchNumberController = TextEditingController();
  final _productionOrderController = TextEditingController();
  final _manualEntryController = TextEditingController();
  final _containerManualEntryController = TextEditingController();

  GLN? _packingLocationGLN;
  String? _packingLocationGLNError;
  String? _parentContainerId;
  final List<String> _scannedEPCs = [];
  bool _isLoading = false;
  bool _closeContainer = false;

  PackingScanningMode _scanningMode = PackingScanningMode.scanner;
  PackingScanningMode _containerScanningMode = PackingScanningMode.scanner;

  AggregationPharmaReadinessChecker? _pharmaReadinessChecker;

  bool _validateStep0Silent() =>
      _referenceController.text.trim().isNotEmpty && _packingLocationGLN != null;

  PackingReferenceDetailsStep _referenceDetailsStep({
    bool embeddedInPanel = false,
    bool showReferenceSection = true,
    bool showLocationSection = true,
    bool showContainerSection = true,
    bool showProductionSection = true,
  }) {
    return PackingReferenceDetailsStep(
      referenceController: _referenceController,
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
      manualEntryController: _containerManualEntryController,
      onScanningModeChanged: (mode) =>
          setState(() => _containerScanningMode = mode),
      onContainerScanResult: _onContainerScanResult,
      onAddManualContainer: _addManualContainer,
      onClearContainer: () => setState(() => _parentContainerId = null),
      showPageHeader: !embeddedInPanel,
      showReferenceSection: showReferenceSection,
      showLocationSection: showLocationSection,
      showContainerSection: showContainerSection,
      showProductionSection: showProductionSection,
    );
  }

  PackingItemScanStep _itemScanStep({
    bool embeddedInPanel = false,
    bool? fillHeight,
  }) {
    return PackingItemScanStep(
      parentContainerId: _parentContainerId,
      packingReference: _referenceController.text,
      scannedEpcs: _scannedEPCs,
      scanningMode: _scanningMode,
      manualEntryController: _manualEntryController,
      onScanningModeChanged: (mode) => setState(() => _scanningMode = mode),
      onItemScanResult: _onItemScanResult,
      onAddManualItem: _addManualItem,
      onRemoveItem: (index) => setState(() => _scannedEPCs.removeAt(index)),
      onClearAll: () => setState(() => _scannedEPCs.clear()),
      fillHeight: fillHeight ?? embeddedInPanel,
      showPageHeader: !embeddedInPanel,
    );
  }

  PackingReviewStep _reviewStep({bool embeddedInPanel = false}) {
    return PackingReviewStep(
      packingReference: _referenceController.text,
      packingLocationGln: _packingLocationGLN,
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
    _referenceController.dispose();
    _workOrderController.dispose();
    _batchNumberController.dispose();
    _productionOrderController.dispose();
    _manualEntryController.dispose();
    _containerManualEntryController.dispose();
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
          packingReference: _referenceController.text,
          packingLocationGln: _packingLocationGLN,
        );
        if (referenceError != null) {
          if (referenceError.contains('GLN')) {
            setState(() => _packingLocationGLNError = referenceError);
          } else {
            PackingSnackbar.showError(context, referenceError);
          }
          return false;
        }
        final containerError =
            PackingOperationStepValidator.validateContainerStep(_parentContainerId);
        if (containerError != null) {
          PackingSnackbar.showError(context, containerError);
          return false;
        }
        return true;
      case 1:
        final itemsError =
            PackingOperationStepValidator.validateItemsStep(_scannedEPCs);
        if (itemsError != null) {
          PackingSnackbar.showError(context, itemsError);
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
          EPCURIConverter.convertBatchToEPCUri(_scannedEPCs);
      final epcUris = List<String>.from(conversionResult['successful'] ?? []);
      final failedConversions =
          List<String>.from(conversionResult['failed'] ?? []);

      if (failedConversions.isNotEmpty) {
        PackingSnackbar.showError(
          context,
          '${failedConversions.length} item(s) could not be processed — their barcodes are not in a valid GS1 format. '
          'Remove them from the list, check the labels, and re-scan:\n${failedConversions.join('\n')}',
        );
        setState(() => _isLoading = false);
        return;
      }

      if (epcUris.isEmpty) {
        PackingSnackbar.showError(
          context,
          'None of the scanned items could be converted to valid EPCs. '
          'Remove all items and re-scan using product labels that include a GTIN and serial number.',
        );
        setState(() => _isLoading = false);
        return;
      }

      final containerEpc =
          EPCURIConverter.convertToEPCUri(_parentContainerId!) ??
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
        packingReference: _referenceController.text.trim(),
        parentContainerId: containerEpc,
        childEpcs: epcUris,
        packingLocationGLN: _packingLocationGLN!.glnCode,
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
      );

      final response =
          await packingService.createPackingOperation(packingRequest);

      if (response.isSuccessOrPartial) {
        if (response.status == PackingStatus.partialSuccess) {
          PackingSnackbar.showSuccess(
            context,
            'Packing submitted with warnings — some items were not processed. '
            'Open the operation record to see which items need attention.',
          );
        } else {
          PackingSnackbar.showSuccess(
            context,
            'Packing operation completed successfully.',
          );
        }
        if (mounted && response.operationId != null) {
          context.go(
            '${Constants.opPackingRoute}?selected=${response.operationId}',
          );
        } else if (mounted) {
          context.go(Constants.opPackingRoute);
        }
      } else {
        final errorMessage = response.messages?.isNotEmpty == true
            ? response.messages!.first
            : 'The packing operation could not be completed. Check your inputs and try again. '
              'If the problem persists, contact your system administrator.';
        PackingSnackbar.showError(context, errorMessage);
      }
    } on ApiException catch (e) {
      PackingSnackbar.showError(context, e.getUserFriendlyMessage());
    } catch (e) {
      PackingSnackbar.showError(
        context,
        'An unexpected error occurred while submitting the packing operation. '
        'Please try again. If the problem continues, contact support.',
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onContainerScanResult(ScanResult result) {
    if (!result.isValid) return;

    final barcode = result.data;
    final parsed = GS1BarcodeParser.parseGS1Barcode(barcode);
    final ssccError = AggregationEventFormValidators.validateSsccInput(
      parsed['SSCC'] ?? barcode,
    );
    if (ssccError != null) {
      PackingSnackbar.showError(
        context,
        'That barcode is not a valid container label (SSCC). '
        'Make sure you are scanning the outer carton or pallet label — not a product label.',
      );
      return;
    }

    final containerId = parsed['SSCC'] ?? barcode;
    setState(() => _parentContainerId = containerId);
    PackingSnackbar.showSuccess(context, 'Container ready — SSCC: $containerId');
  }

  void _onItemScanResult(ScanResult result) {
    if (!result.isValid) return;

    final barcode = result.data;
    final duplicate =
        OperationEpcScanValidator.checkDuplicate(barcode, _scannedEPCs);
    if (duplicate != null) {
      PackingSnackbar.showError(
        context,
        'This item is already in the list. Each product serial can only appear once in a packing operation.',
      );
      return;
    }

    final epcError =
        AggregationEventFormValidators.validateChildEpcEntry(barcode);
    if (epcError != null) {
      PackingSnackbar.showError(
        context,
        'This barcode is not a valid product serial (EPC). '
        'Scan a product label that includes both a GTIN (AI 01) and a serial number (AI 21).',
      );
      return;
    }

    setState(() => _scannedEPCs.add(barcode));
    PackingSnackbar.showSuccess(context, 'Item added ✓');
  }

  void _addManualContainer() {
    final barcode = _containerManualEntryController.text.trim();
    if (barcode.isEmpty) {
      PackingSnackbar.showError(context, 'Please type or paste an SSCC before tapping Add.');
      return;
    }

    final parsed = GS1BarcodeParser.parseGS1Barcode(barcode);
    final ssccToValidate = parsed['SSCC'] ?? barcode;
    final ssccError =
        AggregationEventFormValidators.validateSsccInput(ssccToValidate);
    if (ssccError != null) {
      PackingSnackbar.showError(
        context,
        'The value entered is not a valid SSCC. '
        'An SSCC must be exactly 18 digits. Check the number and try again.',
      );
      return;
    }

    setState(() => _parentContainerId = parsed['SSCC'] ?? barcode);
    _containerManualEntryController.clear();
  }

  void _addManualItem() {
    final barcode = _manualEntryController.text.trim();
    if (barcode.isEmpty) {
      PackingSnackbar.showError(context, 'Please type or paste a product barcode before tapping Add.');
      return;
    }

    final duplicate =
        OperationEpcScanValidator.checkDuplicate(barcode, _scannedEPCs);
    if (duplicate != null) {
      PackingSnackbar.showError(
        context,
        'This item is already in the list. Each product serial can only appear once in a packing operation.',
      );
      return;
    }

    final epcError =
        AggregationEventFormValidators.validateChildEpcEntry(barcode);
    if (epcError != null) {
      PackingSnackbar.showError(
        context,
        'This barcode is not a recognised product serial format. '
        'It must contain a GTIN (AI 01) and a serial number (AI 21), or be a valid EPC URI.',
      );
      return;
    }

    setState(() => _scannedEPCs.add(barcode));
    _manualEntryController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return AppLayoutBuilder(
      builder: (context, layout) {
        if (layout.isDesktopUp) {
          return PackingOperationDesktopLayout(
            isLoading: _isLoading,
            step1Complete: _validateStep0Silent(),
            step2Complete: _scannedEPCs.isNotEmpty,
            detailsStep: _referenceDetailsStep(
              embeddedInPanel: true,
              showContainerSection: false,
            ),
            itemsStep: PackingOperationItemsStepContent(
              containerStep: _referenceDetailsStep(
                embeddedInPanel: true,
                showReferenceSection: false,
                showLocationSection: false,
                showProductionSection: false,
              ),
              itemsStep: _itemScanStep(embeddedInPanel: true, fillHeight: false),
            ),
            reviewStep: _reviewStep(embeddedInPanel: true),
            onSubmit: _submitPackingOperation,
          );
        }

        return PackingOperationMobileLayout(
          isLoading: _isLoading,
          currentStep: _currentStep,
          steps: _wizardSteps,
          pageController: _pageController,
          onPageChanged: (page) => setState(() => _currentStep = page),
          onPrevious: _previousStep,
          onNext: _nextStep,
          onSubmit: _submitPackingOperation,
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
