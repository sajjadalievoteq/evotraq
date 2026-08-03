import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

class SubscriptionStatItem extends StatelessWidget {
  const SubscriptionStatItem({
    super.key,
    required this.label,
    required this.value,
    required this.iconAsset,
    required this.color,
  });

  final String label;
  final String value;
  final String iconAsset;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TraqIcon(iconAsset, size: 16, color: color),
            const SizedBox(width: TraqSpacing.xs),
            Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
            ),
          ],
        ),
        const SizedBox(height: TraqSpacing.xs),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: c.textMuted,
              ),
        ),
      ],
    );
  }
}
