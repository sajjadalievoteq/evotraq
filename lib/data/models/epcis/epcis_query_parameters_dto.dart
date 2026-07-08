class EPCISQueryParametersDTO {
  final DateTime? startTime;
  
  final DateTime? endTime;
  
  final List<String>? epcs;
  
  final List<String>? epcClass;
  
  final List<String>? parentId;
  
  final List<String>? eventTypes;
  
  final List<String>? businessSteps;
  
  final List<String>? dispositions;
  
  final List<String>? readPoints;
  
  final List<String>? businessLocations;
  
  final List<String>? actions;
  
  final Map<String, List<String>>? bizTransactions;
  
  final Map<String, dynamic>? customFields;
  
  final int? limit;
  
  final int? offset;
  
  final String? orderBy;
  
  final String? orderDirection;
  
  final String? outputFormat;

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

  String _formatDateWithTimezone(DateTime dateTime) {
    final String iso8601String = dateTime.toIso8601String();
    
    if (iso8601String.endsWith('Z') || iso8601String.contains('+')) {
      return iso8601String;
    }
    
    return '${iso8601String}Z';
  }
}
