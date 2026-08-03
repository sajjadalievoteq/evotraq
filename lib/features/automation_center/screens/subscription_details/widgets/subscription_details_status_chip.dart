import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

class SubscriptionDetailsStatusChip extends StatelessWidget {
  const SubscriptionDetailsStatusChip({
    super.key,
    required this.status,
  });

  final String status;

  @override
  Widget build(BuildContext context) {
    Color chipColor;
    String chipIconAsset;

    switch (status) {
      case 'ACTIVE':
        chipColor = AppColorMapper.successColor(context);
        chipIconAsset = AppAssets.iconCheckCircle;
        break;
      case 'PAUSED':
        chipColor = AppColorMapper.warningColor(context);
        chipIconAsset = AppAssets.iconPause;
        break;
      case 'ERROR':
        chipColor = AppColorMapper.errorColor(context);
        chipIconAsset = AppAssets.iconXCircle;
        break;
      default:
        chipColor = context.colors.textMuted;
        chipIconAsset = NavIcons.helpSupport;
    }

    return Chip(
      avatar: TraqIcon(
        chipIconAsset,
        color: context.colors.textOnInverse,
        size: 16,
      ),
      label: Text(
        status,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: context.colors.textOnInverse,
              fontWeight: FontWeight.w600,
            ),
      ),
      backgroundColor: chipColor,
    );
  }
}
