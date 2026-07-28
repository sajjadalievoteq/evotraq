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
