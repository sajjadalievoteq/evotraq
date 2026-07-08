import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

class JourneyStateRow extends StatelessWidget {
  const JourneyStateRow({
    super.key,
    required this.icon,
    required this.label,
    this.value,
    this.isLast = false,
  });

  final String icon;
  final String label;
  final String? value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final theme = Theme.of(context);
    final display = (value == null || value!.isEmpty) ? '—' : value!;

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : TraqSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TraqIcon(icon, size: 14, color: c.textMuted),
          const SizedBox(width: TraqSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: c.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: TraqSpacing.sm,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: c.textMuted.withValues(alpha: 0.05),
                    borderRadius: const BorderRadius.all(TraqRadius.md),
                    border: Border.all(color: c.textMuted),
                  ),
                  child: Text(
                    display,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: c.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
