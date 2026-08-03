import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';

class NotificationCenterLoadingSkeleton extends StatelessWidget {
  const NotificationCenterLoadingSkeleton({
    super.key,
    required this.shrinkWrap,
  });

  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final cards = List.generate(
      3,
      (_) => TraqCard(
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
