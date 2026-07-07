import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/operations/shared/utils/operation_pharma_readiness_checker.dart';

class CancelReceivingPharmaReadinessChecker {
  CancelReceivingPharmaReadinessChecker._();

  static List<String> findIssues({
    required GLN? sourceGln,
    required GLN? receivingGln,
    required List<String> epcs,
    required String cancelReason,
    required String? originalReceivingReference,
  }) {
    final issues = OperationPharmaReadinessChecker.twoGlnIssues(
      sourceGln: sourceGln,
      destinationGln: receivingGln,
      epcs: epcs,
      sourceLabel: 'Sender (Ship-From) GLN',
      destinationLabel: 'Receive-At GLN',
      sourceRequiredMessage:
          'Sender (Ship-From) GLN is required. '
          'The cancel receiving event must identify the original sender (CBV 2.0 §8.5).',
      destinationRequiredMessage:
          'Receive-At GLN is required. '
          'The receiver\'s site must be recorded for the DSCSA audit trail.',
      sameLocationMessage:
          'Sender (Ship-From) and Receive-At GLNs are identical. '
          'A cancel receiving event requires two distinct trading-partner locations.',
      emptyEpcsMessage:
          'No EPCs captured. At least one serialized SGTIN or SSCC is required.',
      duplicateEpcsMessage:
          'Duplicate EPCs detected. Each item may only appear once per cancel event.',
    );

    if (cancelReason.trim().isEmpty) {
      issues.add('A cancellation reason is required (DSCSA §582 / FMD Art. 22).');
    }

    if (originalReceivingReference == null ||
        originalReceivingReference.trim().isEmpty) {
      issues.add('Original Receiving Reference (GINC) is missing. '
          'DSCSA requires the original Transaction Information number to be referenced '
          'in the bizTransactionList of a cancel receiving event. '
          'Enter the GINC from the original receiving event, or confirm this cancellation is not '
          'subject to DSCSA before proceeding without it.');
    }

    return issues;
  }
}
