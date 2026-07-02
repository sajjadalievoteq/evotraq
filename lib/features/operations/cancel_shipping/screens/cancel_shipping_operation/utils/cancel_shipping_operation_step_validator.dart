import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/operations/shared/utils/gln_check_digit_validator.dart';

class CancelShippingOperationStepValidator {
  CancelShippingOperationStepValidator._();

  static String? validateReferenceStep({
    required GLN? sourceGln,
    required GLN? destinationGln,
    required String cancelReason,
  }) {
    if (sourceGln == null) {
      return 'Please select the original Ship-From location (required for GS1 cancel shipping).';
    }
    if (destinationGln == null) {
      return 'Please select the original Ship-To location (required for DSCSA audit trail).';
    }
    if (sourceGln.glnCode == destinationGln.glnCode) {
      return 'Ship-From and Ship-To locations cannot be the same.';
    }
    if (!GlnCheckDigitValidator.isValid(sourceGln.glnCode)) {
      return 'Ship-From GLN "${sourceGln.glnCode}" is not a valid GS1 GLN.';
    }
    if (!GlnCheckDigitValidator.isValid(destinationGln.glnCode)) {
      return 'Ship-To GLN "${destinationGln.glnCode}" is not a valid GS1 GLN.';
    }
    if (cancelReason.trim().isEmpty) {
      return 'A cancellation reason is required (DSCSA §582 / FMD Art. 22).';
    }
    return null;
  }

  static String? validateItemsStep(List<String> scannedEpcs) {
    if (scannedEpcs.isEmpty) {
      return 'Scan at least one SGTIN or SSCC from the original shipment.';
    }
    for (final epc in scannedEpcs) {
      if (epc.startsWith('urn:epc:class:lgtin:')) {
        return '"$epc" is a lot-based GTIN. '
            'Only serialized SGTINs and SSCCs are valid for cancel shipping under DSCSA/FMD.';
      }
    }
    if (scannedEpcs.toSet().length != scannedEpcs.length) {
      return 'Duplicate EPCs found. Each item can only appear once per cancel event.';
    }
    return null;
  }
}
