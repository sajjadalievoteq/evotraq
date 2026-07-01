import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/operations/decommissioning/screens/decommissioning_operation/utils/decommissioning_disposition.dart';

class DecommissioningOperationStepValidator {
  DecommissioningOperationStepValidator._();

  static String? validateDetailsStep({
    required GLN? locationGln,
    required DecommissioningDisposition? disposition,
  }) {
    if (locationGln == null) {
      return 'Decommissioning location GLN is required.';
    }
    if (disposition == null) {
      return 'Disposition is required.';
    }
    return null;
  }

  static String? validateItemsStep(List<String> epcs) {
    if (epcs.isEmpty) {
      return 'Scan at least one EPC to decommission.';
    }
    return null;
  }
}
