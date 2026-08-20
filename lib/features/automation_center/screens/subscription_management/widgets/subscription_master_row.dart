import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/theme/traq_theme_tokens.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/data/models/automation_center/notification_subscription.dart';
import 'package:traqtrace_app/features/automation_center/utils/subscription_delivery_utils.dart';

class SubscriptionMasterRow extends StatelessWidget {
  const SubscriptionMasterRow({super.key,
    required this.subscription,
    required this.selected,
    required this.onTap,
  });

  final NotificationSubscription subscription;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final created = DateFormat.yMMMd().format(subscription.createdAt.toLocal());

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: selected ? c.primary.withValues(alpha: 0.06) : c.surface,
        borderRadius: TraqRadius.card,
        border: Border.all(
          color: selected ? c.primary.withValues(alpha: 0.5) : c.border,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: TraqRadius.card,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: TraqSpacing.md,
              vertical: TraqSpacing.md,
            ),
            child: Row(
              children: [
                TraqIcon(
                  SubscriptionDeliveryUtils.iconForEndpoint(
                    subscription.webhookUrl,
                  ),
                  size: 18,
                  color: selected ? c.primary : c.textMuted,
                ),
                const SizedBox(width: TraqSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subscription.subscriptionName,
                        style: context.text.bodySm.copyWith(
                          fontWeight: FontWeight.w700,
                          color: c.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: TraqSpacing.xs),
                      Text(
                        subscription.webhookUrl,
                        style: context.text.cap.copyWith(color: c.textMuted),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Created $created',
                        style: context.text.cap.copyWith(color: c.textMuted),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: TraqSpacing.xs),
                TraqIcon(AppAssets.iconChevronR, size: 14, color: c.textMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
