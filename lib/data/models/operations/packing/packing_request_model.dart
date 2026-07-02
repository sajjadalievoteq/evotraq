import 'package:traqtrace_app/data/models/operations/shared/operation_gln_display.dart';
import 'package:traqtrace_app/features/operations/shared/utils/operation_event_time_codec.dart';

class PackingRequest {
  String? packingReference;
  String parentContainerId;
  List<String> childEpcs;
  String? packingLocationGLN;
  OperationGlnDisplay? operationLocation;
  String? readPointGLN;
  DateTime? eventTime;
  String? eventTimeZoneOffset;
  bool closeContainer;
  String? workOrderNumber;
  String? productionOrder;
  String? batchNumber;
  Map<String, String>? additionalData;

  PackingRequest({
    this.packingReference,
    required this.parentContainerId,
    required this.childEpcs,
    this.packingLocationGLN,
    this.operationLocation,
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
    final eventFields = OperationEventTimeCodec.fieldsForRequest(eventTime);
    return {
      if (packingReference != null && packingReference!.isNotEmpty)
        'packingReference': packingReference,
      'parentContainerId': parentContainerId,
      'childEpcs': childEpcs,
      'packingLocationGLN': packingLocationGLN,
      if (operationLocation != null)
        'operationLocation': operationLocation!.toJson(),
      'readPointGLN': readPointGLN,
      'eventTime': eventFields['eventTime'],
      'eventTimeZoneOffset':
          eventTimeZoneOffset ?? eventFields['eventTimeZoneOffset'],
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
