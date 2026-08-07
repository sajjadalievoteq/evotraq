import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/display_date_utils.dart';
import 'package:traqtrace_app/data/models/automation_center/notification_subscription.dart';
import 'package:traqtrace_app/features/automation_center/utils/subscription_delivery_utils.dart';
import 'package:traqtrace_app/features/automation_center/widgets/subscription_card/subscription_action_menu.dart';
import 'package:traqtrace_app/features/automation_center/widgets/subscription_card/subscription_status_chip.dart';
import 'package:traqtrace_app/features/automation_center/widgets/subscription_card/subscription_meta_chip.dart';
import 'package:traqtrace_app/features/automation_center/widgets/subscription_card/subscription_stats_row.dart';

class SubscriptionCard extends StatelessWidget {
  final NotificationSubscription subscription;
  final Function(NotificationSubscription) onEdit;
  final Function(NotificationSubscription) onDelete;
  final Function(NotificationSubscription) onPause;
  final Function(NotificationSubscription) onResume;
  final Function(NotificationSubscription) onViewDetails;

  const SubscriptionCard({
    super.key,
    required this.subscription,
    required this.onEdit,
    required this.onDelete,
    required this.onPause,
    required this.onResume,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return TraqCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: () => onViewDetails(subscription),
        borderRadius: TraqRadius.card,
        child: Padding(
          padding: TraqSpacing.surfacePad,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      subscription.subscriptionName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: c.textPrimary,
                          ),
                    ),
                  ),
                  SubscriptionStatusChip(status: subscription.status),
                  const SizedBox(width: TraqSpacing.sm),
                  SubscriptionActionMenu(
                    subscription: subscription,
                    onEdit: () => onEdit(subscription),
                    onPause: () => onPause(subscription),
                    onResume: () => onResume(subscription),
                    onDelete: () => onDelete(subscription),
                  ),
                ],
              ),
              const SizedBox(height: TraqSpacing.sm),
              Wrap(
                spacing: TraqSpacing.sm,
                runSpacing: TraqSpacing.xs,
                children: [
                  SubscriptionMetaChip(
                    label: subscription.subscriptionType,
                    icon: AppAssets.iconList,
                  ),
                  SubscriptionMetaChip(
                    label: SubscriptionDeliveryUtils.labelForEndpoint(
                      subscription.webhookUrl,
                    ),
                    icon: SubscriptionDeliveryUtils.iconForEndpoint(
                      subscription.webhookUrl,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: TraqSpacing.sm),
              Text(
                'Endpoint: ${subscription.webhookUrl}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: c.textMuted,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: TraqSpacing.xs),
              Text(
                'Created: ${DisplayDateUtils.dmy(subscription.createdAt)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: c.textMuted,
                    ),
              ),
              if (subscription.stats != null) ...[
                const SizedBox(height: TraqSpacing.md),
                SubscriptionStatsRow(stats: subscription.stats!),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
