import 'package:flutter/material.dart';

class SkeletonBox extends StatelessWidget {
  const SkeletonBox(
    this.color, {
    this.width,
    required this.height,
    this.radius = 12,
    super.key,
  });

  final Color color;
  final double? width;
  final double height;
  final double radius;

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
