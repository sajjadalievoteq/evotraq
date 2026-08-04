import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/data/models/admin/monitoring_models.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/utils/status_visual_mappers.dart';
import 'package:traqtrace_app/features/admin/utils/admin_alert_format_utils.dart';

class AlertsPanelRow extends StatelessWidget {
  const AlertsPanelRow({
    super.key,
    required this.alert,
    required this.onAcknowledge,
  });

  final PerformanceAlert alert;
  final Function(String) onAcknowledge;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: StatusVisualMappers.severityColor(context, alert.severity)
              .withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          TraqIcon(
            StatusVisualMappers.severityIcon(alert.severity),
            color: StatusVisualMappers.severityColor(context, alert.severity),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.message,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${alert.type} • ${AdminAlertFormatUtils.formatTime(alert.triggeredAt)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          if (!alert.acknowledged)
            TextButton(
              onPressed: () => onAcknowledge(alert.id),
              child: const Text(
                'Acknowledge',
                style: TextStyle(fontSize: 12),
              ),
            ),
          if (alert.acknowledged)
            TraqIcon(
              AppAssets.iconCheck,
              color: AppColorMapper.successColor(context),
              size: 16,
            ),
        ],
      ),
    );
  }
}
