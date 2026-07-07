import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/operations/shared/utils/operation_pharma_readiness_checker.dart';

/// GS1 pharma / DSCSA readiness checks for shipping operations.
/// Returns a list of human-readable issue strings. Empty list = ready.
class ReturnShippingPharmaReadinessChecker {
  ReturnShippingPharmaReadinessChecker._();

  static List<String> findIssues({
    required GLN? sourceGln,
    required GLN? destinationGln,
    required List<String> epcs,
  }) {
    return OperationPharmaReadinessChecker.twoGlnIssues(
      sourceGln: sourceGln,
      destinationGln: destinationGln,
      epcs: epcs,
      sourceLabel: 'Source GLN',
      destinationLabel: 'Destination GLN',
      sourceRequiredMessage:
          'Source (Ship From) GLN is required for GS1 pharma compliance.',
      destinationRequiredMessage:
          'Destination (Ship To) GLN is required for GS1 pharma compliance.',
      sameLocationMessage:
          'Source and destination GLN are identical. '
          'A shipment must move between different legal entities or locations.',
      duplicateEpcsMessage:
          'Duplicate EPCs detected. Each serialized item or container '
          'can only appear once in a shipment.',
    );
  }
}
