import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';

class SSCC {
  final String? id;
  final String ssccCode;
  final String? canonicalIdentifier;

  final UnitType unitType;
  final LogisticUnitStatus status;
  final ContentHomogeneity contentHomogeneity;

  final String? containedGtin;
  final int? containedQuantity;
  final String? containedBatch;
  final DateTime? containedExpiry;

  final DateTime? allocatedAt;
  final DateTime? commissionedAt;
  final DateTime? packingDate;
  final DateTime? lastShipmentAt;
  final DateTime? shippingDate;
  final DateTime? receivingDate;
  final DateTime? decommissionedAt;
  final DateTime? nonReuseUntil;
  final DateTime? validFrom;
  final DateTime? validUntil;
  final DateTime? retentionExpiry;

  final String? gs1CompanyPrefix;
  final String? extensionDigit;
  final String? serialReference;
  final String? checkDigit;

  final SSCC? parentSscc;
  final String? parentSsccCode;
  final String? scanVisibleSsccCode;
  final int? childCount;
  final int? totalLeafCount;

  final String? shipFromGln;
  final String? shipToGln;
  final String? billToGln;
  final String? shipForGln;
  final String? currentLocationGln;
  final String? currentReadpointGln;
  final String? currentBizlocationGln;
  final String? currentCustodianGln;
  final GLN? currentLocation;

  final String? purchaseOrderNumber;
  final String? ginc;
  final String? gsin;
  final String? carrierRoutingCode;
  final String? shipToPostalCode;

  final String? aggregationEventId;
  final String? commissioningEventId;
  final List<String>? childSsccs;
  final List<String>? childSgtins;

  final GLN? sourceLocation;
  final GLN? destinationLocation;
  final GLN? issuingGLN;

  final List<String>? availableTransitions;

  final DateTime createdAt;
  final DateTime updatedAt;

  const SSCC({
    this.id,
    required this.ssccCode,
    this.canonicalIdentifier,
    required this.unitType,
    required this.status,
    this.contentHomogeneity = ContentHomogeneity.UNKNOWN,
    this.containedGtin,
    this.containedQuantity,
    this.containedBatch,
    this.containedExpiry,
    this.allocatedAt,
    this.commissionedAt,
    this.packingDate,
    this.lastShipmentAt,
    this.shippingDate,
    this.receivingDate,
    this.decommissionedAt,
    this.nonReuseUntil,
    this.validFrom,
    this.validUntil,
    this.retentionExpiry,
    this.gs1CompanyPrefix,
    this.extensionDigit,
    this.serialReference,
    this.checkDigit,
    this.parentSscc,
    this.parentSsccCode,
    this.scanVisibleSsccCode,
    this.childCount,
    this.totalLeafCount,
    this.shipFromGln,
    this.shipToGln,
    this.billToGln,
    this.shipForGln,
    this.currentLocationGln,
    this.currentReadpointGln,
    this.currentBizlocationGln,
    this.currentCustodianGln,
    this.currentLocation,
    this.purchaseOrderNumber,
    this.ginc,
    this.gsin,
    this.carrierRoutingCode,
    this.shipToPostalCode,
    this.aggregationEventId,
    this.commissioningEventId,
    this.childSsccs,
    this.childSgtins,
    this.sourceLocation,
    this.destinationLocation,
    this.issuingGLN,
    this.availableTransitions,
    required this.createdAt,
    required this.updatedAt,
  });

  SSCC copyWith({
    String? id,
    String? ssccCode,
    String? canonicalIdentifier,
    UnitType? unitType,
    LogisticUnitStatus? status,
    ContentHomogeneity? contentHomogeneity,
    String? containedGtin,
    int? containedQuantity,
    String? containedBatch,
    DateTime? containedExpiry,
    DateTime? allocatedAt,
    DateTime? commissionedAt,
    DateTime? packingDate,
    DateTime? lastShipmentAt,
    DateTime? shippingDate,
    DateTime? receivingDate,
    DateTime? decommissionedAt,
    DateTime? nonReuseUntil,
    DateTime? validFrom,
    DateTime? validUntil,
    DateTime? retentionExpiry,
    String? gs1CompanyPrefix,
    String? extensionDigit,
    String? serialReference,
    String? checkDigit,
    SSCC? parentSscc,
    String? parentSsccCode,
    String? scanVisibleSsccCode,
    int? childCount,
    int? totalLeafCount,
    String? shipFromGln,
    String? shipToGln,
    String? billToGln,
    String? shipForGln,
    String? currentLocationGln,
    String? currentReadpointGln,
    String? currentBizlocationGln,
    String? currentCustodianGln,
    GLN? currentLocation,
    String? purchaseOrderNumber,
    String? ginc,
    String? gsin,
    String? carrierRoutingCode,
    String? shipToPostalCode,
    String? aggregationEventId,
    String? commissioningEventId,
    List<String>? childSsccs,
    List<String>? childSgtins,
    GLN? sourceLocation,
    GLN? destinationLocation,
    GLN? issuingGLN,
    List<String>? availableTransitions,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SSCC(
      id: id ?? this.id,
      ssccCode: ssccCode ?? this.ssccCode,
      canonicalIdentifier:
          canonicalIdentifier ?? this.canonicalIdentifier,
      unitType: unitType ?? this.unitType,
      status: status ?? this.status,
      contentHomogeneity: contentHomogeneity ?? this.contentHomogeneity,
      containedGtin: containedGtin ?? this.containedGtin,
      containedQuantity: containedQuantity ?? this.containedQuantity,
      containedBatch: containedBatch ?? this.containedBatch,
      containedExpiry: containedExpiry ?? this.containedExpiry,
      allocatedAt: allocatedAt ?? this.allocatedAt,
      commissionedAt: commissionedAt ?? this.commissionedAt,
      packingDate: packingDate ?? this.packingDate,
      lastShipmentAt: lastShipmentAt ?? this.lastShipmentAt,
      shippingDate: shippingDate ?? this.shippingDate,
      receivingDate: receivingDate ?? this.receivingDate,
      decommissionedAt: decommissionedAt ?? this.decommissionedAt,
      nonReuseUntil: nonReuseUntil ?? this.nonReuseUntil,
      validFrom: validFrom ?? this.validFrom,
      validUntil: validUntil ?? this.validUntil,
      retentionExpiry: retentionExpiry ?? this.retentionExpiry,
      gs1CompanyPrefix: gs1CompanyPrefix ?? this.gs1CompanyPrefix,
      extensionDigit: extensionDigit ?? this.extensionDigit,
      serialReference: serialReference ?? this.serialReference,
      checkDigit: checkDigit ?? this.checkDigit,
      parentSscc: parentSscc ?? this.parentSscc,
      parentSsccCode: parentSsccCode ?? this.parentSsccCode,
      scanVisibleSsccCode: scanVisibleSsccCode ?? this.scanVisibleSsccCode,
      childCount: childCount ?? this.childCount,
      totalLeafCount: totalLeafCount ?? this.totalLeafCount,
      shipFromGln: shipFromGln ?? this.shipFromGln,
      shipToGln: shipToGln ?? this.shipToGln,
      billToGln: billToGln ?? this.billToGln,
      shipForGln: shipForGln ?? this.shipForGln,
      currentLocationGln: currentLocationGln ?? this.currentLocationGln,
      currentReadpointGln: currentReadpointGln ?? this.currentReadpointGln,
      currentBizlocationGln:
          currentBizlocationGln ?? this.currentBizlocationGln,
      currentCustodianGln: currentCustodianGln ?? this.currentCustodianGln,
      currentLocation: currentLocation ?? this.currentLocation,
      purchaseOrderNumber: purchaseOrderNumber ?? this.purchaseOrderNumber,
      ginc: ginc ?? this.ginc,
      gsin: gsin ?? this.gsin,
      carrierRoutingCode: carrierRoutingCode ?? this.carrierRoutingCode,
      shipToPostalCode: shipToPostalCode ?? this.shipToPostalCode,
      aggregationEventId: aggregationEventId ?? this.aggregationEventId,
      commissioningEventId:
          commissioningEventId ?? this.commissioningEventId,
      childSsccs: childSsccs ?? this.childSsccs,
      childSgtins: childSgtins ?? this.childSgtins,
      sourceLocation: sourceLocation ?? this.sourceLocation,
      destinationLocation: destinationLocation ?? this.destinationLocation,
      issuingGLN: issuingGLN ?? this.issuingGLN,
      availableTransitions: availableTransitions ?? this.availableTransitions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory SSCC.fromJson(Map<String, dynamic> json) {
    final String ssccCode = json['sscc'] ?? json['ssccCode'] ?? '';
    final DateTime now = DateTime.now();
    final DateTime createdAt = _parseDateTime(json['createdAt']) ??
        _parseDateTime(json['statusDate']) ??
        now;
    final DateTime updatedAt =
        _parseDateTime(json['updatedAt']) ?? createdAt;

    List<String>? transitions;
    final rawTransitions = json['availableTransitions'];
    if (rawTransitions is List) {
      transitions = rawTransitions.map((e) => e.toString()).toList();
    }

    return SSCC(
      id: json['id']?.toString(),
      ssccCode: ssccCode,
      canonicalIdentifier: _parseCanonicalIdentifier(json),
      unitType: parseUnitType(
        json['unitType'] as String? ?? json['containerType'] as String?,
      ),
      status: parseStatus(
        json['status'] as String? ?? json['containerStatus'] as String?,
      ),
      contentHomogeneity: parseContentHomogeneity(
        json['contentHomogeneity'] as String?,
      ),
      containedGtin: json['containedGtin'] as String?,
      containedQuantity: json['containedQuantity'] as int?,
      containedBatch: json['containedBatch'] as String?,
      containedExpiry: _parseDateOnly(json['containedExpiry']),
      allocatedAt: _parseDateTime(json['allocatedAt']),
      commissionedAt: _parseDateTime(json['commissionedAt']),
      packingDate: _parseDateTime(json['packingDate']),
      lastShipmentAt: _parseDateTime(json['lastShipmentAt']),
      shippingDate: _parseDateTime(json['shippingDate']),
      receivingDate: _parseDateTime(json['receivingDate']),
      decommissionedAt: _parseDateTime(json['decommissionedAt']),
      nonReuseUntil: _parseDateOnly(json['nonReuseUntil']),
      validFrom: _parseDateTime(json['validFrom']),
      validUntil: _parseDateTime(json['validUntil']),
      retentionExpiry: _parseDateOnly(json['retentionExpiry']),
      gs1CompanyPrefix:
          json['companyPrefix'] as String? ?? json['gs1CompanyPrefix'] as String?,
      extensionDigit: json['extensionDigit'] as String?,
      serialReference: json['serialReference'] as String?,
      checkDigit: json['checkDigit'] as String?,
      parentSscc: json['parentSscc'] is Map<String, dynamic>
          ? SSCC.fromJson(json['parentSscc'] as Map<String, dynamic>)
          : null,
      parentSsccCode: json['parentSSCC'] as String?,
      scanVisibleSsccCode: json['scanVisibleSsccCode'] as String?,
      childCount: json['childCount'] as int?,
      totalLeafCount: json['totalLeafCount'] as int?,
      shipFromGln: json['shipFromGLN'] as String?,
      shipToGln: json['shipToGLN'] as String?,
      billToGln: json['billToGLN'] as String?,
      shipForGln: json['shipForGLN'] as String?,
      currentLocationGln: json['currentLocationGLN'] as String?,
      currentReadpointGln: json['currentReadpointGLN'] as String?,
      currentBizlocationGln: json['currentBizlocationGLN'] as String?,
      currentCustodianGln: json['currentCustodianGLN'] as String?,
      currentLocation: _parseCurrentLocation(json),
      purchaseOrderNumber: json['purchaseOrderNumber'] as String?,
      ginc: json['ginc'] as String?,
      gsin: json['gsin'] as String?,
      carrierRoutingCode: json['carrierRoutingCode'] as String?,
      shipToPostalCode: json['shipToPostalCode'] as String?,
      aggregationEventId: json['aggregationEventId'] as String?,
      commissioningEventId: json['commissioningEventId'] as String?,
      childSsccs: _parseStringList(json['childSsccs']),
      childSgtins: _parseStringList(json['childSgtins']),
      sourceLocation: json['sourceLocation'] is Map<String, dynamic>
          ? GLN.fromJson(json['sourceLocation'] as Map<String, dynamic>)
          : null,
      destinationLocation: json['destinationLocation'] is Map<String, dynamic>
          ? GLN.fromJson(json['destinationLocation'] as Map<String, dynamic>)
          : null,
      issuingGLN: _parseGlnField(json['issuingGLN']),
      availableTransitions: transitions,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'sscc': ssccCode,
      if (canonicalIdentifier != null)
        'canonicalIdentifier': canonicalIdentifier,
      'status': status.name,
      'containerStatus': legacyContainerStatusName(status),
      'unitType': unitType.name,
      'containerType': unitType.name,
      'contentHomogeneity': contentHomogeneity.name,
      if (containedGtin != null) 'containedGtin': containedGtin,
      if (containedQuantity != null) 'containedQuantity': containedQuantity,
      if (containedBatch != null) 'containedBatch': containedBatch,
      if (containedExpiry != null)
        'containedExpiry': _formatDateOnly(containedExpiry!),
      if (packingDate != null)
        'packingDate': _formatDateWithTimezone(packingDate!),
      if (parentSsccCode != null) 'parentSSCC': parentSsccCode,
      if (scanVisibleSsccCode != null)
        'scanVisibleSsccCode': scanVisibleSsccCode,
      if (shipFromGln != null) 'shipFromGLN': shipFromGln,
      if (shipToGln != null) 'shipToGLN': shipToGln,
      if (billToGln != null) 'billToGLN': billToGln,
      if (shipForGln != null) 'shipForGLN': shipForGln,
      if (purchaseOrderNumber != null)
        'purchaseOrderNumber': purchaseOrderNumber,
      if (gsin != null) 'gsin': gsin,
      if (ginc != null) 'ginc': ginc,
      if (carrierRoutingCode != null)
        'carrierRoutingCode': carrierRoutingCode,
      if (shipToPostalCode != null) 'shipToPostalCode': shipToPostalCode,
      if (aggregationEventId != null)
        'aggregationEventId': aggregationEventId,
      if (commissioningEventId != null)
        'commissioningEventId': commissioningEventId,
      if (currentReadpointGln != null)
        'currentReadpointGLN': currentReadpointGln,
      if (currentBizlocationGln != null)
        'currentBizlocationGLN': currentBizlocationGln,
      if (currentCustodianGln != null)
        'currentCustodianGLN': currentCustodianGln,
      if (currentLocation != null) ...{
        'currentLocationGLN': currentLocation!.glnCode,
        'currentLocationName': currentLocation!.locationName,
      },
      if (issuingGLN != null) 'issuingGLN': issuingGLN!.glnCode,
      if (gs1CompanyPrefix != null) 'gs1CompanyPrefix': gs1CompanyPrefix,
      if (extensionDigit != null) 'extensionDigit': extensionDigit,
      if (serialReference != null) 'serialReference': serialReference,
      if (checkDigit != null) 'checkDigit': checkDigit,
    };
  }

  static String? _parseCanonicalIdentifier(Map<String, dynamic> json) {
    final canonical = json['canonicalIdentifier'];
    if (canonical is String && canonical.trim().isNotEmpty) {
      return canonical.trim();
    }
    for (final key in ['ssccUri', 'gs1DigitalLinkUri', 'epcUri']) {
      final value = json[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return null;
  }

  static List<String>? _parseStringList(dynamic value) {
    if (value is! List) return null;
    return value.map((e) => e.toString()).toList();
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  static DateTime? _parseDateOnly(dynamic value) {
    if (value == null) return null;
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  static GLN? _parseGlnField(dynamic glnField) {
    if (glnField == null) return null;
    if (glnField is String) return GLN.fromCode(glnField);
    if (glnField is Map<String, dynamic>) return GLN.fromJson(glnField);
    return null;
  }

  static GLN? _parseCurrentLocation(Map<String, dynamic> json) {
    if (json['currentLocation'] is Map<String, dynamic>) {
      return GLN.fromJson(json['currentLocation'] as Map<String, dynamic>);
    }
    final glnCode = json['currentLocationGLN'] as String? ??
        json['currentLocationGln'] as String? ??
        json['currentBizlocationGLN'] as String?;
    final locationName = json['currentLocationName'] as String?;
    if (glnCode != null) {
      return GLN(
        glnCode: glnCode,
        locationName: locationName ?? 'Unknown Location',
        addressLine1: '',
        city: '',
        stateProvince: '',
        postalCode: '',
        country: '',
        locationType: LocationType.other,
        active: true,
      );
    }
    return null;
  }

  static String _formatDateWithTimezone(DateTime dateTime) {
    final iso = dateTime.toIso8601String();
    if (iso.endsWith('Z') || iso.contains('+')) return iso;
    return '${iso}Z';
  }

  static String _formatDateOnly(DateTime date) {
    return date.toIso8601String().split('T').first;
  }

  static LogisticUnitStatus parseStatus(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return LogisticUnitStatus.DRAFT;
    }
    final s = raw.trim().toUpperCase();
    for (final v in LogisticUnitStatus.values) {
      if (v.name == s) return v;
    }
    return switch (s) {
      'CREATED' => LogisticUnitStatus.DRAFT,
      'PACKED' => LogisticUnitStatus.ACTIVE,
      'SHIPPED' => LogisticUnitStatus.IN_TRANSIT,
      'UNPACKED' || 'DISPOSED' => LogisticUnitStatus.DECOMMISSIONED,
      'DAMAGED' => LogisticUnitStatus.RECEIVED,
      _ => LogisticUnitStatus.DRAFT,
    };
  }

  static UnitType parseUnitType(String? raw) {
    if (raw == null || raw.trim().isEmpty) return UnitType.OTHER;
    final s = raw.trim().toUpperCase();
    for (final v in UnitType.values) {
      if (v.name == s) return v;
    }
    return UnitType.OTHER;
  }

  static ContentHomogeneity parseContentHomogeneity(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return ContentHomogeneity.UNKNOWN;
    }
    final s = raw.trim().toUpperCase();
    for (final v in ContentHomogeneity.values) {
      if (v.name == s) return v;
    }
    return ContentHomogeneity.UNKNOWN;
  }

  static String legacyContainerStatusName(LogisticUnitStatus status) {
    return switch (status) {
      LogisticUnitStatus.DRAFT || LogisticUnitStatus.ALLOCATED => 'CREATED',
      LogisticUnitStatus.ACTIVE => 'PACKED',
      LogisticUnitStatus.IN_TRANSIT => 'IN_TRANSIT',
      LogisticUnitStatus.RECEIVED => 'RECEIVED',
      LogisticUnitStatus.DECOMMISSIONED => 'UNPACKED',
      LogisticUnitStatus.VOIDED => 'DISPOSED',
    };
  }
}

enum UnitType {
  PALLET,
  CASE,
  CARTON,
  TOTE,
  CONTAINER,
  DRUM,
  AIR_ULD,
  PARCEL,
  ROLL_CAGE,
  OTHER,
}

enum LogisticUnitStatus {
  DRAFT,
  ALLOCATED,
  ACTIVE,
  IN_TRANSIT,
  RECEIVED,
  DECOMMISSIONED,
  VOIDED,
}

enum ContentHomogeneity {
  HOMOGENEOUS,
  MIXED,
  UNKNOWN,
}
