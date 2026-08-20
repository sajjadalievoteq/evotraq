import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/theme/traq_theme_tokens.dart';
import 'package:traqtrace_app/core/widgets/app_skeleton_box.dart';

class SubscriptionDetailPaneSkeleton extends StatelessWidget {
  const SubscriptionDetailPaneSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: TraqRadius.card,
        border: Border.all(color: c.border),
      ),
      child: Padding(
        padding: TraqSpacing.surfacePad,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSkeletonBox(
                  width: 22,
                  height: 22,
                  radius: 6,
                  color: c.surfaceMuted,
                ),
                const SizedBox(width: TraqSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppSkeletonBox(
                        width: 180,
                        height: 18,
                        radius: 4,
                        color: c.surfaceMuted,
                      ),
                      const SizedBox(height: TraqSpacing.sm),
                      AppSkeletonBox(
                        width: 72,
                        height: 22,
                        radius: 999,
                        color: c.surfaceMuted,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: TraqSpacing.lg),
            AppSkeletonBox(
              width: double.infinity,
              height: 12,
              radius: 4,
              color: c.surfaceMuted,
            ),
            const SizedBox(height: TraqSpacing.sm),
            AppSkeletonBox(
              width: double.infinity,
              height: 12,
              radius: 4,
              color: c.surfaceMuted,
            ),
            const SizedBox(height: TraqSpacing.sm),
            AppSkeletonBox(
              width: 160,
              height: 12,
              radius: 4,
              color: c.surfaceMuted,
            ),
            const SizedBox(height: TraqSpacing.xl),
            Row(
              children: [
                AppSkeletonBox(
                  width: 88,
                  height: 36,
                  radius: 8,
                  color: c.surfaceMuted,
                ),
                const SizedBox(width: TraqSpacing.sm),
                AppSkeletonBox(
                  width: 88,
                  height: 36,
                  radius: 8,
                  color: c.surfaceMuted,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
