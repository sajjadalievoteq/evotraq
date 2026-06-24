import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/user/screens/profile/widgets/profile_skeleton_box.dart';
import 'package:traqtrace_app/features/user/screens/profile/widgets/profile_skeleton_circle.dart';
import 'package:traqtrace_app/features/user/screens/profile/widgets/profile_skeleton_pill.dart';

class ProfileInfoSkeleton extends StatelessWidget {
  const ProfileInfoSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: const [
        SizedBox(height: 16),
        ProfileSkeletonCircle(size: 100),
        SizedBox(height: 12),
        ProfileSkeletonBox(width: 220, height: 18),
        SizedBox(height: 8),
        ProfileSkeletonBox(width: 140, height: 14),
        SizedBox(height: 24),
        ProfileSkeletonPill(width: 170, height: 42),
        SizedBox(height: 24),
        ProfileSkeletonBox(width: double.infinity, height: 56, radius: 12),
        SizedBox(height: 16),
        ProfileSkeletonBox(width: double.infinity, height: 56, radius: 12),
        SizedBox(height: 16),
        ProfileSkeletonBox(width: double.infinity, height: 56, radius: 12),
        SizedBox(height: 16),
        ProfileSkeletonBox(width: double.infinity, height: 56, radius: 12),
        SizedBox(height: 16),
        ProfileSkeletonBox(width: double.infinity, height: 56, radius: 12),
      ],
    );
  }
}
