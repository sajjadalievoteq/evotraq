import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/status_visual_mappers.dart';

class JobQueuePriorityBar extends StatelessWidget {
  const JobQueuePriorityBar({
    super.key,
    required this.priority,
    required this.count,
    required this.total,
  });
  final String priority;
  final int count;
  final int total;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final percentage = total > 0 ? count / total : 0.0;
    final color = StatusVisualMappers.jobPriorityColor(
      context,
      int.tryParse(priority) ?? 5,
    );
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
                    ColoredBox(color: colors.surfaceMuted),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: percentage),
                      duration: MediaQuery.disableAnimationsOf(context)
                          ? Duration.zero
                          : TraqDuration.slow,
                      curve: TraqDuration.ease,
                      builder: (context, value, _) => Align(
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: value.clamp(0, 1),
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
              '${(percentage * 100).toStringAsFixed(0)}% · $count',
              textAlign: TextAlign.end,
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: colors.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}
