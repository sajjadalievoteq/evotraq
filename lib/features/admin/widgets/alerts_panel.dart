import 'package:flutter/material.dart';
import '../models/monitoring_models.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/features/admin/widgets/utils/admin_helper_mappers.dart';

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
    final highestSeverity = _getHighestSeverity();
    final highestSeverityColor = AdminHelperMappers.severityColor(highestSeverity);

    return Card(
      color: highestSeverityColor.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                TraqIcon(AppAssets.iconAlert,
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
            ...alerts.take(3).map((alert) => _buildAlertRow(alert)).toList(),
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

  Widget _buildAlertRow(PerformanceAlert alert) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AdminHelperMappers.severityColor(alert.severity).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          TraqIcon(
            AdminHelperMappers.severityIcon(alert.severity),
            color: AdminHelperMappers.severityColor(alert.severity),
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
                  '${alert.type} • ${_formatTime(alert.triggeredAt)}',
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
              onPressed: () => onAlertAcknowledge(alert.id),
              child: const Text(
                'Acknowledge',
                style: TextStyle(fontSize: 12),
              ),
            ),
          if (alert.acknowledged)
            TraqIcon(AppAssets.iconCheck,
              color: Colors.green,
              size: 16,
            ),
        ],
      ),
    );
  }

  String _getHighestSeverity() {
    if (alerts.any((alert) => alert.severity.toUpperCase() == 'CRITICAL')) {
      return 'CRITICAL';
    }
    if (alerts.any((alert) => alert.severity.toUpperCase() == 'HIGH')) {
      return 'HIGH';
    }
    if (alerts.any((alert) => alert.severity.toUpperCase() == 'MEDIUM')) {
      return 'MEDIUM';
    }
    return 'LOW';
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:'
           '${dateTime.minute.toString().padLeft(2, '0')}';
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
                                  AdminHelperMappers.severityIcon(alert.severity),
                                  color: AdminHelperMappers.severityColor(alert.severity),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  alert.severity.toUpperCase(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AdminHelperMappers.severityColor(alert.severity),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  _formatDateTime(alert.triggeredAt),
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
                              Text(
                                'Details:',
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                              ...alert.details.entries.map((entry) => 
                                Text(
                                  '${entry.key}: ${entry.value}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                )
                              ).toList(),
                            ],
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (alert.acknowledged)
                                  const Text(
                                    'Acknowledged',
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                if (!alert.acknowledged)
                                  ElevatedButton(
                                    onPressed: () => onAlertAcknowledge(alert.id),
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

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
