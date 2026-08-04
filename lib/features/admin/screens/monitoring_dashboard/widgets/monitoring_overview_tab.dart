import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/admin/monitoring_models.dart';
import 'package:traqtrace_app/features/admin/widgets/alerts_panel.dart';
import 'package:traqtrace_app/features/admin/widgets/event_type_metrics_chart.dart';
import 'package:traqtrace_app/features/admin/widgets/load_state.dart';
import 'package:traqtrace_app/features/admin/widgets/load_state_view.dart';
import 'package:traqtrace_app/features/admin/widgets/monitoring_overview_card.dart';
import 'package:traqtrace_app/features/admin/widgets/performance_chart.dart';

class MonitoringOverviewTab extends StatelessWidget {
  const MonitoringOverviewTab({
    super.key,
    required this.performanceState,
    required this.storageState,
    required this.integrityState,
    required this.alertsState,
    required this.performanceHistory,
    required this.onRetry,
    required this.onAlertAcknowledge,
  });

  final LoadState<PerformanceMetrics> performanceState;
  final LoadState<StorageStatistics> storageState;
  final LoadState<IntegrityStatistics> integrityState;
  final LoadState<List<PerformanceAlert>> alertsState;
  final List<PerformanceMetrics> performanceHistory;
  final VoidCallback onRetry;
  final void Function(String alertId) onAlertAcknowledge;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          MonitoringOverviewCard(
            performance: performanceState.data,
            storage: storageState.data,
            integrity: integrityState.data,
            alerts: alertsState.data ?? [],
          ),
          const SizedBox(height: 16),
          LoadStateView<List<PerformanceAlert>>(
            state: alertsState,
            loadingWidget: const SizedBox.shrink(),
            emptyWidget: const SizedBox.shrink(),
            onRetry: onRetry,
            builder: (context, alerts) {
              if (alerts.isEmpty) return const SizedBox.shrink();
              return Column(
                children: [
                  AlertsPanel(
                    alerts: alerts,
                    onAlertAcknowledge: onAlertAcknowledge,
                  ),
                  const SizedBox(height: 16),
                ],
              );
            },
          ),
          LoadStateView<PerformanceMetrics>(
            state: performanceState,
            loadingWidget: const SizedBox.shrink(),
            onRetry: onRetry,
            builder: (context, performance) {
              return Column(
                children: [
                  if (performanceHistory.isNotEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Real-time Performance',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 300,
                              child: PerformanceChart(
                                metrics: performanceHistory,
                                chartType: 'response_time',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  if (performance.eventTypeMetrics.isNotEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Event Type Metrics',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 300,
                              child: EventTypeMetricsChart(
                                eventTypeMetrics:
                                    performance.eventTypeMetrics,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
