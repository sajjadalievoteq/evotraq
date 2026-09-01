import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/features/automation_center/widgets/subscription_card/subscription_tonal_status_chip.dart';
import 'package:traqtrace_app/features/automation_center/widgets/subscription_card/subscription_solid_status_chip.dart';

enum SubscriptionStatusChipStyle {
  
  tonal,

  solid,
}

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
      SubscriptionStatusChipStyle.tonal => SubscriptionTonalStatusChip(
        status: status,
        color: color,
        iconAsset: iconAsset,
      ),
      SubscriptionStatusChipStyle.solid => SubscriptionSolidStatusChip(
        status: status,
        color: color,
        iconAsset: iconAsset,
      ),
    };
  }
}