import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';

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
