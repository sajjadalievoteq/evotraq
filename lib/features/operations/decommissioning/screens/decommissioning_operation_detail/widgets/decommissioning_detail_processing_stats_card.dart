import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/decommissioning/decommissioning_response_model.dart';
import 'package:traqtrace_app/features/operations/decommissioning/screens/decommissioning_operation_detail/widgets/decommissioning_detail_group_card.dart';
import 'package:traqtrace_app/features/operations/decommissioning/screens/decommissioning_operation_detail/widgets/decommissioning_detail_info_row.dart';
import 'package:traqtrace_app/features/operations/decommissioning/utils/decommissioning_status_utils.dart';

/// Processing info card for Decommissioning operation detail.
class DecommissioningDetailProcessingStatsCard extends StatelessWidget {
  const DecommissioningDetailProcessingStatsCard({
    super.key,
    required this.operation,
  });

  final DecommissioningResponse operation;

  @override
  Widget build(BuildContext context) {
    return DecommissioningDetailGroupCard(
      title: 'Processing Info',
      children: [
        if (operation.processingTimeMs != null)
          DecommissioningDetailInfoRow(
            label: 'Processing Time',
            value: '${operation.processingTimeMs} ms',
          ),
        DecommissioningDetailInfoRow(
          label: 'Status',
          value: DecommissioningStatusUtils.detailLabel(operation.status),
        ),
      ],
    );
  }
}
