import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/operations/update_status/screens/update_status_operation/utils/update_status_disposition.dart';
import 'package:traqtrace_app/features/operations/update_status/screens/update_status_operation/utils/update_status_reason_options.dart';

class UpdateStatusOperationStepValidator {
  UpdateStatusOperationStepValidator._();

  static String? validateDetailsStep({
    required GLN? locationGln,
    required UpdateStatusDisposition? disposition,
    String? selectedReason,
    String? freeTextReason,
  }) {
    if (locationGln == null) {
      return 'Location GLN is required.';
    }
    if (disposition == null) {
      return 'Status is required.';
    }
    if (disposition == UpdateStatusDisposition.sample) {
      if (selectedReason == null || selectedReason.isEmpty) {
        return 'Reason is required for Sample status.';
      }
      if (!SampleReasonOptions.values.contains(selectedReason)) {
        return 'Please select a valid sample reason from the list.';
      }
    }
    if (disposition == UpdateStatusDisposition.damaged) {
      if (selectedReason == null || selectedReason.isEmpty) {
        return 'Reason is required for Damaged status.';
      }
      if (!DamagedReasonOptions.values.contains(selectedReason)) {
        return 'Please select a valid damage reason from the list.';
      }
    }
    return null;
  }

  static String? validateItemsStep(List<String> epcs) {
    if (epcs.isEmpty) {
      return 'Scan at least one EPC to update.';
    }
    return null;
  }
}
