import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/operations/shared/utils/operation_step_validation_utils.dart';

class CancelReceivingOperationStepValidator {
  CancelReceivingOperationStepValidator._();

  static String? validateReferenceStep({
    required GLN? sourceGln,
    required GLN? receivingGln,
    required String cancelReason,
  }) {
    final locationError = OperationStepValidationUtils.validateReferenceGlnStep(
      sourceGln: sourceGln,
      destinationGln: receivingGln,
      sourceMissingMessage:
          'Please select the original sender (Ship-From GLN) (required for GS1 cancel receiving).',
      destinationMissingMessage:
          'Please select the receive-at location (your site) (required for DSCSA audit trail).',
      sameLocationMessage:
          'Sender (Ship-From) and Receive-At locations cannot be the same.',
      sourceInvalidMessagePrefix: 'Sender (Ship-From) GLN ',
      destinationInvalidMessagePrefix: 'Receive-At GLN ',
      sourceInvalidMessageSuffix: ' is not a valid GS1 GLN.',
      destinationInvalidMessageSuffix: ' is not a valid GS1 GLN.',
    );
    if (locationError != null) return locationError;
    if (cancelReason.trim().isEmpty) {
      return 'A cancellation reason is required (DSCSA §582 / FMD Art. 22).';
    }
    return null;
  }

  static String? validateItemsStep(List<String> scannedEpcs) {
    return OperationStepValidationUtils.validateCancelItemsStep(
      scannedEpcs,
      emptyMessage:
          'Scan at least one SGTIN or SSCC from the erroneous receiving event.',
    );
  }
}
