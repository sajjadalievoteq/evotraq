import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme_tokens.dart';
import 'package:traqtrace_app/features/automation_center/widgets/subscription_scaffold/subscription_management_master_detail_skeleton.dart';
import 'package:traqtrace_app/features/automation_center/widgets/subscription_scaffold/subscription_skeleton_card.dart';
import 'package:traqtrace_app/features/automation_center/widgets/subscription_scaffold/subscription_skeleton_shape.dart';

class SubscriptionLoadingSkeleton extends StatelessWidget {
  const SubscriptionLoadingSkeleton({
    super.key,
    required this.shrinkWrap,
    this.itemCount = 3,
    this.shape = SubscriptionSkeletonShape.activityCard,
    this.asColumn = false,
  });

  final bool shrinkWrap;
  final int itemCount;
  final SubscriptionSkeletonShape shape;

  /// When true, lays out skeletons in an intrinsic [Column] (job-queue
  /// embedded). When false, uses [ListView.separated] with padding driven by
  /// [shrinkWrap] (subscription panels / standalone job queue).
  final bool asColumn;

  @override
  Widget build(BuildContext context) {
    if (shape == SubscriptionSkeletonShape.managementMasterDetail) {
      return SubscriptionManagementMasterDetailSkeleton(shrinkWrap: shrinkWrap);
    }

    if (asColumn) {
      return Column(
        children: List.generate(
          itemCount,
          (index) => Padding(
            padding: EdgeInsets.only(top: index == 0 ? 0 : TraqSpacing.md),
            child: SubscriptionSkeletonCard(shape: shape),
          ),
        ),
      );
    }

    if (shrinkWrap) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: List.generate(
          itemCount,
          (index) => Padding(
            padding: EdgeInsets.only(top: index == 0 ? 0 : TraqSpacing.md),
            child: SubscriptionSkeletonCard(shape: shape),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: TraqSpacing.surfacePad,
      itemCount: itemCount,
      separatorBuilder: (_, __) => const SizedBox(height: TraqSpacing.md),
      itemBuilder: (_, index) => SubscriptionSkeletonCard(shape: shape),
    );
  }
}

/// Mirrors [SubscriptionManagementBody]'s LayoutBuilder breakpoint (`maxWidth < 900`
/// or mobile → stacked; otherwise list + detail side-by-side).
