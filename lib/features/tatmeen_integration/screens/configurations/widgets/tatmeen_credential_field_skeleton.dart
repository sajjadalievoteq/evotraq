import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/app_skeleton_box.dart';
import 'package:traqtrace_app/core/widgets/shimmer_wrapper.dart';

class TatmeenCredentialFieldSkeleton extends StatelessWidget {
  const TatmeenCredentialFieldSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppSkeletonBox(
      height: 56,
      radius: 4,
      color: AppShimmer.defaultBaseColor(context),
    );
  }
}
