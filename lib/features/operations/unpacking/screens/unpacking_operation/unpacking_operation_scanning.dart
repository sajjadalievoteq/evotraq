import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/models/scan_result.dart';
import 'package:traqtrace_app/core/utils/gs1/gs1_converter.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_presenter.dart';
import 'package:traqtrace_app/core/widgets/epc_input_widget/epc_parser.dart';
import 'package:traqtrace_app/core/widgets/epc_input_widget/epc_types.dart';
import 'package:traqtrace_app/data/services/hierarchy/hierarchy_service.dart';
import 'package:traqtrace_app/features/epcis/aggregation_events/screens/aggregation_event_form/utils/aggregation_event_form_validators.dart';
import 'package:traqtrace_app/features/operations/shared/utils/operation_parent_container_epc.dart';
import 'package:traqtrace_app/features/operations/unpacking/screens/unpacking_operation/unpacking_operation_screen.dart';
import 'package:traqtrace_app/features/operations/unpacking/screens/unpacking_operation/utils/unpacking_container_contents_loader.dart';
import 'package:traqtrace_app/features/operations/unpacking/utils/unpacking_scope.dart';
import 'package:traqtrace_app/features/shared/hierarchy/utils/hierarchy_epc_utils.dart';

extension UnpackingOperationScanning on UnpackingOperationScreenState {
  void onContainerScanResult(ScanResult result) {
    if (!result.isValid) return;

    try {
      final parsed = parseToEPC(result.data);
      if (parsed.type != EPCType.sscc && parsed.type != EPCType.sgtin) {
        context.showError(
          'Parent container must be an SSCC (carton/pallet) or SGTIN (product serial).',
        );
        return;
      }
      onManualContainerAdded(parsed);
      final label = parsed.type == EPCType.sscc
          ? 'SSCC: ${parsed.sscc ?? parsed.raw}'
          : 'SGTIN: ${parsed.epc}';
      context.showSuccess('Container ready — $label');
    } on EPCParseException catch (e) {
      context.showError(e.message);
    }
  }

  Future<void> loadContainerContents() async {
    if (parentContainerId == null || parentContainerId!.isEmpty) return;

    setState(() {
      isLoadingContents = true;
      contentsLoadError = null;
    });

    try {
      final contents =
          await UnpackingContainerContentsLoader.loadDirectChildren(
            getIt<HierarchyService>(),
            parentContainerId!,
          );
      if (!mounted) return;
      setState(() {
        containerContents = contents;
        isLoadingContents = false;
        _applyScopeSelection();
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        isLoadingContents = false;
        contentsLoadError =
            'Could not load container contents. Check your connection and try again.';
        containerContents = [];
        selectedEpcs.clear();
      });
    }
  }

  void onUnpackingScopeChanged(UnpackingScope scope) {
    setState(() {
      unpackingScope = scope;
      _applyScopeSelection();
    });
  }

  void _applyScopeSelection() {
    if (unpackingScope == UnpackingScope.wholeContainer) {
      selectedEpcs
        ..clear()
        ..addAll(containerContents.map((node) => node.epc));
    } else {
      selectedEpcs.removeWhere(
        (epc) => !containerContents.any((node) => node.epc == epc),
      );
    }
  }

  void onItemSelectionChanged(String epc, bool selected) {
    setState(() {
      if (unpackingScope == UnpackingScope.wholeContainer) {
        unpackingScope = UnpackingScope.partial;
      }
      if (selected) {
        selectedEpcs.add(epc);
      } else {
        selectedEpcs.remove(epc);
      }
    });
  }

  String? _resolveContainerMemberEpc(String barcode) {
    final uri = Gs1Converter.barcodeToEpc(barcode) ?? barcode;
    final normalized = normalizeHierarchyEpc(uri);
    for (final node in containerContents) {
      if (normalizeHierarchyEpc(node.epc) == normalized) {
        return node.epc;
      }
    }
    return null;
  }

  void onItemAdded(EPCParseResult result) {
    _tryAddItemByBarcode(result.epc);
  }

  void onManualContainerAdded(EPCParseResult result) {
    final validationError = validateParentContainerEpc(result);
    if (validationError != null) {
      context.showError(validationError);
      return;
    }

    setState(() => parentContainerId = parentContainerIdFromParsed(result));
    loadContainerContents();
  }

  void _tryAddItemByBarcode(String barcode) {
    final memberEpc = _resolveContainerMemberEpc(barcode);
    if (memberEpc == null) {
      context.showError(
        'This item is not packed in the selected container. '
        'Choose it from the table above or enter an EPC that belongs to '
        'container $parentContainerId.',
      );
      return;
    }

    if (selectedEpcs.contains(memberEpc)) {
      context.showError('This item is already selected for unpacking.');
      return;
    }

    final epcError = AggregationEventFormValidators.validateChildEpcEntry(
      barcode,
    );
    if (epcError != null) {
      context.showError(
        'This barcode is not a valid child EPC. '
        'Scan a product serial (SGTIN), lot-based GTIN, or nested SSCC label.',
      );
      return;
    }

    setState(() {
      if (unpackingScope == UnpackingScope.wholeContainer) {
        unpackingScope = UnpackingScope.partial;
      }
      selectedEpcs.add(memberEpc);
    });
    context.showSuccess('Item added ✓');
  }
}
