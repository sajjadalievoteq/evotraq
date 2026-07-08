import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/operations/shared/utils/operation_step_validation_utils.dart';

class ShippingOperationStepValidator {
  ShippingOperationStepValidator._();

  static String? validateReferenceStep({
    required GLN? sourceGln,
    required GLN? destinationGln,
  }) {
    return OperationStepValidationUtils.validateReferenceGlnStep(
      sourceGln: sourceGln,
      destinationGln: destinationGln,
      sourceMissingMessage: 'Please select Ship From Location (source GLN).',
      destinationMissingMessage:
          'Please select Ship To Location (destination GLN).',
      sameLocationMessage: 'Ship From and Ship To locations cannot be the same.',
      sourceInvalidMessagePrefix: 'Ship From GLN ',
      destinationInvalidMessagePrefix: 'Ship To GLN ',
      sourceInvalidMessageSuffix:
          ' is not a valid GS1 GLN (must be 13 digits with a valid check digit).',
      destinationInvalidMessageSuffix:
          ' is not a valid GS1 GLN (must be 13 digits with a valid check digit).',
    );
  }

  static String? validateItemsStep(List<String> scannedEpcs) {
    return OperationStepValidationUtils.validateSerializedItemsStep(scannedEpcs);
  }
}

