import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/app_skeleton_box.dart';

class ProductHierarchyTreeSkeletonLeafRow extends StatelessWidget {
  const ProductHierarchyTreeSkeletonLeafRow({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(
        horizontal: TraqSpacing.sm,
        vertical: TraqSpacing.sm,
      ),
      child: Row(
        children: [
          AppSkeletonBox(width: 36, height: 14, radius: 4),
          SizedBox(width: TraqSpacing.sm),
          AppSkeletonBox(width: 18, height: 18, radius: 6),
          SizedBox(width: TraqSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                AppSkeletonBox(width: double.infinity, height: 14, radius: 4),
                SizedBox(height: 4),
                AppSkeletonBox(width: 96, height: 10, radius: 4),
              ],
            ),
          ),
          SizedBox(width: 4),
          AppSkeletonBox(width: 28, height: 28, radius: 6),
        ],
      ),
    );
  }
}
