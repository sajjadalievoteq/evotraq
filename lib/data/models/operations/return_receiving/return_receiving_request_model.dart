import 'package:traqtrace_app/data/models/operations/shared/operation_gln_display.dart';
import 'package:traqtrace_app/features/operations/shared/utils/operation_event_time_codec.dart';

class ReturnReceivingRequest {

  ReturnReceivingRequest({

    this.returnReceivingReference,

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

    this.returnAuthorizationNumber,

    this.comments,

    this.gincNumber,

    this.eventTime,

    this.eventTimeZoneOffset,

    this.sourceEventId,

    this.returnReason,

    this.actingGln,

    this.returnShippingEventId,

  });



  String? returnReceivingReference;

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

  String? returnAuthorizationNumber;

  String? comments;

  String? gincNumber;

  DateTime? eventTime;

  String? eventTimeZoneOffset;

  String? sourceEventId;

  String? returnReason;

  String? actingGln;

  String? returnShippingEventId;



  ReturnReceivingRequest copyWith({

    String? returnReceivingReference,

    List<String>? epcs,

    String? sourceGLN,

    String? receivingGLN,

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

    return ReturnReceivingRequest(

      returnReceivingReference: returnReceivingReference ?? this.returnReceivingReference,

      epcs: epcs ?? this.epcs,

      sourceGLN: sourceGLN ?? this.sourceGLN,

      receivingGLN: receivingGLN ?? this.receivingGLN,

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

      if (returnReceivingReference != null &&

          returnReceivingReference!.isNotEmpty)

        'returnReceivingReference': returnReceivingReference,

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

      'returnAuthorizationNumber': returnAuthorizationNumber,

      'comments': comments,

      if (gincNumber != null && gincNumber!.isNotEmpty) 'gincNumber': gincNumber,

      'eventTime': eventFields['eventTime'],

      'eventTimeZoneOffset':
          eventTimeZoneOffset ?? eventFields['eventTimeZoneOffset'],

      if (sourceEventId != null) 'sourceEventId': sourceEventId,

      if (returnReason != null) 'returnReason': returnReason,

      if (actingGln != null) 'actingGln': actingGln,

      if (returnShippingEventId != null) 'returnShippingEventId': returnShippingEventId,

    };

  }



  factory ReturnReceivingRequest.fromJson(Map<String, dynamic> json) {

    return ReturnReceivingRequest(

      returnReceivingReference: json['returnReceivingReference']?.toString(),

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

      returnAuthorizationNumber: json['returnAuthorizationNumber']?.toString(),

      comments: json['comments']?.toString(),

      gincNumber: json['gincNumber']?.toString(),

      eventTime: json['eventTime'] != null
          ? DateTime.tryParse(json['eventTime'].toString())
          : null,
      eventTimeZoneOffset: json['eventTimeZoneOffset']?.toString(),
      sourceEventId: json['sourceEventId']?.toString(),
      returnReason: json['returnReason']?.toString(),
      actingGln: json['actingGln']?.toString(),
      returnShippingEventId: json['returnShippingEventId']?.toString(),
    );
  }
}