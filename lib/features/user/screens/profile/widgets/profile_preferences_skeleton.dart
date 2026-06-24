import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/user/screens/profile/widgets/profile_skeleton_box.dart';

class ProfilePreferencesSkeleton extends StatelessWidget {
  const ProfilePreferencesSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        ProfileSkeletonBox(width: 220, height: 18),
        SizedBox(height: 16),
        ProfileSkeletonBox(width: double.infinity, height: 140, radius: 12),
        SizedBox(height: 24),
        ProfileSkeletonBox(width: 220, height: 18),
        SizedBox(height: 16),
        ProfileSkeletonBox(width: double.infinity, height: 220, radius: 12),
      ],
    );
  }
}
