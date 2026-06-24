import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/commissioning/commissioning_models.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation_detail/widgets/commissioning_detail_group_card.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation_detail/widgets/commissioning_detail_info_row.dart';

class CommissioningDetailProcessingStatsCard extends StatelessWidget {
  const CommissioningDetailProcessingStatsCard({
    super.key,
    required this.batch,
  });

  final CommissioningBatch batch;

  @override
  Widget build(BuildContext context) {
    final total = batch.totalRequested > 0
        ? batch.totalRequested
        : batch.totalCommissioned + batch.totalFailed;
    final successRate = total > 0 ? batch.totalCommissioned / total : 0.0;

    return CommissioningDetailGroupCard(
      title: 'Processing Stats',
      children: [
        CommissioningDetailInfoRow(label: 'Total Requested', value: '$total'),
        CommissioningDetailInfoRow(
          label: 'Total Commissioned',
          value: '${batch.totalCommissioned}',
        ),
        if (batch.totalFailed > 0)
          CommissioningDetailInfoRow(
            label: 'Total Failed',
            value: '${batch.totalFailed}',
            valueColor: Colors.red[700],
          ),
        const SizedBox(height: 8),
        Row(
          children: [
            SizedBox(
              width: 120,
              child: Text(
                'Success Rate',
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: successRate.clamp(0.0, 1.0),
                  minHeight: 8,
                  backgroundColor: Colors.red[100],
                  color: Colors.green,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${(successRate * 100).toStringAsFixed(1)}%',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
