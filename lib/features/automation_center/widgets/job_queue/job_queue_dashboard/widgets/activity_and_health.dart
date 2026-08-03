import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/job_queue_dashboard/job_queue_dashboard_snapshot.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/job_queue_dashboard/widgets/sparkline_and_section.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/job_queue_dashboard/widgets/status_badge.dart';
import 'package:traqtrace_app/features/admin/widgets/utils/admin_helper_mappers.dart';

class JobQueueSystemHealthPanel extends StatelessWidget {
  const JobQueueSystemHealthPanel({
    super.key,
    required this.snapshot,
  });

  final JobQueueDashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return JobQueueDashboardSection(
      title: 'System health',
      trailing: JobQueueStatusBadge(
        label: snapshot.statusLabel,
        tone: snapshot.processingPaused
            ? JobQueueStatusTone.warn
            : (snapshot.healthy
                ? JobQueueStatusTone.ok
                : JobQueueStatusTone.err),
      ),
      child: Column(
        children: [
          Wrap(
            spacing: TraqSpacing.md,
            runSpacing: TraqSpacing.md,
            children: [
              _MiniGauge(
                label: 'Queue usage',
                value: snapshot.queueUsage,
                color: snapshot.queueUsage > 0.8
                    ? AppColorMapper.errorColor(context)
                    : AppColorMapper.successColor(context),
              ),
              _MiniGauge(
                label: 'Workers',
                value: snapshot.workerUtilization,
                color: snapshot.workerUtilization > 0.9
                    ? AppColorMapper.errorColor(context)
                    : AppColorMapper.infoColor(context),
              ),
              _StatPill(
                label: 'Processing',
                value: snapshot.processingPaused ? 'Paused' : 'Running',
                icon: snapshot.processingPaused
                    ? AppAssets.iconPause
                    : AppAssets.iconPlay,
              ),
            ],
          ),
          if (snapshot.issues.isNotEmpty) ...[
            const SizedBox(height: TraqSpacing.md),
            ...snapshot.issues.map(
              (issue) => Padding(
                padding: const EdgeInsets.only(bottom: TraqSpacing.xs),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TraqIcon(
                      AppAssets.iconAlert,
                      size: 14,
                      color: AppColorMapper.warningColor(context),
                    ),
                    const SizedBox(width: TraqSpacing.sm),
                    Expanded(
                      child: Text(
                        issue,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: c.textSecondary,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MiniGauge extends StatelessWidget {
  const _MiniGauge({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SizedBox(
      width: 120,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: c.textMuted,
                ),
          ),
          const SizedBox(height: TraqSpacing.xs),
          ClipRRect(
            borderRadius: TraqRadius.chip,
            child: LinearProgressIndicator(
              value: value.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: c.surfaceMuted,
              color: color,
            ),
          ),
          const SizedBox(height: TraqSpacing.xs),
          Text(
            '${(value * 100).clamp(0, 100).toStringAsFixed(0)}%',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final String icon;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: TraqSpacing.md,
        vertical: TraqSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: c.surfaceMuted,
        borderRadius: TraqRadius.card,
        border: Border.all(color: c.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TraqIcon(icon, size: 14, color: c.textMuted),
          const SizedBox(width: TraqSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: c.textMuted,
                    ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class JobQueueRecentActivityCard extends StatelessWidget {
  const JobQueueRecentActivityCard({
    super.key,
    required this.activeJobs,
    required this.history,
  });

  final List<Map<String, dynamic>> activeJobs;
  final List<Map<String, dynamic>> history;

  @override
  Widget build(BuildContext context) {
    final items = <_ActivityItem>[
      for (final job in activeJobs.take(4))
        _ActivityItem(
          title: '${job['jobType'] ?? 'Job'} started',
          subtitle: '${job['jobId'] ?? ''}',
          status: '${job['status'] ?? 'RUNNING'}',
          icon: AppAssets.iconPlay,
        ),
      for (final job in history.take(6))
        _ActivityItem(
          title: '${job['jobType'] ?? 'Job'} ${job['status'] ?? ''}'.trim(),
          subtitle: '${job['jobId'] ?? ''}',
          status: '${job['status'] ?? ''}',
          icon: _iconFor('${job['status'] ?? ''}'),
        ),
    ];

    return JobQueueDashboardSection(
      title: 'Recent activity',
      child: items.isEmpty
          ? const JobQueueEmptyPanel(
              title: 'No recent activity',
              subtitle: 'Scheduled and completed jobs show up here.',
              iconAsset: AppAssets.iconClock,
            )
          : Column(
              children: [
                for (final item in items.take(8))
                  Padding(
                    padding: const EdgeInsets.only(bottom: TraqSpacing.md),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TraqIcon(
                          item.icon,
                          size: 16,
                          color: AdminHelperMappers.bulkJobStatusColor(
                            context,
                            item.status,
                          ),
                        ),
                        const SizedBox(width: TraqSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              if (item.subtitle.isNotEmpty)
                                Text(
                                  item.subtitle,
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                        color: context.colors.textMuted,
                                      ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }

  String _iconFor(String status) {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
        return AppAssets.iconCheckCircle;
      case 'FAILED':
        return AppAssets.iconXCircle;
      case 'CANCELLED':
        return AppAssets.iconMinus;
      case 'RUNNING':
        return AppAssets.iconPlay;
      default:
        return AppAssets.iconClock;
    }
  }
}

class _ActivityItem {
  const _ActivityItem({
    required this.title,
    required this.subtitle,
    required this.status,
    required this.icon,
  });
  final String title;
  final String subtitle;
  final String status;
  final String icon;
}

class JobQueueTimelineCard extends StatelessWidget {
  const JobQueueTimelineCard({
    super.key,
    required this.activeJobs,
  });

  final List<Map<String, dynamic>> activeJobs;

  @override
  Widget build(BuildContext context) {
    return JobQueueDashboardSection(
      title: 'Job timeline',
      child: activeJobs.isEmpty
          ? const JobQueueEmptyPanel(
              title: 'Nothing running',
              subtitle: 'Live job progress appears while work is active.',
              iconAsset: AppAssets.iconPlay,
            )
          : Column(
              children: [
                for (final job in activeJobs)
                  Padding(
                    padding: const EdgeInsets.only(bottom: TraqSpacing.md),
                    child: _TimelineRow(job: job),
                  ),
              ],
            ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.job});
  final Map<String, dynamic> job;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final progress = ((job['progress'] as num?)?.toDouble() ?? 0) / 100.0;
    final color = AppColorMapper.infoColor(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '${job['jobType'] ?? 'Job'}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              '${job['elapsedTime'] ?? ''}',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: c.textMuted,
                  ),
            ),
          ],
        ),
        const SizedBox(height: TraqSpacing.xs),
        ClipRRect(
          borderRadius: TraqRadius.chip,
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 6,
            backgroundColor: c.surfaceMuted,
            color: color,
          ),
        ),
      ],
    );
  }
}
