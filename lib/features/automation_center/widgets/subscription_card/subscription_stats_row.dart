import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/data/models/automation_center/notification_subscription.dart';
import 'package:traqtrace_app/features/automation_center/widgets/subscription_card/subscription_stat_item.dart';

class SubscriptionStatsRow extends StatelessWidget {
  const SubscriptionStatsRow({
    super.key,
    required this.stats,
  });

  final NotificationStats stats;

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
      child: Row(
        children: [
          Expanded(
            child: SubscriptionStatItem(
              label: 'Success Rate',
              value: '${(stats.successRate * 100).toStringAsFixed(1)}%',
              iconAsset: AppAssets.iconCheckCircle,
              color: AppColorMapper.successColor(context),
            ),
          ),
          Expanded(
            child: SubscriptionStatItem(
              label: 'Total',
              value: stats.totalNotifications.toString(),
              iconAsset: NavIcons.notifications,
              color: AppColorMapper.infoColor(context),
            ),
          ),
          Expanded(
            child: SubscriptionStatItem(
              label: 'Failed',
              value: stats.failedNotifications.toString(),
              iconAsset: AppAssets.iconXCircle,
              color: AppColorMapper.errorColor(context),
            ),
          ),
        ],
      ),
    );
  }
}
