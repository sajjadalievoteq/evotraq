import 'package:flutter/material.dart';

class GtinFieldSkeletonMask extends StatelessWidget {
  const GtinFieldSkeletonMask({
    super.key,
    required this.show,
    required this.child,
    required this.skeletonBuilder,
  });

  final bool show;
  final Widget child;
  final Widget Function(Color baseColor) skeletonBuilder;

  @override
  Widget build(BuildContext context) {
    if (!show) return child;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;

    return Stack(
      alignment: Alignment.topCenter,
      clipBehavior: Clip.hardEdge,
      children: [
        Opacity(opacity: 0, child: IgnorePointer(child: child)),
        IgnorePointer(
          child: Align(
            alignment: Alignment.topCenter,
            widthFactor: 1,
            child: skeletonBuilder(baseColor),
          ),
        ),
      ],
    );
  }
}
