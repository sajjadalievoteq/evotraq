import 'package:flutter/material.dart';

class UserApprovalSkeletonBox extends StatelessWidget {
  const UserApprovalSkeletonBox({
    super.key,
    required this.color,
    required this.width,
    required this.height,
    this.radius = 12,
  });

  final Color color;
  final double width;
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
