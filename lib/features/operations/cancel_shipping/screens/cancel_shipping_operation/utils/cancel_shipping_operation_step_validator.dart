import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/operations/shared/utils/operation_step_validation_utils.dart';

class CancelShippingOperationStepValidator {
  CancelShippingOperationStepValidator._();

  static String? validateReferenceStep({
    required GLN? sourceGln,
    required GLN? destinationGln,
    required String cancelReason,
  }) {
    final locationError = OperationStepValidationUtils.validateReferenceGlnStep(
      sourceGln: sourceGln,
      destinationGln: destinationGln,
      sourceMissingMessage:
          'Please select the original Ship-From location (required for GS1 cancel shipping).',
      destinationMissingMessage:
          'Please select the original Ship-To location (required for DSCSA audit trail).',
      sameLocationMessage: 'Ship-From and Ship-To locations cannot be the same.',
      sourceInvalidMessagePrefix: 'Ship-From GLN ',
      destinationInvalidMessagePrefix: 'Ship-To GLN ',
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
      emptyMessage: 'Scan at least one SGTIN or SSCC from the original shipment.',
    );
  }
}
