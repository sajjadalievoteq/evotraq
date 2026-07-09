import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/data/models/gs1/sgtin/sgtin_model.dart';
import 'package:traqtrace_app/features/gs1/sgtin/utils/sgtin_status_rules.dart'
    as status_rules;
import 'package:traqtrace_app/features/gs1/sgtin/widgets/sgtin_info_row.dart';

class SgtinLifecycleStatusField extends StatelessWidget {
  const SgtinLifecycleStatusField({
    super.key,
    required this.isEditing,
    required this.isCreating,
    required this.selectedStatus,
    required this.onStatusChanged,
    required this.onTransitionError,
  });

  final bool isEditing;
  final bool isCreating;
  final ItemStatus? selectedStatus;
  final ValueChanged<ItemStatus> onStatusChanged;
  final ValueChanged<String> onTransitionError;

  @override
  Widget build(BuildContext context) {
    if (isEditing && !isCreating && selectedStatus != null) {
      final options = status_rules.selectableStatuses(selectedStatus!);
      if (options.isNotEmpty) {
        return DropdownButtonFormField<ItemStatus>(
          value: selectedStatus,
          decoration: const InputDecoration(
            labelText: 'Status',
            border: OutlineInputBorder(),
          ),
          items: [
            DropdownMenuItem<ItemStatus>(
              value: selectedStatus,
              child: Row(
                children: [
                  TraqIcon(AppAssets.iconCircle, color: status_rules.statusColor(selectedStatus!), size: 12),
                  const SizedBox(width: 8),
                  Text(status_rules.friendlyLabel(selectedStatus!)),
                ],
              ),
            ),
            ...options.map(
              (s) => DropdownMenuItem<ItemStatus>(
                value: s,
                child: Row(
                  children: [
                    TraqIcon(AppAssets.iconCircle, color: status_rules.statusColor(s), size: 12),
                    const SizedBox(width: 8),
                    Text(status_rules.friendlyLabel(s)),
                  ],
                ),
              ),
            ),
          ],
          onChanged: (newStatus) {
            if (newStatus == null) return;
            final err =
                status_rules.validateTransition(selectedStatus!, newStatus);
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
          : status_rules.friendlyLabel(ItemStatus.ALLOCATED),
      valueColor: selectedStatus != null
          ? status_rules.statusColor(selectedStatus!)
          : status_rules.statusColor(ItemStatus.ALLOCATED),
    );
  }
}
