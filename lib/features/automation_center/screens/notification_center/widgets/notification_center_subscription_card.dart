import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/utils/relative_time_utils.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/data/models/automation_center/notification_subscription.dart';
import 'package:traqtrace_app/features/automation_center/widgets/subscription_card/subscription_status_chip.dart';
import 'package:traqtrace_app/features/automation_center/widgets/subscription_card/subscription_stat_tile.dart';

class NotificationCenterSubscriptionCard extends StatelessWidget {
  const NotificationCenterSubscriptionCard({
    super.key,
    required this.subscription,
  });

  final NotificationSubscription subscription;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final stats = subscription.stats;
    final hasActivity =
        stats != null &&
        (stats.successfulNotifications > 0 ||
            stats.failedNotifications > 0 ||
            stats.totalNotifications > 0);

    return TraqCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        // Keep hardcoded navigation (same as before). The management
        // [SubscriptionCard] uses an [onViewDetails] callback; wiring that
        // here would require call-site changes outside this consolidation.
        onTap: () => context.go('/notifications/${subscription.id}'),
        borderRadius: TraqRadius.card,
        child: Padding(
          padding: TraqSpacing.surfacePad,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  TraqIcon(
                    NavIcons.notifications,
                    color: hasActivity
                        ? AppColorMapper.infoColor(context)
                        : c.textMuted,
                  ),
                  const SizedBox(width: TraqSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subscription.subscriptionName,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: c.textPrimary,
                              ),
                        ),
                        Text(
                          'Type: ${subscription.subscriptionType}',
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(color: c.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (stats != null) ...[
                const SizedBox(height: TraqSpacing.md),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final narrow = constraints.maxWidth < 360;
                    // Preserve NC's 4-metric bordered tiles (Delivered / Failed /
                    // Matched / Success Rate). [SubscriptionStatsRow] shows a
                    // different 3-metric compact layout for the management card.
                    final tiles = [
                      SubscriptionStatTile(
                        label: 'Delivered',
                        value: '${stats.successfulNotifications}',
                        color: AppColorMapper.successColor(context),
                        iconAsset: AppAssets.iconCheckCircle,
                      ),
                      SubscriptionStatTile(
                        label: 'Failed',
                        value: '${stats.failedNotifications}',
                        color: AppColorMapper.errorColor(context),
                        iconAsset: AppAssets.iconXCircle,
                      ),
                      SubscriptionStatTile(
                        label: 'Matched',
                        value: '${stats.totalNotifications}',
                        color: AppColorMapper.infoColor(context),
                        iconAsset: NavIcons.notifications,
                      ),
                      SubscriptionStatTile(
                        label: 'Success Rate',
                        value:
                            '${(stats.successRate * 100).toStringAsFixed(0)}%',
                        color: AppColorMapper.successColor(context),
                        iconAsset: AppAssets.iconCheckCircle,
                      ),
                    ];
                    if (narrow) {
                      return Wrap(
                        spacing: TraqSpacing.sm,
                        runSpacing: TraqSpacing.sm,
                        children: [
                          for (final tile in tiles)
                            SizedBox(
                              width:
                                  (constraints.maxWidth - TraqSpacing.sm) / 2,
                              child: tile,
                            ),
                        ],
                      );
                    }
                    return Row(
                      children: [
                        for (final tile in tiles) ...[
                          Expanded(child: tile),
                          if (tile != tiles.last)
                            const SizedBox(width: TraqSpacing.sm),
                        ],
                      ],
                    );
                  },
                ),
              ],
              const SizedBox(height: TraqSpacing.sm),
              Row(
                children: [
                  SubscriptionStatusChip(status: subscription.status),
                  const Spacer(),
                  Flexible(
                    child: Text(
                      'Created: ${RelativeTimeUtils.recentWithYesterdayOrDate(subscription.createdAt)}',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: c.textMuted),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
