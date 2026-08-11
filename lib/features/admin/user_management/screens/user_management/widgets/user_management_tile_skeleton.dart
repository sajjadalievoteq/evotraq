import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/skeleton_box.dart';

class UserManagementTileSkeleton extends StatelessWidget {
  const UserManagementTileSkeleton({super.key, required this.baseColor});
  final Color baseColor;

  @override
  Widget build(BuildContext context) {
    final radius = TraqRadius.md.x.toDouble();
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
                SkeletonBox(baseColor, width: 160, height: 18, radius: radius),
                const SizedBox(height: 6),
                SkeletonBox(
                  baseColor,
                  width: double.infinity,
                  height: 14,
                  radius: radius,
                ),
                const SizedBox(height: 4),
                SkeletonBox(baseColor, width: 140, height: 14, radius: radius),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 6,
                  children: [
                    SkeletonBox(baseColor, width: 72, height: 22, radius: 999),
                    SkeletonBox(baseColor, width: 82, height: 22, radius: 999),
                  ],
                ),
              ],
            );
            final actions = Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SkeletonBox(baseColor, width: 28, height: 28, radius: 999),
                const SizedBox(width: 8),
                SkeletonBox(baseColor, width: 52, height: 26, radius: 999),
              ],
            );
            if (compact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonBox(
                        baseColor,
                        width: 40,
                        height: 40,
                        radius: 999,
                      ),
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
                SkeletonBox(baseColor, width: 40, height: 40, radius: 999),
                const SizedBox(width: 16),
                Expanded(child: details),
                const SizedBox(width: 16),
                Padding(padding: const EdgeInsets.only(top: 4), child: actions),
              ],
            );
          },
        ),
      ),
    );
  }
}
