import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

class JobQueueStripMetric {
  const JobQueueStripMetric({
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

class JobQueueStripMetricTile extends StatelessWidget {
  const JobQueueStripMetricTile({super.key, required this.metric});
  final JobQueueStripMetric metric;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
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
                color: colors.textPrimary,
                height: 1.1,
              ),
            ),
            Text(
              metric.label,
              style: context.text.cap.copyWith(color: colors.textMuted),
            ),
          ],
        ),
      ],
    );
  }
}
