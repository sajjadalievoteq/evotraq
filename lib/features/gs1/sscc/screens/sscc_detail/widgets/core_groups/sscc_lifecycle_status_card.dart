import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/gs1/serialization/sscc/sscc_model.dart';
import 'package:traqtrace_app/features/gs1/sgtin/widgets/sgtin_info_row.dart';
import 'package:traqtrace_app/features/gs1/sscc/screens/sscc_detail/widgets/core_groups/sscc_lifecycle_status_field.dart';
import 'package:traqtrace_app/features/gs1/sscc/utils/sscc_card_helpers.dart';
import 'package:traqtrace_app/features/gs1/sscc/utils/sscc_edit_rules.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';

class SsccLifecycleStatusCard extends StatelessWidget {
  const SsccLifecycleStatusCard({
    super.key,
    required this.borderColor,
    required this.allowManualStatusEdit,
    required this.isCreating,
    required this.isReadOnly,
    required this.onStatusChanged,
    required this.onTransitionError,
    this.sscc,
    this.selectedStatus,
    this.serverTransitions,
  });

  final Color borderColor;
  final bool allowManualStatusEdit;
  final bool isCreating;
  final bool isReadOnly;
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
          SsccLifecycleStatusField(
            allowManualStatusEdit: allowManualStatusEdit,
            isCreating: isCreating,
            isReadOnly: isReadOnly,
            selectedStatus: selectedStatus,
            serverTransitions: serverTransitions,
            onStatusChanged: onStatusChanged,
            onTransitionError: onTransitionError,
          ),
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
}
