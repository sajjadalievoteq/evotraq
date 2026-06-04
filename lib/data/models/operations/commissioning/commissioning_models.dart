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

  /// Country of manufacture — ISO 3166-1 alpha-2 (e.g. "AE").
  /// Required for Tatmeen / UAE regulatory submissions (cbvmda:countryOfOrigin).
  String? countryOfOrigin;

  /// Read-point GLN — the GLN of the scan point within the commissioning location.
  /// Defaults to the commissioning location GLN if omitted.
  String? readPointGLN;

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
    this.countryOfOrigin,
    this.readPointGLN,
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
      'notes': comments,
      'regulatoryMarket': regulatoryMarket,
      'regulatoryStatus': regulatoryStatus,
      'countryOfOrigin': countryOfOrigin,
      'readPointGLN': readPointGLN,
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
      comments: json['notes'] ?? json['comments'],
      regulatoryMarket: json['regulatoryMarket'],
      regulatoryStatus: json['regulatoryStatus'],
      countryOfOrigin: json['countryOfOrigin'],
      readPointGLN: json['readPointGLN'],
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

  /// EPCIS 2.0 §7.4.2: long-term item state set at commissioning (always 'active').
  String? persistentDisposition;

  /// Business transaction references attached to the EPCIS event.
  /// Each entry has keys 'type' (CBV BTT URN) and 'bizTransaction' (the ID).
  List<Map<String, String>>? bizTransactionList;

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
    this.persistentDisposition,
    this.bizTransactionList,
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
      persistentDisposition: json['persistentDisposition'],
      bizTransactionList: json['bizTransactionList'] != null
          ? (json['bizTransactionList'] as List)
              .map((e) => Map<String, String>.from(e as Map))
              .toList()
          : null,
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
      'persistentDisposition': persistentDisposition,
      'bizTransactionList': bizTransactionList,
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

/// Batch status values returned by GET /commissioning/batches
enum CommissioningBatchStatus {
  pending,
  inProgress,
  success,
  partialSuccess,
  failed,
}

/// Maps to CommissioningBatchDTO — returned by GET /commissioning/batches
class CommissioningBatch {
  final String batchId;
  final String? commissioningReference;
  final String? epcisEventId;
  final String? gtinCode;
  final String? batchLotNumber;
  final String? commissioningLocationGLN;
  final int totalRequested;
  final int totalCommissioned;
  final int totalFailed;
  final CommissioningBatchStatus status;
  final DateTime? expiryDate;
  final DateTime? productionDate;
  final String? operatorId;
  final String? createdBy;
  final DateTime? createdAt;
  final DateTime? completedAt;

  const CommissioningBatch({
    required this.batchId,
    this.commissioningReference,
    this.epcisEventId,
    this.gtinCode,
    this.batchLotNumber,
    this.commissioningLocationGLN,
    required this.totalRequested,
    required this.totalCommissioned,
    required this.totalFailed,
    required this.status,
    this.expiryDate,
    this.productionDate,
    this.operatorId,
    this.createdBy,
    this.createdAt,
    this.completedAt,
  });

  factory CommissioningBatch.fromJson(Map<String, dynamic> json) {
    return CommissioningBatch(
      batchId: json['batchId'] as String,
      commissioningReference: json['commissioningReference'] as String?,
      epcisEventId: json['epcisEventId'] as String?,
      gtinCode: json['gtinCode'] as String?,
      batchLotNumber: json['batchLotNumber'] as String?,
      commissioningLocationGLN: json['commissioningLocationGLN'] as String?,
      totalRequested: (json['totalRequested'] as num?)?.toInt() ?? 0,
      totalCommissioned: (json['totalCommissioned'] as num?)?.toInt() ?? 0,
      totalFailed: (json['totalFailed'] as num?)?.toInt() ?? 0,
      status: _parseStatus(json['status'] as String?),
      expiryDate: json['expiryDate'] != null
          ? DateTime.tryParse(json['expiryDate'] as String)
          : null,
      productionDate: json['productionDate'] != null
          ? DateTime.tryParse(json['productionDate'] as String)
          : null,
      operatorId: json['operatorId'] as String?,
      createdBy: json['createdBy'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'] as String)
          : null,
    );
  }

  static CommissioningBatchStatus _parseStatus(String? raw) {
    switch (raw) {
      case 'PENDING':
        return CommissioningBatchStatus.pending;
      case 'IN_PROGRESS':
        return CommissioningBatchStatus.inProgress;
      case 'SUCCESS':
        return CommissioningBatchStatus.success;
      case 'PARTIAL_SUCCESS':
        return CommissioningBatchStatus.partialSuccess;
      case 'FAILED':
        return CommissioningBatchStatus.failed;
      default:
        return CommissioningBatchStatus.pending;
    }
  }
}

/// Per-item result returned by GET /commissioning/batches/{batchId}/items
class CommissioningBatchItem {
  final String serialNumber;
  final String? epcUri;
  final int? sgtinId;
  final bool success;
  final String? errorMessage;

  const CommissioningBatchItem({
    required this.serialNumber,
    this.epcUri,
    this.sgtinId,
    required this.success,
    this.errorMessage,
  });

  factory CommissioningBatchItem.fromJson(Map<String, dynamic> json) {
    return CommissioningBatchItem(
      serialNumber: json['serialNumber'] as String? ?? '',
      epcUri: json['epcUri'] as String?,
      sgtinId: (json['sgtinId'] as num?)?.toInt(),
      success: json['success'] as bool? ?? false,
      errorMessage: json['errorMessage'] as String?,
    );
  }
}
