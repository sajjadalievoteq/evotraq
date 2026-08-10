class NotificationConstants {
  static const List<Map<String, String>> eventTypes = [
    {
      'value': 'ObjectEvent',
      'label': 'Object Event',
      'description': 'Basic item tracking events (most common)',
    },
    {
      'value': 'AggregationEvent',
      'label': 'Aggregation Event',
      'description': 'Container/pallet grouping and ungrouping',
    },
    {
      'value': 'TransactionEvent',
      'label': 'Transaction Event',
      'description': 'Business transactions and ownership transfers',
    },
    {
      'value': 'TransformationEvent',
      'label': 'Transformation Event',
      'description': 'Item transformations and manufacturing',
    },
  ];

  static const List<Map<String, String>> subscriptionTypes = [
    {
      'value': 'REALTIME',
      'label': 'Real-time Notifications',
      'description': 'Immediate notifications when events occur',
    },
    {
      'value': 'BATCH',
      'label': 'Batch Notifications',
      'description': 'Grouped notifications sent at intervals',
    },
    {
      'value': 'SCHEDULED',
      'label': 'Scheduled Notifications',
      'description': 'Notifications sent at specific times',
    },
  ];

  static const List<Map<String, String>> deliveryMethods = [
    {
      'value': 'WEBHOOK',
      'label': 'Webhook',
      'description': 'Send to HTTP endpoint (for developers)',
    },
    {
      'value': 'EMAIL',
      'label': 'Email',
      'description': 'Send to email address (user-friendly)',
    },
  ];

  static const List<Map<String, String>> notificationFrequencies = [
    {
      'value': 'IMMEDIATE',
      'label': 'Immediate',
      'description': 'Send as soon as the batch job next runs (~15 min poll)',
    },
    {
      'value': 'HOURLY',
      'label': 'Hourly',
      'description': 'Group events and deliver about once an hour',
    },
    {
      'value': 'DAILY',
      'label': 'Daily',
      'description': 'Group events and deliver about once a day',
    },
    {
      'value': 'WEEKLY',
      'label': 'Weekly',
      'description': 'Group events and deliver about once a week',
    },
    {
      'value': 'MONTHLY',
      'label': 'Monthly',
      'description': 'Group events and deliver about once a month',
    },
  ];

  static const List<Map<String, String>> notificationFormats = [
    {
      'value': 'JSON',
      'label': 'JSON',
      'description': 'Standard JSON format (recommended)',
    },
    {'value': 'XML', 'label': 'XML', 'description': 'EPCIS XML format'},
    {
      'value': 'SUMMARY',
      'label': 'Summary',
      'description': 'Simplified text summary',
    },
    {
      'value': 'EMAIL_HTML',
      'label': 'Email HTML',
      'description': 'Rich HTML email format (email only)',
    },
  ];
}
