import 'package:flutter/material.dart';
import '../models/monitoring_models.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/features/admin/widgets/utils/admin_helper_mappers.dart';

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
    final overallStatus = _getOverallStatus();
    final overallStatusColor =
        AdminHelperMappers.monitoringOverallStatusColor(overallStatus);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                TraqIcon(
                  AdminHelperMappers.monitoringOverallStatusIcon(overallStatus),
                  color: overallStatusColor,
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
                    color: overallStatusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: overallStatusColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    overallStatus,
                    style: TextStyle(
                      color: overallStatusColor,
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
                Expanded(
                  child: _buildMetricCard(
                    'Performance',
                    _getPerformanceStatus(),
                    AdminHelperMappers.monitoringPerformanceStatusColor(
                      _getPerformanceStatus(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMetricCard(
                    'Storage',
                    _getStorageStatus(),
                    AdminHelperMappers.monitoringStorageStatusColor(
                      _getStorageStatus(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMetricCard(
                    'Integrity',
                    _getIntegrityStatus(),
                    AdminHelperMappers.monitoringIntegrityStatusColor(
                      _getIntegrityStatus(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMetricCard(
                    'Alerts',
                    _getAlertsStatus(),
                    AdminHelperMappers.monitoringAlertsStatusColor(
                      _getAlertsStatus(),
                    ),
                  ),
                ),
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
                    TraqIcon(AppAssets.iconAlert, color: Colors.red, size: 20),
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
              child: _buildStatRow('Events/sec', performance!.eventsPerSecond.toStringAsFixed(1)),
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

  String _getPerformanceStatus() {
    if (performance == null) return 'UNKNOWN';
    if (performance!.successRate < 90) return 'POOR';
    if (performance!.successRate < 95) return 'FAIR';
    if (performance!.averageProcessingTimeMs > 1000) return 'SLOW';
    return 'GOOD';
  }

  String _getStorageStatus() {
    if (storage == null) return 'UNKNOWN';
    if (storage!.storageUtilizationGB > 50) return 'CRITICAL';
    if (storage!.storageUtilizationGB > 25) return 'HIGH';
    if (storage!.storageUtilizationGB > 10) return 'MODERATE';
    return 'LOW';
  }

  String _getIntegrityStatus() {
    if (integrity == null) return 'UNKNOWN';
    if (integrity!.overallIntegrityScore < 70) return 'POOR';
    if (integrity!.overallIntegrityScore < 90) return 'FAIR';
    return 'EXCELLENT';
  }

  String _getAlertsStatus() {
    if (alerts.isEmpty) return 'NONE';
    if (alerts.any((alert) => alert.severity.toUpperCase() == 'CRITICAL')) return 'CRITICAL';
    if (alerts.any((alert) => alert.severity.toUpperCase() == 'HIGH')) return 'HIGH';
    return 'ACTIVE';
  }

}
