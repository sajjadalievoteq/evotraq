import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/app_skeleton_box.dart';

class ProductHierarchySidebarSkeletonLabel extends StatelessWidget {
  const ProductHierarchySidebarSkeletonLabel({super.key});

  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: Alignment.centerLeft,
      child: AppSkeletonBox(width: 100, height: 10, radius: 4),
    );
  }
}
