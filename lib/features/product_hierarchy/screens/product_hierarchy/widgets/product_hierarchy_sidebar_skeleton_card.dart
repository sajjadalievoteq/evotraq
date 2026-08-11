import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/app_skeleton_box.dart';

class ProductHierarchySidebarSkeletonCard extends StatelessWidget {
  const ProductHierarchySidebarSkeletonCard({super.key, required this.height});
  final double height;

  @override
  Widget build(BuildContext context) {
    return AppSkeletonBox(width: double.infinity, height: height, radius: 8);
  }
}
