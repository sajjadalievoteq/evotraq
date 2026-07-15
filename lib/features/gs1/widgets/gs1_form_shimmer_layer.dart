import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/shimmer_wrapper.dart';

class Gs1FormShimmerLayer extends StatelessWidget {
  const Gs1FormShimmerLayer({
    super.key,
    required this.show,
    required this.formColumn,
    required this.skeleton,
  });

  final bool show;
  final Widget formColumn;
  final Widget skeleton;

  @override
  Widget build(BuildContext context) {
    if (!show) return formColumn;

    // Skeleton only — do not build the real form underneath Opacity(0).
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;
    final highlightColor = isDark ? Colors.grey.shade700 : Colors.grey.shade100;

    return IgnorePointer(
      child: AppShimmer(
        baseColor: baseColor,
        highlightColor: highlightColor,
        period: const Duration(milliseconds: 1200),
        child: skeleton,
      ),
    );
  }
}
