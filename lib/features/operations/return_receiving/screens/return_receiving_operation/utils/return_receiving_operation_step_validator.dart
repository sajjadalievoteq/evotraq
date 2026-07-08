import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/operations/shared/utils/operation_step_validation_utils.dart';

class ReturnReceivingOperationStepValidator {
  ReturnReceivingOperationStepValidator._();

  static String? validateReferenceStep({
    required GLN? sourceGln,
    required GLN? receivingGln,
  }) {
    return OperationStepValidationUtils.validateReferenceGlnStep(
      sourceGln: sourceGln,
      destinationGln: receivingGln,
      sourceMissingMessage:
          'Please select Returned From Location (source GLN).',
      destinationMissingMessage: 'Please select Receiving Location.',
      sameLocationMessage:
          'Returned From and Receiving locations cannot be the same.',
      sourceInvalidMessagePrefix: 'Source GLN ',
      destinationInvalidMessagePrefix: 'Receiving GLN ',
      sourceInvalidMessageSuffix: ' is not a valid GS1 GLN.',
      destinationInvalidMessageSuffix: ' is not a valid GS1 GLN.',
    );
  }

  static String? validateItemsStep(List<String> scannedEpcs) {
    return OperationStepValidationUtils.validateSerializedItemsStep(scannedEpcs);
  }
}

