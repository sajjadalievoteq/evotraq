import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/layout/layout_manager.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/models/scan_result.dart';
import 'package:traqtrace_app/core/widgets/operation_wizard/operation_step_config.dart';
import 'package:traqtrace_app/data/models/operations/unpacking/unpacking_request_model.dart';
import 'package:traqtrace_app/data/models/operations/unpacking/unpacking_status.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/data/services/operations/unpacking/unpacking_operation_service.dart';
import 'package:traqtrace_app/data/services/gs1/gln/gln_service.dart';
import 'package:traqtrace_app/data/services/gs1/serialization/sgtin/sgtin_service.dart';
import 'package:traqtrace_app/data/services/gs1/serialization/sscc/sscc_service.dart';
import 'package:traqtrace_app/features/barcode/services/epc_uri_converter.dart';
import 'package:traqtrace_app/features/barcode/services/gs1_barcode_parser.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/screens/aggregation_event_form/utils/aggregation_event_form_validators.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/screens/aggregation_event_form/utils/aggregation_pharma_readiness_checker.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/screens/aggregation_event_form/widgets/aggregation_pharma_issues_dialog.dart';
import 'package:traqtrace_app/features/operations/unpacking/screens/unpacking_operation/utils/unpacking_operation_step_validator.dart';
import 'package:traqtrace_app/features/operations/unpacking/screens/unpacking_operation/widgets/unpacking_item_scan_step.dart';
import 'package:traqtrace_app/features/operations/unpacking/screens/unpacking_operation/widgets/unpacking_operation_desktop_layout.dart';
import 'package:traqtrace_app/features/operations/unpacking/screens/unpacking_operation/widgets/unpacking_operation_items_step_content.dart';
import 'package:traqtrace_app/features/operations/unpacking/screens/unpacking_operation/widgets/unpacking_operation_mobile_layout.dart';
import 'package:traqtrace_app/features/operations/unpacking/screens/unpacking_operation/widgets/unpacking_reference_details_step.dart';
import 'package:traqtrace_app/features/operations/unpacking/screens/unpacking_operation/widgets/unpacking_review_step.dart';
import 'package:traqtrace_app/features/operations/unpacking/utils/unpacking_scanning_mode.dart';
import 'package:traqtrace_app/features/operations/unpacking/utils/unpacking_snackbar.dart';
import 'package:traqtrace_app/features/operations/shared/operation_epc_scan_validator.dart';

/// Multi-step unpacking operations screen.
class UnpackingOperationScreen extends StatefulWidget {
  const UnpackingOperationScreen({super.key});

  @override
  State<UnpackingOperationScreen> createState() => _UnpackingOperationScreenState();
}

class _UnpackingOperationScreenState extends State<UnpackingOperationScreen> {
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

  GLN? _unpackingLocationGLN;
  String? _unpackingLocationGLNError;
  String? _parentContainerId;
  final List<String> _scannedEPCs = [];
  bool _isLoading = false;

  UnpackingScanningMode _scanningMode = UnpackingScanningMode.scanner;
  UnpackingScanningMode _containerScanningMode = UnpackingScanningMode.scanner;

  AggregationPharmaReadinessChecker? _pharmaReadinessChecker;

  bool _validateStep0Silent() =>
      _referenceController.text.trim().isNotEmpty && _unpackingLocationGLN != null;

  UnpackingReferenceDetailsStep _referenceDetailsStep({
    bool embeddedInPanel = false,
    bool showReferenceSection = true,
    bool showLocationSection = true,
    bool showContainerSection = true,
    bool showProductionSection = true,
  }) {
    return UnpackingReferenceDetailsStep(
      referenceController: _referenceController,
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

  UnpackingItemScanStep _itemScanStep({
    bool embeddedInPanel = false,
    bool? fillHeight,
  }) {
    return UnpackingItemScanStep(
      parentContainerId: _parentContainerId,
      unpackingReference: _referenceController.text,
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

  UnpackingReviewStep _reviewStep({bool embeddedInPanel = false}) {
    return UnpackingReviewStep(
      unpackingReference: _referenceController.text,
      unpackingLocationGln: _unpackingLocationGLN,
      workOrder: _workOrderController.text,
      batchNumber: _batchNumberController.text,
      productionOrder: _productionOrderController.text,
      parentContainerId: _parentContainerId,
      scannedEpcs: _scannedEPCs,
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
    setState(() => _unpackingLocationGLNError = null);

    switch (_currentStep) {
      case 0:
        final referenceError = UnpackingOperationStepValidator.validateReferenceStep(
          unpackingReference: _referenceController.text,
          unpackingLocationGln: _unpackingLocationGLN,
        );
        if (referenceError != null) {
          if (referenceError.contains('GLN')) {
            setState(() => _unpackingLocationGLNError = referenceError);
          } else {
            UnpackingSnackbar.showError(context, referenceError);
          }
          return false;
        }
        final containerError =
            UnpackingOperationStepValidator.validateContainerStep(_parentContainerId);
        if (containerError != null) {
          UnpackingSnackbar.showError(context, containerError);
          return false;
        }
        return true;
      case 1:
        final itemsError =
            UnpackingOperationStepValidator.validateItemsStep(_scannedEPCs);
        if (itemsError != null) {
          UnpackingSnackbar.showError(context, itemsError);
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
          EPCURIConverter.convertBatchToEPCUri(_scannedEPCs);
      final epcUris = List<String>.from(conversionResult['successful'] ?? []);
      final failedConversions =
          List<String>.from(conversionResult['failed'] ?? []);

      if (failedConversions.isNotEmpty) {
        UnpackingSnackbar.showError(
          context,
          '${failedConversions.length} item(s) could not be processed — their barcodes are not in a valid GS1 format. '
          'Remove them from the list, check the labels, and re-scan:\n${failedConversions.join('\n')}',
        );
        setState(() => _isLoading = false);
        return;
      }

      if (epcUris.isEmpty) {
        UnpackingSnackbar.showError(
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
        unpackingReference: _referenceController.text.trim(),
        parentContainerId: containerEpc,
        childEpcs: epcUris,
        unpackingLocationGLN: _unpackingLocationGLN!.glnCode,
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
          await unpackingService.createUnpackingOperation(unpackingRequest);

      if (response.isSuccessOrPartial) {
        if (response.status == UnpackingStatus.partialSuccess) {
          UnpackingSnackbar.showSuccess(
            context,
            'Unpacking submitted with warnings — some items were not processed. '
            'Open the operation record to see which items need attention.',
          );
        } else {
          UnpackingSnackbar.showSuccess(
            context,
            'Unpacking operation completed successfully.',
          );
        }
        if (mounted) {
          if (!context.isDesktop && response.operationId != null) {
            context.go('${Constants.opUnpackingRoute}/${response.operationId}');
          } else {
            context.go(Constants.opUnpackingRoute);
          }
        }
      } else {
        final errorMessage = response.messages?.isNotEmpty == true
            ? response.messages!.first
            : 'The unpacking operation could not be completed. Check your inputs and try again. '
              'If the problem persists, contact your system administrator.';
        UnpackingSnackbar.showError(context, errorMessage);
      }
    } on ApiException catch (e) {
      UnpackingSnackbar.showError(context, e.getUserFriendlyMessage());
    } catch (e) {
      UnpackingSnackbar.showError(
        context,
        'An unexpected error occurred while submitting the unpacking operation. '
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
      UnpackingSnackbar.showError(
        context,
        'That barcode is not a valid container label (SSCC). '
        'Make sure you are scanning the outer carton or pallet label — not a product label.',
      );
      return;
    }

    final containerId = parsed['SSCC'] ?? barcode;
    setState(() => _parentContainerId = containerId);
    UnpackingSnackbar.showSuccess(context, 'Container ready — SSCC: $containerId');
  }

  void _onItemScanResult(ScanResult result) {
    if (!result.isValid) return;

    final barcode = result.data;
    final duplicate =
        OperationEpcScanValidator.checkDuplicate(barcode, _scannedEPCs);
    if (duplicate != null) {
      UnpackingSnackbar.showError(
        context,
        'This item is already in the list. Each product serial can only appear once in an unpacking operation.',
      );
      return;
    }

    final epcError =
        AggregationEventFormValidators.validateChildEpcEntry(barcode);
    if (epcError != null) {
      UnpackingSnackbar.showError(
        context,
        'This barcode is not a valid product serial (EPC). '
        'Scan a product label that includes both a GTIN (AI 01) and a serial number (AI 21).',
      );
      return;
    }

    setState(() => _scannedEPCs.add(barcode));
    UnpackingSnackbar.showSuccess(context, 'Item added ✓');
  }

  void _addManualContainer() {
    final barcode = _containerManualEntryController.text.trim();
    if (barcode.isEmpty) {
      UnpackingSnackbar.showError(context, 'Please type or paste an SSCC before tapping Add.');
      return;
    }

    final parsed = GS1BarcodeParser.parseGS1Barcode(barcode);
    final ssccToValidate = parsed['SSCC'] ?? barcode;
    final ssccError =
        AggregationEventFormValidators.validateSsccInput(ssccToValidate);
    if (ssccError != null) {
      UnpackingSnackbar.showError(
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
      UnpackingSnackbar.showError(context, 'Please type or paste a product barcode before tapping Add.');
      return;
    }

    final duplicate =
        OperationEpcScanValidator.checkDuplicate(barcode, _scannedEPCs);
    if (duplicate != null) {
      UnpackingSnackbar.showError(
        context,
        'This item is already in the list. Each product serial can only appear once in an unpacking operation.',
      );
      return;
    }

    final epcError =
        AggregationEventFormValidators.validateChildEpcEntry(barcode);
    if (epcError != null) {
      UnpackingSnackbar.showError(
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
          return UnpackingOperationDesktopLayout(
            isLoading: _isLoading,
            step1Complete: _validateStep0Silent(),
            step2Complete: _scannedEPCs.isNotEmpty,
            detailsStep: _referenceDetailsStep(
              embeddedInPanel: true,
              showContainerSection: false,
            ),
            itemsStep: UnpackingOperationItemsStepContent(
              containerStep: _referenceDetailsStep(
                embeddedInPanel: true,
                showReferenceSection: false,
                showLocationSection: false,
                showProductionSection: false,
              ),
              itemsStep: _itemScanStep(embeddedInPanel: true, fillHeight: false),
            ),
            reviewStep: _reviewStep(embeddedInPanel: true),
            onSubmit: _submitUnpackingOperation,
          );
        }

        return UnpackingOperationMobileLayout(
          isLoading: _isLoading,
          currentStep: _currentStep,
          steps: _wizardSteps,
          pageController: _pageController,
          onPageChanged: (page) => setState(() => _currentStep = page),
          onPrevious: _previousStep,
          onNext: _nextStep,
          onSubmit: _submitUnpackingOperation,
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
