import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme_tokens.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';

class TraqCard extends StatelessWidget {
  const TraqCard({
    super.key,
    required this.child,
    this.padding = TraqSpacing.cardPad,
    this.brackets = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool brackets;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: c.surface,
        border: Border.all(color: c.border),
        borderRadius: TraqRadius.card,
      ),
      child: child,
    );
  }
}
