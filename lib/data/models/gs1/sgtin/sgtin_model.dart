import 'package:equatable/equatable.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/data/models/gs1/serialization/sscc/sscc_model.dart';
import 'package:traqtrace_app/data/models/gs1/sgtin/sgtin_pharmaceutical_extension_model.dart';

class SGTIN extends Equatable {
  final String? id;
  final String gtinCode;
  final String serialNumber;
  final DateTime? expiryDate;
  final String? batchLotNumber;
  final DateTime? productionDate;
  final DateTime? bestBeforeDate;
  final ItemStatus status;
  final GLN? currentLocation;
  final SSCC? currentSSCC;
  /// SSCC container code when the API returns a plain string (not a nested object).
  final String? currentSsccCode;
  final String? regulatoryMarket;
  final String? regulatoryStatus;
  final String? decommissionedReason;
  final DateTime? decommissionedDate;
  final DateTime createdAt;
  final DateTime? updatedAt;

  final String? epcUri;
  final String? gs1DigitalLinkUri;
  final DateTime? commissionedAt;
  final String? commissioningReadpointGln;
  final String? commissioningEventId;
  final DateTime? expiryDateTime;
  final String? serialGenerationStrategy;
  final String? serialOrigin;
  final String? serialRangeId;
  final String? parentEpc;
  final DateTime? aggregatedAt;
  final String? currentCustodianGln;
  final String? latestEventId;
  final String? latestBizStep;
  final String? latestDisposition;
  final int verificationCount;
  final String? verificationStatus;
  final DateTime? retentionExpiry;
  final int alertCount;

  final double? serialGuessingProbability;
  final String? serialEntropySeed;

  final String? createdBy;

  final SGTINPharmaceuticalExtensionModel? pharmaExtension;
  final List<String> childEpcs;

  const SGTIN({
    this.id,
    required this.gtinCode,
    required this.serialNumber,
    this.expiryDate,
    this.batchLotNumber,
    this.productionDate,
    this.bestBeforeDate,
    required this.status,
    this.currentLocation,
    this.currentSSCC,
    this.currentSsccCode,
    this.regulatoryMarket,
    this.regulatoryStatus,
    this.decommissionedReason,
    this.decommissionedDate,
    required this.createdAt,
    this.updatedAt,
    this.epcUri,
    this.gs1DigitalLinkUri,
    this.commissionedAt,
    this.commissioningReadpointGln,
    this.commissioningEventId,
    this.expiryDateTime,
    this.serialGenerationStrategy,
    this.serialOrigin,
    this.serialRangeId,
    this.parentEpc,
    this.aggregatedAt,
    this.currentCustodianGln,
    this.latestEventId,
    this.latestBizStep,
    this.latestDisposition,
    this.verificationCount = 0,
    this.verificationStatus,
    this.retentionExpiry,
    this.alertCount = 0,
    this.serialGuessingProbability,
    this.serialEntropySeed,
    this.createdBy,
    this.pharmaExtension,
    this.childEpcs = const [],
  });

  factory SGTIN.fromJson(Map<String, dynamic> json) {
    String? id;
    if (json['id'] != null) {
      id = json['id'].toString();
    }

    return SGTIN(
      id: id,
      gtinCode: _parseGtinCode(json),
      serialNumber: json['serialNumber'] ?? '',
      expiryDate: _parseDateTime(json['expiryDate']),
      batchLotNumber: json['batchLotNumber'],
      productionDate: _parseDateTime(json['productionDate']),
      bestBeforeDate: _parseDateTime(json['bestBeforeDate']),
      status: _parseItemStatus(json['status']),
      currentLocation: _parseCurrentLocation(json),
      currentSsccCode: _parseCurrentSsccCode(json['currentSSCC']),
      currentSSCC: json['currentSSCC'] is Map<String, dynamic>
          ? SSCC.fromJson(json['currentSSCC'] as Map<String, dynamic>)
          : null,
      regulatoryMarket: json['regulatoryMarket'],
      regulatoryStatus: json['regulatoryStatus'],
      decommissionedReason: json['decommissionedReason'],
      decommissionedDate: _parseDateTime(json['decommissionedDate']),
      createdAt: _parseDateTime(json['createdAt']) ?? DateTime.now(),
      updatedAt: _parseDateTime(json['updatedAt']),
      epcUri: json['epcUri'],
      gs1DigitalLinkUri: json['gs1DigitalLinkUri'],
      commissionedAt: _parseDateTime(json['commissionedAt']),
      commissioningReadpointGln: json['commissioningReadpointGln'],
      commissioningEventId: json['commissioningEventId'],
      expiryDateTime: _parseDateTime(json['expiryDateTime']),
      serialGenerationStrategy: json['serialGenerationStrategy'],
      serialOrigin: json['serialOrigin'],
      serialRangeId: json['serialRangeId']?.toString(),
      parentEpc: json['parentEpc'],
      aggregatedAt: _parseDateTime(json['aggregatedAt']),
      currentCustodianGln: json['currentCustodianGln'],
      latestEventId: json['latestEventId'],
      latestBizStep: json['latestBizStep'],
      latestDisposition: json['latestDisposition'],
      verificationCount: (json['verificationCount'] as int?) ?? 0,
      verificationStatus: json['verificationStatus'],
      retentionExpiry: _parseDateTime(json['retentionExpiry']),
      alertCount: (json['alertCount'] as int?) ?? 0,
      serialGuessingProbability: (json['serialGuessingProbability'] as num?)?.toDouble(),
      serialEntropySeed: json['serialEntropySeed'] as String?,
      createdBy: json['createdBy'] as String?,
      pharmaExtension: json['pharmaExtension'] is Map<String, dynamic>
          ? SGTINPharmaceuticalExtensionModel.fromJson(
              json['pharmaExtension'] as Map<String, dynamic>)
          : null,
      childEpcs: (json['childEpcs'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id.toString(),
      'gtin': gtinCode,
      'serialNumber': serialNumber,
      if (expiryDate != null) 'expiryDate': _formatDateWithTimezone(expiryDate!),
      if (batchLotNumber != null) 'batchLotNumber': batchLotNumber,
      if (productionDate != null) 'productionDate': _formatDateWithTimezone(productionDate!),
      if (bestBeforeDate != null) 'bestBeforeDate': _formatDateWithTimezone(bestBeforeDate!),
      'status': status.name,
      if (currentLocation != null) 'currentLocationGLN': currentLocation!.glnCode,
      if (currentSsccCode != null) 'currentSSCC': currentSsccCode,
      if (currentSSCC != null && currentSsccCode == null)
        'currentSSCC': currentSSCC!.id,
      if (regulatoryMarket != null) 'regulatoryMarket': regulatoryMarket,
      if (regulatoryStatus != null) 'regulatoryStatus': regulatoryStatus,
      if (decommissionedReason != null) 'decommissionedReason': decommissionedReason,
      if (decommissionedDate != null) 'decommissionedDate': _formatDateWithTimezone(decommissionedDate!),
      'createdAt': _formatDateWithTimezone(createdAt),
      if (updatedAt != null) 'updatedAt': _formatDateWithTimezone(updatedAt!),
      if (epcUri != null) 'epcUri': epcUri,
      if (gs1DigitalLinkUri != null) 'gs1DigitalLinkUri': gs1DigitalLinkUri,
      if (commissionedAt != null) 'commissionedAt': _formatDateWithTimezone(commissionedAt!),
      if (commissioningReadpointGln != null) 'commissioningReadpointGln': commissioningReadpointGln,
      if (commissioningEventId != null) 'commissioningEventId': commissioningEventId,
      if (expiryDateTime != null) 'expiryDateTime': _formatDateWithTimezone(expiryDateTime!),
      if (serialGenerationStrategy != null) 'serialGenerationStrategy': serialGenerationStrategy,
      if (serialOrigin != null) 'serialOrigin': serialOrigin,
      if (serialRangeId != null) 'serialRangeId': serialRangeId,
      if (parentEpc != null) 'parentEpc': parentEpc,
      if (aggregatedAt != null) 'aggregatedAt': _formatDateWithTimezone(aggregatedAt!),
      if (currentCustodianGln != null) 'currentCustodianGln': currentCustodianGln,
      if (latestEventId != null) 'latestEventId': latestEventId,
      if (latestBizStep != null) 'latestBizStep': latestBizStep,
      if (latestDisposition != null) 'latestDisposition': latestDisposition,
      'verificationCount': verificationCount,
      if (verificationStatus != null) 'verificationStatus': verificationStatus,
      if (retentionExpiry != null) 'retentionExpiry': _formatDateWithTimezone(retentionExpiry!),
      'alertCount': alertCount,
      if (serialGuessingProbability != null) 'serialGuessingProbability': serialGuessingProbability,
      if (serialEntropySeed != null) 'serialEntropySeed': serialEntropySeed,
      if (createdBy != null) 'createdBy': createdBy,
      if (pharmaExtension != null) 'pharmaExtension': pharmaExtension!.toJson(),
      if (childEpcs.isNotEmpty) 'childEpcs': childEpcs,
    };
  }

  SGTIN copyWith({
    String? id,
    String? gtinCode,
    String? serialNumber,
    DateTime? expiryDate,
    String? batchLotNumber,
    DateTime? productionDate,
    DateTime? bestBeforeDate,
    ItemStatus? status,
    GLN? currentLocation,
    SSCC? currentSSCC,
    String? currentSsccCode,
    String? regulatoryMarket,
    String? regulatoryStatus,
    String? decommissionedReason,
    DateTime? decommissionedDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? epcUri,
    String? gs1DigitalLinkUri,
    DateTime? commissionedAt,
    String? commissioningReadpointGln,
    String? commissioningEventId,
    DateTime? expiryDateTime,
    String? serialGenerationStrategy,
    String? serialOrigin,
    String? serialRangeId,
    String? parentEpc,
    DateTime? aggregatedAt,
    String? currentCustodianGln,
    String? latestEventId,
    String? latestBizStep,
    String? latestDisposition,
    int? verificationCount,
    String? verificationStatus,
    DateTime? retentionExpiry,
    int? alertCount,
    double? serialGuessingProbability,
    String? serialEntropySeed,
    String? createdBy,
    SGTINPharmaceuticalExtensionModel? pharmaExtension,
  }) {
    return SGTIN(
      id: id ?? this.id,
      gtinCode: gtinCode ?? this.gtinCode,
      serialNumber: serialNumber ?? this.serialNumber,
      expiryDate: expiryDate ?? this.expiryDate,
      batchLotNumber: batchLotNumber ?? this.batchLotNumber,
      productionDate: productionDate ?? this.productionDate,
      bestBeforeDate: bestBeforeDate ?? this.bestBeforeDate,
      status: status ?? this.status,
      currentLocation: currentLocation ?? this.currentLocation,
      currentSSCC: currentSSCC ?? this.currentSSCC,
      currentSsccCode: currentSsccCode ?? this.currentSsccCode,
      regulatoryMarket: regulatoryMarket ?? this.regulatoryMarket,
      regulatoryStatus: regulatoryStatus ?? this.regulatoryStatus,
      decommissionedReason: decommissionedReason ?? this.decommissionedReason,
      decommissionedDate: decommissionedDate ?? this.decommissionedDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      epcUri: epcUri ?? this.epcUri,
      gs1DigitalLinkUri: gs1DigitalLinkUri ?? this.gs1DigitalLinkUri,
      commissionedAt: commissionedAt ?? this.commissionedAt,
      commissioningReadpointGln: commissioningReadpointGln ?? this.commissioningReadpointGln,
      commissioningEventId: commissioningEventId ?? this.commissioningEventId,
      expiryDateTime: expiryDateTime ?? this.expiryDateTime,
      serialGenerationStrategy: serialGenerationStrategy ?? this.serialGenerationStrategy,
      serialOrigin: serialOrigin ?? this.serialOrigin,
      serialRangeId: serialRangeId ?? this.serialRangeId,
      parentEpc: parentEpc ?? this.parentEpc,
      aggregatedAt: aggregatedAt ?? this.aggregatedAt,
      currentCustodianGln: currentCustodianGln ?? this.currentCustodianGln,
      latestEventId: latestEventId ?? this.latestEventId,
      latestBizStep: latestBizStep ?? this.latestBizStep,
      latestDisposition: latestDisposition ?? this.latestDisposition,
      verificationCount: verificationCount ?? this.verificationCount,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      retentionExpiry: retentionExpiry ?? this.retentionExpiry,
      alertCount: alertCount ?? this.alertCount,
      serialGuessingProbability: serialGuessingProbability ?? this.serialGuessingProbability,
      serialEntropySeed: serialEntropySeed ?? this.serialEntropySeed,
      createdBy: createdBy ?? this.createdBy,
      pharmaExtension: pharmaExtension ?? this.pharmaExtension,
    );
  }

  String get computedEpcUri {
    if (epcUri != null) return epcUri!;
    final String padded = gtinCode.padLeft(14, '0');
    final String companyPrefix = padded.substring(1, 8);
    final String itemRef = padded.substring(8, 13);
    return 'urn:epc:id:sgtin:$companyPrefix.$itemRef.$serialNumber';
  }

  String get sgtinString => '$gtinCode$serialNumber';

  @override
  List<Object?> get props => [
        id, gtinCode, serialNumber, expiryDate, batchLotNumber, productionDate,
        bestBeforeDate, status, currentLocation, currentSSCC, currentSsccCode,
        regulatoryMarket,
        regulatoryStatus, decommissionedReason, decommissionedDate, createdAt,
        updatedAt, epcUri, gs1DigitalLinkUri, commissionedAt,
        commissioningReadpointGln, commissioningEventId, expiryDateTime,
        serialGenerationStrategy, serialOrigin, serialRangeId, parentEpc,
        aggregatedAt, currentCustodianGln, latestEventId, latestBizStep,
        latestDisposition, verificationCount, verificationStatus, retentionExpiry,
        alertCount, serialGuessingProbability, serialEntropySeed, createdBy,
        pharmaExtension,
        childEpcs,
      ];

  static String _parseGtinCode(Map<String, dynamic> json) {
    final gtin = json['gtin'];
    if (gtin is String) return gtin;
    if (gtin is Map<String, dynamic>) {
      return (gtin['gtinCode'] ?? gtin['code'] ?? '').toString();
    }
    return (json['gtinCode'] ?? '').toString();
  }

  static String? _parseCurrentSsccCode(dynamic value) {
    if (value is String && value.trim().isNotEmpty) return value.trim();
    if (value is Map<String, dynamic>) {
      return (value['ssccCode'] ?? value['sscc'])?.toString();
    }
    return null;
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    try {
      return DateTime.parse(value as String);
    } catch (_) {
      return null;
    }
  }

  String _formatDateWithTimezone(DateTime dateTime) {
    final DateTime utc = dateTime.toUtc();
    final String iso = utc.toIso8601String();
    return iso.endsWith('Z') ? iso : '${iso}Z';
  }

  static GLN? _parseCurrentLocation(Map<String, dynamic> json) {
    if (json['currentLocationGLN'] != null) {
      return GLN(
        glnCode: json['currentLocationGLN'] as String,
        locationName: json['currentLocationName'] as String? ?? 'Unknown Location',
        addressLine1: '',
        city: '',
        stateProvince: '',
        postalCode: '',
        country: '',
        locationType: LocationType.other,
        active: true,
      );
    }
    if (json['currentLocation'] is Map<String, dynamic>) {
      return GLN.fromJson(json['currentLocation'] as Map<String, dynamic>);
    }
    return null;
  }

  static ItemStatus _parseItemStatus(String? value) {
    if (value == null) return ItemStatus.COMMISSIONED;
    try {
      return ItemStatus.values.firstWhere(
        (s) => s.name == value,
        orElse: () => ItemStatus.COMMISSIONED,
      );
    } catch (_) {
      return ItemStatus.COMMISSIONED;
    }
  }
}

enum ItemStatus {
  RESERVED,
  ALLOCATED,
  COMMISSIONED,
  ACTIVE,
  IN_TRANSIT,
  RECEIVED,
  DISPENSED,
  RETURNED,
  DESTROYED,
  RECALLED,
  STOLEN,
  EXPIRED,
  EXCEPTION,
}
