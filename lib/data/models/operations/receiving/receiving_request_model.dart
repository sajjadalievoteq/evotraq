import 'package:traqtrace_app/data/models/operations/shared/operation_gln_display.dart';
import 'package:traqtrace_app/features/operations/shared/utils/operation_event_time_codec.dart';

class ReceivingRequest {
  ReceivingRequest({
    this.receivingReference,
    required this.epcs,
    required this.sourceGLN,
    required this.receivingGLN,
    this.sourceLocation,
    this.receivingLocation,
    this.purchaseOrderNumber,
    this.despatchAdviceNumber,
    this.receivingAdviceNumber,
    this.invoiceNumber,
    this.billOfLadingNumber,
    this.carrier,
    this.trackingNumber,
    this.comments,
    this.eventTime,
    this.eventTimeZoneOffset,
  });

  String? receivingReference;
  List<String> epcs;
  String sourceGLN;
  String receivingGLN;
  OperationGlnDisplay? sourceLocation;
  OperationGlnDisplay? receivingLocation;
  String? purchaseOrderNumber;
  String? despatchAdviceNumber;
  String? receivingAdviceNumber;
  String? invoiceNumber;
  String? billOfLadingNumber;
  String? carrier;
  String? trackingNumber;
  String? comments;
  DateTime? eventTime;
  String? eventTimeZoneOffset;

  ReceivingRequest copyWith({
    String? receivingReference,
    List<String>? epcs,
    String? sourceGLN,
    String? receivingGLN,
    OperationGlnDisplay? sourceLocation,
    OperationGlnDisplay? receivingLocation,
    String? purchaseOrderNumber,
    String? despatchAdviceNumber,
    String? receivingAdviceNumber,
    String? invoiceNumber,
    String? billOfLadingNumber,
    String? carrier,
    String? trackingNumber,
    String? comments,
    DateTime? eventTime,
    String? eventTimeZoneOffset,
  }) {
    return ReceivingRequest(
      receivingReference: receivingReference ?? this.receivingReference,
      epcs: epcs ?? this.epcs,
      sourceGLN: sourceGLN ?? this.sourceGLN,
      receivingGLN: receivingGLN ?? this.receivingGLN,
      sourceLocation: sourceLocation ?? this.sourceLocation,
      receivingLocation: receivingLocation ?? this.receivingLocation,
      purchaseOrderNumber: purchaseOrderNumber ?? this.purchaseOrderNumber,
      despatchAdviceNumber: despatchAdviceNumber ?? this.despatchAdviceNumber,
      receivingAdviceNumber:
          receivingAdviceNumber ?? this.receivingAdviceNumber,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      billOfLadingNumber: billOfLadingNumber ?? this.billOfLadingNumber,
      carrier: carrier ?? this.carrier,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      comments: comments ?? this.comments,
      eventTime: eventTime ?? this.eventTime,
      eventTimeZoneOffset: eventTimeZoneOffset ?? this.eventTimeZoneOffset,
    );
  }

  Map<String, dynamic> toJson() {
    final eventFields = OperationEventTimeCodec.fieldsForRequest(eventTime);
    return {
      if (receivingReference != null && receivingReference!.isNotEmpty)
        'receivingReference': receivingReference,
      'epcs': epcs,
      'sourceGLN': sourceGLN,
      'receivingGLN': receivingGLN,
      if (sourceLocation != null) 'sourceLocation': sourceLocation!.toJson(),
      if (receivingLocation != null)
        'receivingLocation': receivingLocation!.toJson(),
      'purchaseOrderNumber': purchaseOrderNumber,
      'despatchAdviceNumber': despatchAdviceNumber,
      'receivingAdviceNumber': receivingAdviceNumber,
      'invoiceNumber': invoiceNumber,
      'billOfLadingNumber': billOfLadingNumber,
      'carrier': carrier,
      'trackingNumber': trackingNumber,
      'comments': comments,
      'eventTime': eventFields['eventTime'],
      'eventTimeZoneOffset':
          eventTimeZoneOffset ?? eventFields['eventTimeZoneOffset'],
    };
  }

  factory ReceivingRequest.fromJson(Map<String, dynamic> json) {
    return ReceivingRequest(
      receivingReference: json['receivingReference']?.toString(),
      epcs: (json['epcs'] as List? ?? const [])
          .map((e) => e.toString())
          .toList(),
      sourceGLN: (json['sourceGLN'] ?? '').toString(),
      receivingGLN: (json['receivingGLN'] ?? '').toString(),
      purchaseOrderNumber: json['purchaseOrderNumber']?.toString(),
      despatchAdviceNumber: json['despatchAdviceNumber']?.toString(),
      receivingAdviceNumber: json['receivingAdviceNumber']?.toString(),
      invoiceNumber: json['invoiceNumber']?.toString(),
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
