import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/theme/traq_theme_tokens.dart';
import 'package:traqtrace_app/core/widgets/app_skeleton_box.dart';

class SubscriptionMasterListSkeletonRow extends StatelessWidget {
  const SubscriptionMasterListSkeletonRow({super.key, required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: TraqSpacing.md,
        vertical: TraqSpacing.md,
      ),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: TraqRadius.card,
        border: Border.all(
          color: index == 0 ? c.primary.withValues(alpha: 0.5) : c.border,
          width: index == 0 ? 1.5 : 1,
        ),
      ),
      child: Row(
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
                  width: index == 0 ? 140 : 110,
                  height: 14,
                  radius: 4,
                  color: c.surfaceMuted,
                ),
                const SizedBox(height: TraqSpacing.xs),
                AppSkeletonBox(
                  width: 88,
                  height: 11,
                  radius: 4,
                  color: c.surfaceMuted,
                ),
              ],
            ),
          ),
          AppSkeletonBox(
            width: 56,
            height: 22,
            radius: 999,
            color: c.surfaceMuted,
          ),
        ],
      ),
    );
  }
}
