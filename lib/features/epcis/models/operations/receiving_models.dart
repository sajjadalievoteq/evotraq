class ReceivingRequest {
  String receivingReference;
  List<String> epcs;
  String? receivingGLN;
  String? sourceGLN;
  String? businessLocationGLN;
  String? readPointGLN;
  DateTime? eventTime;
  String? purchaseOrderNumber;
  String? invoiceNumber;
  String? billOfLadingNumber;
  String? carrier;
  String? trackingNumber;
  String? receivingCondition;
  Map<String, String>? additionalData;
  String? comments;

  ReceivingRequest({
    required this.receivingReference,
    required this.epcs,
    this.receivingGLN,
    this.sourceGLN,
    this.businessLocationGLN,
    this.readPointGLN,
    this.eventTime,
    this.purchaseOrderNumber,
    this.invoiceNumber,
    this.billOfLadingNumber,
    this.carrier,
    this.trackingNumber,
    this.receivingCondition,
    this.additionalData,
    this.comments,
  });

  Map<String, dynamic> toJson() {
    return {
      'receivingReference': receivingReference,
      'epcs': epcs,
      'receivingGLN': receivingGLN,
      'sourceGLN': sourceGLN,
      'businessLocationGLN': businessLocationGLN,
      'readPointGLN': readPointGLN,
      'eventTime': eventTime?.toIso8601String(),
      'purchaseOrderNumber': purchaseOrderNumber,
      'invoiceNumber': invoiceNumber,
      'billOfLadingNumber': billOfLadingNumber,
      'carrier': carrier,
      'trackingNumber': trackingNumber,
      'receivingCondition': receivingCondition,
      'additionalData': additionalData,
      'comments': comments,
    };
  }

  factory ReceivingRequest.fromJson(Map<String, dynamic> json) {
    return ReceivingRequest(
      receivingReference: json['receivingReference'],
      epcs: List<String>.from(json['epcs']),
      receivingGLN: json['receivingGLN'],
      sourceGLN: json['sourceGLN'],
      businessLocationGLN: json['businessLocationGLN'],
      readPointGLN: json['readPointGLN'],
      eventTime: json['eventTime'] != null ? DateTime.parse(json['eventTime']) : null,
      purchaseOrderNumber: json['purchaseOrderNumber'],
      invoiceNumber: json['invoiceNumber'],
      billOfLadingNumber: json['billOfLadingNumber'],
      carrier: json['carrier'],
      trackingNumber: json['trackingNumber'],
      receivingCondition: json['receivingCondition'],
      additionalData: json['additionalData'] != null ? Map<String, String>.from(json['additionalData']) : null,
      comments: json['comments'],
    );
  }
}

enum ReceivingStatus {
  success,
  partialSuccess,
  failed,
  validationError,
}

class ReceivingResponse {
  String? receivingOperationId;
  String? receivingReference;
  List<String>? eventIds;
  int? processedEpcsCount;
  List<String>? epcList;
  ReceivingStatus? status;
  DateTime? processedAt;
  String? receivingGLN;
  String? sourceGLN;
  String? purchaseOrderNumber;
  String? invoiceNumber;
  String? billOfLadingNumber;
  String? carrier;
  String? trackingNumber;
  String? comments;
  List<String>? messages;
  int? processingTimeMs;
  Map<String, dynamic>? metadata;

  ReceivingResponse({
    this.receivingOperationId,
    this.receivingReference,
    this.eventIds,
    this.processedEpcsCount,
    this.epcList,
    this.status,
    this.processedAt,
    this.receivingGLN,
    this.sourceGLN,
    this.purchaseOrderNumber,
    this.invoiceNumber,
    this.billOfLadingNumber,
    this.carrier,
    this.trackingNumber,
    this.comments,
    this.messages,
    this.processingTimeMs,
    this.metadata,
  });

  factory ReceivingResponse.fromJson(Map<String, dynamic> json) {
    return ReceivingResponse(
      receivingOperationId: json['receivingOperationId'],
      receivingReference: json['receivingReference'],
      eventIds: json['eventIds'] != null ? List<String>.from(json['eventIds']) : null,
      processedEpcsCount: json['processedEpcsCount'],
      epcList: json['epcList'] != null ? List<String>.from(json['epcList']) : null,
      status: json['status'] != null ? _parseStatus(json['status']) : null,
      processedAt: json['processedAt'] != null ? DateTime.parse(json['processedAt']) : null,
      receivingGLN: json['receivingGLN'],
      sourceGLN: json['sourceGLN'],
      purchaseOrderNumber: json['purchaseOrderNumber'],
      invoiceNumber: json['invoiceNumber'],
      billOfLadingNumber: json['billOfLadingNumber'],
      carrier: json['carrier'],
      trackingNumber: json['trackingNumber'],
      comments: json['comments'],
      messages: json['messages'] != null ? List<String>.from(json['messages']) : null,
      processingTimeMs: json['processingTimeMs'],
      metadata: json['metadata'],
    );
  }

  static ReceivingStatus _parseStatus(String status) {
    switch (status.toUpperCase()) {
      case 'SUCCESS':
        return ReceivingStatus.success;
      case 'PARTIAL_SUCCESS':
        return ReceivingStatus.partialSuccess;
      case 'FAILED':
        return ReceivingStatus.failed;
      case 'VALIDATION_ERROR':
        return ReceivingStatus.validationError;
      default:
        return ReceivingStatus.failed;
    }
  }

  bool get isSuccess => status == ReceivingStatus.success;
  bool get hasErrors => status == ReceivingStatus.failed || status == ReceivingStatus.validationError;
}
