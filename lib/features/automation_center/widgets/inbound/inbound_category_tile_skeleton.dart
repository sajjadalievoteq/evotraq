import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme_colors.dart';
import 'package:traqtrace_app/core/theme/traq_theme_tokens.dart';
import 'package:traqtrace_app/core/widgets/app_skeleton_box.dart';

class InboundCategoryTileSkeleton extends StatelessWidget {
  const InboundCategoryTileSkeleton({super.key, required this.colors});

  final TraqColors colors;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(TraqSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AppSkeletonBox(
                  width: 24,
                  height: 24,
                  radius: 6,
                  color: colors.surfaceMuted,
                ),
                const Spacer(),
                AppSkeletonBox(
                  width: 28,
                  height: 28,
                  radius: 999,
                  color: colors.surfaceMuted,
                ),
              ],
            ),
            const SizedBox(height: TraqSpacing.sm),
            AppSkeletonBox(
              width: 120,
              height: 18,
              radius: 4,
              color: colors.surfaceMuted,
            ),
            const SizedBox(height: TraqSpacing.xs),
            AppSkeletonBox(
              width: double.infinity,
              height: 12,
              radius: 4,
              color: colors.surfaceMuted,
            ),
            const SizedBox(height: TraqSpacing.xs),
            AppSkeletonBox(
              width: 140,
              height: 12,
              radius: 4,
              color: colors.surfaceMuted,
            ),
            const Spacer(),
            Align(
              alignment: Alignment.centerRight,
              child: AppSkeletonBox(
                width: 132,
                height: 28,
                radius: 8,
                color: colors.surfaceMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
