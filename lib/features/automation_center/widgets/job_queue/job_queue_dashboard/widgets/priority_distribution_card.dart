import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/status_visual_mappers.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/job_queue_dashboard/widgets/job_queue_empty_panel.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/job_queue_dashboard/widgets/sparkline_and_section.dart';

class JobQueuePriorityDistributionCard extends StatelessWidget {
  const JobQueuePriorityDistributionCard({
    super.key,
    required this.distribution,
  });

  final Map<String, int> distribution;

  @override
  Widget build(BuildContext context) {
    final entries = distribution.entries.toList()
      ..sort((a, b) {
        final ak = int.tryParse(a.key) ?? 0;
        final bk = int.tryParse(b.key) ?? 0;
        return ak.compareTo(bk);
      });
    final total = entries.fold<int>(0, (s, e) => s + e.value);
    final nonZero = entries.where((e) => e.value > 0).toList();

    return JobQueueDashboardSection(
      title: 'Priority distribution',
      child: total <= 0 || nonZero.isEmpty
          ? const JobQueueEmptyPanel(
              title: 'No queued jobs',
              subtitle: 'Priorities appear here when work is waiting.',
              iconAsset: AppAssets.iconList,
            )
          : Column(
              children: [
                for (final e in nonZero)
                  _PriorityBar(
                    priority: e.key,
                    count: e.value,
                    total: total,
                  ),
              ],
            ),
    );
  }
}

class _PriorityBar extends StatelessWidget {
  const _PriorityBar({
    required this.priority,
    required this.count,
    required this.total,
  });

  final String priority;
  final int count;
  final int total;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final pct = total > 0 ? count / total : 0.0;
    final color = StatusVisualMappers.jobPriorityColor(
      context,
      int.tryParse(priority) ?? 5,
    );
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: TraqSpacing.md),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: TraqSpacing.xs,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: TraqRadius.chip,
                border: Border.all(color: color.withValues(alpha: 0.35)),
              ),
              child: Text(
                'P$priority',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ),
          const SizedBox(width: TraqSpacing.md),
          Expanded(
            child: ClipRRect(
              borderRadius: TraqRadius.chip,
              child: SizedBox(
                height: 10,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ColoredBox(color: c.surfaceMuted),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: pct),
                      duration:
                          reduceMotion ? Duration.zero : TraqDuration.slow,
                      curve: TraqDuration.ease,
                      builder: (context, value, _) => Align(
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: value.clamp(0.0, 1.0),
                          child: ColoredBox(color: color),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: TraqSpacing.md),
          SizedBox(
            width: 64,
            child: Text(
              '${(pct * 100).toStringAsFixed(0)}% · $count',
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: c.textMuted,
                  ),
            ),
          ),
        ],
      ),
    );
  }

}
