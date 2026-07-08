import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/data/models/operations/hierarchy/hierarchy_node.dart';
import 'package:traqtrace_app/features/operations/unpacking/utils/unpacking_scope.dart';

class UnpackingOperationStepValidator {
  UnpackingOperationStepValidator._();

  static String? validateReferenceStep({
    required GLN? unpackingLocationGln,
  }) {
    if (unpackingLocationGln == null) {
      return 'Please select the Unpacking Location — search for the GLN of the facility where unpacking is taking place.';
    }
    return null;
  }

  static String? validateContainerStep(String? parentContainerId) {
    if (parentContainerId == null || parentContainerId.isEmpty) {
      return 'No container scanned yet. Scan or enter the SSCC barcode on the carton or pallet you are unpacking.';
    }
    if (!parentContainerId.startsWith('urn:epc:id:sscc:')) {
      return 'Container ID must be a valid SSCC EPC URI (urn:epc:id:sscc:...). '
          'Use the scanner or enter the full 18-digit SSCC number.';
    }
    return null;
  }

  static String? validateItemsStep({
    required Set<String> selectedEpcs,
    required UnpackingScope scope,
    required List<HierarchyNode> containerContents,
  }) {
    if (containerContents.isEmpty) {
      return 'This container has no packed items to unpack.';
    }
    if (selectedEpcs.isEmpty) {
      if (scope == UnpackingScope.wholeContainer) {
        return 'No items found in the container. Reload contents or choose a different container.';
      }
      return 'Select at least one item from the table or scan a barcode to unpack.';
    }
    return null;
  }
}
