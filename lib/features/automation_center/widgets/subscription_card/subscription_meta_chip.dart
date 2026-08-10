import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

class SubscriptionMetaChip extends StatelessWidget {
  const SubscriptionMetaChip({
    super.key,
    required this.label,
    required this.icon,
  });

  final String label;
  final String icon;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: TraqSpacing.sm,
        vertical: TraqSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: c.surfaceMuted,
        borderRadius: TraqRadius.chip,
        border: Border.all(color: c.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TraqIcon(icon, size: 12, color: c.textMuted),
          const SizedBox(width: TraqSpacing.xs),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: c.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
