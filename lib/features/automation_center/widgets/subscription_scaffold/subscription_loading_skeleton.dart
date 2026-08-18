import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/app_skeleton_box.dart';
import 'package:traqtrace_app/features/automation_center/widgets/subscription_scaffold/subscription_title_block_skeleton_card.dart';

/// Skeleton placeholder shapes used by subscription lists and the job queue.
enum SubscriptionSkeletonShape {
  /// Notification Center: title bar + tall block (content height 56).
  activityCard,

  /// Job queue: title bar + content block (content height 48).
  jobQueueCard,

  /// Subscription Management: title + two text lines (legacy list-only).
  managementCard,

  /// Subscription Management master/detail: mirrors the real side-by-side /
  /// stacked layout used by [SubscriptionManagementBody].
  managementMasterDetail,
}

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
      return _ManagementMasterDetailSkeleton(shrinkWrap: shrinkWrap);
    }

    final c = context.colors;
    final cards = List.generate(itemCount, (_) {
      switch (shape) {
        case SubscriptionSkeletonShape.activityCard:
          return SubscriptionTitleBlockSkeletonCard(
            colors: c,
            contentHeight: 56,
          );
        case SubscriptionSkeletonShape.jobQueueCard:
          return SubscriptionTitleBlockSkeletonCard(
            colors: c,
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
                  color: c.surfaceMuted,
                ),
                const SizedBox(height: TraqSpacing.sm),
                AppSkeletonBox(
                  height: TraqSpacing.md,
                  width: double.infinity,
                  radius: 8,
                  color: c.surfaceMuted,
                ),
                const SizedBox(height: TraqSpacing.xs),
                AppSkeletonBox(
                  height: TraqSpacing.md,
                  width: 220,
                  radius: 8,
                  color: c.surfaceMuted,
                ),
              ],
            ),
          );
        case SubscriptionSkeletonShape.managementMasterDetail:
          // Handled above.
          return const SizedBox.shrink();
      }
    });

    if (asColumn) {
      return Column(
        children: [
          for (var i = 0; i < cards.length; i++) ...[
            if (i > 0) const SizedBox(height: TraqSpacing.md),
            cards[i],
          ],
        ],
      );
    }

    if (shrinkWrap) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < cards.length; i++) ...[
            if (i > 0) const SizedBox(height: TraqSpacing.md),
            cards[i],
          ],
        ],
      );
    }

    return ListView.separated(
      padding: TraqSpacing.surfacePad,
      itemCount: cards.length,
      separatorBuilder: (_, __) => const SizedBox(height: TraqSpacing.md),
      itemBuilder: (_, i) => cards[i],
    );
  }
}

/// Mirrors [SubscriptionManagementBody]'s LayoutBuilder breakpoint (`maxWidth < 900`
/// or mobile → stacked; otherwise list + detail side-by-side).
class _ManagementMasterDetailSkeleton extends StatelessWidget {
  const _ManagementMasterDetailSkeleton({required this.shrinkWrap});

  /// Matches [SubscriptionManagementBody.shrinkWrap]: intrinsic size when
  /// nested in a [ListView] (unbounded height). Flex children are only used
  /// when the parent provides a bounded height.
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 900 || context.isMobile;
        final list = _MasterListSkeleton(
          rowCount: stacked ? 3 : 5,
          shrinkWrap: shrinkWrap,
        );
        const detail = _DetailPaneSkeleton();

        if (stacked) {
          return Column(
            mainAxisSize: shrinkWrap ? MainAxisSize.min : MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 220, child: list),
              const SizedBox(height: TraqSpacing.md),
              if (shrinkWrap) detail else Expanded(child: detail),
            ],
          );
        }

        // IntrinsicHeight lets the Row stretch in unbounded parents (workbench
        // ListView) the same way SubscriptionManagementBody does.
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(width: constraints.maxWidth * 0.34, child: list),
              const SizedBox(width: TraqSpacing.md),
              const Expanded(child: detail),
            ],
          ),
        );
      },
    );
  }
}

class _MasterListSkeleton extends StatelessWidget {
  const _MasterListSkeleton({
    required this.rowCount,
    required this.shrinkWrap,
  });

  final int rowCount;
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    final rows = List<Widget>.generate(rowCount, (index) {
      return _MasterListSkeletonRow(index: index);
    });

    if (shrinkWrap) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const SizedBox(height: TraqSpacing.sm),
            rows[i],
          ],
        ],
      );
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: rows.length,
      separatorBuilder: (_, __) => const SizedBox(height: TraqSpacing.sm),
      itemBuilder: (_, i) => rows[i],
    );
  }
}

class _MasterListSkeletonRow extends StatelessWidget {
  const _MasterListSkeletonRow({required this.index});

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

class _DetailPaneSkeleton extends StatelessWidget {
  const _DetailPaneSkeleton();

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
