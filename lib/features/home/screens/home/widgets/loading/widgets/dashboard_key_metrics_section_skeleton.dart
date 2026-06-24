import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/layout/layout_manager.dart';
import 'package:traqtrace_app/features/home/screens/home/widgets/loading/widgets/dashboard_skeleton_box.dart';
import 'package:traqtrace_app/features/home/screens/home/widgets/loading/widgets/dashboard_stat_card_skeleton.dart';

class DashboardKeyMetricsSectionSkeleton extends StatelessWidget {
  const DashboardKeyMetricsSectionSkeleton({super.key, required this.layout});

  final AppLayoutData layout;

  @override
  Widget build(BuildContext context) {
    const gap = 12.0;
    final minTileWidth = layout.isCompact ? 158.0 : 200.0;
    const maxCols = 7;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const DashboardSkeletonBox(width: 140, height: 14),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final maxW = constraints.maxWidth;
            var cols = ((maxW + gap) / (minTileWidth + gap)).floor();
            if (cols < 1) cols = 1;
            if (cols > maxCols) cols = maxCols;
            final tileW = (maxW - gap * (cols - 1)) / cols;

            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: List.generate(
                9,
                (index) => SizedBox(
                  width: tileW,
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: DashboardStatCardSkeleton(dense: layout.isCompact),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
