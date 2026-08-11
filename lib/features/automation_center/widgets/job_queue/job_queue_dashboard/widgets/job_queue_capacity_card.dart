import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/job_queue_dashboard/widgets/sparkline_and_section.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/job_queue_dashboard/widgets/job_queue_empty_panel.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/job_queue_dashboard/widgets/status_badge.dart';
import 'package:traqtrace_app/core/utils/status_visual_mappers.dart';

class JobQueueCapacityCard extends StatelessWidget {
  const JobQueueCapacityCard({
    super.key,
    required this.queueSize,
    required this.queueCapacity,
    required this.healthy,
    required this.estimatedWaitLabel,
  });

  final int queueSize;
  final int queueCapacity;
  final bool healthy;
  final String estimatedWaitLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final usage = queueCapacity > 0
        ? (queueSize / queueCapacity).clamp(0.0, 1.0)
        : 0.0;
    final color = usage > 0.8
        ? AppColorMapper.errorColor(context)
        : AppColorMapper.successColor(context);

    return JobQueueDashboardSection(
      title: 'Queue capacity',
      trailing: JobQueueStatusBadge(
        label: healthy ? 'Healthy' : 'Issues',
        tone: healthy ? JobQueueStatusTone.ok : JobQueueStatusTone.warn,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                '$queueSize',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                ' / $queueCapacity',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: c.textMuted),
              ),
              const Spacer(),
              Text(
                'Wait $estimatedWaitLabel',
                style: Theme.of(
                  context,
                ).textTheme.labelMedium?.copyWith(color: c.textMuted),
              ),
            ],
          ),
          const SizedBox(height: TraqSpacing.md),
          ClipRRect(
            borderRadius: TraqRadius.chip,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: usage),
              duration: MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : TraqDuration.slow,
              builder: (context, value, _) => LinearProgressIndicator(
                value: value,
                minHeight: 10,
                backgroundColor: c.surfaceMuted,
                color: color,
              ),
            ),
          ),
          const SizedBox(height: TraqSpacing.sm),
          Text(
            '${(usage * 100).toStringAsFixed(0)}% utilized',
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: c.textMuted),
          ),
        ],
      ),
    );
  }
}
