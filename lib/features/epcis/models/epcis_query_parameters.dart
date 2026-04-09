class EPCISQueryParameters {
  String? startTime;
  String? endTime;
  List<String>? epcs;
  List<String>? epcClass;
  List<String>? parentId;
  List<String>? eventTypes;
  List<String>? businessSteps;
  List<String>? dispositions;
  List<String>? readPoints;
  List<String>? businessLocations;
  List<String>? actions;
  Map<String, List<String>>? bizTransactions;
  Map<String, dynamic>? customFields;
  int? limit;
  int? offset;
  String? orderBy;
  String? orderDirection;
  String? outputFormat;

  EPCISQueryParameters({
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

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    
    if (startTime != null) data['startTime'] = startTime;
    if (endTime != null) data['endTime'] = endTime;
    if (epcs != null && epcs!.isNotEmpty) data['epcs'] = epcs;
    if (epcClass != null && epcClass!.isNotEmpty) data['epcClass'] = epcClass;
    if (parentId != null && parentId!.isNotEmpty) data['parentId'] = parentId;
    if (eventTypes != null && eventTypes!.isNotEmpty) data['eventTypes'] = eventTypes;
    if (businessSteps != null && businessSteps!.isNotEmpty) data['businessSteps'] = businessSteps;
    if (dispositions != null && dispositions!.isNotEmpty) data['dispositions'] = dispositions;
    if (readPoints != null && readPoints!.isNotEmpty) data['readPoints'] = readPoints;
    if (businessLocations != null && businessLocations!.isNotEmpty) data['businessLocations'] = businessLocations;
    if (actions != null && actions!.isNotEmpty) data['actions'] = actions;
    if (bizTransactions != null && bizTransactions!.isNotEmpty) data['bizTransactions'] = bizTransactions;
    if (customFields != null && customFields!.isNotEmpty) data['customFields'] = customFields;
    if (limit != null) data['limit'] = limit;
    if (offset != null) data['offset'] = offset;
    if (orderBy != null) data['orderBy'] = orderBy;
    if (orderDirection != null) data['orderDirection'] = orderDirection;
    if (outputFormat != null) data['outputFormat'] = outputFormat;
    
    return data;
  }

  factory EPCISQueryParameters.fromJson(Map<String, dynamic> json) {
    return EPCISQueryParameters(
      startTime: json['startTime'],
      endTime: json['endTime'],
      epcs: json['epcs']?.cast<String>(),
      epcClass: json['epcClass']?.cast<String>(),
      parentId: json['parentId']?.cast<String>(),
      eventTypes: json['eventTypes']?.cast<String>(),
      businessSteps: json['businessSteps']?.cast<String>(),
      dispositions: json['dispositions']?.cast<String>(),
      readPoints: json['readPoints']?.cast<String>(),
      businessLocations: json['businessLocations']?.cast<String>(),
      actions: json['actions']?.cast<String>(),
      bizTransactions: json['bizTransactions']?.map<String, List<String>>(
        (key, value) => MapEntry(key, value.cast<String>()),
      ),
      customFields: json['customFields'],
      limit: json['limit'],
      offset: json['offset'],
      orderBy: json['orderBy'],
      orderDirection: json['orderDirection'],
      outputFormat: json['outputFormat'],
    );
  }

  EPCISQueryParameters copyWith({
    String? startTime,
    String? endTime,
    List<String>? epcs,
    List<String>? epcClass,
    List<String>? parentId,
    List<String>? eventTypes,
    List<String>? businessSteps,
    List<String>? dispositions,
    List<String>? readPoints,
    List<String>? businessLocations,
    List<String>? actions,
    Map<String, List<String>>? bizTransactions,
    Map<String, dynamic>? customFields,
    int? limit,
    int? offset,
    String? orderBy,
    String? orderDirection,
    String? outputFormat,
  }) {
    return EPCISQueryParameters(
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      epcs: epcs ?? this.epcs,
      epcClass: epcClass ?? this.epcClass,
      parentId: parentId ?? this.parentId,
      eventTypes: eventTypes ?? this.eventTypes,
      businessSteps: businessSteps ?? this.businessSteps,
      dispositions: dispositions ?? this.dispositions,
      readPoints: readPoints ?? this.readPoints,
      businessLocations: businessLocations ?? this.businessLocations,
      actions: actions ?? this.actions,
      bizTransactions: bizTransactions ?? this.bizTransactions,
      customFields: customFields ?? this.customFields,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
      orderBy: orderBy ?? this.orderBy,
      orderDirection: orderDirection ?? this.orderDirection,
      outputFormat: outputFormat ?? this.outputFormat,
    );
  }
}
