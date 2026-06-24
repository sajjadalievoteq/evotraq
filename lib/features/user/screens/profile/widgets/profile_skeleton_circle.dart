import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/shimmer_wrapper.dart';

class ProfileSkeletonCircle extends StatelessWidget {
  const ProfileSkeletonCircle({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppShimmer.defaultBaseColor(context),
        shape: BoxShape.circle,
      ),
    );
  }
}
