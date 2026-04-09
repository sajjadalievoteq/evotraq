/// Data Transfer Object for EPCIS query parameters, supporting both simple and complex queries
/// as defined in the GS1 EPCIS standard.
class EPCISQueryParametersDTO {
  /// Time range start
  final DateTime? startTime;
  
  /// Time range end
  final DateTime? endTime;
  
  /// List of Electronic Product Codes
  final List<String>? epcs;
  
  /// List of EPC classes
  final List<String>? epcClass;
  
  /// List of parent IDs for aggregation queries
  final List<String>? parentId;
  
  /// Filter by event types (OBJECT_EVENT, AGGREGATION_EVENT, etc.)
  final List<String>? eventTypes;
  
  /// Filter by business steps
  final List<String>? businessSteps;
  
  /// Filter by dispositions
  final List<String>? dispositions;
  
  /// Filter by read points (location GLNs)
  final List<String>? readPoints;
  
  /// Filter by business locations (location GLNs)
  final List<String>? businessLocations;
  
  /// Filter by actions (ADD, OBSERVE, DELETE)
  final List<String>? actions;
  
  /// Business transaction filters
  final Map<String, List<String>>? bizTransactions;
  
  /// Custom field filters
  final Map<String, dynamic>? customFields;
  
  /// Maximum results to return
  final int? limit;
  
  /// Number of results to skip
  final int? offset;
  
  /// Sort field
  final String? orderBy;
  
  /// Sort direction ('asc' or 'desc')
  final String? orderDirection;
  
  /// Requested output format (e.g., 'json', 'xml')
  final String? outputFormat;

  /// Constructor
  EPCISQueryParametersDTO({
    this.startTime,
    this.endTime,
    this.epcs,
    this.epcClass,
    this.parentId,
    this.eventTypes,
    this.businessSteps,
    this.dispositions,
    this.readPoints,
    this.businessLocations,
    this.actions,
    this.bizTransactions,
    this.customFields,
    this.limit,
    this.offset,
    this.orderBy,
    this.orderDirection,
    this.outputFormat,
  });
  /// Create from JSON
  factory EPCISQueryParametersDTO.fromJson(Map<String, dynamic> json) {
    return EPCISQueryParametersDTO(
      startTime: json['startTime'] != null ? DateTime.parse(json['startTime']) : null,
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      epcs: json['epcs'] != null ? List<String>.from(json['epcs']) : null,
      epcClass: json['epcClass'] != null ? List<String>.from(json['epcClass']) : null,
      parentId: json['parentId'] != null ? List<String>.from(json['parentId']) : null,
      eventTypes: json['eventTypes'] != null ? List<String>.from(json['eventTypes']) : null,
      businessSteps: json['businessSteps'] != null ? List<String>.from(json['businessSteps']) : null,
      dispositions: json['dispositions'] != null ? List<String>.from(json['dispositions']) : null,
      readPoints: json['readPoints'] != null ? List<String>.from(json['readPoints']) : null,
      businessLocations: json['businessLocations'] != null ? List<String>.from(json['businessLocations']) : null,
      actions: json['actions'] != null ? List<String>.from(json['actions']) : null,
      bizTransactions: json['bizTransactions'] != null 
          ? Map<String, List<String>>.from(
              json['bizTransactions'].map(
                (k, v) => MapEntry(k, List<String>.from(v))
              )
            ) 
          : null,
      customFields: json['customFields'],
      limit: json['limit'],
      offset: json['offset'],
      orderBy: json['orderBy'],
      orderDirection: json['orderDirection'],
      outputFormat: json['outputFormat'],
    );  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    
    if (startTime != null) data['startTime'] = _formatDateWithTimezone(startTime!);
    if (endTime != null) data['endTime'] = _formatDateWithTimezone(endTime!);
    if (epcs != null) data['epcs'] = epcs;
    if (epcClass != null) data['epcClass'] = epcClass;
    if (parentId != null) data['parentId'] = parentId;
    if (eventTypes != null) data['eventTypes'] = eventTypes;
    if (businessSteps != null) data['businessSteps'] = businessSteps;
    if (dispositions != null) data['dispositions'] = dispositions;
    if (readPoints != null) data['readPoints'] = readPoints;
    if (businessLocations != null) data['businessLocations'] = businessLocations;
    if (actions != null) data['actions'] = actions;
    if (bizTransactions != null) data['bizTransactions'] = bizTransactions;
    if (customFields != null) data['customFields'] = customFields;
    if (limit != null) data['limit'] = limit;
    if (offset != null) data['offset'] = offset;
    if (orderBy != null) data['orderBy'] = orderBy;
    if (orderDirection != null) data['orderDirection'] = orderDirection;
    if (outputFormat != null) data['outputFormat'] = outputFormat;
    
    return data;
  }

  /// Helper method to format dates with timezone information
  String _formatDateWithTimezone(DateTime dateTime) {
    // Convert to format that Java's ZonedDateTime can parse
    final String iso8601String = dateTime.toIso8601String();
    
    // Check if the string already has timezone information
    if (iso8601String.endsWith('Z') || iso8601String.contains('+')) {
      return iso8601String;
    }
    
    // Add UTC timezone marker if missing
    return '${iso8601String}Z';
  }
}
