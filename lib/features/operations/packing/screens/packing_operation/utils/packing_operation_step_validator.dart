import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/operations/packing/utils/packing_step_validation_messages.dart';

class PackingOperationStepValidator {
  PackingOperationStepValidator._();

  static String? validateReferenceStep({
    required GLN? packingLocationGln,
  }) {
    if (packingLocationGln == null) {
      return PackingStepValidationMessages.packingLocationRequired;
    }
    return null;
  }

  static String? validateContainerStep(String? parentContainerId) {
    if (parentContainerId == null || parentContainerId.isEmpty) {
      return PackingStepValidationMessages.parentContainerRequired;
    }
    return null;
  }

  static String? validateItemsStep(List<String> scannedEpcs) {
    if (scannedEpcs.isEmpty) {
      return PackingStepValidationMessages.itemsRequired;
    }
    return null;
  }
}
