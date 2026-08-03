import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/features/automation_center/widgets/notification_subscription_help/help_example_card.dart';
import 'package:traqtrace_app/features/automation_center/widgets/notification_subscription_help/help_item.dart';
import 'package:traqtrace_app/features/automation_center/widgets/notification_subscription_help/help_section.dart';
import 'package:traqtrace_app/features/automation_center/widgets/notification_subscription_help/help_tip.dart';

class NotificationSubscriptionHelp extends StatelessWidget {
  const NotificationSubscriptionHelp({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          TraqIcon(
            AppAssets.iconInfo,
            color: AppColorMapper.infoColor(context),
          ),
          const SizedBox(width: 8),
          const Text('Notification Subscription Help'),
        ],
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.7,
        child: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HelpSection(
                title: 'Basic Information',
                children: [
                  HelpItem(
                    title: 'Subscription Name',
                    description:
                        'A descriptive name for your subscription (e.g., "Warehouse Receiving Alerts")',
                  ),
                  HelpItem(
                    title: 'Delivery Method',
                    description:
                        '''• Webhook: Send to HTTP endpoint (for developers/systems)
• Email: Send to email address (user-friendly option)''',
                  ),
                  HelpItem(
                    title: 'Webhook Endpoint URL',
                    description:
                        'The HTTPS endpoint where webhook notifications will be sent. Must be a valid URL that can receive POST requests with JSON/XML payloads. (Only for webhook delivery)',
                  ),
                  HelpItem(
                    title: 'Email Address',
                    description:
                        'The email address where notifications will be sent. Must be a valid email address. Supports both individual emails and distribution lists. (Only for email delivery)',
                  ),
                  HelpItem(
                    title: 'Subscription Type',
                    description:
                        '''• Real-time: Notifications sent immediately when events occur
• Batch: Notifications grouped and sent at intervals
• Scheduled: Notifications sent at specific times''',
                  ),
                  HelpItem(
                    title: 'Notification Format',
                    description: '''• JSON: Standard JSON format (webhooks only)
• XML: EPCIS XML format (webhooks only)
• Summary: Simplified text summary (both)
• Email HTML: Rich HTML format (emails only)''',
                  ),
                ],
              ),
              SizedBox(height: 24),
              HelpSection(
                title: 'Event Filtering (Advanced)',
                children: [
                  HelpItem(
                    title: 'Event Types',
                    description: '''Select which EPCIS event types to monitor:
• Object Event: Basic item tracking events
• Aggregation Event: Container/pallet grouping
• Transaction Event: Business transactions
• Transformation Event: Item transformations''',
                  ),
                  HelpItem(
                    title: 'Business Step',
                    description: '''Filter by business process steps:
• Receiving: Items being received
• Shipping: Items being shipped
• Inspecting: Quality control checks
• Storing: Moving to storage
• Commissioning: Putting into service''',
                  ),
                  HelpItem(
                    title: 'Disposition',
                    description: '''Filter by item status/condition:
• Active: Items in active use
• In Progress: Items being processed
• Damaged: Items with damage
• Expired: Items past expiration
• Recalled: Items under recall''',
                  ),
                  HelpItem(
                    title: 'Read Point',
                    description:
                        'Specific location identifier (GLN format) where events occur',
                  ),
                  HelpItem(
                    title: 'EPC Pattern',
                    description:
                        'Filter by specific EPC patterns using wildcards (e.g., https://id.gs1.org/01/*)',
                  ),
                ],
              ),
              SizedBox(height: 24),
              HelpSection(
                title: 'Examples',
                children: [
                  HelpExampleCard(
                    title: 'Warehouse Receiving Alerts',
                    description: '''Monitor all items being received at warehouse:
• Event Types: Object Event
• Business Step: Receiving
• Read Point: Your warehouse GLN
• Webhook: https://yourapp.com/webhooks/receiving''',
                  ),
                  HelpExampleCard(
                    title: 'Product Recall Monitoring',
                    description: '''Track recalled products:
• Event Types: Object Event
• Disposition: Recalled
• EPC Pattern: Specific product range
• Webhook: https://yourapp.com/webhooks/recalls''',
                  ),
                  HelpExampleCard(
                    title: 'Shipment Tracking',
                    description: '''Monitor shipping events:
• Event Types: Object Event, Aggregation Event
• Business Step: Shipping
• Webhook: https://yourapp.com/webhooks/shipping''',
                  ),
                ],
              ),
              SizedBox(height: 24),
              HelpSection(
                title: 'Best Practices',
                children: [
                  HelpTip(
                    tip:
                        'Start with broad filters and refine based on notification volume',
                  ),
                  HelpTip(
                    tip:
                        'Test your webhook endpoint before creating subscriptions',
                  ),
                  HelpTip(
                    tip:
                        'Use descriptive names to easily identify subscriptions',
                  ),
                  HelpTip(
                    tip:
                        'Monitor webhook delivery rates in subscription statistics',
                  ),
                  HelpTip(
                    tip:
                        'Set up proper error handling in your webhook endpoint',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
