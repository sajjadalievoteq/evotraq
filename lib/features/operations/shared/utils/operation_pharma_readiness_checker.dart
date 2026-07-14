import 'package:traqtrace_app/core/utils/gs1/gs1_canonical_identifier.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/operations/shared/utils/gln_check_digit_validator.dart';

abstract final class OperationPharmaReadinessChecker {
  static List<String> twoGlnIssues({
    required GLN? sourceGln,
    required GLN? destinationGln,
    required List<String> epcs,
    required String sourceLabel,
    required String destinationLabel,
    required String sourceRequiredMessage,
    required String destinationRequiredMessage,
    String? sameLocationMessage,
    String emptyEpcsMessage =
        'No EPCs captured. At least one SGTIN or SSCC is required.',
    String duplicateEpcsMessage =
        'Duplicate EPCs detected. Each serialized item or container '
        'can only appear once.',
  }) {
    final issues = <String>[];

    if (sourceGln == null) {
      issues.add(sourceRequiredMessage);
    } else if (!GlnCheckDigitValidator.isValid(sourceGln.glnCode)) {
      issues.add(
        '$sourceLabel "${sourceGln.glnCode}" has an invalid GS1 check digit.',
      );
    }

    if (destinationGln == null) {
      issues.add(destinationRequiredMessage);
    } else if (!GlnCheckDigitValidator.isValid(destinationGln.glnCode)) {
      issues.add(
        '$destinationLabel "${destinationGln.glnCode}" has an invalid GS1 check digit.',
      );
    }

    if (sourceGln != null &&
        destinationGln != null &&
        sourceGln.glnCode == destinationGln.glnCode) {
      issues.add(
        sameLocationMessage ??
            '$sourceLabel and $destinationLabel must be different locations.',
      );
    }

    if (epcs.isEmpty) {
      issues.add(emptyEpcsMessage);
    }

    issues.addAll(epcIssues(epcs, duplicateMessage: duplicateEpcsMessage));

    return issues;
  }

  static List<String> epcIssues(
    List<String> epcs, {
    String duplicateMessage =
        'Duplicate EPCs detected. Each serialized item or container '
        'can only appear once.',
  }) {
    final issues = <String>[];

    for (final epc in epcs) {
      if (Gs1CanonicalIdentifier.isLgtin(epc)) {
        issues.add(
          '"$epc" is a lot-based GTIN (lgtin). '
          'DSCSA requires serialized SGTINs. lgtin is not valid for pharma events.',
        );
      } else if (!Gs1CanonicalIdentifier.isSerializedInstance(epc)) {
        issues.add(
          '"$epc" is not a valid GS1 EPC URI for a pharma event. '
          'Expected https://id.gs1.org/01/…/21/… or https://id.gs1.org/00/… '
          '(URN forms are also accepted).',
        );
      }
    }

    if (epcs.isNotEmpty && epcs.toSet().length != epcs.length) {
      issues.add(duplicateMessage);
    }

    return issues;
  }
}
