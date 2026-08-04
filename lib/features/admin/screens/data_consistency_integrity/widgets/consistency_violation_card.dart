import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/utils/status_visual_mappers.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

class ConsistencyViolationCard extends StatelessWidget {
  const ConsistencyViolationCard({
    super.key,
    required this.violation,
    required this.onCorrect,
    required this.onViewDetails,
  });

  final Map<String, dynamic> violation;
  final VoidCallback onCorrect;
  final VoidCallback onViewDetails;

  @override
  Widget build(BuildContext context) {
    final severity = violation['severity'] ?? 'UNKNOWN';
    final type = violation['violation_type'] ?? 'UNKNOWN';
    final description = violation['description'] ?? '';
    final suggestedResolution = violation['suggested_resolution'] ?? '';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ExpansionTile(
        leading: TraqIcon(
          AppAssets.iconAlert,
          color: StatusVisualMappers.dashboardSeverityColor(context, severity),
        ),
        title: Text(type),
        subtitle: Text(description),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Chip(
              label: Text(severity),
              backgroundColor: StatusVisualMappers.dashboardSeverityColor(
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
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: onCorrect,
              icon: TraqIcon(AppAssets.iconBuild, size: 16),
              label: const Text('Correct'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColorMapper.successColor(context),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ],
        ),
        children: [
          if (suggestedResolution.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Suggested Resolution:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(suggestedResolution),
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
                        icon: TraqIcon(AppAssets.iconSparkle),
                        label: const Text('Apply Fix'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              AppColorMapper.warningColor(context),
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
