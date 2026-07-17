import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/operations/shared/utils/gln_check_digit_validator.dart';
import 'package:traqtrace_app/features/operations/shared/utils/operation_step_validation_utils.dart';

class ReturnShippingOperationStepValidator {
  ReturnShippingOperationStepValidator._();

  static String? validateReferenceStep({
    required GLN? sourceGln,
  }) {
    if (sourceGln == null) {
      return 'Please select Return From Location (source GLN).';
    }
    if (!GlnCheckDigitValidator.isValid(sourceGln.glnCode)) {
      return 'Return From GLN "${sourceGln.glnCode}" is not a valid GS1 GLN '
          '(must be 13 digits with a valid check digit).';
    }
    return null;
  }

  static String? validateItemsStep(List<String> scannedEpcs) {
    return OperationStepValidationUtils.validateSerializedItemsStep(scannedEpcs);
  }
}
