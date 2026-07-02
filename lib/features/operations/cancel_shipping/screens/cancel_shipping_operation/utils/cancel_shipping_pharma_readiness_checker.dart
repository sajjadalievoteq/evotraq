import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/operations/shared/utils/gln_check_digit_validator.dart';

class CancelShippingPharmaReadinessChecker {
  CancelShippingPharmaReadinessChecker._();

  static List<String> findIssues({
    required GLN? sourceGln,
    required GLN? destinationGln,
    required List<String> epcs,
    required String cancelReason,
    required String? originalShippingReference,
  }) {
    final issues = <String>[];

    if (sourceGln == null) {
      issues.add('Original Ship-From GLN is required. '
          'The cancel shipping event must identify the shipper\'s location (CBV 2.0 §8.5).');
    } else if (!GlnCheckDigitValidator.isValid(sourceGln.glnCode)) {
      issues.add('Ship-From GLN "${sourceGln.glnCode}" has an invalid GS1 check digit.');
    }

    if (destinationGln == null) {
      issues.add('Original Ship-To GLN is required. '
          'The originally intended recipient must be recorded for the DSCSA audit trail.');
    } else if (!GlnCheckDigitValidator.isValid(destinationGln.glnCode)) {
      issues.add('Ship-To GLN "${destinationGln.glnCode}" has an invalid GS1 check digit.');
    }

    if (sourceGln != null &&
        destinationGln != null &&
        sourceGln.glnCode == destinationGln.glnCode) {
      issues.add('Ship-From and Ship-To GLNs are identical. '
          'A cancel shipping event requires two distinct trading-partner locations.');
    }

    if (epcs.isEmpty) {
      issues.add('No EPCs captured. At least one serialized SGTIN or SSCC is required.');
    }

    for (final epc in epcs) {
      if (epc.startsWith('urn:epc:class:lgtin:')) {
        issues.add('"$epc" is a lot-based GTIN (lgtin). '
            'Only serialized SGTINs (urn:epc:id:sgtin:…) and SSCCs are valid for cancel shipping '
            'under DSCSA and EU FMD.');
      } else if (!epc.startsWith('urn:epc:id:sgtin:') &&
          !epc.startsWith('urn:epc:id:sscc:')) {
        issues.add('"$epc" is not a valid GS1 EPC URI for a cancel shipping event.');
      }
    }

    if (epcs.toSet().length != epcs.length) {
      issues.add('Duplicate EPCs detected. Each item may only appear once per cancel event.');
    }

    if (cancelReason.trim().isEmpty) {
      issues.add('A cancellation reason is required (DSCSA §582 / FMD Art. 22).');
    }

    if (originalShippingReference == null ||
        originalShippingReference.trim().isEmpty) {
      issues.add('Original Shipping Reference (GINC) is missing. '
          'DSCSA requires the original Transaction Information number to be referenced '
          'in the bizTransactionList of a cancel shipping event. '
          'Enter the GINC from the original shipment, or confirm this cancellation is not '
          'subject to DSCSA before proceeding without it.');
    }

    return issues;
  }
}
