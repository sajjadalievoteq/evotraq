import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';

/// Validation helpers for unpacking operation wizard steps.
class UnpackingOperationStepValidator {
  UnpackingOperationStepValidator._();

  static String? validateReferenceStep({
    required String unpackingReference,
    required GLN? unpackingLocationGln,
  }) {
    if (unpackingReference.trim().isEmpty) {
      return 'Please enter an Unpacking Reference — this is the internal ID for this operation (e.g. UNPACK-2024-001).';
    }
    if (unpackingLocationGln == null) {
      return 'Please select the Unpacking Location — search for the GLN of the facility where unpacking is taking place.';
    }
    return null;
  }

  static String? validateContainerStep(String? parentContainerId) {
    if (parentContainerId == null || parentContainerId.isEmpty) {
      return 'No container scanned yet. Scan or enter the SSCC barcode on the carton or pallet you are unpacking.';
    }
    // GS1 EPCIS 2.0: parentID must be an SSCC EPC URI
    if (!parentContainerId.startsWith('urn:epc:id:sscc:')) {
      return 'Container ID must be a valid SSCC EPC URI (urn:epc:id:sscc:...). '
          'Use the scanner or enter the full 18-digit SSCC number.';
    }
    return null;
  }

  static String? validateItemsStep(List<String> scannedEpcs) {
    if (scannedEpcs.isEmpty) {
      return 'No items added yet. Scan at least one product barcode (GTIN + serial number) to remove from the container.';
    }
    return null;
  }
}
