import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/operations/shared/utils/gln_check_digit_validator.dart';
import 'package:traqtrace_app/features/operations/shared/utils/operation_pharma_readiness_checker.dart';

class ReturnShippingPharmaReadinessChecker {
  ReturnShippingPharmaReadinessChecker._();

  static List<String> findIssues({
    required GLN? sourceGln,
    required List<String> epcs,
  }) {
    final issues = <String>[];
    if (sourceGln == null) {
      issues.add(
        'Source (Ship From) GLN is required for GS1 pharma compliance.',
      );
    } else if (!GlnCheckDigitValidator.isValid(sourceGln.glnCode)) {
      issues.add(
        'Source GLN "${sourceGln.glnCode}" has an invalid GS1 check digit.',
      );
    }
    if (epcs.isEmpty) {
      issues.add(
        'No EPCs captured. At least one SGTIN or SSCC is required.',
      );
    }
    issues.addAll(
      OperationPharmaReadinessChecker.epcIssues(
        epcs,
        duplicateMessage:
            'Duplicate EPCs detected. Each serialized item or container '
            'can only appear once in a shipment.',
      ),
    );
    return issues;
  }
}
