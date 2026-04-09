import 'package:flutter/material.dart';
import '../models/monitoring_models.dart';

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
                  'Updated: ${_formatTime(performance.timestamp)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Key performance indicators
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    'Events/Second',
                    performance.eventsPerSecond.toStringAsFixed(2),
                    Icons.speed,
                    _getPerformanceColor(performance.eventsPerSecond, 100, 50),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricTile(
                    'Avg Processing Time',
                    '${performance.averageProcessingTimeMs.toStringAsFixed(1)}ms',
                    Icons.timer,
                    _getPerformanceColor(performance.averageProcessingTimeMs, 100, 500, inverted: true),
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
                    Icons.check_circle,
                    _getPerformanceColor(performance.successRate, 95, 90),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricTile(
                    'Error Rate',
                    '${performance.errorRate.toStringAsFixed(2)}%',
                    Icons.error,
                    _getPerformanceColor(performance.errorRate, 1, 5, inverted: true),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // System metrics
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    'Memory Usage',
                    '${performance.memoryUsagePercentage.toStringAsFixed(1)}%',
                    Icons.memory,
                    _getPerformanceColor(performance.memoryUsagePercentage, 70, 85, inverted: true),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricTile(
                    'CPU Usage',
                    '${performance.cpuUsagePercentage.toStringAsFixed(1)}%',
                    Icons.developer_board,
                    _getPerformanceColor(performance.cpuUsagePercentage, 70, 85, inverted: true),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Database metrics
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    'DB Connections',
                    '${performance.activeConnections}',
                    Icons.storage,
                    _getPerformanceColor(performance.databaseConnectionUtilization, 70, 85, inverted: true),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricTile(
                    'Queued Transactions',
                    '${performance.queuedTransactions}',
                    Icons.queue,
                    _getPerformanceColor(performance.queuedTransactions.toDouble(), 5, 20, inverted: true),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Action buttons
            Wrap(
              spacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _showIsolationDialog(context),
                  icon: const Icon(Icons.settings),
                  label: const Text('Configure Isolation'),
                ),
                ElevatedButton.icon(
                  onPressed: onResolveDeadlocks,
                  icon: const Icon(Icons.healing),
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

  Widget _buildMetricTile(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
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

  Color _getPerformanceColor(double value, double good, double warning, {bool inverted = false}) {
    if (inverted) {
      if (value <= good) return Colors.green;
      if (value <= warning) return Colors.orange;
      return Colors.red;
    } else {
      if (value >= good) return Colors.green;
      if (value >= warning) return Colors.orange;
      return Colors.red;
    }
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:'
           '${dateTime.minute.toString().padLeft(2, '0')}:'
           '${dateTime.second.toString().padLeft(2, '0')}';
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
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
