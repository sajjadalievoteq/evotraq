import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/theme/traq_theme_tokens.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/job_queue_dashboard/job_queue_dashboard_snapshot.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/job_queue_dashboard/widgets/metric_card.dart';

class JobQueueMetricsGrid extends StatelessWidget {
  const JobQueueMetricsGrid({
    super.key,
    required this.snapshot,
    this.onOpenActive,
    this.onOpenQueue,
    this.onOpenHistory,
  });
  final JobQueueDashboardSnapshot snapshot;
  final VoidCallback? onOpenActive;
  final VoidCallback? onOpenQueue;
  final VoidCallback? onOpenHistory;

  @override
  Widget build(BuildContext context) {
    final cards = [
      JobQueueMetricCard(
        title: 'Active Jobs',
        value: '${snapshot.activeJobs}',
        subtitle: snapshot.activeJobs == 0 ? 'No jobs running' : 'In flight',
        iconAsset: AppAssets.iconPlay,
        accent: context.colors.primary,
        sparkline: snapshot.activeSparkline,
        onTap: onOpenActive,
      ),
      JobQueueMetricCard(
        title: 'Queued Jobs',
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
        subtitle: 'History',
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
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 900
            ? 4
            : constraints.maxWidth >= 560
            ? 2
            : 1;
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: TraqSpacing.md,
          crossAxisSpacing: TraqSpacing.md,
          childAspectRatio: crossAxisCount == 1
              ? 3.2
              : crossAxisCount == 2
              ? 2.4
              : 2.1,
          children: cards,
        );
      },
    );
  }
}
