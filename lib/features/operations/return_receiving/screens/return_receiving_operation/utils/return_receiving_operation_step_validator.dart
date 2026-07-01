import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/operations/shared/operation_epc_scan_validator.dart';

/// Validation helpers for return receiving operation wizard steps.
class ReturnReceivingOperationStepValidator {
  ReturnReceivingOperationStepValidator._();

  static String? validateReferenceStep({
    required GLN? sourceGln,
    required GLN? receivingGln,
  }) {
    if (sourceGln == null) {
      return 'Please select Returned From Location (source GLN).';
    }
    if (receivingGln == null) {
      return 'Please select Receiving Location.';
    }
    if (sourceGln.glnCode == receivingGln.glnCode) {
      return 'Returned From and Receiving locations cannot be the same.';
    }

    if (!_isValidGln(sourceGln.glnCode)) {
      return 'Source GLN "${sourceGln.glnCode}" is not a valid GS1 GLN.';
    }
    if (!_isValidGln(receivingGln.glnCode)) {
      return 'Receiving GLN "${receivingGln.glnCode}" is not a valid GS1 GLN.';
    }

    return null;
  }

  static String? validateItemsStep(List<String> scannedEpcs) {
    if (scannedEpcs.isEmpty) {
      return 'Scan at least one SGTIN, SSCC, or GTIN (lot-based) before continuing.';
    }

    for (final epc in scannedEpcs) {
      if (!_isValidEpc(epc)) {
        return '"$epc" is not a valid GS1 EPC.\n'
            'Expected format: urn:epc:id:sgtin:…, urn:epc:id:sscc:…, '
            'urn:epc:class:lgtin:…, or a scannable SGTIN/SSCC/GTIN barcode.';
      }
    }

    final unique = scannedEpcs.toSet();
    if (unique.length != scannedEpcs.length) {
      return 'Duplicate EPCs found. Each item can only be returned once.';
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
        epc.startsWith('urn:epc:id:sscc:') ||
        epc.startsWith('urn:epc:class:lgtin:') ||
        epc.startsWith('urn:epc:idpat:sgtin:')) {
      return true;
    }
    return OperationEpcScanValidator.resolveEpcType(epc) !=
        OperationScanItemType.unknown;
  }
}
