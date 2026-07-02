import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/operations/shared/utils/gln_check_digit_validator.dart';

class CancelReceivingOperationStepValidator {
  CancelReceivingOperationStepValidator._();

  static String? validateReferenceStep({
    required GLN? sourceGln,
    required GLN? receivingGln,
    required String cancelReason,
  }) {
    if (sourceGln == null) {
      return 'Please select the original sender (Ship-From GLN) (required for GS1 cancel receiving).';
    }
    if (receivingGln == null) {
      return 'Please select the receive-at location (your site) (required for DSCSA audit trail).';
    }
    if (sourceGln.glnCode == receivingGln.glnCode) {
      return 'Sender (Ship-From) and Receive-At locations cannot be the same.';
    }
    if (!GlnCheckDigitValidator.isValid(sourceGln.glnCode)) {
      return 'Sender (Ship-From) GLN "${sourceGln.glnCode}" is not a valid GS1 GLN.';
    }
    if (!GlnCheckDigitValidator.isValid(receivingGln.glnCode)) {
      return 'Receive-At GLN "${receivingGln.glnCode}" is not a valid GS1 GLN.';
    }
    if (cancelReason.trim().isEmpty) {
      return 'A cancellation reason is required (DSCSA §582 / FMD Art. 22).';
    }
    return null;
  }

  static String? validateItemsStep(List<String> scannedEpcs) {
    if (scannedEpcs.isEmpty) {
      return 'Scan at least one SGTIN or SSCC from the erroneous receiving event.';
    }
    for (final epc in scannedEpcs) {
      if (epc.startsWith('urn:epc:class:lgtin:')) {
        return '"$epc" is a lot-based GTIN. '
            'Only serialized SGTINs and SSCCs are valid for cancel receiving under DSCSA/FMD.';
      }
    }
    if (scannedEpcs.toSet().length != scannedEpcs.length) {
      return 'Duplicate EPCs found. Each item can only appear once per cancel event.';
    }
    return null;
  }
}
