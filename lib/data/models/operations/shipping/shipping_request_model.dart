import 'package:traqtrace_app/data/models/operations/shared/operation_gln_display.dart';
import 'package:traqtrace_app/features/operations/shared/utils/operation_event_time_codec.dart';

class ShippingRequest {
  ShippingRequest({
    this.shippingReference,
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
    this.comments,
    this.gincNumber,
    this.eventTime,
    this.eventTimeZoneOffset,
  });

  String? shippingReference;
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
  String? comments;
  String? gincNumber;
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
      if (sourceLocation != null) 'sourceLocation': sourceLocation!.toJson(),
      if (destinationLocation != null)
        'destinationLocation': destinationLocation!.toJson(),
      'purchaseOrderNumber': purchaseOrderNumber,
      'despatchAdviceNumber': despatchAdviceNumber,
      'billOfLadingNumber': billOfLadingNumber,
      'carrier': carrier,
      'trackingNumber': trackingNumber,
      'comments': comments,
      if (gincNumber != null && gincNumber!.isNotEmpty) 'gincNumber': gincNumber,
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
      gincNumber: json['gincNumber']?.toString(),
      eventTime: json['eventTime'] != null
          ? DateTime.tryParse(json['eventTime'].toString())
          : null,
      eventTimeZoneOffset: json['eventTimeZoneOffset']?.toString(),
    );
  }
}
