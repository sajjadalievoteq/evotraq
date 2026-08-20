import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/theme/traq_theme_tokens.dart';
import 'package:traqtrace_app/core/widgets/app_skeleton_box.dart';

class B2bUsersListSkeleton extends StatelessWidget {
  const B2bUsersListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final muted = context.colors.surfaceMuted;
    return Column(
      children: [
        for (var index = 0; index < 3; index++) ...[
          if (index > 0) const SizedBox(height: TraqSpacing.sm),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: TraqSpacing.sm),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppSkeletonBox(
                        width: 120 + (index * 24),
                        height: 14,
                        radius: 4,
                        color: muted,
                      ),
                      const SizedBox(height: TraqSpacing.xs),
                      AppSkeletonBox(
                        width: 200,
                        height: 12,
                        radius: 4,
                        color: muted,
                      ),
                    ],
                  ),
                ),
                AppSkeletonBox(width: 56, height: 12, radius: 4, color: muted),
                const SizedBox(width: TraqSpacing.md),
                AppSkeletonBox(width: 40, height: 24, radius: 12, color: muted),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
