import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/operations/update_status/screens/update_status_operation/utils/update_status_disposition.dart';
import 'package:traqtrace_app/features/operations/update_status/screens/update_status_operation/utils/update_status_reason_options.dart';
import 'package:traqtrace_app/features/operations/update_status/screens/update_status_operation/widgets/update_status_reason_dropdown.dart';

class UpdateStatusReasonField extends StatelessWidget {
  const UpdateStatusReasonField({
    super.key,
    required this.selectedDisposition,
    required this.reasonController,
    required this.selectedReason,
    required this.onReasonChanged,
  });

  final UpdateStatusDisposition? selectedDisposition;
  final TextEditingController reasonController;
  final String? selectedReason;
  final ValueChanged<String?> onReasonChanged;

  @override
  Widget build(BuildContext context) {
    if (selectedDisposition == UpdateStatusDisposition.sample) {
      return UpdateStatusReasonDropdown(
        key: const ValueKey('sample-reason'),
        options: SampleReasonOptions.values,
        selectedReason: selectedReason,
        hint: 'Select a sample reason',
        onChanged: onReasonChanged,
      );
    }

    if (selectedDisposition == UpdateStatusDisposition.damaged) {
      return UpdateStatusReasonDropdown(
        key: const ValueKey('damaged-reason'),
        options: DamagedReasonOptions.values,
        selectedReason: selectedReason,
        hint: 'Select a damage reason',
        onChanged: onReasonChanged,
      );
    }

    return TextField(
      key: const ValueKey('freetext-reason'),
      controller: reasonController,
      decoration: const InputDecoration(
        labelText: 'Reason (optional)',
        hintText: 'e.g. Item lost during transit',
        border: OutlineInputBorder(),
      ),
      maxLines: 2,
    );
  }
}
