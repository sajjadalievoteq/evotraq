import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class AppShimmer extends StatelessWidget {
  const AppShimmer({
    super.key,
    required this.child,
    this.enabled = true,
    this.baseColor,
    this.highlightColor,
    this.period = const Duration(milliseconds: 1200),
    this.direction = ShimmerDirection.ltr,
  });

  final Widget child;
  final bool enabled;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration period;
  final ShimmerDirection direction;

  static Color defaultBaseColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? Colors.grey.shade800 : Colors.grey.shade300;
  }

  static Color defaultHighlightColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? Colors.grey.shade700 : Colors.grey.shade100;
  }

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;

    return Shimmer.fromColors(
      baseColor: baseColor ?? defaultBaseColor(context),
      highlightColor: highlightColor ?? defaultHighlightColor(context),
      period: period,
      direction: direction,
      child: child,
    );
  }
}
