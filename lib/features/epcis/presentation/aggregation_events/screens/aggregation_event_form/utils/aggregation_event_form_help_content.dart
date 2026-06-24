abstract final class AggregationEventFormHelpContent {
  static const sections = <String, Map<String, String>>{
    'overview': {
      'title': 'Aggregation Event Overview',
      'content':
          'An Aggregation Event captures the physical relationship between a parent container and its child items. '
          'This is a crucial part of pharmaceutical track and trace systems that enables supply chain visibility '
          'by recording when products are packed together, observed in their containment state, or unpacked.',
    },
    'action': {
      'title': 'Action',
      'content':
          'Specifies what happened to the aggregation relationship:\n\n'
          '• ADD: Creates a new parent-child relationship (packing items into a container)\n'
          '• OBSERVE: Records an observation of an existing aggregation without changing it\n'
          '• DELETE: Removes a parent-child relationship (unpacking items from a container)\n\n'
          'According to GS1 EPCIS standards, these actions define how the aggregation event affects the supply chain.',
    },
    'eventTime': {
      'title': 'Event Time',
      'content':
          'The date and time when the aggregation event occurred. '
          'This timestamp is crucial for establishing the chronological sequence of events in the supply chain '
          'and is used for traceability queries. The system uses ISO 8601 format with timezone information.',
    },
    'parentEPC': {
      'title': 'Parent EPC',
      'content':
          'The Electronic Product Code (EPC) identifying the parent container, typically an SSCC '
          '(Serial Shipping Container Code). In pharmaceutical supply chains, this usually identifies a case, '
          'pallet, tote, or shipping container that contains multiple product items.\n\n'
          'Format examples:\n'
          '• URN format: urn:epc:id:sscc:0614141.1234567890\n'
          '• GS1 barcode format: (00)00614141123456789',
    },
    'childEPCs': {
      'title': 'Child EPCs',
      'content':
          'The list of Electronic Product Codes (EPCs) for the items contained within the parent. '
          'In pharmaceutical track and trace, these are typically SGTINs (Serialized Global Trade Item Numbers) '
          'representing individual product packages.\n\n'
          'Format examples:\n'
          '• URN format: urn:epc:id:sgtin:0614141.112345.1234567\n'
          '• GS1 barcode format: (01)00614141123451(21)1234567\n\n'
          'Multiple child EPCs should be separated by commas.',
    },
    'businessStep': {
      'title': 'Business Step',
      'content':
          'Identifies the business process step during which the aggregation event took place. '
          'GS1\'s Core Business Vocabulary (CBV) standardizes these values to ensure consistent interpretation '
          'across the supply chain. Common values in pharmaceutical track and trace include:\n\n'
          '• commissioning: Initial creation of the product identifiers\n'
          '• packing: Placing items into a container\n'
          '• shipping: Dispatching containers from a location\n'
          '• receiving: Accepting containers at a location\n'
          '• unpacking: Removing items from a container\n'
          '• dispensing: Providing products to a patient',
    },
    'disposition': {
      'title': 'Disposition',
      'content':
          'Indicates the business condition of the objects in the aggregation. The disposition '
          'works together with the business step to provide context for the event. GS1\'s Core Business '
          'Vocabulary (CBV) standardizes these values. Common dispositions include:\n\n'
          '• in_progress: The process is currently happening\n'
          '• in_transit: The items are being transported\n'
          '• container_closed: The container has been sealed\n'
          '• container_closed: The container is sealed\n'
          '• sellable_accessible: Products are available for sale\n'
          '• dispensed: Products have been provided to a patient',
    },
    'locationGLN': {
      'title': 'Location GLN',
      'content':
          'The Global Location Number (GLN) identifying where the aggregation event occurred. '
          'This is a crucial element for traceability as it establishes the physical location context for '
          'the event. In EPCIS, this is typically used for both the readPoint (exact location, like a dock door) '
          'and businessLocation (the broader location, like a warehouse).\n\n'
          'Format example: 0614141000011 (13-digit GLN code)',
    },
    'sourceList': {
      'title': 'Source List',
      'content':
          'Identifies the source(s) from which the objects in the event came. '
          'Each source has a type and value. The type identifies what kind of source it is, '
          'while the value is typically a GLN or other identifier for the source.\n\n'
          'Common source types include:\n'
          '• owning_party: The business that owned the items before this event\n'
          '• possessing_party: The business that possessed the items before this event\n'
          '• location: The physical location the items came from\n'
          '• processing_party: The business that processed the items before this event\n\n'
          'Source values are typically in GLN format.',
    },
    'destinationList': {
      'title': 'Destination List',
      'content':
          'Identifies the destination(s) to which the objects in the event are going. '
          'Each destination has a type and value. The type identifies what kind of destination it is, '
          'while the value is typically a GLN or other identifier for the destination.\n\n'
          'Common destination types include:\n'
          '• owning_party: The business that will own the items after this event\n'
          '• possessing_party: The business that will possess the items after this event\n'
          '• location: The physical location the items are going to\n'
          '• processing_party: The business that will process the items next\n\n'
          'Destination values are typically in GLN format.',
    },
    'businessData': {
      'title': 'Business Data',
      'content':
          'Additional data specific to this event that provides business context beyond '
          'the standard EPCIS fields. This user-defined information can include:\n\n'
          '• Batch/lot information\n'
          '• Purchase order references\n'
          '• Expiration dates\n'
          '• Temperature logs\n'
          '• Quality information\n'
          '• Custom identifiers\n\n'
          'Business data is stored as key-value pairs and can be used for custom queries and reports.',
    },
  };

  static const sectionOrder = [
    'overview',
    'action',
    'eventTime',
    'parentEPC',
    'childEPCs',
    'businessStep',
    'disposition',
    'locationGLN',
    'sourceList',
    'destinationList',
    'businessData',
  ];
}
