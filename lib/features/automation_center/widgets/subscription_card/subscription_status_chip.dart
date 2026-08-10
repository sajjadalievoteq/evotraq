import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

/// Visual treatment for [SubscriptionStatusChip].
enum SubscriptionStatusChipStyle {
  /// Outlined/tonal chip: tinted background, colored icon + text (card lists).
  tonal,

  /// Solid filled chip: status color background, white icon + text (details).
  solid,
}

/// Canonical subscription status chip (status → color/icon), case-insensitive.
class SubscriptionStatusChip extends StatelessWidget {
  const SubscriptionStatusChip({
    super.key,
    required this.status,
    this.style = SubscriptionStatusChipStyle.tonal,
  });

  final String status;
  final SubscriptionStatusChipStyle style;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    late final Color color;
    late final String iconAsset;

    switch (status.toLowerCase()) {
      case 'active':
        color = AppColorMapper.successColor(context);
        iconAsset = AppAssets.iconCheckCircle;
      case 'paused':
        color = AppColorMapper.warningColor(context);
        iconAsset = AppAssets.iconPause;
      case 'error':
        color = AppColorMapper.errorColor(context);
        iconAsset = AppAssets.iconXCircle;
      case 'expired':
        color = c.textMuted;
        iconAsset = AppAssets.iconClock;
      default:
        color = c.textMuted;
        iconAsset = NavIcons.helpSupport;
    }

    return switch (style) {
      SubscriptionStatusChipStyle.tonal => _TonalChip(
        status: status,
        color: color,
        iconAsset: iconAsset,
      ),
      SubscriptionStatusChipStyle.solid => _SolidChip(
        status: status,
        color: color,
        iconAsset: iconAsset,
      ),
    };
  }
}

class _TonalChip extends StatelessWidget {
  const _TonalChip({
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

class _SolidChip extends StatelessWidget {
  const _SolidChip({
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
