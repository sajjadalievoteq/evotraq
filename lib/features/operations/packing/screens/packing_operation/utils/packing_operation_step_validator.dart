import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';

class PackingOperationStepValidator {
  PackingOperationStepValidator._();

  static String? validateReferenceStep({
    required GLN? packingLocationGln,
  }) {
    if (packingLocationGln == null) {
      return 'Please select the Packing Location — search for the GLN of the facility where packing is taking place.';
    }
    return null;
  }

  static String? validateContainerStep(String? parentContainerId) {
    if (parentContainerId == null || parentContainerId.isEmpty) {
      return 'No container scanned yet. Scan or enter the SSCC barcode on the carton or pallet you are packing into.';
    }
    return null;
  }

  static String? validateItemsStep(List<String> scannedEpcs) {
    if (scannedEpcs.isEmpty) {
      return 'No items added yet. Scan at least one product barcode (GTIN + serial number) before continuing.';
    }
    return null;
  }
}
