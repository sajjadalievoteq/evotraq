import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/operations/shared/utils/operation_pharma_readiness_checker.dart';

class CancelShippingPharmaReadinessChecker {
  CancelShippingPharmaReadinessChecker._();

  static List<String> findIssues({
    required GLN? sourceGln,
    required GLN? destinationGln,
    required List<String> epcs,
    required String cancelReason,
    required String? originalShippingReference,
  }) {
    final issues = OperationPharmaReadinessChecker.twoGlnIssues(
      sourceGln: sourceGln,
      destinationGln: destinationGln,
      epcs: epcs,
      sourceLabel: 'Ship-From GLN',
      destinationLabel: 'Ship-To GLN',
      sourceRequiredMessage:
          'Original Ship-From GLN is required. '
          'The cancel shipping event must identify the shipper\'s location (CBV 2.0 §8.5).',
      destinationRequiredMessage:
          'Original Ship-To GLN is required. '
          'The originally intended recipient must be recorded for the DSCSA audit trail.',
      sameLocationMessage:
          'Ship-From and Ship-To GLNs are identical. '
          'A cancel shipping event requires two distinct trading-partner locations.',
      emptyEpcsMessage:
          'No EPCs captured. At least one serialized SGTIN or SSCC is required.',
      duplicateEpcsMessage:
          'Duplicate EPCs detected. Each item may only appear once per cancel event.',
    );

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
