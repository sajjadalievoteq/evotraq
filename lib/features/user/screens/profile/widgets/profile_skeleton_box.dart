import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/shimmer_wrapper.dart';

class ProfileSkeletonBox extends StatelessWidget {
  const ProfileSkeletonBox({
    super.key,
    required this.width,
    required this.height,
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
        color: AppShimmer.defaultBaseColor(context),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
