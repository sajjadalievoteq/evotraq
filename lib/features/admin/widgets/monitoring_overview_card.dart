import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/data/models/admin/monitoring_models.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/utils/status_visual_mappers.dart';
import 'package:traqtrace_app/features/admin/utils/monitoring_overview_status_utils.dart';
import 'package:traqtrace_app/features/admin/widgets/monitoring_overview_metric_card.dart';
import 'package:traqtrace_app/features/admin/widgets/monitoring_overview_quick_stats.dart';

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
    final performanceStatus =
        MonitoringOverviewStatusUtils.performanceStatus(performance);
    final storageStatus =
        MonitoringOverviewStatusUtils.storageStatus(storage);
    final integrityStatus =
        MonitoringOverviewStatusUtils.integrityStatus(integrity);
    final alertsStatus = MonitoringOverviewStatusUtils.alertsStatus(alerts);
    final overallStatus = MonitoringOverviewStatusUtils.overallStatus(
      alerts: alerts,
      performanceStatus: performanceStatus,
      storageStatus: storageStatus,
      integrityStatus: integrityStatus,
    );
    final overallStatusColor =
        StatusVisualMappers.monitoringOverallStatusColor(context, overallStatus);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                TraqIcon(
                  StatusVisualMappers.monitoringOverallStatusIcon(overallStatus),
                  color: overallStatusColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'System Overview',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: overallStatusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: overallStatusColor.withOpacity(0.3)),
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
                  child: MonitoringOverviewMetricCard(
                    title: 'Performance',
                    status: performanceStatus,
                    color: StatusVisualMappers.monitoringPerformanceStatusColor(
                      context,
                      performanceStatus,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: MonitoringOverviewMetricCard(
                    title: 'Storage',
                    status: storageStatus,
                    color: StatusVisualMappers.monitoringStorageStatusColor(
                      context,
                      storageStatus,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: MonitoringOverviewMetricCard(
                    title: 'Integrity',
                    status: integrityStatus,
                    color: StatusVisualMappers.monitoringIntegrityStatusColor(
                      context,
                      integrityStatus,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: MonitoringOverviewMetricCard(
                    title: 'Alerts',
                    status: alertsStatus,
                    color: StatusVisualMappers.monitoringAlertsStatusColor(
                      context,
                      alertsStatus,
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
                  color: AppColorMapper.errorColor(context).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColorMapper.errorColor(context).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    TraqIcon(
                      AppAssets.iconAlert,
                      color: AppColorMapper.errorColor(context),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'System has ${alerts.length} active alert${alerts.length != 1 ? 's' : ''}',
                        style: TextStyle(
                          color: AppColorMapper.errorColor(context),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('View'),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            MonitoringOverviewQuickStats(
              performance: performance,
              storage: storage,
            ),
          ],
        ),
      ),
    );
  }
}
