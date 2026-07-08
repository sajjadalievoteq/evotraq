import 'package:flutter/material.dart';

/// Placeholder box for use inside [AppShimmer] loading states.
class AppSkeletonBox extends StatelessWidget {
  const AppSkeletonBox({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.radius = 6,
    this.color = Colors.white,
  });

  final double width;
  final double height;
  final double radius;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
