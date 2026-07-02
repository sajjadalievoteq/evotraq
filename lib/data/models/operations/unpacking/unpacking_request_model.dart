import 'package:traqtrace_app/data/models/operations/shared/operation_gln_display.dart';
import 'package:traqtrace_app/features/operations/shared/utils/operation_event_time_codec.dart';

class UnpackingRequest {
  String? unpackingReference;
  String parentContainerId;
  List<String> childEpcs;
  String unpackingLocationGLN;
  OperationGlnDisplay? operationLocation;
  String? readPointGLN;
  DateTime? eventTime;
  String? eventTimeZoneOffset;
  String? workOrderNumber;
  String? productionOrder;
  String? batchNumber;
  Map<String, String>? additionalData;

  UnpackingRequest({
    this.unpackingReference,
    required this.parentContainerId,
    required this.childEpcs,
    required this.unpackingLocationGLN,
    this.operationLocation,
    this.readPointGLN,
    this.eventTime,
    this.eventTimeZoneOffset,
    this.workOrderNumber,
    this.productionOrder,
    this.batchNumber,
    this.additionalData,
  });

  Map<String, dynamic> toJson() {
    final eventFields = OperationEventTimeCodec.fieldsForRequest(eventTime);
    return {
      if (unpackingReference != null && unpackingReference!.isNotEmpty)
        'unpackingReference': unpackingReference,
      'parentContainerId': parentContainerId,
      'childEpcs': childEpcs,
      'unpackingLocationGLN': unpackingLocationGLN,
      if (operationLocation != null)
        'operationLocation': operationLocation!.toJson(),
      'readPointGLN': readPointGLN,
      'eventTime': eventFields['eventTime'],
      'eventTimeZoneOffset':
          eventTimeZoneOffset ?? eventFields['eventTimeZoneOffset'],
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
