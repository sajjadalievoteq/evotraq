import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';

/// Shimmer placeholder for GS1 master-data list rows (GLN / GTIN card layout).
class Gs1ListLoadingShimmer extends StatelessWidget {
  const Gs1ListLoadingShimmer({
    super.key,
    this.itemCount = 8,
  });

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;
    final highlightColor = isDark ? Colors.grey.shade700 : Colors.grey.shade100;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 420;
          final horizontalMargin = isCompact ? 8.0 : 16.0;
          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: Constants.sectionMaxWidth,
              ),
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: horizontalMargin),
                itemCount: itemCount,
                separatorBuilder: (_, __) => const SizedBox(height: 4),
                itemBuilder: (context, index) {
                  return _Gs1ListItemShimmer(
                    baseColor: baseColor,
                    isCompact: isCompact,
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class Gs1ListLoadMoreShimmer extends StatelessWidget {
  const Gs1ListLoadMoreShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;
    final highlightColor = isDark ? Colors.grey.shade700 : Colors.grey.shade100;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Constants.spacing),
        child: Center(
          child: _skeletonBox(
            baseColor,
            width: 160,
            height: 40,
            radius: 20,
          ),
        ),
      ),
    );
  }
}

class _Gs1ListItemShimmer extends StatelessWidget {
  const _Gs1ListItemShimmer({
    required this.baseColor,
    required this.isCompact,
  });

  final Color baseColor;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final contentPadding = isCompact
        ? const EdgeInsets.symmetric(horizontal: 12, vertical: 12)
        : const EdgeInsets.all(16);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: 2,
      child: Padding(
        padding: contentPadding,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _skeletonBox(
                    baseColor,
                    width: double.infinity,
                    height: 18,
                    radius: 8,
                  ),
                  const SizedBox(height: 8),
                  _skeletonBox(
                    baseColor,
                    width: isCompact ? 200 : 280,
                    height: 14,
                    radius: 6,
                  ),
                  const SizedBox(height: 6),
                  _skeletonBox(
                    baseColor,
                    width: isCompact ? 160 : 220,
                    height: 14,
                    radius: 6,
                  ),
                  const SizedBox(height: 6),
                  _skeletonBox(
                    baseColor,
                    width: isCompact ? 120 : 180,
                    height: 12,
                    radius: 6,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _skeletonBox(
                  baseColor,
                  width: 72,
                  height: 24,
                  radius: 999,
                ),
                const SizedBox(height: 4),
                _skeletonBox(
                  baseColor,
                  width: 48,
                  height: 12,
                  radius: 6,
                ),
              ],
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
