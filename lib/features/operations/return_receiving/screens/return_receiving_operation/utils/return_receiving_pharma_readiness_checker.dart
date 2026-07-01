import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';

/// GS1 pharma / DSCSA readiness checks for return receiving operations.
class ReturnReceivingPharmaReadinessChecker {
  ReturnReceivingPharmaReadinessChecker._();

  static List<String> findIssues({
    required GLN? sourceGln,
    required GLN? receivingGln,
    required List<String> epcs,
  }) {
    final issues = <String>[];

    if (sourceGln == null) {
      issues.add('Source (Returned From) GLN is required for GS1 pharma compliance.');
    } else if (!_isValidGln(sourceGln.glnCode)) {
      issues.add(
        'Source GLN "${sourceGln.glnCode}" has an invalid GS1 check digit.',
      );
    }

    if (receivingGln == null) {
      issues.add('Return Receiving GLN is required for GS1 pharma compliance.');
    } else if (!_isValidGln(receivingGln.glnCode)) {
      issues.add(
        'Return Receiving GLN "${receivingGln.glnCode}" has an invalid GS1 check digit.',
      );
    }

    if (sourceGln != null &&
        receivingGln != null &&
        sourceGln.glnCode == receivingGln.glnCode) {
      issues.add(
        'Source and Return Receiving GLN are identical. '
        'A receiving event must record movement between different locations.',
      );
    }

    if (epcs.isEmpty) {
      issues.add('No EPCs captured. At least one SGTIN or SSCC is required.');
    }

    for (final epc in epcs) {
      if (!epc.startsWith('urn:epc:id:sgtin:') &&
          !epc.startsWith('urn:epc:id:sscc:')) {
        issues.add('"$epc" is not a valid GS1 EPC URI.');
      }
    }

    if (epcs.toSet().length != epcs.length) {
      issues.add(
        'Duplicate EPCs detected. Each item can only appear once per receiving event.',
      );
    }

    return issues;
  }

  static bool _isValidGln(String gln) {
    if (!RegExp(r'^\d{13}$').hasMatch(gln)) return false;
    var sum = 0;
    for (var i = 0; i < 12; i++) {
      final digit = int.parse(gln[i]);
      sum += i.isOdd ? digit * 3 : digit;
    }
    final checkDigit = (10 - (sum % 10)) % 10;
    return checkDigit == int.parse(gln[12]);
  }
}
