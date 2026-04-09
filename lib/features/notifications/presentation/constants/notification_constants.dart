class NotificationConstants {
  // EPCIS Event Types
  static const List<Map<String, String>> eventTypes = [
    {
      'value': 'ObjectEvent',
      'label': 'Object Event',
      'description': 'Basic item tracking events (most common)'
    },
    {
      'value': 'AggregationEvent',
      'label': 'Aggregation Event',
      'description': 'Container/pallet grouping and ungrouping'
    },
    {
      'value': 'TransactionEvent',
      'label': 'Transaction Event',
      'description': 'Business transactions and ownership transfers'
    },
    {
      'value': 'TransformationEvent',
      'label': 'Transformation Event',
      'description': 'Item transformations and manufacturing'
    },
    {
      'value': 'AssociationEvent',
      'label': 'Association Event',
      'description': 'Item associations and relationships'
    },
  ];

  // Business Steps (CBV Standard)
  static const List<Map<String, String>> businessSteps = [
    {
      'value': 'urn:epcglobal:cbv:bizstep:accepting',
      'label': 'Accepting',
      'description': 'Accepting delivery or ownership'
    },
    {
      'value': 'urn:epcglobal:cbv:bizstep:arriving',
      'label': 'Arriving',
      'description': 'Physical arrival at location'
    },
    {
      'value': 'urn:epcglobal:cbv:bizstep:assembling',
      'label': 'Assembling',
      'description': 'Assembly or manufacturing process'
    },
    {
      'value': 'urn:epcglobal:cbv:bizstep:collecting',
      'label': 'Collecting',
      'description': 'Collecting items for processing'
    },
    {
      'value': 'urn:epcglobal:cbv:bizstep:commissioning',
      'label': 'Commissioning',
      'description': 'Putting items into service'
    },
    {
      'value': 'urn:epcglobal:cbv:bizstep:decommissioning',
      'label': 'Decommissioning',
      'description': 'Taking items out of service'
    },
    {
      'value': 'urn:epcglobal:cbv:bizstep:departing',
      'label': 'Departing',
      'description': 'Physical departure from location'
    },
    {
      'value': 'urn:epcglobal:cbv:bizstep:destroying',
      'label': 'Destroying',
      'description': 'Destruction or disposal'
    },
    {
      'value': 'urn:epcglobal:cbv:bizstep:disassembling',
      'label': 'Disassembling',
      'description': 'Breaking down or disassembly'
    },
    {
      'value': 'urn:epcglobal:cbv:bizstep:dispensing',
      'label': 'Dispensing',
      'description': 'Dispensing or distributing'
    },
    {
      'value': 'urn:epcglobal:cbv:bizstep:encoding',
      'label': 'Encoding',
      'description': 'Encoding identification data'
    },
    {
      'value': 'urn:epcglobal:cbv:bizstep:entering_exiting',
      'label': 'Entering/Exiting',
      'description': 'Entering or exiting a location'
    },
    {
      'value': 'urn:epcglobal:cbv:bizstep:holding',
      'label': 'Holding',
      'description': 'Temporary holding or storage'
    },
    {
      'value': 'urn:epcglobal:cbv:bizstep:inspecting',
      'label': 'Inspecting',
      'description': 'Quality control or inspection'
    },
    {
      'value': 'urn:epcglobal:cbv:bizstep:installing',
      'label': 'Installing',
      'description': 'Installation process'
    },
    {
      'value': 'urn:epcglobal:cbv:bizstep:killing',
      'label': 'Killing',
      'description': 'Deactivating RFID tags'
    },
    {
      'value': 'urn:epcglobal:cbv:bizstep:loading',
      'label': 'Loading',
      'description': 'Loading onto transport'
    },
    {
      'value': 'urn:epcglobal:cbv:bizstep:other',
      'label': 'Other',
      'description': 'Other business step'
    },
    {
      'value': 'urn:epcglobal:cbv:bizstep:packing',
      'label': 'Packing',
      'description': 'Packing for shipment'
    },
    {
      'value': 'urn:epcglobal:cbv:bizstep:picking',
      'label': 'Picking',
      'description': 'Order picking or selection'
    },
    {
      'value': 'urn:epcglobal:cbv:bizstep:receiving',
      'label': 'Receiving',
      'description': 'Receiving delivery'
    },
    {
      'value': 'urn:epcglobal:cbv:bizstep:removing',
      'label': 'Removing',
      'description': 'Removing from location'
    },
    {
      'value': 'urn:epcglobal:cbv:bizstep:repairing',
      'label': 'Repairing',
      'description': 'Repair or maintenance'
    },
    {
      'value': 'urn:epcglobal:cbv:bizstep:replacing',
      'label': 'Replacing',
      'description': 'Replacement process'
    },
    {
      'value': 'urn:epcglobal:cbv:bizstep:reserving',
      'label': 'Reserving',
      'description': 'Reserving for future use'
    },
    {
      'value': 'urn:epcglobal:cbv:bizstep:retail_selling',
      'label': 'Retail Selling',
      'description': 'Retail sales transaction'
    },
    {
      'value': 'urn:epcglobal:cbv:bizstep:shipping',
      'label': 'Shipping',
      'description': 'Shipping or dispatch'
    },
    {
      'value': 'urn:epcglobal:cbv:bizstep:staging_outbound',
      'label': 'Staging Outbound',
      'description': 'Staging for outbound shipment'
    },
    {
      'value': 'urn:epcglobal:cbv:bizstep:stock_taking',
      'label': 'Stock Taking',
      'description': 'Inventory counting'
    },
    {
      'value': 'urn:epcglobal:cbv:bizstep:stocking',
      'label': 'Stocking',
      'description': 'Stocking or replenishment'
    },
    {
      'value': 'urn:epcglobal:cbv:bizstep:storing',
      'label': 'Storing',
      'description': 'Moving to storage'
    },
    {
      'value': 'urn:epcglobal:cbv:bizstep:transporting',
      'label': 'Transporting',
      'description': 'In-transit movement'
    },
    {
      'value': 'urn:epcglobal:cbv:bizstep:unloading',
      'label': 'Unloading',
      'description': 'Unloading from transport'
    },
    {
      'value': 'urn:epcglobal:cbv:bizstep:unpacking',
      'label': 'Unpacking',
      'description': 'Unpacking from shipment'
    },
    {
      'value': 'urn:epcglobal:cbv:bizstep:void_shipping',
      'label': 'Void Shipping',
      'description': 'Cancelling shipment'
    },
  ];

  // Dispositions (CBV Standard)
  static const List<Map<String, String>> dispositions = [
    {
      'value': 'urn:epcglobal:cbv:disp:active',
      'label': 'Active',
      'description': 'Items in active use or circulation'
    },
    {
      'value': 'urn:epcglobal:cbv:disp:container_closed',
      'label': 'Container Closed',
      'description': 'Container is closed/sealed'
    },
    {
      'value': 'urn:epcglobal:cbv:disp:container_open',
      'label': 'Container Open',
      'description': 'Container is open/unsealed'
    },
    {
      'value': 'urn:epcglobal:cbv:disp:damaged',
      'label': 'Damaged',
      'description': 'Items with physical damage'
    },
    {
      'value': 'urn:epcglobal:cbv:disp:destroyed',
      'label': 'Destroyed',
      'description': 'Items that have been destroyed'
    },
    {
      'value': 'urn:epcglobal:cbv:disp:dispensed',
      'label': 'Dispensed',
      'description': 'Items that have been dispensed'
    },
    {
      'value': 'urn:epcglobal:cbv:disp:disposed',
      'label': 'Disposed',
      'description': 'Items that have been disposed of'
    },
    {
      'value': 'urn:epcglobal:cbv:disp:encoded',
      'label': 'Encoded',
      'description': 'Items with encoded identification'
    },
    {
      'value': 'urn:epcglobal:cbv:disp:expired',
      'label': 'Expired',
      'description': 'Items past expiration date'
    },
    {
      'value': 'urn:epcglobal:cbv:disp:in_progress',
      'label': 'In Progress',
      'description': 'Items being processed'
    },
    {
      'value': 'urn:epcglobal:cbv:disp:in_transit',
      'label': 'In Transit',
      'description': 'Items being transported'
    },
    {
      'value': 'urn:epcglobal:cbv:disp:inactive',
      'label': 'Inactive',
      'description': 'Items not in active use'
    },
    {
      'value': 'urn:epcglobal:cbv:disp:mismatch_class',
      'label': 'Mismatch Class',
      'description': 'Items with class mismatch'
    },
    {
      'value': 'urn:epcglobal:cbv:disp:mismatch_instance',
      'label': 'Mismatch Instance',
      'description': 'Items with instance mismatch'
    },
    {
      'value': 'urn:epcglobal:cbv:disp:mismatch_quantity',
      'label': 'Mismatch Quantity',
      'description': 'Items with quantity mismatch'
    },
    {
      'value': 'urn:epcglobal:cbv:disp:no_pedigree_match',
      'label': 'No Pedigree Match',
      'description': 'Items without pedigree match'
    },
    {
      'value': 'urn:epcglobal:cbv:disp:non_conformant',
      'label': 'Non Conformant',
      'description': 'Items not meeting standards'
    },
    {
      'value': 'urn:epcglobal:cbv:disp:partially_dispensed',
      'label': 'Partially Dispensed',
      'description': 'Items partially dispensed'
    },
    {
      'value': 'urn:epcglobal:cbv:disp:recalled',
      'label': 'Recalled',
      'description': 'Items under recall'
    },
    {
      'value': 'urn:epcglobal:cbv:disp:reserved',
      'label': 'Reserved',
      'description': 'Items reserved for specific use'
    },
    {
      'value': 'urn:epcglobal:cbv:disp:retail_sold',
      'label': 'Retail Sold',
      'description': 'Items sold at retail'
    },
    {
      'value': 'urn:epcglobal:cbv:disp:returned',
      'label': 'Returned',
      'description': 'Items that have been returned'
    },
    {
      'value': 'urn:epcglobal:cbv:disp:sold',
      'label': 'Sold',
      'description': 'Items that have been sold'
    },
    {
      'value': 'urn:epcglobal:cbv:disp:stolen',
      'label': 'Stolen',
      'description': 'Items reported as stolen'
    },
    {
      'value': 'urn:epcglobal:cbv:disp:unknown',
      'label': 'Unknown',
      'description': 'Items with unknown status'
    },
  ];

  // Subscription Types
  static const List<Map<String, String>> subscriptionTypes = [
    {
      'value': 'REALTIME',
      'label': 'Real-time Notifications',
      'description': 'Immediate notifications when events occur'
    },
    {
      'value': 'BATCH',
      'label': 'Batch Notifications',
      'description': 'Grouped notifications sent at intervals'
    },
    {
      'value': 'SCHEDULED',
      'label': 'Scheduled Notifications',
      'description': 'Notifications sent at specific times'
    },
  ];

  // Delivery Methods
  static const List<Map<String, String>> deliveryMethods = [
    {
      'value': 'WEBHOOK',
      'label': 'Webhook',
      'description': 'Send to HTTP endpoint (for developers)'
    },
    {
      'value': 'EMAIL',
      'label': 'Email',
      'description': 'Send to email address (user-friendly)'
    },
  ];

  // Notification Formats
  static const List<Map<String, String>> notificationFormats = [
    {
      'value': 'JSON',
      'label': 'JSON',
      'description': 'Standard JSON format (recommended)'
    },
    {
      'value': 'XML',
      'label': 'XML',
      'description': 'EPCIS XML format'
    },
    {
      'value': 'SUMMARY',
      'label': 'Summary',
      'description': 'Simplified text summary'
    },
    {
      'value': 'EMAIL_HTML',
      'label': 'Email HTML',
      'description': 'Rich HTML email format (email only)'
    },
  ];
}
