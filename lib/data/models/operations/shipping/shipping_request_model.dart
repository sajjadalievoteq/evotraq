import 'package:traqtrace_app/features/operations/shared/utils/operation_event_time_codec.dart';

class ShippingRequest {
  ShippingRequest({
    this.shippingReference,
    required this.epcs,
    required this.sourceGLN,
    required this.destinationGLN,
    this.purchaseOrderNumber,
    this.despatchAdviceNumber,
    this.billOfLadingNumber,
    this.carrier,
    this.trackingNumber,
    this.comments,
    this.eventTime,
    this.eventTimeZoneOffset,
  });

  String? shippingReference;
  List<String> epcs;
  String sourceGLN;
  String destinationGLN;
  String? purchaseOrderNumber;
  String? despatchAdviceNumber;
  String? billOfLadingNumber;
  String? carrier;
  String? trackingNumber;
  String? comments;
  DateTime? eventTime;
  String? eventTimeZoneOffset;

  Map<String, dynamic> toJson() {
    final eventFields = OperationEventTimeCodec.fieldsForRequest(eventTime);
    return {
      if (shippingReference != null && shippingReference!.isNotEmpty)
        'shippingReference': shippingReference,
      'epcs': epcs,
      'sourceGLN': sourceGLN,
      'destinationGLN': destinationGLN,
      'purchaseOrderNumber': purchaseOrderNumber,
      'despatchAdviceNumber': despatchAdviceNumber,
      'billOfLadingNumber': billOfLadingNumber,
      'carrier': carrier,
      'trackingNumber': trackingNumber,
      'comments': comments,
      'eventTime': eventFields['eventTime'],
      'eventTimeZoneOffset':
          eventTimeZoneOffset ?? eventFields['eventTimeZoneOffset'],
    };
  }

  factory ShippingRequest.fromJson(Map<String, dynamic> json) {
    return ShippingRequest(
      shippingReference: json['shippingReference']?.toString(),
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
      comments: json['comments']?.toString(),
      eventTime: json['eventTime'] != null
          ? DateTime.tryParse(json['eventTime'].toString())
          : null,
      eventTimeZoneOffset: json['eventTimeZoneOffset']?.toString(),
    );
  }
}
