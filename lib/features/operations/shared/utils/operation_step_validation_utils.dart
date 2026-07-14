import 'package:traqtrace_app/core/utils/gs1/gs1_canonical_identifier.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/operations/shared/utils/gln_check_digit_validator.dart';

abstract final class OperationStepValidationUtils {
  static String? validateSerializedItemsStep(List<String> scannedEpcs) {
    if (scannedEpcs.isEmpty) {
      return 'Scan at least one serialized SGTIN or SSCC before continuing.';
    }
    for (final epc in scannedEpcs) {
      if (Gs1CanonicalIdentifier.isLgtin(epc)) {
        return '"$epc" is a lot-based GTIN (lgtin). '
            'DSCSA requires serialized SGTINs '
            '(https://id.gs1.org/01/…/21/…). '
            'Lot-level EPCs are not permitted.';
      }
      if (Gs1CanonicalIdentifier.isClassGtin(epc)) {
        return '"$epc" is an EPC pattern type used for queries — not valid in an event. '
            'Scan a serialized SGTIN or SSCC instead.';
      }
      if (!Gs1CanonicalIdentifier.isSerializedInstance(epc)) {
        return '"$epc" is not a valid GS1 EPC URI. '
            'Expected: https://id.gs1.org/01/…/21/… or https://id.gs1.org/00/… '
            '(URN forms are also accepted).';
      }
    }
    if (scannedEpcs.toSet().length != scannedEpcs.length) {
      return 'Duplicate EPCs found. Each item can only appear once.';
    }
    return null;
  }

  static String? validateCancelItemsStep(
    List<String> scannedEpcs, {
    required String emptyMessage,
  }) {
    if (scannedEpcs.isEmpty) return emptyMessage;
    for (final epc in scannedEpcs) {
      if (Gs1CanonicalIdentifier.isLgtin(epc)) {
        return '"$epc" is a lot-based GTIN. '
            'Only serialized SGTINs and SSCCs are valid for cancel operations under DSCSA/FMD.';
      }
    }
    if (scannedEpcs.toSet().length != scannedEpcs.length) {
      return 'Duplicate EPCs found. Each item can only appear once per cancel event.';
    }
    return null;
  }

  static String? validateReferenceGlnStep({
    required GLN? sourceGln,
    required GLN? destinationGln,
    required String sourceMissingMessage,
    required String destinationMissingMessage,
    required String sameLocationMessage,
    required String sourceInvalidMessagePrefix,
    required String destinationInvalidMessagePrefix,
    String sourceInvalidMessageSuffix = '',
    String destinationInvalidMessageSuffix = '',
  }) {
    if (sourceGln == null) return sourceMissingMessage;
    if (destinationGln == null) return destinationMissingMessage;
    if (sourceGln.glnCode == destinationGln.glnCode) return sameLocationMessage;

    if (!GlnCheckDigitValidator.isValid(sourceGln.glnCode)) {
      return '$sourceInvalidMessagePrefix"${sourceGln.glnCode}"$sourceInvalidMessageSuffix';
    }
    if (!GlnCheckDigitValidator.isValid(destinationGln.glnCode)) {
      return '$destinationInvalidMessagePrefix"${destinationGln.glnCode}"$destinationInvalidMessageSuffix';
    }
    return null;
  }
}
