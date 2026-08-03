import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';

class SubscriptionManagementLoadingSkeleton extends StatelessWidget {
  const SubscriptionManagementLoadingSkeleton({
    super.key,
    required this.shrinkWrap,
  });

  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final cards = List.generate(
      4,
      (_) => TraqCard(
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
      ),
    );

    if (shrinkWrap) {
      return Column(
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
