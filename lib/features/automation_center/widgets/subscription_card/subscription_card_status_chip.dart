import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

class SubscriptionCardStatusChip extends StatelessWidget {
  const SubscriptionCardStatusChip({
    super.key,
    required this.status,
  });

  final String status;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    Color color;
    String iconAsset;
    final label = status;

    switch (status.toLowerCase()) {
      case 'active':
        color = AppColorMapper.successColor(context);
        iconAsset = AppAssets.iconCheckCircle;
        break;
      case 'paused':
        color = AppColorMapper.warningColor(context);
        iconAsset = AppAssets.iconPause;
        break;
      case 'error':
        color = AppColorMapper.errorColor(context);
        iconAsset = AppAssets.iconXCircle;
        break;
      case 'expired':
        color = c.textMuted;
        iconAsset = AppAssets.iconClock;
        break;
      default:
        color = c.textMuted;
        iconAsset = NavIcons.helpSupport;
    }

    return Semantics(
      label: 'Status $label',
      child: Chip(
        visualDensity: VisualDensity.compact,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TraqIcon(iconAsset, size: 14, color: color),
            const SizedBox(width: TraqSpacing.xs),
            Text(
              label,
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
