import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/theme/traq_theme_tokens.dart';
import 'package:traqtrace_app/core/widgets/skeleton_box.dart';

class UserManagementFilterSkeleton extends StatelessWidget {
  const UserManagementFilterSkeleton({super.key, required this.baseColor});
  final Color baseColor;

  @override
  Widget build(BuildContext context) {
    final radius = TraqRadius.md.x.toDouble();
    return Card(
      elevation: 1,
      child: Padding(
        padding: Constants.sectionPadding,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth.isFinite
                ? constraints.maxWidth
                : MediaQuery.sizeOf(context).width;
            final widths = _FilterSkeletonWidths.fromWidth(maxWidth);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: Constants.spacing,
                  runSpacing: Constants.spacing,
                  children: [
                    SkeletonBox(
                      baseColor,
                      width: widths.searchWidth,
                      height: 50,
                    ),
                    SkeletonBox(
                      baseColor,
                      width: widths.filterWidth,
                      height: 50,
                    ),
                    SkeletonBox(
                      baseColor,
                      width: widths.filterWidth,
                      height: 50,
                    ),
                  ],
                ),
                const SizedBox(height: Constants.spacing),
                Wrap(
                  spacing: Constants.spacing,
                  runSpacing: Constants.spacing,
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    SkeletonBox(
                      baseColor,
                      width: 120,
                      height: 18,
                      radius: radius,
                    ),
                    Wrap(
                      spacing: Constants.spacing,
                      runSpacing: Constants.spacing,
                      children: [
                        SkeletonBox(
                          baseColor,
                          width: 120,
                          height: 36,
                          radius: TraqRadius.sm.x.toDouble(),
                        ),
                        SkeletonBox(
                          baseColor,
                          width: 132,
                          height: 36,
                          radius: TraqRadius.sm.x.toDouble(),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FilterSkeletonWidths {
  const _FilterSkeletonWidths({
    required this.searchWidth,
    required this.filterWidth,
  });
  final double searchWidth;
  final double filterWidth;

  factory _FilterSkeletonWidths.fromWidth(double maxWidth) {
    if (maxWidth < 700) {
      return _FilterSkeletonWidths(
        searchWidth: maxWidth,
        filterWidth: maxWidth,
      );
    }
    if (maxWidth < 1080) {
      return _FilterSkeletonWidths(
        searchWidth: maxWidth,
        filterWidth: (maxWidth - Constants.spacing) / 2,
      );
    }
    final filterWidth = ((maxWidth * 0.42) - Constants.spacing) / 2;
    return _FilterSkeletonWidths(
      searchWidth: maxWidth * 0.58 - Constants.spacing,
      filterWidth: filterWidth,
    );
  }
}
