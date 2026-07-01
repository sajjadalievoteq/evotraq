import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/return_receiving/return_receiving_response_model.dart';
import 'package:traqtrace_app/features/operations/return_receiving/screens/return_receiving_operation_detail/widgets/return_receiving_detail_group_card.dart';
import 'package:traqtrace_app/features/operations/return_receiving/screens/return_receiving_operation_detail/widgets/return_receiving_detail_info_row.dart';
import 'package:traqtrace_app/features/operations/return_receiving/utils/return_receiving_status_utils.dart';

/// Processing info card for Return Receiving operation detail.
class ReturnReceivingDetailProcessingStatsCard extends StatelessWidget {
  const ReturnReceivingDetailProcessingStatsCard({
    super.key,
    required this.operation,
  });

  final ReturnReceivingResponse operation;

  @override
  Widget build(BuildContext context) {
    return ReturnReceivingDetailGroupCard(
      title: 'Processing Info',
      children: [
        if (operation.processingTimeMs != null)
          ReturnReceivingDetailInfoRow(
            label: 'Processing Time',
            value: '${operation.processingTimeMs} ms',
          ),
        ReturnReceivingDetailInfoRow(
          label: 'Status',
          value: ReturnReceivingStatusUtils.detailLabel(operation.status),
        ),
      ],
    );
  }
}

