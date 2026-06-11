class ShippingRequest {
  String shippingReference;
  List<String> epcs;
  String? destinationGLN;
  String? sourceGLN;
  String? businessLocationGLN;
  String? readPointGLN;
  DateTime? eventTime;
  String? purchaseOrderNumber;
  String? invoiceNumber;
  String? billOfLadingNumber;
  String? carrier;
  String? trackingNumber;
  DateTime? expectedDeliveryDate;
  Map<String, String>? additionalData;
  String? comments;

  ShippingRequest({
    required this.shippingReference,
    required this.epcs,
    this.destinationGLN,
    this.sourceGLN,
    this.businessLocationGLN,
    this.readPointGLN,
    this.eventTime,
    this.purchaseOrderNumber,
    this.invoiceNumber,
    this.billOfLadingNumber,
    this.carrier,
    this.trackingNumber,
    this.expectedDeliveryDate,
    this.additionalData,
    this.comments,
  });

  Map<String, dynamic> toJson() {
    return {
      'shippingReference': shippingReference,
      'epcs': epcs,
      'destinationGLN': destinationGLN,
      'sourceGLN': sourceGLN,
      'businessLocationGLN': businessLocationGLN,
      'readPointGLN': readPointGLN,
      'eventTime': eventTime?.toIso8601String(),
      'purchaseOrderNumber': purchaseOrderNumber,
      'invoiceNumber': invoiceNumber,
      'billOfLadingNumber': billOfLadingNumber,
      'carrier': carrier,
      'trackingNumber': trackingNumber,
      'expectedDeliveryDate': expectedDeliveryDate?.toIso8601String(),
      'additionalData': additionalData,
      'comments': comments,
    };
  }

  factory ShippingRequest.fromJson(Map<String, dynamic> json) {
    return ShippingRequest(
      shippingReference: json['shippingReference'],
      epcs: List<String>.from(json['epcs']),
      destinationGLN: json['destinationGLN'],
      sourceGLN: json['sourceGLN'],
      businessLocationGLN: json['businessLocationGLN'],
      readPointGLN: json['readPointGLN'],
      eventTime: json['eventTime'] != null ? DateTime.parse(json['eventTime']) : null,
      purchaseOrderNumber: json['purchaseOrderNumber'],
      invoiceNumber: json['invoiceNumber'],
      billOfLadingNumber: json['billOfLadingNumber'],
      carrier: json['carrier'],
      trackingNumber: json['trackingNumber'],
      expectedDeliveryDate: json['expectedDeliveryDate'] != null ? DateTime.parse(json['expectedDeliveryDate']) : null,
      additionalData: json['additionalData'] != null ? Map<String, String>.from(json['additionalData']) : null,
      comments: json['comments'],
    );
  }
}

enum ShippingStatus {
  success,
  partialSuccess,
  failed,
  validationError,
}

class ShippingResponse {
  String? shippingOperationId;
  String? shippingReference;
  List<String>? eventIds;
  int? processedEpcsCount;
  List<String>? epcList;
  ShippingStatus? status;
  DateTime? processedAt;
  String? destinationGLN;
  String? sourceGLN;
  String? comments;
  List<String>? messages;
  int? processingTimeMs;
  Map<String, dynamic>? metadata;

  ShippingResponse({
    this.shippingOperationId,
    this.shippingReference,
    this.eventIds,
    this.processedEpcsCount,
    this.epcList,
    this.status,
    this.processedAt,
    this.destinationGLN,
    this.sourceGLN,
    this.comments,
    this.messages,
    this.processingTimeMs,
    this.metadata,
  });

  factory ShippingResponse.fromJson(Map<String, dynamic> json) {
    return ShippingResponse(
      shippingOperationId: json['shippingOperationId'],
      shippingReference: json['shippingReference'],
      eventIds: json['eventIds'] != null ? List<String>.from(json['eventIds']) : null,
      processedEpcsCount: json['processedEpcsCount'],
      epcList: json['epcList'] != null ? List<String>.from(json['epcList']) : null,
      status: json['status'] != null ? _parseStatus(json['status']) : null,
      processedAt: json['processedAt'] != null ? DateTime.parse(json['processedAt']) : null,
      destinationGLN: json['destinationGLN'],
      sourceGLN: json['sourceGLN'],
      comments: json['comments'],
      messages: json['messages'] != null ? List<String>.from(json['messages']) : null,
      processingTimeMs: json['processingTimeMs'],
      metadata: json['metadata'],
    );
  }

  static ShippingStatus _parseStatus(String status) {
    switch (status.toUpperCase()) {
      case 'SUCCESS':
        return ShippingStatus.success;
      case 'PARTIAL_SUCCESS':
        return ShippingStatus.partialSuccess;
      case 'FAILED':
        return ShippingStatus.failed;
      case 'VALIDATION_ERROR':
        return ShippingStatus.validationError;
      default:
        return ShippingStatus.failed;
    }
  }

  bool get isSuccess => status == ShippingStatus.success;
  bool get hasErrors => status == ShippingStatus.failed || status == ShippingStatus.validationError;
}