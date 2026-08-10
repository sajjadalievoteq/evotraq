import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/job_queue_dashboard/widgets/sparkline_and_section.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/job_queue_dashboard/widgets/job_queue_empty_panel.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/job_queue_dashboard/widgets/status_badge.dart';
import 'package:traqtrace_app/core/utils/status_visual_mappers.dart';

class JobQueueJobTypeChart extends StatelessWidget {
  const JobQueueJobTypeChart({super.key, required this.distribution});

  final Map<String, int> distribution;

  @override
  Widget build(BuildContext context) {
    final entries = distribution.entries.where((e) => e.value > 0).toList();
    final total = entries.fold<int>(0, (s, e) => s + e.value);

    return JobQueueDashboardSection(
      title: 'Job types',
      child: total <= 0
          ? const JobQueueEmptyPanel(
              title: 'No active or queued jobs',
              subtitle: 'Type mix appears when the queue has work.',
              iconAsset: AppAssets.iconWork,
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 320;
                final chart = SizedBox(
                  height: 160,
                  width: 160,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 42,
                          sections: [
                            for (var i = 0; i < entries.length; i++)
                              PieChartSectionData(
                                value: entries[i].value.toDouble(),
                                color: StatusVisualMappers.jobTypeColor(
                                  context,
                                  entries[i].key,
                                ),
                                radius: 28,
                                showTitle: false,
                              ),
                          ],
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$total',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          Text(
                            'Total',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(color: context.colors.textMuted),
                          ),
                        ],
                      ),
                    ],
                  ),
                );

                final legend = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final e in entries)
                      Padding(
                        padding: const EdgeInsets.only(bottom: TraqSpacing.sm),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: StatusVisualMappers.jobTypeColor(
                                  context,
                                  e.key,
                                ),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: TraqSpacing.sm),
                            Expanded(
                              child: Text(
                                e.key,
                                style: Theme.of(context).textTheme.bodySmall,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '${e.value}',
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                  ],
                );

                if (compact) {
                  return Column(
                    children: [
                      chart,
                      const SizedBox(height: TraqSpacing.lg),
                      legend,
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    chart,
                    const SizedBox(width: TraqSpacing.lg),
                    Expanded(child: legend),
                  ],
                );
              },
            ),
    );
  }
}

class JobQueueWorkerPoolCard extends StatelessWidget {
  const JobQueueWorkerPoolCard({
    super.key,
    required this.active,
    required this.poolSize,
    required this.max,
    required this.utilization,
  });

  final int active;
  final int poolSize;
  final int max;
  final double utilization;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final util = utilization.clamp(0.0, 1.0);
    final color = util > 0.9
        ? AppColorMapper.errorColor(context)
        : util > 0.7
        ? AppColorMapper.warningColor(context)
        : AppColorMapper.infoColor(context);

    return JobQueueDashboardSection(
      title: 'Worker pool',
      trailing: JobQueueStatusBadge(
        label: util > 0.9 ? 'Hot' : (active == 0 ? 'Idle' : 'Active'),
        tone: util > 0.9
            ? JobQueueStatusTone.err
            : (active == 0
                  ? JobQueueStatusTone.muted
                  : JobQueueStatusTone.info),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              SizedBox(
                width: 72,
                height: 72,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: util),
                  duration: MediaQuery.disableAnimationsOf(context)
                      ? Duration.zero
                      : TraqDuration.slow,
                  builder: (context, value, _) => CustomPaint(
                    painter: _RingPainter(
                      progress: value,
                      track: c.surfaceMuted,
                      color: color,
                    ),
                    child: Center(
                      child: Text(
                        '${(util * 100).toStringAsFixed(0)}%',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: TraqSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$active / $max workers',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: TraqSpacing.xs),
                    Text(
                      'Pool size $poolSize · max $max',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: c.textMuted),
                    ),
                    const SizedBox(height: TraqSpacing.md),
                    ClipRRect(
                      borderRadius: TraqRadius.chip,
                      child: LinearProgressIndicator(
                        value: max > 0 ? active / max : 0,
                        minHeight: 8,
                        backgroundColor: c.surfaceMuted,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: TraqSpacing.md),
          Wrap(
            spacing: TraqSpacing.xs,
            runSpacing: TraqSpacing.xs,
            children: [
              for (var i = 0; i < max.clamp(0, 24); i++)
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: i < active ? color : c.border.withValues(alpha: 0.6),
                    borderRadius: TraqRadius.chip,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.track,
    required this.color,
  });

  final double progress;
  final Color track;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - 4;
    final trackPaint = Paint()
      ..color = track
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7;
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.5708,
      progress * 6.28318,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}

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
