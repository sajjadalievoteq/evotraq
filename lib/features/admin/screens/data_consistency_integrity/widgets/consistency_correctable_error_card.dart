import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/utils/status_visual_mappers.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

class ConsistencyCorrectableErrorCard extends StatelessWidget {
  const ConsistencyCorrectableErrorCard({
    super.key,
    required this.error,
    required this.onCorrect,
  });

  final Map<String, dynamic> error;
  final VoidCallback onCorrect;

  @override
  Widget build(BuildContext context) {
    final type = error['error_type'] ?? 'UNKNOWN';
    final severity = error['severity'] ?? 'MEDIUM';
    final description = error['error_description'] ?? '';
    final correctionType = error['correction_type'] ?? 'MANUAL';
    final isCorrectable = error['is_correctable'] ?? false;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                TraqIcon(
                  isCorrectable ? NavIcons.systemTools : AppAssets.iconAlert,
                  color: isCorrectable
                      ? AppColorMapper.successColor(context)
                      : AppColorMapper.warningColor(context),
                ),
                const SizedBox(width: 8),
                Text(
                  type,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (isCorrectable)
                  ElevatedButton(
                    onPressed: onCorrect,
                    child: const Text('Correct'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(description),
            const SizedBox(height: 8),
            Row(
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
                Chip(
                  label: Text(correctionType),
                  backgroundColor:
                      AppColorMapper.infoColor(context).withOpacity(0.1),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
