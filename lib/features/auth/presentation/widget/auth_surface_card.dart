import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/evotraq_theme.dart';

class AuthSurfaceCard extends StatelessWidget {
  const AuthSurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: EvotraqRadius.card,
        border: Border.all(color: c.border),
      ),
      child: child,
    );
  }
}
