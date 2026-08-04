import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/data/models/admin/monitoring_models.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/utils/status_visual_mappers.dart';
import 'package:traqtrace_app/features/admin/utils/admin_alert_format_utils.dart';
import 'package:traqtrace_app/features/admin/widgets/alerts_panel_row.dart';

class AlertsPanel extends StatelessWidget {
  final List<PerformanceAlert> alerts;
  final Function(String) onAlertAcknowledge;

  const AlertsPanel({
    super.key,
    required this.alerts,
    required this.onAlertAcknowledge,
  });

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) {
      return const SizedBox.shrink();
    }
    final highestSeverity = AdminAlertFormatUtils.highestSeverity(alerts);
    final highestSeverityColor =
        StatusVisualMappers.severityColor(context, highestSeverity);

    return Card(
      color: highestSeverityColor.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                TraqIcon(
                  AppAssets.iconAlert,
                  color: highestSeverityColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Active Alerts (${alerts.length})',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: highestSeverityColor,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => _showAllAlertsDialog(context),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...alerts
                .take(3)
                .map(
                  (alert) => AlertsPanelRow(
                    alert: alert,
                    onAcknowledge: onAlertAcknowledge,
                  ),
                ),
            if (alerts.length > 3)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '... and ${alerts.length - 3} more alerts',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showAllAlertsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'All Active Alerts',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: TraqIcon(AppAssets.iconX),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: alerts.length,
                  itemBuilder: (context, index) {
                    final alert = alerts[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                TraqIcon(
                                  StatusVisualMappers.severityIcon(
                                    alert.severity,
                                  ),
                                  color: StatusVisualMappers.severityColor(
                                    context,
                                    alert.severity,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  alert.severity.toUpperCase(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: StatusVisualMappers.severityColor(
                                      context,
                                      alert.severity,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  AdminAlertFormatUtils.formatDateTime(
                                    alert.triggeredAt,
                                  ),
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              alert.message,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              'Type: ${alert.type}',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            if (alert.details.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              const Text(
                                'Details:',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              ...alert.details.entries.map(
                                (entry) => Text(
                                  '${entry.key}: ${entry.value}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (alert.acknowledged)
                                  Text(
                                    'Acknowledged',
                                    style: TextStyle(
                                      color: AppColorMapper.successColor(
                                        context,
                                      ),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                if (!alert.acknowledged)
                                  ElevatedButton(
                                    onPressed: () =>
                                        onAlertAcknowledge(alert.id),
                                    child: const Text('Acknowledge'),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
