import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/theme/traq_theme_tokens.dart';
import 'package:traqtrace_app/core/theme/traq_theme_widgets.dart';
import 'package:traqtrace_app/core/widgets/app_skeleton_box.dart';
import 'package:traqtrace_app/features/automation_center/widgets/subscription_scaffold/subscription_skeleton_shape.dart';
import 'package:traqtrace_app/features/automation_center/widgets/subscription_scaffold/subscription_title_block_skeleton_card.dart';

class SubscriptionSkeletonCard extends StatelessWidget {
  const SubscriptionSkeletonCard({super.key, required this.shape});

  final SubscriptionSkeletonShape shape;

  @override
  Widget build(BuildContext context) {
    switch (shape) {
      case SubscriptionSkeletonShape.activityCard:
        return SubscriptionTitleBlockSkeletonCard(
          colors: context.colors,
          contentHeight: 56,
        );
      case SubscriptionSkeletonShape.jobQueueCard:
        return SubscriptionTitleBlockSkeletonCard(
          colors: context.colors,
          contentHeight: 48,
        );
      case SubscriptionSkeletonShape.managementCard:
        return TraqCard(
          padding: TraqSpacing.surfacePad,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSkeletonBox(
                height: TraqSpacing.xl,
                width: 180,
                radius: 8,
                color: context.colors.surfaceMuted,
              ),
              const SizedBox(height: TraqSpacing.sm),
              AppSkeletonBox(
                height: TraqSpacing.md,
                width: double.infinity,
                radius: 8,
                color: context.colors.surfaceMuted,
              ),
              const SizedBox(height: TraqSpacing.xs),
              AppSkeletonBox(
                height: TraqSpacing.md,
                width: 220,
                radius: 8,
                color: context.colors.surfaceMuted,
              ),
            ],
          ),
        );
      case SubscriptionSkeletonShape.managementMasterDetail:
        return const SizedBox.shrink();
    }
  }
}
