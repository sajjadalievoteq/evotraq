import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';

/// Skeleton placeholder shapes used by the two subscription list screens.
enum SubscriptionSkeletonShape {
  /// Notification Center: title bar + tall block.
  activityCard,

  /// Subscription Management: title + two text lines.
  managementCard,
}

class SubscriptionLoadingSkeleton extends StatelessWidget {
  const SubscriptionLoadingSkeleton({
    super.key,
    required this.shrinkWrap,
    this.itemCount = 3,
    this.shape = SubscriptionSkeletonShape.activityCard,
  });

  final bool shrinkWrap;
  final int itemCount;
  final SubscriptionSkeletonShape shape;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final cards = List.generate(itemCount, (_) {
      switch (shape) {
        case SubscriptionSkeletonShape.activityCard:
          return TraqCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: TraqSpacing.xl,
                  width: 160,
                  decoration: BoxDecoration(
                    color: c.surfaceMuted,
                    borderRadius: TraqRadius.chip,
                  ),
                ),
                const SizedBox(height: TraqSpacing.md),
                Container(
                  height: 56,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: c.surfaceMuted,
                    borderRadius: TraqRadius.card,
                  ),
                ),
              ],
            ),
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
