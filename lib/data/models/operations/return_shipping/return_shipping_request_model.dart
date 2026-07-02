import 'package:traqtrace_app/data/models/operations/shared/operation_gln_display.dart';
import 'package:traqtrace_app/features/operations/shared/utils/operation_event_time_codec.dart';

class ReturnShippingRequest {
  ReturnShippingRequest({
    this.returnReference,
    required this.epcs,
    required this.sourceGLN,
    required this.destinationGLN,
    this.sourceLocation,
    this.destinationLocation,
    this.purchaseOrderNumber,
    this.despatchAdviceNumber,
    this.billOfLadingNumber,
    this.carrier,
    this.trackingNumber,
    this.returnAuthorizationNumber,
    this.comments,
    this.eventTime,
    this.eventTimeZoneOffset,
    this.sourceEventId,
    this.returnReason,
    this.actingGln,
  });

  String? returnReference;
  List<String> epcs;
  String sourceGLN;
  String destinationGLN;
  OperationGlnDisplay? sourceLocation;
  OperationGlnDisplay? destinationLocation;
  String? purchaseOrderNumber;
  String? despatchAdviceNumber;
  String? billOfLadingNumber;
  String? carrier;
  String? trackingNumber;
  String? returnAuthorizationNumber;
  String? comments;
  DateTime? eventTime;
  String? eventTimeZoneOffset;
  String? sourceEventId;
  String? returnReason;
  String? actingGln;

  Map<String, dynamic> toJson() {
    final eventFields = OperationEventTimeCodec.fieldsForRequest(eventTime);
    return {
      if (returnReference != null && returnReference!.isNotEmpty)
        'returnReference': returnReference,
      'epcs': epcs,
      'sourceGLN': sourceGLN,
      'destinationGLN': destinationGLN,
      if (sourceLocation != null) 'sourceLocation': sourceLocation!.toJson(),
      if (destinationLocation != null)
        'destinationLocation': destinationLocation!.toJson(),
      'purchaseOrderNumber': purchaseOrderNumber,
      'despatchAdviceNumber': despatchAdviceNumber,
      'billOfLadingNumber': billOfLadingNumber,
      'carrier': carrier,
      'trackingNumber': trackingNumber,
      'returnAuthorizationNumber': returnAuthorizationNumber,
      'comments': comments,
      'eventTime': eventFields['eventTime'],
      'eventTimeZoneOffset':
          eventTimeZoneOffset ?? eventFields['eventTimeZoneOffset'],
      if (sourceEventId != null) 'sourceEventId': sourceEventId,
      if (returnReason != null) 'returnReason': returnReason,
      if (actingGln != null) 'actingGln': actingGln,
    };
  }

  factory ReturnShippingRequest.fromJson(Map<String, dynamic> json) {
    return ReturnShippingRequest(
      returnReference: json['returnReference']?.toString(),
      epcs: (json['epcs'] as List? ?? const [])
          .map((e) => e.toString())
          .toList(),
      sourceGLN: (json['sourceGLN'] ?? '').toString(),
      destinationGLN: (json['destinationGLN'] ?? '').toString(),
      purchaseOrderNumber: json['purchaseOrderNumber']?.toString(),
      despatchAdviceNumber: json['despatchAdviceNumber']?.toString(),
      billOfLadingNumber: json['billOfLadingNumber']?.toString(),
      carrier: json['carrier']?.toString(),
      trackingNumber: json['trackingNumber']?.toString(),
      returnAuthorizationNumber: json['returnAuthorizationNumber']?.toString(),
      comments: json['comments']?.toString(),
      eventTime: json['eventTime'] != null
          ? DateTime.tryParse(json['eventTime'].toString())
          : null,
      eventTimeZoneOffset: json['eventTimeZoneOffset']?.toString(),
      sourceEventId: json['sourceEventId']?.toString(),
      returnReason: json['returnReason']?.toString(),
      actingGln: json['actingGln']?.toString(),
    );
  }
}
