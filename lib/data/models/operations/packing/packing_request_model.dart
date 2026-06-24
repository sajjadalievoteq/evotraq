String _localTimezoneOffset() {
  final offset = DateTime.now().timeZoneOffset;
  final hours = offset.inHours.abs().toString().padLeft(2, '0');
  final minutes = (offset.inMinutes.abs() % 60).toString().padLeft(2, '0');
  final sign = offset.isNegative ? '-' : '+';
  return '$sign$hours:$minutes';
}

class PackingRequest {
  String packingReference;
  String parentContainerId;
  List<String> childEpcs;
  String? packingLocationGLN;
  String? readPointGLN;
  DateTime? eventTime;
  String? eventTimeZoneOffset;
  bool closeContainer;
  String? workOrderNumber;
  String? productionOrder;
  String? batchNumber;
  Map<String, String>? additionalData;

  PackingRequest({
    required this.packingReference,
    required this.parentContainerId,
    required this.childEpcs,
    this.packingLocationGLN,
    this.readPointGLN,
    this.eventTime,
    this.eventTimeZoneOffset,
    this.closeContainer = false,
    this.workOrderNumber,
    this.productionOrder,
    this.batchNumber,
    this.additionalData,
  });

  Map<String, dynamic> toJson() {
    return {
      'packingReference': packingReference,
      'parentContainerId': parentContainerId,
      'childEpcs': childEpcs,
      'packingLocationGLN': packingLocationGLN,
      'readPointGLN': readPointGLN,
      'eventTime': eventTime != null
          ? eventTime!.toUtc().toIso8601String()
          : DateTime.now().toUtc().toIso8601String(),
      'eventTimeZoneOffset': eventTimeZoneOffset ?? _localTimezoneOffset(),
      'closeContainer': closeContainer,
      'workOrderNumber': workOrderNumber,
      'productionOrder': productionOrder,
      'batchNumber': batchNumber,
      'additionalData': additionalData,
    };
  }

  factory PackingRequest.fromJson(Map<String, dynamic> json) {
    return PackingRequest(
      packingReference: json['packingReference'],
      parentContainerId: json['parentContainerId'],
      childEpcs: List<String>.from(json['childEpcs']),
      packingLocationGLN: json['packingLocationGLN'],
      readPointGLN: json['readPointGLN'],
      eventTime:
          json['eventTime'] != null ? DateTime.parse(json['eventTime']) : null,
      eventTimeZoneOffset: json['eventTimeZoneOffset'],
      closeContainer: json['closeContainer'] ?? false,
      workOrderNumber: json['workOrderNumber'],
      productionOrder: json['productionOrder'],
      batchNumber: json['batchNumber'],
      additionalData: json['additionalData'] != null
          ? Map<String, String>.from(json['additionalData'])
          : null,
    );
  }
}
