import 'commissioning_canonical_identifier.dart';

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
      canonicalIdentifier: parseCommissioningCanonicalIdentifier(json),
      sgtinId: (json['sgtinId'] as num?)?.toInt(),
      success: json['success'] as bool? ?? false,
      errorMessage: json['errorMessage'] as String?,
    );
  }
}
