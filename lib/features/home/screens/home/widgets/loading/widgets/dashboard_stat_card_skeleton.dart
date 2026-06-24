import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/home/screens/home/widgets/loading/widgets/dashboard_skeleton_box.dart';

class DashboardStatCardSkeleton extends StatelessWidget {
  const DashboardStatCardSkeleton({super.key, required this.dense});

  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(dense ? 18 : 22),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      DashboardSkeletonBox(
                        width: dense ? 18 : 24,
                        height: dense ? 18 : 24,
                        radius: 4,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DashboardSkeletonBox(height: dense ? 12 : 16),
                      ),
                    ],
                  ),
                  DashboardSkeletonBox(
                    width: dense ? 48 : 64,
                    height: dense ? 24 : 36,
                  ),
                ],
              ),
            ),
            SizedBox(width: dense ? 12 : 20),
            const Expanded(
              child: DashboardSkeletonBox(height: double.infinity, radius: 4),
            ),
          ],
        ),
      ),
    );
  }
}
