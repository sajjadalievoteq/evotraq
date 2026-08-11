import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/skeleton_box.dart';

class CbvSkeletonStatBlock extends StatelessWidget {
  const CbvSkeletonStatBlock({required this.base, super.key});

  final Color base;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SkeletonBox(base, width: 32, height: 22, radius: 4),
        const SizedBox(height: 4),
        SkeletonBox(base, width: 48, height: 11, radius: 4),
      ],
    );
  }
}
