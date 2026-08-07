import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';

/// Skeleton placeholder shapes used by subscription lists and the job queue.
enum SubscriptionSkeletonShape {
  /// Notification Center: title bar + tall block (content height 56).
  activityCard,

  /// Job queue: title bar + content block (content height 48).
  jobQueueCard,

  /// Subscription Management: title + two text lines.
  managementCard,
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
    final c = context.colors;
    final cards = List.generate(itemCount, (_) {
      switch (shape) {
        case SubscriptionSkeletonShape.activityCard:
          return _TitleAndBlockCard(
            colors: c,
            contentHeight: 56,
          );
        case SubscriptionSkeletonShape.jobQueueCard:
          return _TitleAndBlockCard(
            colors: c,
            contentHeight: 48,
          );
        case SubscriptionSkeletonShape.managementCard:
          return TraqCard(
            padding: TraqSpacing.surfacePad,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: TraqSpacing.xl,
                  width: 180,
                  decoration: BoxDecoration(
                    color: c.surfaceMuted,
                    borderRadius: TraqRadius.chip,
                  ),
                ),
                const SizedBox(height: TraqSpacing.sm),
                Container(
                  height: TraqSpacing.md,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: c.surfaceMuted,
                    borderRadius: TraqRadius.chip,
                  ),
                ),
                const SizedBox(height: TraqSpacing.xs),
                Container(
                  height: TraqSpacing.md,
                  width: 220,
                  decoration: BoxDecoration(
                    color: c.surfaceMuted,
                    borderRadius: TraqRadius.chip,
                  ),
                ),
              ],
            ),
          );
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
      return ListView.separated(
        padding: EdgeInsets.zero,
        itemCount: cards.length,
        separatorBuilder: (_, __) => const SizedBox(height: TraqSpacing.md),
        itemBuilder: (_, i) => cards[i],
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

class _TitleAndBlockCard extends StatelessWidget {
  const _TitleAndBlockCard({
    required this.colors,
    required this.contentHeight,
  });

  final TraqColors colors;
  final double contentHeight;

  @override
  Widget build(BuildContext context) {
    return TraqCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: TraqSpacing.xl,
            width: 160,
            decoration: BoxDecoration(
              color: colors.surfaceMuted,
              borderRadius: TraqRadius.chip,
            ),
          ),
          const SizedBox(height: TraqSpacing.md),
          Container(
            height: contentHeight,
            width: double.infinity,
            decoration: BoxDecoration(
              color: colors.surfaceMuted,
              borderRadius: TraqRadius.card,
            ),
          ),
        ],
      ),
    );
  }
}
