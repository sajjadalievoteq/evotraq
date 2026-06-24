import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/home/screens/home/widgets/loading/widgets/dashboard_skeleton_box.dart';

class DashboardComplianceSkeleton extends StatelessWidget {
  const DashboardComplianceSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DashboardSkeletonBox(width: 180, height: 20),
        SizedBox(height: 12),
        Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                DashboardSkeletonBox(height: 24),
                SizedBox(height: 12),
                DashboardSkeletonBox(height: 24),
                SizedBox(height: 12),
                DashboardSkeletonBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
