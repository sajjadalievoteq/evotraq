import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/features/automation_center/widgets/help_widgets/help_example_card.dart';
import 'package:traqtrace_app/features/automation_center/widgets/help_widgets/help_item.dart';
import 'package:traqtrace_app/features/automation_center/widgets/help_widgets/help_section.dart';
import 'package:traqtrace_app/features/automation_center/widgets/help_widgets/help_tip.dart';

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
        width: (MediaQuery.sizeOf(context).width - 64)
            .clamp(280.0, 720.0)
            .toDouble(),
        height: (MediaQuery.sizeOf(context).height * 0.7)
            .clamp(360.0, 720.0)
            .toDouble(),
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
                        '''• API: Send to HTTP endpoint (for developers/systems)
• Email: Send to email address (user-friendly option)''',
                  ),
                  HelpItem(
                    title: 'API Endpoint URL',
                    description:
                        'The HTTPS endpoint where API notifications will be sent. Must be a valid URL that can receive POST requests with JSON/XML payloads. (Only for API delivery)',
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
                    description: '''• JSON: Standard JSON format (API only)
• XML: EPCIS XML format (API only)
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
                    title: 'Operations',
                    description:
                        '''Filter by which supply-chain operation produced the event:
• Shipping / Return Shipping / Cancel Shipping
• Receiving / Return Receiving / Cancel Receiving
• Accepting: Items being accepted into inventory
• Packing / Unpacking: Container grouping and ungrouping
• Decommissioning: Items taken out of service''',
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
                    description:
                        '''Monitor all items being received at warehouse:
• Event Types: Object Event
• Operations: Receiving
• Read Point: Your warehouse GLN
• API: https://yourapp.com/api/receiving''',
                  ),
                  HelpExampleCard(
                    title: 'Product Recall Monitoring',
                    description: '''Track recalled products:
• Event Types: Object Event
• Operations: Decommissioning
• EPC Pattern: Specific product range
• API: https://yourapp.com/api/recalls''',
                  ),
                  HelpExampleCard(
                    title: 'Shipment Tracking',
                    description: '''Monitor shipping events:
• Event Types: Object Event, Aggregation Event
• Operations: Shipping
• API: https://yourapp.com/api/shipping''',
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
                    tip: 'Test your API endpoint before creating subscriptions',
                  ),
                  HelpTip(
                    tip:
                        'Use descriptive names to easily identify subscriptions',
                  ),
                  HelpTip(
                    tip:
                        'Monitor API delivery rates in subscription statistics',
                  ),
                  HelpTip(
                    tip: 'Set up proper error handling in your API endpoint',
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
