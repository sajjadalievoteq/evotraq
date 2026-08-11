import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

class ProductHierarchyChildCountBadge extends StatelessWidget {
  const ProductHierarchyChildCountBadge({
    super.key,
    required this.count,
    this.onPrimary = false,
  });

  final int count;
  final bool onPrimary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: onPrimary ? c.onPrimary.withValues(alpha: 0.2) : c.surfaceMuted,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: onPrimary ? c.onPrimary.withValues(alpha: 0.35) : c.border,
        ),
      ),
      child: Text(
        '$count',
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: onPrimary ? c.onPrimary : c.textPrimary,
        ),
      ),
    );
  }
}
