import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/job_queue_dashboard/job_queue_dashboard_snapshot.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/job_queue_dashboard/widgets/status_badge.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/job_queue_dashboard/widgets/strip_metric_tile.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/job_queue_dashboard/widgets/updated_timestamp.dart';

class JobQueueStatusStrip extends StatelessWidget {
  const JobQueueStatusStrip({
    super.key,
    required this.snapshot,
    required this.onRefresh,
    required this.onSchedule,
  });
  final JobQueueDashboardSnapshot snapshot;
  final VoidCallback onRefresh;
  final VoidCallback onSchedule;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tone = snapshot.processingPaused
        ? JobQueueStatusTone.warn
        : (snapshot.healthy ? JobQueueStatusTone.ok : JobQueueStatusTone.err);
    final metrics = <JobQueueStripMetric>[
      JobQueueStripMetric(
        icon: NavIcons.jobQueueManagement,
        value: '${snapshot.queuedJobs}',
        label: 'Queue',
        color: AppColorMapper.warningColor(context),
      ),
      JobQueueStripMetric(
        icon: AppAssets.iconPlay,
        value: '${snapshot.activeJobs}',
        label: 'Running',
        color: AppColorMapper.infoColor(context),
      ),
      JobQueueStripMetric(
        icon: AppAssets.iconUsers,
        value: '${snapshot.workerActive} / ${snapshot.workerMax}',
        label: 'Busy / capacity',
        color: AppColorMapper.successColor(context),
      ),
      JobQueueStripMetric(
        icon: AppAssets.iconCheckCircle,
        value: snapshot.successRateOrNull == null
            ? '—'
            : '${(snapshot.successRateOrNull! * 100).toStringAsFixed(0)}%',
        label: 'Success',
        color: AppColorMapper.successColor(context),
      ),
    ];
    return TraqCard(
      padding: const EdgeInsets.symmetric(
        horizontal: TraqSpacing.lg,
        vertical: TraqSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: TraqSpacing.lg,
            runSpacing: TraqSpacing.md,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Queue Health',
                    style: context.text.cap.copyWith(color: colors.textMuted),
                  ),
                  const SizedBox(height: TraqSpacing.xs),
                  JobQueueStatusBadge(
                    label: snapshot.statusLabel,
                    tone: tone,
                    pulse: snapshot.healthy && !snapshot.processingPaused,
                  ),
                ],
              ),
              for (final metric in metrics)
                JobQueueStripMetricTile(metric: metric),
            ],
          ),
          const SizedBox(height: TraqSpacing.md),
          Align(
            alignment: Alignment.centerRight,
            child: JobQueueUpdatedTimestamp(lastUpdated: snapshot.lastUpdated),
          ),
        ],
      ),
    );
  }
}
