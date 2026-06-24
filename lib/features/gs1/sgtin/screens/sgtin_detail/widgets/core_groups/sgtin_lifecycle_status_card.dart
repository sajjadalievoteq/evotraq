import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/gs1/sgtin/sgtin_model.dart';
import 'package:traqtrace_app/features/gs1/sgtin/screens/sgtin_detail/widgets/core_groups/sgtin_lifecycle_status_field.dart';
import 'package:traqtrace_app/features/gs1/sgtin/utils/sgtin_card_helpers.dart';
import 'package:traqtrace_app/features/gs1/sgtin/widgets/sgtin_info_row.dart';
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
          SgtinLifecycleStatusField(
            isEditing: isEditing,
            isCreating: isCreating,
            selectedStatus: selectedStatus,
            onStatusChanged: onStatusChanged,
            onTransitionError: onTransitionError,
          ),
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
}
