import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';



class ProductHierarchySectionLabel extends StatelessWidget {
  const ProductHierarchySectionLabel(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: TraqSpacing.sm),
      child: Text(
        text.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: context.colors.textMuted,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.7,
            ),
      ),
    );
  }
}

class ProductHierarchyTypeBadge extends StatelessWidget {
  const ProductHierarchyTypeBadge(this.type, {super.key});
  final String type;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isSscc = type.toUpperCase() == 'SSCC';
    final color = isSscc ? c.primary : c.secondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: TraqRadius.chip,
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        type.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class ProductHierarchyDetailRow extends StatelessWidget {
  const ProductHierarchyDetailRow({super.key, required this.label, this.value});
  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final display = (value ?? '').trim();
    if (display.isEmpty) return const SizedBox.shrink();
    final c = context.colors;
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: TraqSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 118,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(color: c.textMuted),
            ),
          ),
          Expanded(
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
    );
  }
}
