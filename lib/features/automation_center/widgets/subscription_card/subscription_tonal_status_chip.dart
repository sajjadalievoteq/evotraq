import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

class SubscriptionTonalStatusChip extends StatelessWidget {
  const SubscriptionTonalStatusChip({
    required this.status,
    required this.color,
    required this.iconAsset,
  });

  final String status;
  final Color color;
  final String iconAsset;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Status $status',
      child: Chip(
        visualDensity: VisualDensity.compact,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TraqIcon(iconAsset, size: 14, color: color),
            const SizedBox(width: TraqSpacing.xs),
            Text(
              status,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        backgroundColor: color.withValues(alpha: 0.1),
        side: BorderSide(color: color.withValues(alpha: 0.3)),
        padding: const EdgeInsets.symmetric(horizontal: TraqSpacing.xs),
      ),
    );
  }
}
