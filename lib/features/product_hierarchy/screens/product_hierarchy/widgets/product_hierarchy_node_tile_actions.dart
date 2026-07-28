import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

class ProductHierarchyClimbButton extends StatelessWidget {
  const ProductHierarchyClimbButton({
    super.key,
    required this.onPressed,
    required this.iconColor,
  });

  final VoidCallback onPressed;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: TraqIcon(AppAssets.iconChevronU, size: 18, color: iconColor),
      tooltip: 'Show parent',
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      onPressed: onPressed,
    );
  }
}

class ProductHierarchyLeadingChevron extends StatelessWidget {
  const ProductHierarchyLeadingChevron({
    super.key,
    required this.isExpanded,
    required this.isLoading,
    required this.color,
  });

  final bool isExpanded;
  final bool isLoading;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      height: 22,
      child: isLoading
          ? Padding(
              padding: const EdgeInsets.all(3),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: color,
              ),
            )
          : AnimatedRotation(
              turns: isExpanded ? 0.25 : 0,
              duration: TraqDuration.normal,
              curve: TraqDuration.ease,
              child: TraqIcon(
                AppAssets.iconChevronR,
                size: 18,
                color: color,
              ),
            ),
    );
  }
}

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
        color: onPrimary
            ? c.onPrimary.withValues(alpha: 0.2)
            : c.surfaceMuted,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: onPrimary
              ? c.onPrimary.withValues(alpha: 0.35)
              : c.border,
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

class ProductHierarchyCopyEpcButton extends StatelessWidget {
  const ProductHierarchyCopyEpcButton({
    super.key,
    required this.epc,
    required this.iconColor,
  });

  final String epc;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: TraqIcon(AppAssets.iconCopy, size: 16, color: iconColor),
      tooltip: 'Copy EPC',
      visualDensity: VisualDensity.compact,
      onPressed: () {
        Clipboard.setData(ClipboardData(text: epc));
        context.showSuccess(
          'EPC copied',
          duration: const Duration(seconds: 1),
        );
      },
    );
  }
}
