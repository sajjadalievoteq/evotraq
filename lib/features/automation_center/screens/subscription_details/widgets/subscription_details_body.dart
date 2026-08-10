import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/display_date_utils.dart';
import 'package:traqtrace_app/data/models/automation_center/notification_subscription.dart';
import 'package:traqtrace_app/features/automation_center/screens/subscription_details/widgets/subscription_detail_row.dart';
import 'package:traqtrace_app/features/automation_center/screens/subscription_details/widgets/subscription_details_section.dart';
import 'package:traqtrace_app/features/automation_center/widgets/subscription_card/subscription_status_chip.dart';

class SubscriptionDetailsBody extends StatelessWidget {
  const SubscriptionDetailsBody({
    super.key,
    required this.subscription,
    this.stats,
  });

  final NotificationSubscription subscription;
  final NotificationStats? stats;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          subscription.subscriptionName,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      SubscriptionStatusChip(
                        status: subscription.status,
                        style: SubscriptionStatusChipStyle.solid,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Type: ${subscription.subscriptionType}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  if (subscription.notificationFormat?.isNotEmpty == true) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Format: ${subscription.notificationFormat}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: context.colors.textMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SubscriptionDetailsSection(
            title: 'Contact Information',
            children: [
              SubscriptionDetailRow(
                label: 'Email',
                value: subscription.webhookUrl.contains('@')
                    ? subscription.webhookUrl
                    : 'Not configured',
              ),
              if (subscription.webhookUrl.isNotEmpty &&
                  !subscription.webhookUrl.contains('@'))
                SubscriptionDetailRow(
                  label: 'Webhook URL',
                  value: subscription.webhookUrl,
                ),
            ],
          ),
          SubscriptionDetailsSection(
            title: 'Subscription Configuration',
            children: [
              SubscriptionDetailRow(
                label: 'Query Parameters',
                value:
                    subscription.queryParameters?.entries
                        .map((e) => '${e.key}: ${e.value}')
                        .join(', ') ??
                    'None',
              ),
              SubscriptionDetailRow(
                label: 'Notification Format',
                value: subscription.notificationFormat ?? 'Default',
              ),
            ],
          ),
          SubscriptionDetailsSection(
            title: 'Timing & Delivery',
            children: [
              SubscriptionDetailRow(
                label: 'Created',
                value: DisplayDateUtils.dmyHm(subscription.createdAt),
              ),
              SubscriptionDetailRow(
                label: 'Last Modified',
                value: subscription.updatedAt != null
                    ? DisplayDateUtils.dmyHm(subscription.updatedAt!)
                    : 'Never',
              ),
              SubscriptionDetailRow(
                label: 'Next Scheduled',
                value: subscription.status == 'ACTIVE' ? 'Real-time' : 'Paused',
              ),
            ],
          ),
          SubscriptionDetailsSection(
            title: 'Statistics',
            children: [
              SubscriptionDetailRow(
                label: 'Total Notifications',
                value: stats?.totalNotifications.toString() ?? 'Loading...',
              ),
              SubscriptionDetailRow(
                label: 'Success Rate',
                value: stats != null
                    ? '${(stats!.successRate * 100).toStringAsFixed(1)}%'
                    : 'Loading...',
              ),
              SubscriptionDetailRow(
                label: 'Last Notification',
                value: stats?.lastNotificationSent != null
                    ? DisplayDateUtils.dmyHm(stats!.lastNotificationSent!)
                    : 'None',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
