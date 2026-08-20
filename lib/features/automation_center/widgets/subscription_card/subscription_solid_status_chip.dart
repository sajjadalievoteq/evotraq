import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

class SubscriptionSolidStatusChip extends StatelessWidget {
  const SubscriptionSolidStatusChip({
    required this.status,
    required this.color,
    required this.iconAsset,
  });

  final String status;
  final Color color;
  final String iconAsset;

  @override
  Widget build(BuildContext context) {
    final onInverse = context.colors.textOnInverse;
    return Chip(
      avatar: TraqIcon(iconAsset, color: onInverse, size: 16),
      label: Text(
        status,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: onInverse,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: color,
    );
  }
}
