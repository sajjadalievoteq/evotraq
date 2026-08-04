import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/utils/status_visual_mappers.dart';
import 'package:traqtrace_app/features/admin/screens/data_consistency_integrity/widgets/consistency_metric_card.dart';

class ConsistencyMetricsSection extends StatelessWidget {
  const ConsistencyMetricsSection(this.report, {super.key});

  final Map<String, dynamic> report;

  @override
  Widget build(BuildContext context) {
    final score = report['consistency_score'] ?? 0.0;
    final total = report['total_events_analyzed'] ?? 0;
    final violations = (report['consistency_violations'] as List?)?.length ?? 0;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Consistency Metrics',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ConsistencyMetricCard(
                    'Consistency Score',
                    '${score.toStringAsFixed(1)}%',
                    StatusVisualMappers.scoreColor(context, score),
                    AppAssets.iconScore,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ConsistencyMetricCard(
                    'Events Analyzed',
                    total.toString(),
                    AppColorMapper.infoColor(context),
                    NavIcons.epcisEvents,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ConsistencyMetricCard(
                    'Violations Found',
                    violations.toString(),
                    violations > 0
                        ? AppColorMapper.errorColor(context)
                        : AppColorMapper.successColor(context),
                    AppAssets.iconAlert,
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
