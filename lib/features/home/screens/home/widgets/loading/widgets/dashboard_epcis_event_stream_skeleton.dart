import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/home/screens/home/widgets/loading/widgets/dashboard_skeleton_box.dart';

class DashboardEpcisEventStreamSkeleton extends StatelessWidget {
  const DashboardEpcisEventStreamSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DashboardSkeletonBox(width: 120, height: 20),
                Row(
                  children: [
                    DashboardSkeletonBox(width: 40, height: 16),
                    SizedBox(width: 8),
                    DashboardSkeletonBox(width: 60, height: 20),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            Expanded(
              child: ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 5,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      DashboardSkeletonBox(width: 40, height: 40, radius: 20),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DashboardSkeletonBox(width: 140, height: 16),
                            SizedBox(height: 8),
                            DashboardSkeletonBox(width: 100, height: 12),
                          ],
                        ),
                      ),
                      DashboardSkeletonBox(width: 60, height: 14),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
