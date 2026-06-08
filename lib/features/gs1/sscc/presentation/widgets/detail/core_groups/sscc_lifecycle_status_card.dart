import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/gs1/serialization/sscc/sscc_model.dart';
import 'package:traqtrace_app/features/gs1/sgtin/presentation/detail/widgets/sgtin_info_row.dart';
import 'package:traqtrace_app/features/gs1/sscc/presentation/widgets/detail/core_groups/sscc_card_helpers.dart';
import 'package:traqtrace_app/features/gs1/sscc/utils/sscc_edit_rules.dart';
import 'package:traqtrace_app/features/gs1/sscc/utils/sscc_status_rules.dart'
    as status_rules;
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';

class SsccLifecycleStatusCard extends StatelessWidget {
  const SsccLifecycleStatusCard({
    super.key,
    required this.borderColor,
    required this.allowManualStatusEdit,
    required this.isCreating,
    required this.onStatusChanged,
    required this.onTransitionError,
    this.sscc,
    this.selectedStatus,
    this.serverTransitions,
  });

  final Color borderColor;
  final bool allowManualStatusEdit;
  final bool isCreating;
  final ValueChanged<LogisticUnitStatus> onStatusChanged;
  final ValueChanged<String> onTransitionError;
  final SSCC? sscc;
  final LogisticUnitStatus? selectedStatus;
  final List<String>? serverTransitions;

  @override
  Widget build(BuildContext context) {
    final showEventHint = !isCreating &&
        selectedStatus != null &&
        !allowManualStatusEdit;

    return Gs1GroupCard(
      title: 'Lifecycle Status',
      outlineColor: borderColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildStatusField(context),
          if (showEventHint) ...[
            const SizedBox(height: 8),
            Text(
              statusEventDrivenHint,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
          if (sscc?.allocatedAt != null) ...[
            const SizedBox(height: 12),
            SgtinInfoRow('Allocated At', ssccFormatDt(sscc!.allocatedAt)),
          ],
          if (sscc?.commissionedAt != null) ...[
            const SizedBox(height: 12),
            SgtinInfoRow('Commissioned At', ssccFormatDt(sscc!.commissionedAt)),
          ],
          if (sscc?.decommissionedAt != null) ...[
            const SizedBox(height: 12),
            SgtinInfoRow(
              'Decommissioned At',
              ssccFormatDt(sscc!.decommissionedAt),
              valueColor: Colors.red.shade700,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusField(BuildContext context) {
    if (allowManualStatusEdit && !isCreating && selectedStatus != null) {
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
