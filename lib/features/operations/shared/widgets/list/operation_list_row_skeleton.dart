import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/app_skeleton_box.dart';

class OperationListRowSkeleton extends StatelessWidget {
  const OperationListRowSkeleton({super.key, required this.textWidth});
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
