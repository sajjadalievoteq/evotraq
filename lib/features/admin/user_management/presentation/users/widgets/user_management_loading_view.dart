import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../../core/consts/app_consts.dart';
import 'user_management_constants.dart';
import 'user_management_section_width.dart';

class UserManagementLoadingView extends StatelessWidget {
  const UserManagementLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;
    final highlightColor = isDark ? Colors.grey.shade700 : Colors.grey.shade100;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          UserManagementSectionWidth(
            child: _UserManagementFilterSkeleton(baseColor: baseColor),
          ),
          const SizedBox(height: Constants.spacing),
          Expanded(
            child: ListView.separated(
              itemCount: 6,
              padding: EdgeInsets.zero,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: Constants.spacing),
              itemBuilder: (context, index) {
                return UserManagementSectionWidth(
                  child: _UserManagementCardSkeleton(baseColor: baseColor),
                );
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Constants.cardRadius),
      ),
      child: Padding(
        padding: Constants.sectionPadding,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final widths = _FilterSkeletonWidths.fromWidth(constraints.maxWidth);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _skeletonBox(baseColor, width: 140, height: 28, radius: 8),
                const SizedBox(height: Constants.spacing),
                Wrap(
                  spacing: Constants.spacing,
                  runSpacing: Constants.spacing,
                  children: [
                    _skeletonBox(
                      baseColor,
                      width: widths.searchWidth,
                      height: 56,
                    ),
                    _skeletonBox(
                      baseColor,
                      width: widths.filterWidth,
                      height: 56,
                    ),
                    _skeletonBox(
                      baseColor,
                      width: widths.filterWidth,
                      height: 56,
                    ),
                  ],
                ),
                const SizedBox(height:Constants.spacing),
                Wrap(
                  spacing: Constants.spacing,
                  runSpacing: Constants.spacing,
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _skeletonBox(baseColor, width: 120, height: 18, radius: 8),
                    Wrap(
                      spacing: Constants.spacing,
                      runSpacing: Constants.spacing,
                      children: [
                        _skeletonBox(baseColor, width: 120, height: 44),
                        _skeletonBox(baseColor, width: 132, height: 44),
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
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 760;

            final details = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _skeletonBox(baseColor, width: 180, height: 20, radius: 8),
                const SizedBox(height: 8),
                _skeletonBox(baseColor, width: 220, height: 16, radius: 8),
                const SizedBox(height: 8),
                _skeletonBox(baseColor, width: 160, height: 16, radius: 8),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _skeletonBox(baseColor, width: 72, height: 28, radius: 999),
                    _skeletonBox(baseColor, width: 82, height: 28, radius: 999),
                    _skeletonBox(baseColor, width: 90, height: 28, radius: 999),
                  ],
                ),
              ],
            );

            final actions = Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _skeletonBox(baseColor, width: 28, height: 28, radius: 999),
                const SizedBox(width: 8),
                _skeletonBox(baseColor, width: 60, height: 24, radius: 999),
              ],
            );

            if (compact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _skeletonBox(baseColor, width: 40, height: 40, radius: 999),
                      const SizedBox(width: 12),
                      Expanded(child: details),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: actions,
                  ),
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _skeletonBox(baseColor, width: 40, height: 40, radius: 999),
                const SizedBox(width: 16),
                Expanded(child: details),
                const SizedBox(width: 16),
                actions,
              ],
            );
          },
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

    final filterWidth =
        ((maxWidth * 0.42) - Constants.spacing) / 2;

    return _FilterSkeletonWidths(
      searchWidth: maxWidth * 0.58 - Constants.spacing,
      filterWidth: filterWidth,
    );
  }
}
