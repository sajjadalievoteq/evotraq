import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/theme/traq_theme_tokens.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

class ProductHierarchyChildCountRow extends StatelessWidget {
  const ProductHierarchyChildCountRow({
    super.key,
    required this.icon,
    required this.label,
    required this.count,
  });

  final String icon;
  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: TraqSpacing.sm),
      child: Row(
        children: [
          TraqIcon(icon, size: 16, color: c.primary),
          const SizedBox(width: TraqSpacing.sm),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: c.textSecondary,
              ),
            ),
          ),
          Text(
            '$count',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: c.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
