import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/cancel_receiving/cancel_receiving_response_model.dart';
import 'package:traqtrace_app/features/operations/cancel_receiving/screens/cancel_receiving_operation_detail/widgets/cancel_receiving_detail_group_card.dart';
import 'package:traqtrace_app/features/operations/cancel_receiving/screens/cancel_receiving_operation_detail/widgets/cancel_receiving_detail_info_row.dart';
import 'package:traqtrace_app/features/operations/cancel_receiving/utils/cancel_receiving_status_utils.dart';

/// Processing info card for shipping operation detail.
class CancelReceivingDetailProcessingStatsCard extends StatelessWidget {
  const CancelReceivingDetailProcessingStatsCard({
    super.key,
    required this.operation,
  });

  final CancelReceivingResponse operation;

  @override
  Widget build(BuildContext context) {
    return CancelReceivingDetailGroupCard(
      title: 'Processing Info',
      children: [
        if (operation.processingTimeMs != null)
          CancelReceivingDetailInfoRow(
            label: 'Processing Time',
            value: '${operation.processingTimeMs} ms',
          ),
        CancelReceivingDetailInfoRow(
          label: 'Status',
          value: CancelReceivingStatusUtils.detailLabel(operation.status),
        ),
      ],
    );
  }
}
