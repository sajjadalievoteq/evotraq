import 'package:flutter/material.dart';

class DashboardSkeletonBox extends StatelessWidget {
  const DashboardSkeletonBox({
    super.key,
    this.width = double.infinity,
    this.height = 20,
    this.radius = 8,
  });

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
