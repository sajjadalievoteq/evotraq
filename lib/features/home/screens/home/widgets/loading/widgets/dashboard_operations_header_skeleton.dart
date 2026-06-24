import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/layout/layout_manager.dart';
import 'package:traqtrace_app/features/home/screens/home/widgets/loading/widgets/dashboard_skeleton_box.dart';

class DashboardOperationsHeaderSkeleton extends StatelessWidget {
  const DashboardOperationsHeaderSkeleton({super.key, required this.layout});

  final AppLayoutData layout;

  @override
  Widget build(BuildContext context) {
    if (layout.isTabletUp) {
      return const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          DashboardSkeletonBox(width: 200, height: 32),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                DashboardSkeletonBox(width: 300, height: 40),
                SizedBox(width: 8),
                DashboardSkeletonBox(width: 120, height: 40),
              ],
            ),
          ),
        ],
      );
    }
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            DashboardSkeletonBox(width: 180, height: 28),
            DashboardSkeletonBox(width: 100, height: 32),
          ],
        ),
        SizedBox(height: 12),
        DashboardSkeletonBox(height: 44),
      ],
    );
  }
}
