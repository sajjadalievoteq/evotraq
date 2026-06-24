import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/packing/packing_response_model.dart';
import 'package:traqtrace_app/features/operations/packing/screens/packing_operation_detail/widgets/packing_detail_group_card.dart';
import 'package:traqtrace_app/features/operations/packing/screens/packing_operation_detail/widgets/packing_detail_info_row.dart';
import 'package:traqtrace_app/features/operations/packing/utils/packing_status_utils.dart';

/// Processing info card for packing operation detail.
class PackingDetailProcessingStatsCard extends StatelessWidget {
  const PackingDetailProcessingStatsCard({
    super.key,
    required this.operation,
  });

  final PackingResponse operation;

  @override
  Widget build(BuildContext context) {
    return PackingDetailGroupCard(
      title: 'Processing Info',
      children: [
        if (operation.processingTimeMs != null)
          PackingDetailInfoRow(
            label: 'Processing Time',
            value: '${operation.processingTimeMs} ms',
          ),
        PackingDetailInfoRow(
          label: 'Status',
          value: PackingStatusUtils.detailLabel(operation.status),
        ),
      ],
    );
  }
}
