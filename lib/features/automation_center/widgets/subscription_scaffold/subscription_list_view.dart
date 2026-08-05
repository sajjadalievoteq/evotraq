import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';

/// Shared list shell: empty-state branch, padded cards, shrinkWrap vs refresh.
class SubscriptionListView extends StatelessWidget {
  const SubscriptionListView({
    super.key,
    required this.cards,
    required this.emptyState,
    required this.shrinkWrap,
    required this.onRefresh,
  });

  final List<Widget> cards;
  final Widget emptyState;
  final bool shrinkWrap;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    if (cards.isEmpty) {
      return emptyState;
    }

    final paddedCards = <Widget>[
      for (final card in cards)
        Padding(
          padding: const EdgeInsets.only(bottom: TraqSpacing.md),
          child: card,
        ),
    ];

    if (shrinkWrap) {
      // Embedded in a bounded panel body: scroll within the available height
      // (padding comes from the surrounding card).
      return ListView(
        padding: EdgeInsets.zero,
        children: paddedCards,
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: TraqSpacing.surfacePad,
        children: paddedCards,
      ),
    );
  }
}
