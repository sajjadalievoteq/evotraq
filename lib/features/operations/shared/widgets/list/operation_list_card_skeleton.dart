import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/app_skeleton_box.dart';


class OperationListCardSkeleton extends StatelessWidget {
  const OperationListCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AppSkeletonBox(width: 72, height: 24, radius: 12),
                Spacer(),
                AppSkeletonBox(width: 56, height: 14, radius: 6),
              ],
            ),
            SizedBox(height: 20),
            AppSkeletonBox(width: double.infinity, height: 20, radius: 6),
            SizedBox(height: 10),
            _RowSkeleton(textWidth: 180),
            SizedBox(height: 10),
            _RowSkeleton(textWidth: 160),
            SizedBox(height: 10),
            _RowSkeleton(textWidth: 140),
            SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppSkeletonBox(width: 72, height: 12, radius: 4),
                AppSkeletonBox(width: 110, height: 12, radius: 4),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RowSkeleton extends StatelessWidget {
  const _RowSkeleton({required this.textWidth});

  final double textWidth;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const AppSkeletonBox(width: 16, height: 16, radius: 4),
        const SizedBox(width: 4),
        AppSkeletonBox(width: textWidth, height: 14, radius: 6),
      ],
    );
  }
}
