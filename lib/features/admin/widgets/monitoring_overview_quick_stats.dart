import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/admin/monitoring_models.dart';
import 'package:traqtrace_app/features/admin/widgets/monitoring_overview_stat_row.dart';

class MonitoringOverviewQuickStats extends StatelessWidget {
  const MonitoringOverviewQuickStats({
    super.key,
    required this.performance,
    this.storage,
  });

  final PerformanceMetrics? performance;
  final StorageStatistics? storage;

  @override
  Widget build(BuildContext context) {
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
              child: MonitoringOverviewStatRow(
                label: 'Events/sec',
                value: performance!.eventsPerSecond.toStringAsFixed(1),
              ),
            ),
            Expanded(
              child: MonitoringOverviewStatRow(
                label: 'Avg Processing',
                value:
                    '${performance!.averageProcessingTimeMs.toStringAsFixed(1)}ms',
              ),
            ),
            Expanded(
              child: MonitoringOverviewStatRow(
                label: 'Success Rate',
                value: '${performance!.successRate.toStringAsFixed(1)}%',
              ),
            ),
            if (storage != null)
              Expanded(
                child: MonitoringOverviewStatRow(
                  label: 'Storage',
                  value: '${storage!.storageUtilizationGB.toStringAsFixed(1)}GB',
                ),
              ),
          ],
        ),
      ],
    );
  }
}
