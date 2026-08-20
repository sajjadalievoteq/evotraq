import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/app_skeleton_box.dart';
import 'package:traqtrace_app/core/widgets/shimmer_wrapper.dart';

class TatmeenChartSkeleton extends StatelessWidget {
  const TatmeenChartSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final muted = AppShimmer.defaultBaseColor(context);
    return AppShimmer(
      child: SizedBox.expand(
        child: AppSkeletonBox(height: double.infinity, color: muted),
      ),
    );
  }
}
