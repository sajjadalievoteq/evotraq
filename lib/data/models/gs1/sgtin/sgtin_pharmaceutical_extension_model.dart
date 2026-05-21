import 'package:equatable/equatable.dart';

double? _jsonDouble(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  final s = v.toString().trim();
  if (s.isEmpty) return null;
  return double.tryParse(s);
}

int? _jsonInt(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toInt();
  final s = v.toString().trim();
  if (s.isEmpty) return null;
  return int.tryParse(s);
}

/// Physical state of the tamper-evident seal (maps to backend AntiTamperStatus).
enum SgtinAntiTamperStatus {
  intact,
  broken,
  missing,
  notApplicable,
}

extension SgtinAntiTamperStatusExtension on SgtinAntiTamperStatus {
  String get value {
    switch (this) {
      case SgtinAntiTamperStatus.intact:
        return 'INTACT';
      case SgtinAntiTamperStatus.broken:
        return 'BROKEN';
      case SgtinAntiTamperStatus.missing:
        return 'MISSING';
      case SgtinAntiTamperStatus.notApplicable:
        return 'NOT_APPLICABLE';
    }
  }

  String get displayName {
    switch (this) {
      case SgtinAntiTamperStatus.intact:
        return 'Intact';
      case SgtinAntiTamperStatus.broken:
        return 'Broken';
      case SgtinAntiTamperStatus.missing:
        return 'Missing';
      case SgtinAntiTamperStatus.notApplicable:
        return 'Not Applicable';
    }
  }

  static SgtinAntiTamperStatus fromString(String? value) {
    switch (value?.toUpperCase()) {
      case 'INTACT':
        return SgtinAntiTamperStatus.intact;
      case 'BROKEN':
        return SgtinAntiTamperStatus.broken;
      case 'MISSING':
        return SgtinAntiTamperStatus.missing;
      default:
        return SgtinAntiTamperStatus.notApplicable;
    }
  }
}

/// Return workflow state for a dispensed item.
enum SgtinReturnStatus {
  notReturned,
  returnPending,
  returnVerified,
  returnRejected,
}

extension SgtinReturnStatusExtension on SgtinReturnStatus {
  String get value {
    switch (this) {
      case SgtinReturnStatus.notReturned:
        return 'NOT_RETURNED';
      case SgtinReturnStatus.returnPending:
        return 'RETURN_PENDING';
      case SgtinReturnStatus.returnVerified:
        return 'RETURN_VERIFIED';
      case SgtinReturnStatus.returnRejected:
        return 'RETURN_REJECTED';
    }
  }

  String get displayName {
    switch (this) {
      case SgtinReturnStatus.notReturned:
        return 'Not Returned';
      case SgtinReturnStatus.returnPending:
        return 'Return Pending';
      case SgtinReturnStatus.returnVerified:
        return 'Return Verified';
      case SgtinReturnStatus.returnRejected:
        return 'Return Rejected';
    }
  }

  static SgtinReturnStatus fromString(String? value) {
    switch (value?.toUpperCase()) {
      case 'RETURN_PENDING':
        return SgtinReturnStatus.returnPending;
      case 'RETURN_VERIFIED':
        return SgtinReturnStatus.returnVerified;
      case 'RETURN_REJECTED':
        return SgtinReturnStatus.returnRejected;
      default:
        return SgtinReturnStatus.notReturned;
    }
  }
}

/// Parallel trade / repackaging state.
enum SgtinParallelTradeStatus {
  none,
  repackaged,
  relabeled,
  repackagedAndRelabeled,
}

extension SgtinParallelTradeStatusExtension on SgtinParallelTradeStatus {
  String get value {
    switch (this) {
      case SgtinParallelTradeStatus.none:
        return 'NONE';
      case SgtinParallelTradeStatus.repackaged:
        return 'REPACKAGED';
      case SgtinParallelTradeStatus.relabeled:
        return 'RELABELED';
      case SgtinParallelTradeStatus.repackagedAndRelabeled:
        return 'REPACKAGED_AND_RELABELED';
    }
  }

  String get displayName {
    switch (this) {
      case SgtinParallelTradeStatus.none:
        return 'None';
      case SgtinParallelTradeStatus.repackaged:
        return 'Repackaged';
      case SgtinParallelTradeStatus.relabeled:
        return 'Relabeled';
      case SgtinParallelTradeStatus.repackagedAndRelabeled:
        return 'Repackaged and Relabeled';
    }
  }

  static SgtinParallelTradeStatus fromString(String? value) {
    switch (value?.toUpperCase()) {
      case 'REPACKAGED':
        return SgtinParallelTradeStatus.repackaged;
      case 'RELABELED':
        return SgtinParallelTradeStatus.relabeled;
      case 'REPACKAGED_AND_RELABELED':
        return SgtinParallelTradeStatus.repackagedAndRelabeled;
      default:
        return SgtinParallelTradeStatus.none;
    }
  }
}

/// Pharmaceutical lifecycle extension for a serialised item (SGTIN).
///
/// Maps to [SGTINPharmaceuticalExtensionDTO] on the backend.
/// Nested inside [SgtinModel.pharmaExtension].
class SGTINPharmaceuticalExtensionModel extends Equatable {
  final int? id;

  // Cold chain summary
  final bool coldChainExcursionFlag;
  final double? tempMinRecorded;
  final double? tempMaxRecorded;
  /// RFC 6920 ni: URI of the last sensor EPCIS event.
  final String? lastSensorEventId;

  // Anti-counterfeit
  final SgtinAntiTamperStatus antiTamperStatus;
  /// Fraud probability [0.00, 1.00]; stored as NUMERIC(3,2) in DB.
  final double? fraudScore;

  // Dispensing
  /// RFC 6920 ni: URI of the EPCIS dispense event.
  final String? dispenseEventId;
  /// GLN of the dispensing location (13 digits).
  final String? dispenseGln;
  final SgtinReturnStatus returnStatus;

  // Clinical trial
  /// ISO/ICH clinical trial protocol identifier (an..20).
  final String? protocolId;
  /// Encrypted linkage token — treat as opaque string.
  final String? trialSubjectLinkage;

  // Recall
  final bool recallAffectedFlag;
  final String? recallNotificationId;

  // Parallel trade
  final SgtinParallelTradeStatus parallelTradeStatus;
  final String? newSerialLinkage;
  /// Original SGTIN composite ref when this instance is the NEW repackaged serial.
  /// Format: '<gtin>/<serialNumber>'
  final String? originalSgtinRef;

  // Regulatory reporting
  /// List of applicable regime codes, e.g. ['UAE_TATMEEN', 'EU_FMD'].
  final List<String> reportingRegimes;
  final String? emvoUploadStatus;
  final String? tatmeenSubmissionStatus;
  final String? dscsaTransactionHash;

  // Anti-counterfeit — duplicate-detection evidence
  final int duplicateEvidenceCount;

  // Controlled substance — simplified custody status
  final String? controlledCustodyRef;

  const SGTINPharmaceuticalExtensionModel({
    this.id,
    this.coldChainExcursionFlag = false,
    this.tempMinRecorded,
    this.tempMaxRecorded,
    this.lastSensorEventId,
    this.antiTamperStatus = SgtinAntiTamperStatus.notApplicable,
    this.fraudScore,
    this.dispenseEventId,
    this.dispenseGln,
    this.returnStatus = SgtinReturnStatus.notReturned,
    this.protocolId,
    this.trialSubjectLinkage,
    this.recallAffectedFlag = false,
    this.recallNotificationId,
    this.parallelTradeStatus = SgtinParallelTradeStatus.none,
    this.newSerialLinkage,
    this.originalSgtinRef,
    this.reportingRegimes = const [],
    this.emvoUploadStatus,
    this.tatmeenSubmissionStatus,
    this.dscsaTransactionHash,
    this.duplicateEvidenceCount = 0,
    this.controlledCustodyRef,
  });

  factory SGTINPharmaceuticalExtensionModel.fromJson(
      Map<String, dynamic> json) {
    return SGTINPharmaceuticalExtensionModel(
      id: _jsonInt(json['id']),
      coldChainExcursionFlag: json['coldChainExcursionFlag'] as bool? ?? false,
      tempMinRecorded: _jsonDouble(json['tempMinRecorded']),
      tempMaxRecorded: _jsonDouble(json['tempMaxRecorded']),
      lastSensorEventId: json['lastSensorEventId'] as String?,
      antiTamperStatus: SgtinAntiTamperStatusExtension.fromString(
          json['antiTamperStatus'] as String?),
      fraudScore: _jsonDouble(json['fraudScore']),
      dispenseEventId: json['dispenseEventId'] as String?,
      dispenseGln: json['dispenseGln'] as String?,
      returnStatus: SgtinReturnStatusExtension.fromString(
          json['returnStatus'] as String?),
      protocolId: json['protocolId'] as String?,
      trialSubjectLinkage: json['trialSubjectLinkage'] as String?,
      recallAffectedFlag: json['recallAffectedFlag'] as bool? ?? false,
      recallNotificationId: json['recallNotificationId'] as String?,
      parallelTradeStatus: SgtinParallelTradeStatusExtension.fromString(
          json['parallelTradeStatus'] as String?),
      newSerialLinkage: json['newSerialLinkage'] as String?,
      originalSgtinRef: json['originalSgtinRef'] as String?,
      reportingRegimes: (json['reportingRegimes'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      emvoUploadStatus: json['emvoUploadStatus'] as String?,
      tatmeenSubmissionStatus: json['tatmeenSubmissionStatus'] as String?,
      dscsaTransactionHash: json['dscsaTransactionHash'] as String?,
      duplicateEvidenceCount: (json['duplicateEvidenceCount'] as int?) ?? 0,
      controlledCustodyRef: json['controlledCustodyRef'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'coldChainExcursionFlag': coldChainExcursionFlag,
      'tempMinRecorded': tempMinRecorded,
      'tempMaxRecorded': tempMaxRecorded,
      'lastSensorEventId': lastSensorEventId,
      'antiTamperStatus': antiTamperStatus.value,
      'fraudScore': fraudScore,
      'dispenseEventId': dispenseEventId,
      'dispenseGln': dispenseGln,
      'returnStatus': returnStatus.value,
      'protocolId': protocolId,
      'trialSubjectLinkage': trialSubjectLinkage,
      'recallAffectedFlag': recallAffectedFlag,
      'recallNotificationId': recallNotificationId,
      'parallelTradeStatus': parallelTradeStatus.value,
      'newSerialLinkage': newSerialLinkage,
      'originalSgtinRef': originalSgtinRef,
      'reportingRegimes': reportingRegimes,
      'emvoUploadStatus': emvoUploadStatus,
      'tatmeenSubmissionStatus': tatmeenSubmissionStatus,
      'dscsaTransactionHash': dscsaTransactionHash,
      'duplicateEvidenceCount': duplicateEvidenceCount,
      'controlledCustodyRef': controlledCustodyRef,
    };
  }

  SGTINPharmaceuticalExtensionModel copyWith({
    int? id,
    bool? coldChainExcursionFlag,
    double? tempMinRecorded,
    double? tempMaxRecorded,
    String? lastSensorEventId,
    SgtinAntiTamperStatus? antiTamperStatus,
    double? fraudScore,
    String? dispenseEventId,
    String? dispenseGln,
    SgtinReturnStatus? returnStatus,
    String? protocolId,
    String? trialSubjectLinkage,
    bool? recallAffectedFlag,
    String? recallNotificationId,
    SgtinParallelTradeStatus? parallelTradeStatus,
    String? newSerialLinkage,
    String? originalSgtinRef,
    List<String>? reportingRegimes,
    String? emvoUploadStatus,
    String? tatmeenSubmissionStatus,
    String? dscsaTransactionHash,
    int? duplicateEvidenceCount,
    String? controlledCustodyRef,
  }) {
    return SGTINPharmaceuticalExtensionModel(
      id: id ?? this.id,
      coldChainExcursionFlag:
          coldChainExcursionFlag ?? this.coldChainExcursionFlag,
      tempMinRecorded: tempMinRecorded ?? this.tempMinRecorded,
      tempMaxRecorded: tempMaxRecorded ?? this.tempMaxRecorded,
      lastSensorEventId: lastSensorEventId ?? this.lastSensorEventId,
      antiTamperStatus: antiTamperStatus ?? this.antiTamperStatus,
      fraudScore: fraudScore ?? this.fraudScore,
      dispenseEventId: dispenseEventId ?? this.dispenseEventId,
      dispenseGln: dispenseGln ?? this.dispenseGln,
      returnStatus: returnStatus ?? this.returnStatus,
      protocolId: protocolId ?? this.protocolId,
      trialSubjectLinkage: trialSubjectLinkage ?? this.trialSubjectLinkage,
      recallAffectedFlag: recallAffectedFlag ?? this.recallAffectedFlag,
      recallNotificationId: recallNotificationId ?? this.recallNotificationId,
      parallelTradeStatus: parallelTradeStatus ?? this.parallelTradeStatus,
      newSerialLinkage: newSerialLinkage ?? this.newSerialLinkage,
      originalSgtinRef: originalSgtinRef ?? this.originalSgtinRef,
      reportingRegimes: reportingRegimes ?? this.reportingRegimes,
      emvoUploadStatus: emvoUploadStatus ?? this.emvoUploadStatus,
      tatmeenSubmissionStatus: tatmeenSubmissionStatus ?? this.tatmeenSubmissionStatus,
      dscsaTransactionHash: dscsaTransactionHash ?? this.dscsaTransactionHash,
      duplicateEvidenceCount: duplicateEvidenceCount ?? this.duplicateEvidenceCount,
      controlledCustodyRef: controlledCustodyRef ?? this.controlledCustodyRef,
    );
  }

  @override
  List<Object?> get props => [
        id,
        coldChainExcursionFlag,
        tempMinRecorded,
        tempMaxRecorded,
        lastSensorEventId,
        antiTamperStatus,
        fraudScore,
        dispenseEventId,
        dispenseGln,
        returnStatus,
        protocolId,
        trialSubjectLinkage,
        recallAffectedFlag,
        recallNotificationId,
        parallelTradeStatus,
        newSerialLinkage,
        originalSgtinRef,
        reportingRegimes,
        emvoUploadStatus,
        tatmeenSubmissionStatus,
        dscsaTransactionHash,
        duplicateEvidenceCount,
        controlledCustodyRef,
      ];
}
