import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/skeleton_box.dart';

class CbvSkeletonPairingRow extends StatelessWidget {
  const CbvSkeletonPairingRow({
    required this.base,
    required this.chipCount,
    super.key,
  });

  final Color base;
  final int chipCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: TraqSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 180,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(base, width: 130, height: 13, radius: 4),
                const SizedBox(height: 5),
                SkeletonBox(base, width: 90, height: 10, radius: 3),
              ],
            ),
          ),
          const SizedBox(width: TraqSpacing.lg),
          Expanded(
            child: Wrap(
              spacing: TraqSpacing.sm,
              runSpacing: TraqSpacing.xs,
              children: [
                for (var index = 0; index < chipCount; index++)
                  SkeletonBox(
                    base,
                    width: 72 + (index.isEven ? 16 : 0),
                    height: 26,
                    radius: 16,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
