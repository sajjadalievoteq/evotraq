import 'package:flutter/material.dart';

class NotificationSubscriptionHelp extends StatelessWidget {
  const NotificationSubscriptionHelp({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.help_outline, color: Colors.blue),
          SizedBox(width: 8),
          Text('Notification Subscription Help'),
        ],
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.7,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection(
                'Basic Information',
                [
                  _buildHelpItem(
                    'Subscription Name',
                    'A descriptive name for your subscription (e.g., "Warehouse Receiving Alerts")',
                  ),
                  _buildHelpItem(
                    'Delivery Method',
                    '''• Webhook: Send to HTTP endpoint (for developers/systems)
• Email: Send to email address (user-friendly option)''',
                  ),
                  _buildHelpItem(
                    'Webhook Endpoint URL',
                    'The HTTPS endpoint where webhook notifications will be sent. Must be a valid URL that can receive POST requests with JSON/XML payloads. (Only for webhook delivery)',
                  ),
                  _buildHelpItem(
                    'Email Address',
                    'The email address where notifications will be sent. Must be a valid email address. Supports both individual emails and distribution lists. (Only for email delivery)',
                  ),
                  _buildHelpItem(
                    'Subscription Type',
                    '''• Real-time: Notifications sent immediately when events occur
• Batch: Notifications grouped and sent at intervals
• Scheduled: Notifications sent at specific times''',
                  ),
                  _buildHelpItem(
                    'Notification Format',
                    '''• JSON: Standard JSON format (webhooks only)
• XML: EPCIS XML format (webhooks only)
• Summary: Simplified text summary (both)
• Email HTML: Rich HTML format (emails only)''',
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSection(
                'Event Filtering (Advanced)',
                [
                  _buildHelpItem(
                    'Event Types',
                    '''Select which EPCIS event types to monitor:
• Object Event: Basic item tracking events
• Aggregation Event: Container/pallet grouping
• Transaction Event: Business transactions
• Transformation Event: Item transformations
• Association Event: Item associations''',
                  ),
                  _buildHelpItem(
                    'Business Step',
                    '''Filter by business process steps:
• Receiving: Items being received
• Shipping: Items being shipped
• Inspecting: Quality control checks
• Storing: Moving to storage
• Commissioning: Putting into service''',
                  ),
                  _buildHelpItem(
                    'Disposition',
                    '''Filter by item status/condition:
• Active: Items in active use
• In Progress: Items being processed
• Damaged: Items with damage
• Expired: Items past expiration
• Recalled: Items under recall''',
                  ),
                  _buildHelpItem(
                    'Read Point',
                    'Specific location identifier (GLN format) where events occur',
                  ),
                  _buildHelpItem(
                    'EPC Pattern',
                    'Filter by specific EPC patterns using wildcards (e.g., urn:epc:id:sgtin:*)',
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSection(
                'Examples',
                [
                  _buildExampleCard(
                    'Warehouse Receiving Alerts',
                    '''Monitor all items being received at warehouse:
• Event Types: Object Event
• Business Step: Receiving
• Read Point: Your warehouse GLN
• Webhook: https://yourapp.com/webhooks/receiving''',
                  ),
                  _buildExampleCard(
                    'Product Recall Monitoring',
                    '''Track recalled products:
• Event Types: Object Event
• Disposition: Recalled
• EPC Pattern: Specific product range
• Webhook: https://yourapp.com/webhooks/recalls''',
                  ),
                  _buildExampleCard(
                    'Shipment Tracking',
                    '''Monitor shipping events:
• Event Types: Object Event, Aggregation Event
• Business Step: Shipping
• Webhook: https://yourapp.com/webhooks/shipping''',
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSection(
                'Best Practices',
                [
                  _buildTip('Start with broad filters and refine based on notification volume'),
                  _buildTip('Test your webhook endpoint before creating subscriptions'),
                  _buildTip('Use descriptive names to easily identify subscriptions'),
                  _buildTip('Monitor webhook delivery rates in subscription statistics'),
                  _buildTip('Set up proper error handling in your webhook endpoint'),
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

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildHelpItem(String title, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExampleCard(String title, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, size: 16, color: Colors.blue[700]),
              const SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: TextStyle(
              fontSize: 13,
              color: Colors.blue[800],
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTip(String tip) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, size: 16, color: Colors.green[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              tip,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
