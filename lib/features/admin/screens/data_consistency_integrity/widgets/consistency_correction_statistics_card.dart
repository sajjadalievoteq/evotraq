import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/utils/status_visual_mappers.dart';
import 'package:traqtrace_app/features/admin/screens/data_consistency_integrity/widgets/consistency_metric_card.dart';

class ConsistencyCorrectionStatisticsCard extends StatelessWidget {
  const ConsistencyCorrectionStatisticsCard(this.stats, {super.key});

  final Map<String, dynamic> stats;

  @override
  Widget build(BuildContext context) {
    final totalErrors = stats['total_errors_identified'] ?? 0;
    final totalWorkflows = stats['total_workflows_created'] ?? 0;
    final approvalRate =
        (stats['approval_rate_percentage'] ?? 0.0).toDouble();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Correction Statistics',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ConsistencyMetricCard(
                    'Total Errors',
                    totalErrors.toString(),
                    AppColorMapper.errorColor(context),
                    AppAssets.iconXCircle,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ConsistencyMetricCard(
                    'Workflows Created',
                    totalWorkflows.toString(),
                    AppColorMapper.infoColor(context),
                    AppAssets.iconWork,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ConsistencyMetricCard(
                    'Approval Rate',
                    '${approvalRate.toStringAsFixed(1)}%',
                    StatusVisualMappers.scoreColor(context, approvalRate),
                    AppAssets.iconCheck,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
