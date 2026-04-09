import 'package:flutter/material.dart';
import '../models/monitoring_models.dart';

class MonitoringOverviewCard extends StatelessWidget {
  final PerformanceMetrics? performance;
  final StorageStatistics? storage;
  final IntegrityStatistics? integrity;
  final List<PerformanceAlert> alerts;

  const MonitoringOverviewCard({
    super.key,
    this.performance,
    this.storage,
    this.integrity,
    required this.alerts,
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
              children: [
                Icon(
                  _getOverallStatusIcon(),
                  color: _getOverallStatusColor(),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'System Overview',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getOverallStatusColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _getOverallStatusColor().withOpacity(0.3)),
                  ),
                  child: Text(
                    _getOverallStatus(),
                    style: TextStyle(
                      color: _getOverallStatusColor(),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildMetricCard('Performance', _getPerformanceStatus(), _getPerformanceColor())),
                const SizedBox(width: 8),
                Expanded(child: _buildMetricCard('Storage', _getStorageStatus(), _getStorageColor())),
                const SizedBox(width: 8),
                Expanded(child: _buildMetricCard('Integrity', _getIntegrityStatus(), _getIntegrityColor())),
                const SizedBox(width: 8),
                Expanded(child: _buildMetricCard('Alerts', _getAlertsStatus(), _getAlertsColor())),
              ],
            ),
            if (alerts.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'System has ${alerts.length} active alert${alerts.length != 1 ? 's' : ''}',
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Switch to alerts tab or show alerts dialog
                      },
                      child: const Text('View'),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            _buildQuickStats(),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String status, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            status,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    if (performance == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Stats',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildStatRow('Events/sec', '${performance!.eventsPerSecond.toStringAsFixed(1)}'),
            ),
            Expanded(
              child: _buildStatRow('Avg Processing', '${performance!.averageProcessingTimeMs.toStringAsFixed(1)}ms'),
            ),
            Expanded(
              child: _buildStatRow('Success Rate', '${performance!.successRate.toStringAsFixed(1)}%'),
            ),
            if (storage != null)
              Expanded(
                child: _buildStatRow('Storage', '${storage!.storageUtilizationGB.toStringAsFixed(1)}GB'),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String _getOverallStatus() {
    if (alerts.any((alert) => alert.severity.toUpperCase() == 'CRITICAL')) {
      return 'CRITICAL';
    }
    if (alerts.any((alert) => alert.severity.toUpperCase() == 'HIGH')) {
      return 'WARNING';
    }
    if (_getPerformanceStatus() == 'POOR' || _getStorageStatus() == 'CRITICAL' || _getIntegrityStatus() == 'POOR') {
      return 'DEGRADED';
    }
    return 'HEALTHY';
  }

  Color _getOverallStatusColor() {
    final status = _getOverallStatus();
    switch (status) {
      case 'CRITICAL':
        return Colors.red[800]!;
      case 'WARNING':
        return Colors.orange;
      case 'DEGRADED':
        return Colors.yellow[700]!;
      case 'HEALTHY':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getOverallStatusIcon() {
    final status = _getOverallStatus();
    switch (status) {
      case 'CRITICAL':
        return Icons.dangerous;
      case 'WARNING':
        return Icons.warning;
      case 'DEGRADED':
        return Icons.info;
      case 'HEALTHY':
        return Icons.check_circle;
      default:
        return Icons.help;
    }
  }

  String _getPerformanceStatus() {
    if (performance == null) return 'UNKNOWN';
    if (performance!.successRate < 90) return 'POOR';
    if (performance!.successRate < 95) return 'FAIR';
    if (performance!.averageProcessingTimeMs > 1000) return 'SLOW';
    return 'GOOD';
  }

  Color _getPerformanceColor() {
    final status = _getPerformanceStatus();
    switch (status) {
      case 'POOR':
        return Colors.red;
      case 'FAIR':
        return Colors.orange;
      case 'SLOW':
        return Colors.yellow[700]!;
      case 'GOOD':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getStorageStatus() {
    if (storage == null) return 'UNKNOWN';
    if (storage!.storageUtilizationGB > 50) return 'CRITICAL';
    if (storage!.storageUtilizationGB > 25) return 'HIGH';
    if (storage!.storageUtilizationGB > 10) return 'MODERATE';
    return 'LOW';
  }

  Color _getStorageColor() {
    final status = _getStorageStatus();
    switch (status) {
      case 'CRITICAL':
        return Colors.red;
      case 'HIGH':
        return Colors.orange;
      case 'MODERATE':
        return Colors.yellow[700]!;
      case 'LOW':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getIntegrityStatus() {
    if (integrity == null) return 'UNKNOWN';
    if (integrity!.overallIntegrityScore < 70) return 'POOR';
    if (integrity!.overallIntegrityScore < 90) return 'FAIR';
    return 'EXCELLENT';
  }

  Color _getIntegrityColor() {
    final status = _getIntegrityStatus();
    switch (status) {
      case 'POOR':
        return Colors.red;
      case 'FAIR':
        return Colors.orange;
      case 'EXCELLENT':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getAlertsStatus() {
    if (alerts.isEmpty) return 'NONE';
    if (alerts.any((alert) => alert.severity.toUpperCase() == 'CRITICAL')) return 'CRITICAL';
    if (alerts.any((alert) => alert.severity.toUpperCase() == 'HIGH')) return 'HIGH';
    return 'ACTIVE';
  }

  Color _getAlertsColor() {
    final status = _getAlertsStatus();
    switch (status) {
      case 'NONE':
        return Colors.green;
      case 'CRITICAL':
        return Colors.red;
      case 'HIGH':
        return Colors.orange;
      case 'ACTIVE':
        return Colors.yellow[700]!;
      default:
        return Colors.grey;
    }
  }
}
