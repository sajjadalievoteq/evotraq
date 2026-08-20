import 'commissioning_canonical_identifier.dart';

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

  String? identifierType;

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

class SsccCommissioningRequest {
  String? commissioningReference;
  List<String> epcUris;
  String commissioningLocationGLN;
  String? readPointGLN;
  String? operatorId;
  String? notes;
  String? countryOfOrigin;

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

enum CommissioningStatus { success, partialSuccess, failed, validationError }

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
  bool get isFailed =>
      status == CommissioningStatus.failed ||
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
          ? DateTime.parse(json['processedAt']).toLocal()
          : null,
      eventTime: json['eventTime'] != null
          ? DateTime.parse(json['eventTime']).toLocal()
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
      canonicalIdentifier: parseCommissioningCanonicalIdentifier(json),
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
