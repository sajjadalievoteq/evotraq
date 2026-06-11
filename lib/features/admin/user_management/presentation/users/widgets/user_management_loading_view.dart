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
    final g = context.gutter;

    return AppShimmer(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _UserManagementFilterSkeleton(baseColor: baseColor),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.all(g),
              physics: const ClampingScrollPhysics(),
              itemCount: 8,
              separatorBuilder: (_, __) => SizedBox(height: g),
              itemBuilder: (context, _) =>
                  _UserManagementTileSkeleton(baseColor: baseColor),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Filter bar skeleton ────────────────────────────────────────────────────

class _UserManagementFilterSkeleton extends StatelessWidget {
  const _UserManagementFilterSkeleton({required this.baseColor});

  final Color baseColor;

  @override
  Widget build(BuildContext context) {
    final r = TraqRadius.md.x.toDouble();

    return Card(
      elevation: 1,
      child: Padding(
        padding: Constants.sectionPadding,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final widths = _FilterSkeletonWidths.fromWidth(constraints.maxWidth);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _skeletonBox(baseColor, width: 140, height: 28, radius: r),
                const SizedBox(height: Constants.spacing),
                Wrap(
                  spacing: Constants.spacing,
                  runSpacing: Constants.spacing,
                  children: [
                    _skeletonBox(baseColor, width: widths.searchWidth, height: 50),
                    _skeletonBox(baseColor, width: widths.filterWidth, height: 50),
                    _skeletonBox(baseColor, width: widths.filterWidth, height: 50),
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
                        _skeletonBox(baseColor, width: 120, height: 36,
                            radius: TraqRadius.sm.x.toDouble()),
                        _skeletonBox(baseColor, width: 132, height: 36,
                            radius: TraqRadius.sm.x.toDouble()),
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

// ── List tile skeleton — mirrors _buildListCard layout ────────────────────

class _UserManagementTileSkeleton extends StatelessWidget {
  const _UserManagementTileSkeleton({required this.baseColor});

  final Color baseColor;

  @override
  Widget build(BuildContext context) {
    final r = TraqRadius.md.x.toDouble();

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 760;

            // Details column
            final details = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Full name
                _skeletonBox(baseColor, width: 160, height: 18, radius: r),
                const SizedBox(height: 6),
                // Email
                _skeletonBox(baseColor, width: double.infinity, height: 14, radius: r),
                const SizedBox(height: 4),
                // Username
                _skeletonBox(baseColor, width: 140, height: 14, radius: r),
                const SizedBox(height: 12),
                // Role + Status badges
                Wrap(
                  spacing: 10,
                  runSpacing: 6,
                  children: [
                    _skeletonBox(baseColor, width: 72, height: 22, radius: 999),
                    _skeletonBox(baseColor, width: 82, height: 22, radius: 999),
                  ],
                ),
              ],
            );

            // Action row (edit icon + toggle)
            final actions = Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _skeletonBox(baseColor, width: 28, height: 28, radius: 999),
                const SizedBox(width: 8),
                _skeletonBox(baseColor, width: 52, height: 26, radius: 999),
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
                  Align(alignment: Alignment.centerRight, child: actions),
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
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: actions,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ── Shared helpers ─────────────────────────────────────────────────────────

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
      return _FilterSkeletonWidths(searchWidth: maxWidth, filterWidth: maxWidth);
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
