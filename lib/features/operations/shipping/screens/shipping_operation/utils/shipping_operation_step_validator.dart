import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/operations/shared/operation_epc_scan_validator.dart';

/// Validation helpers for shipping operation wizard steps.
class ShippingOperationStepValidator {
  ShippingOperationStepValidator._();

  static String? validateReferenceStep({
    required String shippingReference,
    required GLN? sourceGln,
    required GLN? destinationGln,
  }) {
    if (shippingReference.trim().isEmpty) {
      return 'Please enter a Shipping Reference.';
    }
    if (sourceGln == null) {
      return 'Please select Ship From Location (source GLN).';
    }
    if (destinationGln == null) {
      return 'Please select Ship To Location (destination GLN).';
    }
    if (sourceGln.glnCode == destinationGln.glnCode) {
      return 'Ship From and Ship To locations cannot be the same.';
    }

    if (!_isValidGln(sourceGln.glnCode)) {
      return 'Ship From GLN "${sourceGln.glnCode}" is not a valid GS1 GLN '
          '(must be 13 digits with a valid check digit).';
    }
    if (!_isValidGln(destinationGln.glnCode)) {
      return 'Ship To GLN "${destinationGln.glnCode}" is not a valid GS1 GLN '
          '(must be 13 digits with a valid check digit).';
    }

    return null;
  }

  static String? validateItemsStep(List<String> scannedEpcs) {
    if (scannedEpcs.isEmpty) {
      return 'Scan at least one SGTIN or SSCC before continuing.';
    }

    for (final epc in scannedEpcs) {
      if (!_isValidEpc(epc)) {
        return '"$epc" is not a valid GS1 EPC.\n'
            'Expected format: urn:epc:id:sgtin:… or urn:epc:id:sscc:…, '
            'or a scannable SGTIN/SSCC barcode.';
      }
    }

    final unique = scannedEpcs.toSet();
    if (unique.length != scannedEpcs.length) {
      return 'Duplicate EPCs found. Each item or container can only be '
          'included once per shipment.';
    }

    return null;
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

  static bool _isValidEpc(String epc) {
    if (epc.startsWith('urn:epc:id:sgtin:') ||
        epc.startsWith('urn:epc:id:sscc:')) {
      return true;
    }
    return OperationEpcScanValidator.resolveEpcType(epc) !=
        OperationScanItemType.unknown;
  }
}
