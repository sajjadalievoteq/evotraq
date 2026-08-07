import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/job_queue_dashboard/job_queue_dashboard_snapshot.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/job_queue_dashboard/widgets/activity_and_health.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/job_queue_dashboard/widgets/metric_card.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/job_queue_dashboard/widgets/ops_cards.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/job_queue_dashboard/widgets/priority_distribution_card.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/job_queue_dashboard/widgets/queue_status_strip.dart';

/// Production operations console for the Job Queue dashboard tab.
class JobQueueDashboard extends StatelessWidget {
  const JobQueueDashboard({
    super.key,
    required this.snapshot,
    required this.onRefresh,
    required this.onSchedule,
    this.onOpenActive,
    this.onOpenQueue,
    this.onOpenHistory,
    this.onOpenWorkers,
  });

  final JobQueueDashboardSnapshot snapshot;
  final VoidCallback onRefresh;
  final VoidCallback onSchedule;
  final VoidCallback? onOpenActive;
  final VoidCallback? onOpenQueue;
  final VoidCallback? onOpenHistory;
  final VoidCallback? onOpenWorkers;

  @override
  Widget build(BuildContext context) {
    final estimatedWait = snapshot.queuedJobs == 0
        ? '0 sec'
        : snapshot.workerActive == 0
            ? '—'
            : '~${(snapshot.queuedJobs * 5 / snapshot.workerActive.clamp(1, 999)).ceil()}s';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        JobQueueStatusStrip(
          snapshot: snapshot,
          onRefresh: onRefresh,
          onSchedule: onSchedule,
        ),
        const SizedBox(height: TraqSpacing.lg),
        _MetricsGrid(
          snapshot: snapshot,
          onOpenActive: onOpenActive,
          onOpenQueue: onOpenQueue,
          onOpenHistory: onOpenHistory,
          onOpenWorkers: onOpenWorkers,
        ),
        const SizedBox(height: TraqSpacing.lg),
        JobQueueSystemHealthPanel(snapshot: snapshot),
        const SizedBox(height: TraqSpacing.lg),
        LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 980;
            final left = Column(
              children: [
                JobQueuePriorityDistributionCard(
                  distribution: snapshot.priorityDistribution,
                ),
                const SizedBox(height: TraqSpacing.lg),
                JobQueueWorkerPoolCard(
                  active: snapshot.workerActive,
                  poolSize: snapshot.workerPoolSize,
                  max: snapshot.workerMax,
                  utilization: snapshot.workerUtilization,
                ),
                const SizedBox(height: TraqSpacing.lg),
                JobQueueTimelineCard(activeJobs: snapshot.activeJobsList),
              ],
            );
            final right = Column(
              children: [
                JobQueueCapacityCard(
                  queueSize: snapshot.queueSize,
                  queueCapacity: snapshot.queueCapacity,
                  healthy: snapshot.healthy,
                  estimatedWaitLabel: estimatedWait,
                ),
                const SizedBox(height: TraqSpacing.lg),
                JobQueueJobTypeChart(
                  distribution: snapshot.jobTypeDistribution,
                ),
                const SizedBox(height: TraqSpacing.lg),
                JobQueueRecentActivityCard(
                  activeJobs: snapshot.activeJobsList,
                  history: snapshot.recentHistory,
                ),
              ],
            );

            if (!wide) {
              return Column(
                children: [
                  left,
                  const SizedBox(height: TraqSpacing.lg),
                  right,
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: left),
                const SizedBox(width: TraqSpacing.lg),
                Expanded(flex: 1, child: right),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _MetricsGrid extends StatelessWidget {
  const _MetricsGrid({
    required this.snapshot,
    this.onOpenActive,
    this.onOpenQueue,
    this.onOpenHistory,
    this.onOpenWorkers,
  });

  final JobQueueDashboardSnapshot snapshot;
  final VoidCallback? onOpenActive;
  final VoidCallback? onOpenQueue;
  final VoidCallback? onOpenHistory;
  final VoidCallback? onOpenWorkers;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final cards = [
      JobQueueMetricCard(
        title: 'Active jobs',
        value: '${snapshot.activeJobs}',
        subtitle: snapshot.activeJobs == 0 ? 'No jobs running' : 'In flight',
        iconAsset: AppAssets.iconPlay,
        accent: c.primary,
        sparkline: snapshot.activeSparkline,
        onTap: onOpenActive,
      ),
      JobQueueMetricCard(
        title: 'Queued jobs',
        value: '${snapshot.queuedJobs}',
        subtitle: snapshot.queuedJobs == 0 ? 'Queue clear' : 'Waiting',
        iconAsset: NavIcons.jobQueueManagement,
        accent: AppColorMapper.warningColor(context),
        sparkline: snapshot.queuedSparkline,
        onTap: onOpenQueue,
      ),
      JobQueueMetricCard(
        title: 'Completed',
        value: '${snapshot.completedJobs}',
        subtitle: 'History total',
        iconAsset: AppAssets.iconCheckCircle,
        accent: AppColorMapper.infoColor(context),
        sparkline: snapshot.activeSparkline,
        onTap: onOpenHistory,
      ),
      JobQueueMetricCard(
        title: 'Failed',
        value: '${snapshot.failedJobs}',
        subtitle: snapshot.failedJobs == 0 ? 'No failures' : 'Needs review',
        iconAsset: AppAssets.iconXCircle,
        accent: AppColorMapper.errorColor(context),
        onTap: onOpenHistory,
      ),
      JobQueueMetricCard(
        title: 'Workers',
        value: '${snapshot.workerActive}/${snapshot.workerMax}',
        subtitle:
            'Utilization ${(snapshot.workerUtilization * 100).toStringAsFixed(0)}%',
        iconAsset: AppAssets.iconUsers,
        accent: AppColorMapper.successColor(context),
        sparkline: snapshot.queuedSparkline,
        onTap: onOpenWorkers,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = width >= 1100
            ? 3
            : width >= 720
                ? 2
                : 1;
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: TraqSpacing.md,
          crossAxisSpacing: TraqSpacing.md,
          childAspectRatio: crossAxisCount == 1 ? 2.6 : 1.55,
          children: cards,
        );
      },
    );
  }
}
