import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/display_date_utils.dart';
import '../models/monitoring_models.dart';
import 'package:traqtrace_app/features/admin/widgets/utils/admin_helper_mappers.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';

class PerformanceMetricsCard extends StatelessWidget {
  final PerformanceMetrics performance;
  final Function(String) onConfigureIsolation;
  final VoidCallback onResolveDeadlocks;

  const PerformanceMetricsCard({
    super.key,
    required this.performance,
    required this.onConfigureIsolation,
    required this.onResolveDeadlocks,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Performance Metrics',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Updated: ${DisplayDateUtils.hms(performance.timestamp)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    'Events/Second',
                    performance.eventsPerSecond.toStringAsFixed(2),
                    NavIcons.performanceOptimization,
                    AdminHelperMappers.performanceColor(
                      performance.eventsPerSecond,
                      100,
                      50,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricTile(
                    'Avg Processing Time',
                    '${performance.averageProcessingTimeMs.toStringAsFixed(1)}ms',
                    NavIcons.performanceTests,
                    AdminHelperMappers.performanceColor(
                      performance.averageProcessingTimeMs,
                      100,
                      500,
                      inverted: true,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    'Success Rate',
                    '${performance.successRate.toStringAsFixed(1)}%',
                    AppAssets.iconCheckCircle,
                    AdminHelperMappers.performanceColor(
                      performance.successRate,
                      95,
                      90,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricTile(
                    'Error Rate',
                    '${performance.errorRate.toStringAsFixed(2)}%',
                    AppAssets.iconXCircle,
                    AdminHelperMappers.performanceColor(
                      performance.errorRate,
                      1,
                      5,
                      inverted: true,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    'Memory Usage',
                    '${performance.memoryUsagePercentage.toStringAsFixed(1)}%',
                    NavIcons.eventSerialization,
                    AdminHelperMappers.performanceColor(
                      performance.memoryUsagePercentage,
                      70,
                      85,
                      inverted: true,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricTile(
                    'CPU Usage',
                    '${performance.cpuUsagePercentage.toStringAsFixed(1)}%',
                    NavIcons.eventSerialization,
                    AdminHelperMappers.performanceColor(
                      performance.cpuUsagePercentage,
                      70,
                      85,
                      inverted: true,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    'DB Connections',
                    '${performance.activeConnections}',
                    NavIcons.databasePartitioning,
                    AdminHelperMappers.performanceColor(
                      performance.databaseConnectionUtilization,
                      70,
                      85,
                      inverted: true,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricTile(
                    'Queued Transactions',
                    '${performance.queuedTransactions}',
                    NavIcons.jobQueueManagement,
                    AdminHelperMappers.performanceColor(
                      performance.queuedTransactions.toDouble(),
                      5,
                      20,
                      inverted: true,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            Wrap(
              spacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _showIsolationDialog(context),
                  icon: TraqIcon(AppAssets.iconSettings),
                  label: const Text('Configure Isolation'),
                ),
                ElevatedButton.icon(
                  onPressed: onResolveDeadlocks,
                  icon: const TraqIcon(AppAssets.iconMedical),
                  label: const Text('Resolve Deadlocks'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile(String title, String value, String iconAsset, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          TraqIcon(iconAsset, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 11),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showIsolationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Configure Transaction Isolation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('READ_UNCOMMITTED'),
              onTap: () {
                Navigator.pop(context);
                onConfigureIsolation('READ_UNCOMMITTED');
              },
            ),
            ListTile(
              title: const Text('READ_COMMITTED'),
              onTap: () {
                Navigator.pop(context);
                onConfigureIsolation('READ_COMMITTED');
              },
            ),
            ListTile(
              title: const Text('REPEATABLE_READ'),
              onTap: () {
                Navigator.pop(context);
                onConfigureIsolation('REPEATABLE_READ');
              },
            ),
            ListTile(
              title: const Text('SERIALIZABLE'),
              onTap: () {
                Navigator.pop(context);
                onConfigureIsolation('SERIALIZABLE');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}