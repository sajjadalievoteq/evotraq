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

  static const List<Map<String, String>> operationTypes = [
    {
      'value': 'SHIPPING',
      'label': 'Shipping',
      'description': 'Items being shipped out',
    },
    {
      'value': 'RECEIVING',
      'label': 'Receiving',
      'description': 'Items being received',
    },
    {
      'value': 'RETURN_SHIPPING',
      'label': 'Return Shipping',
      'description': 'Items shipped back to a supplier',
    },
    {
      'value': 'RETURN_RECEIVING',
      'label': 'Return Receiving',
      'description': 'Returned items being received back',
    },
    {
      'value': 'CANCEL_SHIPPING',
      'label': 'Cancel Shipping',
      'description': 'A shipping operation being voided',
    },
    {
      'value': 'CANCEL_RECEIVING',
      'label': 'Cancel Receiving',
      'description': 'A receiving operation being voided',
    },
    {
      'value': 'ACCEPTING',
      'label': 'Accepting',
      'description': 'Items being accepted into inventory',
    },
    {
      'value': 'DECOMMISSIONING',
      'label': 'Decommissioning',
      'description': 'Items being taken out of service',
    },
    {
      'value': 'PACKING',
      'label': 'Packing',
      'description': 'Items being packed into a container',
    },
    {
      'value': 'UNPACKING',
      'label': 'Unpacking',
      'description': 'Items being removed from a container',
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
      'label': 'API',
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
      'value': 'EXCEL',
      'label': 'CSV',
      'description':
          'CSV attachment containing the complete operation hierarchy',
    },
  ];
}
