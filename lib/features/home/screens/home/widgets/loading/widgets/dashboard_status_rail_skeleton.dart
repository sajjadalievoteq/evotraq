import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/layout/layout_manager.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/features/home/screens/home/widgets/loading/widgets/dashboard_skeleton_box.dart';

class DashboardStatusRailSkeleton extends StatelessWidget {
  const DashboardStatusRailSkeleton({super.key, required this.layout});

  final AppLayoutData layout;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.gutter(context),
          vertical: ResponsiveUtils.gutter(context) * 0.5,
        ),
        child: layout.isTabletUp
            ? const Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DashboardSkeletonBox(width: 240, height: 24),
                        SizedBox(height: 8),
                        DashboardSkeletonBox(width: 180, height: 16),
                      ],
                    ),
                  ),
                  DashboardSkeletonBox(width: 60, height: 36),
                  SizedBox(width: 20),
                  DashboardSkeletonBox(width: 100, height: 36),
                ],
              )
            : const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DashboardSkeletonBox(width: 200, height: 24),
                  SizedBox(height: 8),
                  DashboardSkeletonBox(width: 150, height: 16),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      DashboardSkeletonBox(width: 60, height: 32),
                      DashboardSkeletonBox(width: 100, height: 32),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
