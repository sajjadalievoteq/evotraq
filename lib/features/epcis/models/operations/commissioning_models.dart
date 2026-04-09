// Models for commissioning operations.
// Commissioning is the process of introducing items into the supply chain.
// GS1 Business Step: urn:epcglobal:cbv:bizstep:commissioning
// Uses ObjectEvent with action ADD

/// Request model for bulk commissioning operation
class CommissioningRequest {
  /// Unique reference for this commissioning batch (optional)
  String? commissioningReference;
  
  /// GTIN code for the product being commissioned
  String gtinCode;
  
  /// List of serial numbers to commission
  List<String> serialNumbers;
  
  /// Batch/Lot number for all items
  String batchLotNumber;
  
  /// Commissioning location GLN
  String commissioningLocationGLN;
  
  /// Production/Expiry dates
  DateTime? productionDate;
  DateTime? expiryDate;
  DateTime? bestBeforeDate;
  
  /// Optional metadata
  String? productionOrder;
  String? productionLine;
  String? operatorId;
  String? comments;
  
  /// Regulatory information
  String? regulatoryMarket;
  String? regulatoryStatus;

  CommissioningRequest({
    this.commissioningReference,
    required this.gtinCode,
    required this.serialNumbers,
    required this.batchLotNumber,
    required this.commissioningLocationGLN,
    this.productionDate,
    this.expiryDate,
    this.bestBeforeDate,
    this.productionOrder,
    this.productionLine,
    this.operatorId,
    this.comments,
    this.regulatoryMarket,
    this.regulatoryStatus,
  });

  Map<String, dynamic> toJson() {
    return {
      'commissioningReference': commissioningReference,
      'gtinCode': gtinCode,
      'serialNumbers': serialNumbers,
      'batchLotNumber': batchLotNumber,
      'commissioningLocationGLN': commissioningLocationGLN,
      'productionDate': productionDate?.toIso8601String(),
      'expiryDate': expiryDate?.toIso8601String(),
      'bestBeforeDate': bestBeforeDate?.toIso8601String(),
      'productionOrder': productionOrder,
      'productionLine': productionLine,
      'operatorId': operatorId,
      'comments': comments,
      'regulatoryMarket': regulatoryMarket,
      'regulatoryStatus': regulatoryStatus,
    };
  }

  factory CommissioningRequest.fromJson(Map<String, dynamic> json) {
    return CommissioningRequest(
      commissioningReference: json['commissioningReference'],
      gtinCode: json['gtinCode'],
      serialNumbers: List<String>.from(json['serialNumbers']),
      batchLotNumber: json['batchLotNumber'],
      commissioningLocationGLN: json['commissioningLocationGLN'],
      productionDate: json['productionDate'] != null 
          ? DateTime.parse(json['productionDate']) 
          : null,
      expiryDate: json['expiryDate'] != null 
          ? DateTime.parse(json['expiryDate']) 
          : null,
      bestBeforeDate: json['bestBeforeDate'] != null 
          ? DateTime.parse(json['bestBeforeDate']) 
          : null,
      productionOrder: json['productionOrder'],
      productionLine: json['productionLine'],
      operatorId: json['operatorId'],
      comments: json['comments'],
      regulatoryMarket: json['regulatoryMarket'],
      regulatoryStatus: json['regulatoryStatus'],
    );
  }
}

enum CommissioningStatus {
  success,
  partialSuccess,
  failed,
  validationError,
}

/// Response model for commissioning operation
class CommissioningResponse {
  String? commissioningOperationId;
  String? commissioningReference;
  List<String>? eventIds;
  List<String>? createdSgtinIds;
  int? commissionedCount;
  int? failedCount;
  CommissioningStatus? status;
  DateTime? processedAt;
  DateTime? eventTime;
  String? gtinCode;
  String? batchLotNumber;
  String? commissioningLocationGLN;
  String? readPointGLN;
  List<String>? messages;
  
  // ILMD (Instance/Lot Master Data) fields
  DateTime? productionDate;
  DateTime? expiryDate;
  DateTime? bestBeforeDate;
  String? itemDescription;
  
  // Event data
  List<String>? epcList;
  String? businessStep;
  String? disposition;
  String? action;
  
  // Additional metadata from request
  String? operatorId;
  String? comments;
  String? productionOrder;
  String? productionLine;
  List<CommissioningItemResult>? itemResults;
  int? processingTimeMs;
  Map<String, dynamic>? metadata;

  CommissioningResponse({
    this.commissioningOperationId,
    this.commissioningReference,
    this.eventIds,
    this.createdSgtinIds,
    this.commissionedCount,
    this.failedCount,
    this.status,
    this.processedAt,
    this.eventTime,
    this.gtinCode,
    this.batchLotNumber,
    this.commissioningLocationGLN,
    this.readPointGLN,
    this.messages,
    this.itemResults,
    this.processingTimeMs,
    this.metadata,
    this.productionDate,
    this.expiryDate,
    this.bestBeforeDate,
    this.itemDescription,
    this.epcList,
    this.businessStep,
    this.disposition,
    this.action,
    this.operatorId,
    this.comments,
    this.productionOrder,
    this.productionLine,
  });

  bool get isSuccess => status == CommissioningStatus.success;
  bool get isPartialSuccess => status == CommissioningStatus.partialSuccess;
  bool get isFailed => status == CommissioningStatus.failed || 
                       status == CommissioningStatus.validationError;

  factory CommissioningResponse.fromJson(Map<String, dynamic> json) {
    return CommissioningResponse(
      commissioningOperationId: json['commissioningOperationId'],
      commissioningReference: json['commissioningReference'],
      eventIds: json['eventIds'] != null 
          ? List<String>.from(json['eventIds']) 
          : null,
      createdSgtinIds: json['createdSgtinIds'] != null 
          ? List<String>.from(json['createdSgtinIds']) 
          : null,
      commissionedCount: json['commissionedCount'],
      failedCount: json['failedCount'],
      status: _parseStatus(json['status']),
      processedAt: json['processedAt'] != null 
          ? DateTime.parse(json['processedAt']) 
          : null,
      eventTime: json['eventTime'] != null 
          ? DateTime.parse(json['eventTime']) 
          : null,
      gtinCode: json['gtinCode'],
      batchLotNumber: json['batchLotNumber'],
      commissioningLocationGLN: json['commissioningLocationGLN'],
      readPointGLN: json['readPointGLN'],
      messages: json['messages'] != null 
          ? List<String>.from(json['messages']) 
          : null,
      itemResults: json['itemResults'] != null
          ? (json['itemResults'] as List)
              .map((item) => CommissioningItemResult.fromJson(item))
              .toList()
          : null,
      processingTimeMs: json['processingTimeMs'],
      metadata: json['metadata'],
      productionDate: json['productionDate'] != null 
          ? DateTime.parse(json['productionDate']) 
          : null,
      expiryDate: json['expiryDate'] != null 
          ? DateTime.parse(json['expiryDate']) 
          : null,
      bestBeforeDate: json['bestBeforeDate'] != null 
          ? DateTime.parse(json['bestBeforeDate']) 
          : null,
      itemDescription: json['itemDescription'],
      epcList: json['epcList'] != null 
          ? List<String>.from(json['epcList']) 
          : null,
      businessStep: json['businessStep'],
      disposition: json['disposition'],
      action: json['action'],
      operatorId: json['operatorId'],
      comments: json['comments'],
      productionOrder: json['productionOrder'],
      productionLine: json['productionLine'],
    );
  }

  static CommissioningStatus? _parseStatus(String? status) {
    if (status == null) return null;
    switch (status.toUpperCase()) {
      case 'SUCCESS':
        return CommissioningStatus.success;
      case 'PARTIAL_SUCCESS':
        return CommissioningStatus.partialSuccess;
      case 'FAILED':
        return CommissioningStatus.failed;
      case 'VALIDATION_ERROR':
        return CommissioningStatus.validationError;
      default:
        return null;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'commissioningOperationId': commissioningOperationId,
      'commissioningReference': commissioningReference,
      'eventIds': eventIds,
      'createdSgtinIds': createdSgtinIds,
      'commissionedCount': commissionedCount,
      'failedCount': failedCount,
      'status': status?.name.toUpperCase(),
      'processedAt': processedAt?.toIso8601String(),
      'eventTime': eventTime?.toIso8601String(),
      'gtinCode': gtinCode,
      'batchLotNumber': batchLotNumber,
      'commissioningLocationGLN': commissioningLocationGLN,
      'readPointGLN': readPointGLN,
      'messages': messages,
      'itemResults': itemResults?.map((r) => r.toJson()).toList(),
      'processingTimeMs': processingTimeMs,
      'metadata': metadata,
      'productionDate': productionDate?.toIso8601String(),
      'expiryDate': expiryDate?.toIso8601String(),
      'bestBeforeDate': bestBeforeDate?.toIso8601String(),
      'itemDescription': itemDescription,
      'epcList': epcList,
      'businessStep': businessStep,
      'disposition': disposition,
      'action': action,
      'operatorId': operatorId,
      'comments': comments,
      'productionOrder': productionOrder,
      'productionLine': productionLine,
    };
  }
}

/// Result for individual item commissioning
class CommissioningItemResult {
  String serialNumber;
  String? sgtinId;
  String? epcUri;
  String? eventId;
  bool success;
  String? errorMessage;

  CommissioningItemResult({
    required this.serialNumber,
    this.sgtinId,
    this.epcUri,
    this.eventId,
    required this.success,
    this.errorMessage,
  });

  factory CommissioningItemResult.fromJson(Map<String, dynamic> json) {
    return CommissioningItemResult(
      serialNumber: json['serialNumber'],
      sgtinId: json['sgtinId'],
      epcUri: json['epcUri'],
      eventId: json['eventId'],
      success: json['success'] ?? false,
      errorMessage: json['errorMessage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'serialNumber': serialNumber,
      'sgtinId': sgtinId,
      'epcUri': epcUri,
      'eventId': eventId,
      'success': success,
      'errorMessage': errorMessage,
    };
  }
}
