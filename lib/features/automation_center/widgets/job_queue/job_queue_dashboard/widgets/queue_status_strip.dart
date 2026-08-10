import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/job_queue_dashboard/job_queue_dashboard_snapshot.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/job_queue_dashboard/widgets/status_badge.dart';

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
    final c = context.colors;
    final tone = snapshot.processingPaused
        ? JobQueueStatusTone.warn
        : (snapshot.healthy ? JobQueueStatusTone.ok : JobQueueStatusTone.err);

    // Semantic strip metrics (icon + color + label — never color-only).
    final metrics = <_StripMetric>[
      _StripMetric(
        icon: NavIcons.jobQueueManagement,
        value: '${snapshot.queuedJobs}',
        label: 'Queue',
        color: AppColorMapper.warningColor(context),
      ),
      _StripMetric(
        icon: AppAssets.iconPlay,
        value: '${snapshot.activeJobs}',
        label: 'Running',
        color: AppColorMapper.infoColor(context),
      ),
      _StripMetric(
        icon: AppAssets.iconUsers,
        value: '${snapshot.workerActive} / ${snapshot.workerMax}',
        label: 'Busy / capacity',
        color: AppColorMapper.successColor(context),
      ),
      _StripMetric(
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
                    style: context.text.cap.copyWith(color: c.textMuted),
                  ),
                  const SizedBox(height: TraqSpacing.xs),
                  JobQueueStatusBadge(
                    label: snapshot.statusLabel,
                    tone: tone,
                    pulse: snapshot.healthy && !snapshot.processingPaused,
                  ),
                ],
              ),
              for (final m in metrics) _StripMetricTile(metric: m),
            ],
          ),
          const SizedBox(height: TraqSpacing.md),
          Align(
            alignment: Alignment.centerRight,
            child: _Toolbar(lastUpdated: snapshot.lastUpdated),
          ),
        ],
      ),
    );
  }
}

class _StripMetric {
  const _StripMetric({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });
  final String icon;
  final String value;
  final String label;
  final Color color;
}

class _StripMetricTile extends StatelessWidget {
  const _StripMetricTile({required this.metric});
  final _StripMetric metric;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TraqIcon(metric.icon, size: 16, color: metric.color),
        const SizedBox(width: TraqSpacing.sm),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              metric.value,
              style: context.text.h3.copyWith(
                fontWeight: FontWeight.w700,
                color: c.textPrimary,
                height: 1.1,
              ),
            ),
            Text(
              metric.label,
              style: context.text.cap.copyWith(color: c.textMuted),
            ),
          ],
        ),
      ],
    );
  }
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({required this.lastUpdated});

  final DateTime? lastUpdated;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final time = lastUpdated == null
        ? '—'
        : DateFormat.Hms().format(lastUpdated!.toLocal());

    return Text(
      'Updated $time',
      style: context.text.cap.copyWith(color: c.textMuted),
    );
  }
}
