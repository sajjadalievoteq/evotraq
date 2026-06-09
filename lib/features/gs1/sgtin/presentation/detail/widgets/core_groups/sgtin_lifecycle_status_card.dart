import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/gs1/sgtin/sgtin_model.dart';
import 'package:traqtrace_app/features/gs1/sgtin/presentation/detail/widgets/sgtin_card_helpers.dart';
import 'package:traqtrace_app/features/gs1/sgtin/presentation/detail/widgets/sgtin_info_row.dart';
import 'package:traqtrace_app/features/gs1/sgtin/utils/sgtin_status_rules.dart'
    as status_rules;
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';

class SgtinLifecycleStatusCard extends StatelessWidget {
  const SgtinLifecycleStatusCard({
    super.key,
    required this.borderColor,
    required this.isEditing,
    required this.isCreating,
    required this.onStatusChanged,
    required this.onTransitionError,
    this.sgtin,
    this.selectedStatus,
  });

  final Color borderColor;
  final bool isEditing;
  final bool isCreating;
  final ValueChanged<ItemStatus> onStatusChanged;
  final ValueChanged<String> onTransitionError;
  final SGTIN? sgtin;
  final ItemStatus? selectedStatus;

  @override
  Widget build(BuildContext context) {
    return Gs1GroupCard(
      title: 'Lifecycle Status',
      outlineColor: borderColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildStatusField(context),
          if (sgtin?.commissionedAt != null) ...[
            const SizedBox(height: 12),
            SgtinInfoRow(
              'Commissioned At',
              sgtinFormatDt(sgtin!.commissionedAt),
            ),
          ],
          if (sgtin?.decommissionedDate != null) ...[
            const SizedBox(height: 12),
            SgtinInfoRow(
              'Decommissioned At',
              sgtinFormatDt(sgtin!.decommissionedDate),
              valueColor: Colors.red.shade700,
            ),
            const SizedBox(height: 12),
            SgtinInfoRow(
              'Decommission Reason',
              sgtin!.decommissionedReason,
              valueColor: Colors.red.shade700,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusField(BuildContext context) {
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
              child: Row(children: [
                Icon(Icons.circle,
                    size: 12,
                    color: status_rules.statusColor(selectedStatus!)),
                const SizedBox(width: 8),
                Text(status_rules.friendlyLabel(selectedStatus!)),
              ]),
            ),
            ...options.map((s) => DropdownMenuItem<ItemStatus>(
                  value: s,
                  child: Row(children: [
                    Icon(Icons.circle,
                        size: 12, color: status_rules.statusColor(s)),
                    const SizedBox(width: 8),
                    Text(status_rules.friendlyLabel(s)),
                  ]),
                )),
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
          : 'COMMISSIONED',
      valueColor: selectedStatus != null
          ? status_rules.statusColor(selectedStatus!)
          : Colors.blue,
    );
  }
}
