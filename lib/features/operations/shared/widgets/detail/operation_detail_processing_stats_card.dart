import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_group_card.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_info_row.dart';

class OperationDetailProcessingStatsCard extends StatelessWidget {
  const OperationDetailProcessingStatsCard({
    super.key,
    required this.statusLabel,
    this.processingTimeMs,
  });

  final String statusLabel;
  final int? processingTimeMs;

  @override
  Widget build(BuildContext context) {
    return OperationDetailGroupCard(
      title: 'Processing Info',
      children: [
        if (processingTimeMs != null)
          OperationDetailInfoRow(
            label: 'Processing Time',
            value: '$processingTimeMs ms',
          ),
        OperationDetailInfoRow(label: 'Status', value: statusLabel),
      ],
    );
  }
}
