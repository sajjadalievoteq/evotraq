import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/utils/status_visual_mappers.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

class ConsistencyAnomalyCard extends StatelessWidget {
  const ConsistencyAnomalyCard({
    super.key,
    required this.anomaly,
    required this.onCorrect,
    required this.onViewDetails,
  });

  final Map<String, dynamic> anomaly;
  final VoidCallback onCorrect;
  final VoidCallback onViewDetails;

  @override
  Widget build(BuildContext context) {
    final type = anomaly['anomaly_type'] ?? 'UNKNOWN';
    final severity = anomaly['severity'] ?? 'LOW';
    final confidence = (anomaly['confidence_score'] ?? 0.0) * 100;
    final description = anomaly['description'] ?? '';
    final suggestedActions =
        (anomaly['suggested_actions'] as List?)?.cast<String>() ?? [];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ExpansionTile(
        leading: TraqIcon(
          AppAssets.iconAlert,
          color: StatusVisualMappers.dashboardSeverityColor(context, severity),
        ),
        title: Text(
          type,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(description),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Chip(
              label: Text('${confidence.toStringAsFixed(0)}% confidence'),
              backgroundColor:
                  AppColorMapper.infoColor(context).withOpacity(0.1),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: onCorrect,
              icon: TraqIcon(AppAssets.iconSparkle, size: 16),
              label: const Text('Correct'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColorMapper.warningColor(context),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Chip(
                      label: Text(severity),
                      backgroundColor:
                          StatusVisualMappers.dashboardSeverityColor(
                        context,
                        severity,
                      ).withOpacity(0.1),
                      labelStyle: TextStyle(
                        color: StatusVisualMappers.dashboardSeverityColor(
                          context,
                          severity,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Confidence: ${confidence.toStringAsFixed(1)}%',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                if (suggestedActions.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Suggested Actions:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...suggestedActions.map(
                    (action) => Padding(
                      padding: const EdgeInsets.only(left: 16, bottom: 4),
                      child: Row(
                        children: [
                          TraqIcon(AppAssets.iconChevronR, size: 16),
                          const SizedBox(width: 8),
                          Expanded(child: Text(action)),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: onViewDetails,
                      child: const Text('View Details'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: onCorrect,
                      icon: TraqIcon(AppAssets.iconBuild),
                      label: const Text('Apply Correction'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            AppColorMapper.successColor(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
