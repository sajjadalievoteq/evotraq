import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/receiving/receiving_response_model.dart';
import 'package:traqtrace_app/features/operations/receiving/screens/receiving_operation_detail/widgets/receiving_detail_group_card.dart';
import 'package:traqtrace_app/features/operations/receiving/screens/receiving_operation_detail/widgets/receiving_detail_info_row.dart';
import 'package:traqtrace_app/features/operations/receiving/utils/receiving_status_utils.dart';

/// Processing info card for Receiving operation detail.
class ReceivingDetailProcessingStatsCard extends StatelessWidget {
  const ReceivingDetailProcessingStatsCard({
    super.key,
    required this.operation,
  });

  final ReceivingResponse operation;

  @override
  Widget build(BuildContext context) {
    return ReceivingDetailGroupCard(
      title: 'Processing Info',
      children: [
        if (operation.processingTimeMs != null)
          ReceivingDetailInfoRow(
            label: 'Processing Time',
            value: '${operation.processingTimeMs} ms',
          ),
        ReceivingDetailInfoRow(
          label: 'Status',
          value: ReceivingStatusUtils.detailLabel(operation.status),
        ),
      ],
    );
  }
}
