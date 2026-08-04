import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/admin/monitoring_models.dart';
import 'package:traqtrace_app/features/admin/widgets/bulk_jobs_panel.dart';
import 'package:traqtrace_app/features/admin/widgets/load_state.dart';
import 'package:traqtrace_app/features/admin/widgets/load_state_view.dart';
import 'package:traqtrace_app/features/admin/widgets/performance_metrics_card.dart';

class MonitoringPerformanceTab extends StatelessWidget {
  const MonitoringPerformanceTab({
    super.key,
    required this.performanceState,
    required this.currentBulkJobs,
    required this.onRetry,
    required this.onConfigureIsolation,
    required this.onResolveDeadlocks,
    required this.onJobCancel,
    required this.onJobRetry,
    required this.onRefreshJobs,
  });

  final LoadState<PerformanceMetrics> performanceState;
  final List<BulkJobStatus> currentBulkJobs;
  final VoidCallback onRetry;
  final void Function(String level) onConfigureIsolation;
  final VoidCallback onResolveDeadlocks;
  final void Function(String jobId) onJobCancel;
  final void Function(String jobId) onJobRetry;
  final VoidCallback onRefreshJobs;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          LoadStateView<PerformanceMetrics>(
            state: performanceState,
            onRetry: onRetry,
            builder: (context, performance) => PerformanceMetricsCard(
              performance: performance,
              onConfigureIsolation: onConfigureIsolation,
              onResolveDeadlocks: onResolveDeadlocks,
            ),
          ),
          const SizedBox(height: 16),
          BulkJobsPanel(
            jobs: currentBulkJobs,
            onJobCancel: onJobCancel,
            onJobRetry: onJobRetry,
            onRefresh: onRefreshJobs,
          ),
        ],
      ),
    );
  }
}
