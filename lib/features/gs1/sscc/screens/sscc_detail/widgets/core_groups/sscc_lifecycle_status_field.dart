import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/gs1/serialization/sscc/sscc_model.dart';
import 'package:traqtrace_app/features/gs1/sgtin/widgets/sgtin_info_row.dart';
import 'package:traqtrace_app/features/gs1/sscc/utils/sscc_status_rules.dart'
    as status_rules;

class SsccLifecycleStatusField extends StatelessWidget {
  const SsccLifecycleStatusField({
    super.key,
    required this.allowManualStatusEdit,
    required this.isCreating,
    required this.isReadOnly,
    required this.onStatusChanged,
    required this.onTransitionError,
    this.selectedStatus,
    this.serverTransitions,
  });

  final bool allowManualStatusEdit;
  final bool isCreating;
  final bool isReadOnly;
  final ValueChanged<LogisticUnitStatus> onStatusChanged;
  final ValueChanged<String> onTransitionError;
  final LogisticUnitStatus? selectedStatus;
  final List<String>? serverTransitions;

  @override
  Widget build(BuildContext context) {
    if (allowManualStatusEdit &&
        !isReadOnly &&
        !isCreating &&
        selectedStatus != null) {
      final options = status_rules.selectableStatuses(
        selectedStatus!,
        serverTransitions: serverTransitions,
      );
      if (options.isNotEmpty) {
        return DropdownButtonFormField<LogisticUnitStatus>(
          value: selectedStatus,
          decoration: const InputDecoration(
            labelText: 'Status',
            border: OutlineInputBorder(),
          ),
          items: [
            DropdownMenuItem<LogisticUnitStatus>(
              value: selectedStatus,
              child: Row(
                children: [
                  Icon(
                    Icons.circle,
                    size: 12,
                    color: status_rules.statusColor(selectedStatus!),
                  ),
                  const SizedBox(width: 8),
                  Text(status_rules.friendlyLabel(selectedStatus!)),
                ],
              ),
            ),
            ...options.map(
              (s) => DropdownMenuItem<LogisticUnitStatus>(
                value: s,
                child: Row(
                  children: [
                    Icon(
                      Icons.circle,
                      size: 12,
                      color: status_rules.statusColor(s),
                    ),
                    const SizedBox(width: 8),
                    Text(status_rules.friendlyLabel(s)),
                  ],
                ),
              ),
            ),
          ],
          onChanged: (newStatus) {
            if (newStatus == null) return;
            final err = status_rules.validateTransition(
              selectedStatus!,
              newStatus,
            );
            if (err != null) {
              onTransitionError(err);
              return;
            }
            onStatusChanged(newStatus);
          },
        );
      }
    }

    return SgtinInfoRow(
      'Status',
      selectedStatus != null
          ? status_rules.friendlyLabel(selectedStatus!)
          : 'Draft',
      valueColor: selectedStatus != null
          ? status_rules.statusColor(selectedStatus!)
          : Colors.blueGrey,
    );
  }
}
