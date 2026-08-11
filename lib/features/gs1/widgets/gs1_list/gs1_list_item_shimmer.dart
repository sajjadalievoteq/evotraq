import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/skeleton_box.dart';

class Gs1ListItemShimmer extends StatelessWidget {
  const Gs1ListItemShimmer({
    super.key,
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
                  SkeletonBox(
                    baseColor,
                    width: double.infinity,
                    height: 18,
                    radius: 8,
                  ),
                  const SizedBox(height: 8),
                  SkeletonBox(
                    baseColor,
                    width: isCompact ? 200 : 280,
                    height: 14,
                    radius: 6,
                  ),
                  const SizedBox(height: 6),
                  SkeletonBox(
                    baseColor,
                    width: isCompact ? 160 : 220,
                    height: 14,
                    radius: 6,
                  ),
                  const SizedBox(height: 6),
                  SkeletonBox(
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
                SkeletonBox(baseColor, width: 72, height: 24, radius: 999),
                const SizedBox(height: 4),
                SkeletonBox(baseColor, width: 48, height: 12, radius: 6),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
