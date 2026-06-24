import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/user/screens/profile/widgets/profile_skeleton_box.dart';

class ProfileSkeletonPill extends StatelessWidget {
  const ProfileSkeletonPill({
    super.key,
    required this.width,
    required this.height,
  });

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ProfileSkeletonBox(width: width, height: height, radius: 999);
  }
}
