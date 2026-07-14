
class CommissioningRequest {
  String? commissioningReference;
  
  String gtinCode;
  
  List<String> serialNumbers;
  
  String batchLotNumber;
  
  String commissioningLocationGLN;
  
  DateTime? productionDate;
  DateTime? expiryDate;
  DateTime? bestBeforeDate;
  
  String? productionOrder;
  String? productionLine;
  String? operatorId;
  String? comments;
  
  String? regulatoryMarket;
  String? regulatoryStatus;

  String? countryOfOrigin;

  String? readPointGLN;

  /// UI/review only — not sent to POST /commissioning/bulk.
  String? identifierType;

  /// UI/review only — not sent to POST /commissioning/bulk (use serialNumbers).
  List<String>? canonicalIdentifiers;

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
    this.identifierType,
    this.canonicalIdentifiers,
  });

  Map<String, dynamic> toJson() {
    return {
      'commissioningReference': commissioningReference,
      'gtinCode': gtinCode,
      'serialNumbers': serialNumbers,
      'batchLotNumber': batchLotNumber,
      'commissioningLocationGLN': commissioningLocationGLN,
      // Backend fields are LocalDate (yyyy-MM-dd). Send date-only — a full ISO
      // datetime fails LocalDate deserialization (the cause of the commissioning
      // 500). Matches gtin_model.dart / gtin_pharmaceutical_extension_model.dart.
      'productionDate': productionDate?.toIso8601String().split('T').first,
      'expiryDate': expiryDate?.toIso8601String().split('T').first,
      'bestBeforeDate': bestBeforeDate?.toIso8601String().split('T').first,
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
      identifierType: json['identifierType'] as String?,
      canonicalIdentifiers: json['canonicalIdentifiers'] != null
          ? List<String>.from(json['canonicalIdentifiers'])
          : json['epcUris'] != null
              ? List<String>.from(json['epcUris'])
              : null,
    );
  }
}

/// Request body for POST /commissioning/sscc.
class SsccCommissioningRequest {
  String? commissioningReference;
  List<String> epcUris;
  String commissioningLocationGLN;
  String? readPointGLN;
  String? operatorId;
  String? notes;
  String? countryOfOrigin;

  /// Child SGTIN EPC URIs aggregated into the parent SSCC after commissioning.
  List<String>? childEpcUris;

  SsccCommissioningRequest({
    this.commissioningReference,
    required this.epcUris,
    required this.commissioningLocationGLN,
    this.readPointGLN,
    this.operatorId,
    this.notes,
    this.countryOfOrigin,
    this.childEpcUris,
  });

  Map<String, dynamic> toJson() => {
        if (commissioningReference != null)
          'commissioningReference': commissioningReference,
        'epcUris': epcUris,
        'commissioningLocationGLN': commissioningLocationGLN,
        if (readPointGLN != null && readPointGLN!.isNotEmpty)
          'readPointGLN': readPointGLN,
        if (operatorId != null && operatorId!.isNotEmpty) 'operatorId': operatorId,
        if (notes != null && notes!.isNotEmpty) 'notes': notes,
        if (countryOfOrigin != null && countryOfOrigin!.isNotEmpty)
          'countryOfOrigin': countryOfOrigin,
        if (childEpcUris != null && childEpcUris!.isNotEmpty)
          'childEpcUris': childEpcUris,
      };
}

enum CommissioningStatus {
  success,
  partialSuccess,
  failed,
  validationError,
}

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
  
  DateTime? productionDate;
  DateTime? expiryDate;
  DateTime? bestBeforeDate;
  String? itemDescription;
  
  List<String>? epcList;
  String? businessStep;
  String? disposition;
  String? action;
  
  String? operatorId;
  String? comments;
  String? productionOrder;
  String? productionLine;

  String? persistentDisposition;

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

class CommissioningItemResult {
  String serialNumber;
  String? sgtinId;
  String? canonicalIdentifier;
  String? eventId;
  bool success;
  String? errorMessage;
  String? outcome;

  CommissioningItemResult({
    required this.serialNumber,
    this.sgtinId,
    this.canonicalIdentifier,
    this.eventId,
    required this.success,
    this.errorMessage,
    this.outcome,
  });

  factory CommissioningItemResult.fromJson(Map<String, dynamic> json) {
    return CommissioningItemResult(
      serialNumber: json['serialNumber'] as String? ?? '',
      sgtinId: json['sgtinId']?.toString(),
      canonicalIdentifier: _parseCanonicalIdentifier(json),
      eventId: json['eventId'] as String?,
      success: json['success'] as bool? ?? false,
      errorMessage: json['errorMessage'] as String?,
      outcome: json['outcome'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'serialNumber': serialNumber,
      'sgtinId': sgtinId,
      if (canonicalIdentifier != null)
        'canonicalIdentifier': canonicalIdentifier,
      'eventId': eventId,
      'success': success,
      'errorMessage': errorMessage,
    };
  }
}

enum CommissioningBatchStatus {
  pending,
  inProgress,
  success,
  partialSuccess,
  failed,
}

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

class CommissioningBatchItem {
  final String serialNumber;
  final String? canonicalIdentifier;
  final int? sgtinId;
  final bool success;
  final String? errorMessage;

  const CommissioningBatchItem({
    required this.serialNumber,
    this.canonicalIdentifier,
    this.sgtinId,
    required this.success,
    this.errorMessage,
  });

  factory CommissioningBatchItem.fromJson(Map<String, dynamic> json) {
    return CommissioningBatchItem(
      serialNumber: json['serialNumber'] as String? ?? '',
      canonicalIdentifier: _parseCanonicalIdentifier(json),
      sgtinId: (json['sgtinId'] as num?)?.toInt(),
      success: json['success'] as bool? ?? false,
      errorMessage: json['errorMessage'] as String?,
    );
  }
}

String? _parseCanonicalIdentifier(Map<String, dynamic> json) {
  final canonical = json['canonicalIdentifier'];
  if (canonical is String && canonical.trim().isNotEmpty) {
    return canonical.trim();
  }
  for (final key in ['epcUri', 'gs1DigitalLinkUri', 'ssccUri']) {
    final value = json[key];
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
  }
  return null;
}
