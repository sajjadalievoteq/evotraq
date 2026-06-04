import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/shimmer_wrapper.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';

import '../../../../../../core/consts/app_consts.dart';
import 'user_management_constants.dart';

class UserManagementLoadingView extends StatelessWidget {
  const UserManagementLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;
    final highlightColor = isDark ? Colors.grey.shade700 : Colors.grey.shade100;
    const tileMaxExtent = 240.0;
    final g = context.gutter;
    return AppShimmer(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _UserManagementFilterSkeleton(baseColor: baseColor),
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(g),
      physics: const ClampingScrollPhysics(),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: tileMaxExtent,
        mainAxisSpacing: g,
        crossAxisSpacing: g,
        childAspectRatio: 1,
      ),
              itemCount: 8,
              itemBuilder: (context, index) {
                return _UserManagementCardSkeleton(baseColor: baseColor);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _UserManagementFilterSkeleton extends StatelessWidget {
  const _UserManagementFilterSkeleton({required this.baseColor});

  final Color baseColor;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: Constants.sectionPadding,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final widths = _FilterSkeletonWidths.fromWidth(
              constraints.maxWidth,
            );
            final r = TraqRadius.md.x.toDouble();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _skeletonBox(baseColor, width: 140, height: 28, radius: r),
                const SizedBox(height: Constants.spacing),
                Wrap(
                  spacing: Constants.spacing,
                  runSpacing: Constants.spacing,
                  children: [
                    _skeletonBox(
                      baseColor,
                      width: widths.searchWidth,
                      height: 50,
                    ),
                    _skeletonBox(
                      baseColor,
                      width: widths.filterWidth,
                      height: 50,
                    ),
                    _skeletonBox(
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
                    _skeletonBox(baseColor, width: 120, height: 18, radius: r),
                    Wrap(
                      spacing: Constants.spacing,
                      runSpacing: Constants.spacing,
                      children: [
                        _skeletonBox(
                          baseColor,
                          width: 120,
                          height: 36,
                          radius: TraqRadius.sm.x.toDouble(),
                        ),
                        _skeletonBox(
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

class _UserManagementCardSkeleton extends StatelessWidget {
  const _UserManagementCardSkeleton({required this.baseColor});

  final Color baseColor;

  @override
  Widget build(BuildContext context) {
    final r = TraqRadius.md.x.toDouble();
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _skeletonBox(baseColor, width: 36, height: 36, radius: 999),
                const SizedBox(width: 10),
                Expanded(
                  child: _skeletonBox(
                    baseColor,
                    width: double.infinity,
                    height: 18,
                    radius: r,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _skeletonBox(
                    baseColor,
                    width: double.infinity,
                    height: 14,
                    radius: r,
                  ),
                  const SizedBox(height: 8),
                  _skeletonBox(baseColor, width: 220, height: 14, radius: r),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _skeletonBox(
                        baseColor,
                        width: 72,
                        height: 26,
                        radius: 999,
                      ),
                      _skeletonBox(
                        baseColor,
                        width: 82,
                        height: 26,
                        radius: 999,
                      ),
                      _skeletonBox(
                        baseColor,
                        width: 90,
                        height: 26,
                        radius: 999,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _skeletonBox(baseColor, width: 28, height: 28, radius: 999),
                  const SizedBox(width: 8),
                  _skeletonBox(baseColor, width: 60, height: 24, radius: 999),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _skeletonBox(
  Color color, {
  required double width,
  required double height,
  double radius = 12,
}) {
  return Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
    ),
  );
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
