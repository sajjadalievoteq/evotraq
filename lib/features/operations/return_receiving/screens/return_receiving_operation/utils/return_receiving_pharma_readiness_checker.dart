import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/operations/shared/utils/operation_pharma_readiness_checker.dart';

class ReturnReceivingPharmaReadinessChecker {
  ReturnReceivingPharmaReadinessChecker._();

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
      destinationLabel: 'Return Receiving GLN',
      sourceRequiredMessage:
          'Source (Returned From) GLN is required for GS1 pharma compliance.',
      destinationRequiredMessage:
          'Return Receiving GLN is required for GS1 pharma compliance.',
      sameLocationMessage:
          'Source and Return Receiving GLN are identical. '
          'A receiving event must record movement between different locations.',
      duplicateEpcsMessage:
          'Duplicate EPCs detected. Each item can only appear once per receiving event.',
    );
  }
}
