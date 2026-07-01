import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';

/// GS1 pharma / DSCSA readiness checks for shipping operations.
/// Returns a list of human-readable issue strings. Empty list = ready.
class ReturnShippingPharmaReadinessChecker {
  ReturnShippingPharmaReadinessChecker._();

  static List<String> findIssues({
    required GLN? sourceGln,
    required GLN? destinationGln,
    required List<String> epcs,
  }) {
    final issues = <String>[];

    if (sourceGln == null) {
      issues.add('Source (Ship From) GLN is required for GS1 pharma compliance.');
    } else if (!_isValidGln(sourceGln.glnCode)) {
      issues.add(
        'Source GLN "${sourceGln.glnCode}" has an invalid GS1 check digit. '
        'Verify the GLN against the GS1 registry.',
      );
    }

    if (destinationGln == null) {
      issues.add(
          'Destination (Ship To) GLN is required for GS1 pharma compliance.');
    } else if (!_isValidGln(destinationGln.glnCode)) {
      issues.add(
        'Destination GLN "${destinationGln.glnCode}" has an invalid GS1 check digit. '
        'Verify the GLN against the GS1 registry.',
      );
    }

    if (sourceGln != null &&
        destinationGln != null &&
        sourceGln.glnCode == destinationGln.glnCode) {
      issues.add(
        'Source and destination GLN are identical. '
        'A shipment must move between different legal entities or locations.',
      );
    }

    if (epcs.isEmpty) {
      issues.add('No EPCs captured. At least one SGTIN or SSCC is required.');
    }

    for (final epc in epcs) {
      if (!epc.startsWith('urn:epc:id:sgtin:') &&
          !epc.startsWith('urn:epc:id:sscc:')) {
        issues.add(
          '"$epc" is not a valid GS1 EPC URI. '
          'Only urn:epc:id:sgtin:… and urn:epc:id:sscc:… are accepted for pharma shipments.',
        );
      }
    }

    if (epcs.toSet().length != epcs.length) {
      issues.add(
        'Duplicate EPCs detected. Each serialized item or container '
        'can only appear once in a shipment.',
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
