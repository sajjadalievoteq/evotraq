String _localTimezoneOffset() {
  final offset = DateTime.now().timeZoneOffset;
  final hours = offset.inHours.abs().toString().padLeft(2, '0');
  final minutes = (offset.inMinutes.abs() % 60).toString().padLeft(2, '0');
  final sign = offset.isNegative ? '-' : '+';
  return '$sign$hours:$minutes';
}

class UnpackingRequest {
  String unpackingReference;
  String parentContainerId;
  List<String> childEpcs;
  String unpackingLocationGLN;
  String? readPointGLN;
  DateTime? eventTime;
  String? eventTimeZoneOffset;
  String? workOrderNumber;
  String? productionOrder;
  String? batchNumber;
  Map<String, String>? additionalData;

  UnpackingRequest({
    required this.unpackingReference,
    required this.parentContainerId,
    required this.childEpcs,
    required this.unpackingLocationGLN,
    this.readPointGLN,
    this.eventTime,
    this.eventTimeZoneOffset,
    this.workOrderNumber,
    this.productionOrder,
    this.batchNumber,
    this.additionalData,
  });

  Map<String, dynamic> toJson() {
    return {
      'unpackingReference': unpackingReference,
      'parentContainerId': parentContainerId,
      'childEpcs': childEpcs,
      'unpackingLocationGLN': unpackingLocationGLN,
      'readPointGLN': readPointGLN,
      'eventTime': eventTime != null
          ? eventTime!.toUtc().toIso8601String()
          : DateTime.now().toUtc().toIso8601String(),
      'eventTimeZoneOffset': eventTimeZoneOffset ?? _localTimezoneOffset(),
      'workOrderNumber': workOrderNumber,
      'productionOrder': productionOrder,
      'batchNumber': batchNumber,
      'additionalData': additionalData,
    };
  }

  factory UnpackingRequest.fromJson(Map<String, dynamic> json) {
    return UnpackingRequest(
      unpackingReference: json['unpackingReference'],
      parentContainerId: json['parentContainerId'],
      childEpcs: List<String>.from(json['childEpcs']),
      unpackingLocationGLN: json['unpackingLocationGLN'],
      readPointGLN: json['readPointGLN'],
      eventTime:
          json['eventTime'] != null ? DateTime.parse(json['eventTime']) : null,
      eventTimeZoneOffset: json['eventTimeZoneOffset'],
      workOrderNumber: json['workOrderNumber'],
      productionOrder: json['productionOrder'],
      batchNumber: json['batchNumber'],
      additionalData: json['additionalData'] != null
          ? Map<String, String>.from(json['additionalData'])
          : null,
    );
  }
}
