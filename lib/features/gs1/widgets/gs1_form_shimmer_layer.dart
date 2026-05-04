import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// One shimmer over the entire form column while the real [formColumn] stays
/// mounted (invisible) for controllers and hydration.
class Gs1FormShimmerLayer extends StatelessWidget {
  const Gs1FormShimmerLayer({
    super.key,
    required this.show,
    required this.formColumn,
    required this.skeleton,
  });

  final bool show;
  final Widget formColumn;
  /// Typically a [Column] of placeholder blocks (same horizontal layout as the form).
  final Widget skeleton;

  @override
  Widget build(BuildContext context) {
    if (!show) return formColumn;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;
    final highlightColor = isDark ? Colors.grey.shade700 : Colors.grey.shade100;

    return Stack(
      clipBehavior: Clip.hardEdge,
      alignment: Alignment.topCenter,
      children: [
        Opacity(
          opacity: 0,
          child: IgnorePointer(child: formColumn),
        ),
        IgnorePointer(
          child: Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor,
            period: const Duration(milliseconds: 1200),
            child: skeleton,
          ),
        ),
      ],
    );
  }
}
