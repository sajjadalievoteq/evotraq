import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/user/screens/profile/widgets/profile_skeleton_box.dart';
import 'package:traqtrace_app/features/user/screens/profile/widgets/profile_skeleton_pill.dart';

class ProfileSecuritySkeleton extends StatelessWidget {
  const ProfileSecuritySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        ProfileSkeletonBox(width: 180, height: 18),
        SizedBox(height: 12),
        ProfileSkeletonBox(width: double.infinity, height: 14),
        SizedBox(height: 6),
        ProfileSkeletonBox(width: double.infinity, height: 14),
        SizedBox(height: 24),
        ProfileSkeletonBox(width: double.infinity, height: 56, radius: 12),
        SizedBox(height: 16),
        ProfileSkeletonBox(width: double.infinity, height: 56, radius: 12),
        SizedBox(height: 16),
        ProfileSkeletonBox(width: double.infinity, height: 56, radius: 12),
        SizedBox(height: 24),
        ProfileSkeletonPill(width: double.infinity, height: 50),
        SizedBox(height: 32),
        Divider(),
        SizedBox(height: 16),
        ProfileSkeletonBox(width: 120, height: 18),
        SizedBox(height: 12),
        ProfileSkeletonBox(width: 260, height: 14),
        SizedBox(height: 16),
        ProfileSkeletonBox(width: double.infinity, height: 56, radius: 12),
      ],
    );
  }
}
