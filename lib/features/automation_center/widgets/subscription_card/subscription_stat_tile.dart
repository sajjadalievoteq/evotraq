import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

/// Bordered vertical stat tile used by delivery-activity cards.
///
/// Distinct from [SubscriptionStatItem], which is the compact horizontal
/// metric used inside [SubscriptionStatsRow] on the management card.
class SubscriptionStatTile extends StatelessWidget {
  const SubscriptionStatTile({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    required this.iconAsset,
  });

  final String label;
  final String value;
  final Color color;
  final String iconAsset;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.all(TraqSpacing.md),
      decoration: BoxDecoration(
        color: c.surfaceMuted,
        borderRadius: TraqRadius.card,
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TraqIcon(iconAsset, size: 14, color: color),
          const SizedBox(height: TraqSpacing.xs),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: c.textMuted),
          ),
        ],
      ),
    );
  }
}
