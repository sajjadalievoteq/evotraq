import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme_tokens.dart';
import 'package:traqtrace_app/core/widgets/app_skeleton_box.dart';
import 'package:traqtrace_app/core/widgets/shimmer_wrapper.dart';

class JourneyCanvasHeaderSkeleton extends StatelessWidget {
  const JourneyCanvasHeaderSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: TraqSpacing.lg,
                vertical: TraqSpacing.md,
              ),
              child: Row(
                children: const [
                  AppSkeletonBox(width: 64, height: 16),
                  SizedBox(width: TraqSpacing.md),
                  AppSkeletonBox(width: 52, height: 24, radius: 12),
                  SizedBox(width: TraqSpacing.sm),
                  AppSkeletonBox(width: 56, height: 24, radius: 12),
                  Spacer(),
                  AppSkeletonBox(width: 96, height: 12),
                  SizedBox(width: TraqSpacing.lg),
                  AppSkeletonBox(width: 72, height: 12),
                  SizedBox(width: TraqSpacing.lg),
                  AppSkeletonBox(width: 48, height: 12),
                  SizedBox(width: TraqSpacing.lg),
                  AppSkeletonBox(width: 88, height: 12),
                ],
              ),
            ),
          ),
          const SizedBox(height: TraqSpacing.sm),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: TraqSpacing.md,
                vertical: TraqSpacing.sm,
              ),
              child: Row(
                children: [
                  for (int i = 0; i < 7; i++) ...[
                    if (i > 0) const SizedBox(width: TraqSpacing.sm),
                    AppSkeletonBox(
                      width: i == 0 ? 36 : 72 + (i % 3) * 12.0,
                      height: 28,
                      radius: 14,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
