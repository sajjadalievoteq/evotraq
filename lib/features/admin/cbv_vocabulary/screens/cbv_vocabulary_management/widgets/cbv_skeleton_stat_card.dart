import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/skeleton_box.dart';
import 'package:traqtrace_app/features/admin/cbv_vocabulary/screens/cbv_vocabulary_management/widgets/cbv_skeleton_stat_block.dart';

class CbvSkeletonStatCard extends StatelessWidget {
  const CbvSkeletonStatCard({required this.base, super.key});

  final Color base;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(TraqSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SkeletonBox(base, width: 20, height: 20, radius: 4),
                const SizedBox(width: TraqSpacing.sm),
                SkeletonBox(base, width: 90, height: 14, radius: 4),
              ],
            ),
            const SizedBox(height: TraqSpacing.md),
            Row(
              children: [
                Expanded(child: CbvSkeletonStatBlock(base: base)),
                Expanded(child: CbvSkeletonStatBlock(base: base)),
                Expanded(child: CbvSkeletonStatBlock(base: base)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
