import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/shimmer_wrapper.dart';
import 'package:traqtrace_app/core/widgets/skeleton_box.dart';

class AggregationDetailHeaderSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final bannerBase = Colors.white.withValues(alpha: 0.28);
    final bannerHighlight = Colors.white.withValues(alpha: 0.48);

    return Card(
      margin: EdgeInsets.zero,
      color: primary,
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: 120,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: AppShimmer(
            baseColor: bannerBase,
            highlightColor: bannerHighlight,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.maxWidth;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 3,
                  children: [
                    SkeletonBox(bannerBase, width: w * 0.6, height: 16),
                    SkeletonBox(bannerBase, width: w * 0.45, height: 13),
                    const Spacer(),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: SkeletonBox(
                        bannerBase,
                        width: w * 0.3,
                        height: 12,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
