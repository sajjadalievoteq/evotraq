import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/shimmer_wrapper.dart';
import 'package:traqtrace_app/core/widgets/skeleton_box.dart';

class AggregationDetailSkeletonFieldRow extends StatelessWidget {
  const AggregationDetailSkeletonFieldRow({
    required this.base,
    required this.maxWidth,
    this.withChip = false,
  });

  final Color base;
  final double maxWidth;
  final bool withChip;

  @override
  Widget build(BuildContext context) {
    final field = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SkeletonBox(base, width: maxWidth * 0.4, height: 11),
        const SizedBox(height: 4),
        SkeletonBox(base, width: maxWidth * 0.7, height: 14),
      ],
    );

    if (!withChip) {
      return Padding(padding: const EdgeInsets.only(bottom: 12), child: field);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: field),
          const SizedBox(width: 12),
          SkeletonBox(base, width: 60, height: 28, radius: 16),
        ],
      ),
    );
  }
}
