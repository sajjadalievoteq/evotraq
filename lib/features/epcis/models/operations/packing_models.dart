// Models for packing operations.
// Packing is an aggregation operation where items are packed into a container.
// GS1 Business Step: urn:epcglobal:cbv:bizstep:packing
// Uses AggregationEvent with action ADD

class PackingRequest {
  String packingReference;
  String parentContainerId;
  List<String> childEpcs;
  String? packingLocationGLN;
  String? readPointGLN;
  DateTime? eventTime;
  String? workOrderNumber;
  String? batchNumber;
  String? productionOrder;
  String? packingLine;
  String? operatorId;
  String? comments;
  Map<String, String>? additionalData;

  PackingRequest({
    required this.packingReference,
    required this.parentContainerId,
    required this.childEpcs,
    this.packingLocationGLN,
    this.readPointGLN,
    this.eventTime,
    this.workOrderNumber,
    this.batchNumber,
    this.productionOrder,
    this.packingLine,
    this.operatorId,
    this.comments,
    this.additionalData,
  });

  Map<String, dynamic> toJson() {
    return {
      'packingReference': packingReference,
      'parentContainerId': parentContainerId,
      'childEpcs': childEpcs,
      'packingLocationGLN': packingLocationGLN,
      'readPointGLN': readPointGLN,
      'eventTime': eventTime?.toIso8601String(),
      'workOrderNumber': workOrderNumber,
      'batchNumber': batchNumber,
      'productionOrder': productionOrder,
      'packingLine': packingLine,
      'operatorId': operatorId,
      'comments': comments,
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
      eventTime: json['eventTime'] != null ? DateTime.parse(json['eventTime']) : null,
      workOrderNumber: json['workOrderNumber'],
      batchNumber: json['batchNumber'],
      productionOrder: json['productionOrder'],
      packingLine: json['packingLine'],
      operatorId: json['operatorId'],
      comments: json['comments'],
      additionalData: json['additionalData'] != null 
          ? Map<String, String>.from(json['additionalData']) 
          : null,
    );
  }
}

enum PackingStatus {
  success,
  partialSuccess,
  failed,
  validationError,
}

class PackingResponse {
  String? packingOperationId;
  String? packingReference;
  List<String>? eventIds;
  String? parentContainerId;
  int? packedItemsCount;
  List<String>? childEpcList;
  PackingStatus? status;
  DateTime? processedAt;
  String? packingLocationGLN;
  String? workOrderNumber;
  String? batchNumber;
  String? productionOrder;
  String? packingLine;
  String? operatorId;
  String? comments;
  List<String>? messages;
  int? processingTimeMs;
  Map<String, dynamic>? metadata;

  PackingResponse({
    this.packingOperationId,
    this.packingReference,
    this.eventIds,
    this.parentContainerId,
    this.packedItemsCount,
    this.childEpcList,
    this.status,
    this.processedAt,
    this.packingLocationGLN,
    this.workOrderNumber,
    this.batchNumber,
    this.productionOrder,
    this.packingLine,
    this.operatorId,
    this.comments,
    this.messages,
    this.processingTimeMs,
    this.metadata,
  });

  factory PackingResponse.fromJson(Map<String, dynamic> json) {
    return PackingResponse(
      packingOperationId: json['packingOperationId'],
      packingReference: json['packingReference'],
      eventIds: json['eventIds'] != null ? List<String>.from(json['eventIds']) : null,
      parentContainerId: json['parentContainerId'],
      packedItemsCount: json['packedItemsCount'],
      childEpcList: json['childEpcList'] != null ? List<String>.from(json['childEpcList']) : null,
      status: json['status'] != null ? _parseStatus(json['status']) : null,
      processedAt: json['processedAt'] != null ? DateTime.parse(json['processedAt']) : null,
      packingLocationGLN: json['packingLocationGLN'],
      workOrderNumber: json['workOrderNumber'],
      batchNumber: json['batchNumber'],
      productionOrder: json['productionOrder'],
      packingLine: json['packingLine'],
      operatorId: json['operatorId'],
      comments: json['comments'],
      messages: json['messages'] != null ? List<String>.from(json['messages']) : null,
      processingTimeMs: json['processingTimeMs'],
      metadata: json['metadata'],
    );
  }

  static PackingStatus _parseStatus(String status) {
    switch (status.toUpperCase()) {
      case 'SUCCESS':
        return PackingStatus.success;
      case 'PARTIAL_SUCCESS':
        return PackingStatus.partialSuccess;
      case 'FAILED':
        return PackingStatus.failed;
      case 'VALIDATION_ERROR':
        return PackingStatus.validationError;
      default:
        return PackingStatus.failed;
    }
  }

  bool get isSuccess => status == PackingStatus.success;
  bool get hasErrors => status == PackingStatus.failed || status == PackingStatus.validationError;
}
