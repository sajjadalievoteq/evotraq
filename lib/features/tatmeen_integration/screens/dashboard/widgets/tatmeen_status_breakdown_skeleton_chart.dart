import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/app_skeleton_box.dart';

class TatmeenStatusBreakdownSkeletonChart extends StatelessWidget {
  const TatmeenStatusBreakdownSkeletonChart({super.key, required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return AppSkeletonBox(width: 200, height: 200, radius: 100, color: color);
  }
}
