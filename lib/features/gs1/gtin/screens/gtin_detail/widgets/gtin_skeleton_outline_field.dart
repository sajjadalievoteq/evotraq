import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1/gtin/screens/gtin_detail/widgets/gtin_skeleton_constants.dart';

class GtinSkeletonOutlineField extends StatelessWidget {
  const GtinSkeletonOutlineField({
    super.key,
    required this.color,
    this.height = 56,
  });

  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(kGtinSkeletonInputRadius),
      ),
    );
  }
}
