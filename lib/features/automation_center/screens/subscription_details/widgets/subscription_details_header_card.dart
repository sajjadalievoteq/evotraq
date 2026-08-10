import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/data/models/automation_center/notification_subscription.dart';
import 'package:traqtrace_app/features/automation_center/utils/notification_constants.dart';
import 'package:traqtrace_app/features/automation_center/widgets/subscription_card/subscription_meta_chip.dart';
import 'package:traqtrace_app/features/automation_center/widgets/subscription_card/subscription_status_chip.dart';

/// Header card for the subscription details page: name + status at a glance,
/// plus a row of meta chips (delivery method, subscription type, format)
/// summarizing how this subscription is configured without needing to read
/// the sections below.
class SubscriptionDetailsHeaderCard extends StatelessWidget {
  const SubscriptionDetailsHeaderCard({super.key, required this.subscription});

  final NotificationSubscription subscription;

  bool get _isEmailDelivery => subscription.webhookUrl.contains('@');

  static String _labelFor(List<Map<String, String>> options, String value) {
    for (final option in options) {
      if (option['value'] == value) return option['label'] ?? value;
    }
    return value;
  }

  @override
  Widget build(BuildContext context) {
    final typeLabel = _labelFor(
      NotificationConstants.subscriptionTypes,
      subscription.subscriptionType,
    );
    final formatLabel = subscription.notificationFormat != null
        ? _labelFor(
            NotificationConstants.notificationFormats,
            subscription.notificationFormat!,
          )
        : null;

    return TraqCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  subscription.subscriptionName,
                  style: context.text.h2,
                ),
              ),
              const SizedBox(width: TraqSpacing.md),
              SubscriptionStatusChip(
                status: subscription.status,
                style: SubscriptionStatusChipStyle.solid,
              ),
            ],
          ),
          const SizedBox(height: TraqSpacing.md),
          Wrap(
            spacing: TraqSpacing.sm,
            runSpacing: TraqSpacing.sm,
            children: [
              SubscriptionMetaChip(
                label: _isEmailDelivery ? 'Email' : 'Webhook',
                icon: _isEmailDelivery ? AppAssets.iconMail : AppAssets.iconWebhook,
              ),
              SubscriptionMetaChip(label: typeLabel, icon: AppAssets.iconClock),
              if (formatLabel != null)
                SubscriptionMetaChip(
                  label: formatLabel,
                  icon: AppAssets.iconBarChart,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
