import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/operations/shared/utils/operation_pharma_readiness_checker.dart';

/// GS1 pharma / DSCSA readiness checks for receiving operations.
class ReceivingPharmaReadinessChecker {
  ReceivingPharmaReadinessChecker._();

  static List<String> findIssues({
    required GLN? sourceGln,
    required GLN? receivingGln,
    required List<String> epcs,
  }) {
    return OperationPharmaReadinessChecker.twoGlnIssues(
      sourceGln: sourceGln,
      destinationGln: receivingGln,
      epcs: epcs,
      sourceLabel: 'Source GLN',
      destinationLabel: 'Receiving GLN',
      sourceRequiredMessage:
          'Source (Ship From) GLN is required for GS1 pharma compliance.',
      destinationRequiredMessage:
          'Receiving GLN is required for GS1 pharma compliance.',
      sameLocationMessage:
          'Source and receiving GLN are identical. '
          'A receiving event must record movement between different locations.',
      duplicateEpcsMessage:
          'Duplicate EPCs detected. Each item can only appear once per receiving event.',
    );
  }
}
