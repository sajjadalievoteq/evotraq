import 'package:equatable/equatable.dart';

/// SSCC Tobacco Extension model
/// Based on EU TPD transport requirements, tax stamp aggregation,
/// and tobacco logistics regulatory compliance
class SSCCTobaccoExtension extends Equatable {
  final int? id;
  final int? ssccId;
  final String? ssccCode;

  // EU TPD (Tobacco Products Directive) Transport Compliance
  final String? euTransportUnitId;
  final String? euRouteAuthorizationNumber;
  final DateTime? euRouteAuthorizationDate;
  final DateTime? euRouteAuthorizationExpiry;
  final bool euFirstRetailOutlet;

  // Tax Stamp Aggregation
  final String? taxStampAggregationLevel;
  final int? aggregatedStampCount;
  final String? taxStampAuthorityId;

  // Export/Import Documentation
  final String? customsDeclarationNumber;
  final DateTime? customsDeclarationDate;
  final String? exportLicenseNumber;
  final DateTime? exportLicenseDate;
  final DateTime? exportLicenseExpiry;
  final String? importPermitNumber;
  final DateTime? importPermitDate;
  final String? countryOfOrigin;
  final String? countryOfDestination;

  // Transport Security
  final String? sealNumber;
  final String? sealType;
  final String? sealedBy;
  final DateTime? sealedDate;

  // Carrier Information
  final String? carrierLicenseNumber;
  final String? carrierTobaccoPermitNumber;
  final String? driverId;
  final String? vehicleRegistration;

  // State/Regional Compliance (US)
  final String? pactActManifestNumber;
  final String? stateTransitPermitNumber;
  final String? stateTransitPermitState;

  // Manufacturing Batch Tracking
  final bool containsMultipleBatches;
  final String? primaryBatchNumber;

  // Audit Fields
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const SSCCTobaccoExtension({
    this.id,
    this.ssccId,
    this.ssccCode,
    this.euTransportUnitId,
    this.euRouteAuthorizationNumber,
    this.euRouteAuthorizationDate,
    this.euRouteAuthorizationExpiry,
    this.euFirstRetailOutlet = false,
    this.taxStampAggregationLevel,
    this.aggregatedStampCount,
    this.taxStampAuthorityId,
    this.customsDeclarationNumber,
    this.customsDeclarationDate,
    this.exportLicenseNumber,
    this.exportLicenseDate,
    this.exportLicenseExpiry,
    this.importPermitNumber,
    this.importPermitDate,
    this.countryOfOrigin,
    this.countryOfDestination,
    this.sealNumber,
    this.sealType,
    this.sealedBy,
    this.sealedDate,
    this.carrierLicenseNumber,
    this.carrierTobaccoPermitNumber,
    this.driverId,
    this.vehicleRegistration,
    this.pactActManifestNumber,
    this.stateTransitPermitNumber,
    this.stateTransitPermitState,
    this.containsMultipleBatches = false,
    this.primaryBatchNumber,
    this.createdAt,
    this.updatedAt,
  });

  factory SSCCTobaccoExtension.fromJson(Map<String, dynamic> json) {
    return SSCCTobaccoExtension(
      id: json['id'],
      ssccId: json['ssccId'],
      ssccCode: json['ssccCode'],
      euTransportUnitId: json['euTransportUnitId'],
      euRouteAuthorizationNumber: json['euRouteAuthorizationNumber'],
      euRouteAuthorizationDate: json['euRouteAuthorizationDate'] != null
          ? DateTime.parse(json['euRouteAuthorizationDate'])
          : null,
      euRouteAuthorizationExpiry: json['euRouteAuthorizationExpiry'] != null
          ? DateTime.parse(json['euRouteAuthorizationExpiry'])
          : null,
      euFirstRetailOutlet: json['euFirstRetailOutlet'] ?? false,
      taxStampAggregationLevel: json['taxStampAggregationLevel'],
      aggregatedStampCount: json['aggregatedStampCount'],
      taxStampAuthorityId: json['taxStampAuthorityId'],
      customsDeclarationNumber: json['customsDeclarationNumber'],
      customsDeclarationDate: json['customsDeclarationDate'] != null
          ? DateTime.parse(json['customsDeclarationDate'])
          : null,
      exportLicenseNumber: json['exportLicenseNumber'],
      exportLicenseDate: json['exportLicenseDate'] != null
          ? DateTime.parse(json['exportLicenseDate'])
          : null,
      exportLicenseExpiry: json['exportLicenseExpiry'] != null
          ? DateTime.parse(json['exportLicenseExpiry'])
          : null,
      importPermitNumber: json['importPermitNumber'],
      importPermitDate: json['importPermitDate'] != null
          ? DateTime.parse(json['importPermitDate'])
          : null,
      countryOfOrigin: json['countryOfOrigin'],
      countryOfDestination: json['countryOfDestination'],
      sealNumber: json['sealNumber'],
      sealType: json['sealType'],
      sealedBy: json['sealedBy'],
      sealedDate: json['sealedDate'] != null
          ? DateTime.parse(json['sealedDate'])
          : null,
      carrierLicenseNumber: json['carrierLicenseNumber'],
      carrierTobaccoPermitNumber: json['carrierTobaccoPermitNumber'],
      driverId: json['driverId'],
      vehicleRegistration: json['vehicleRegistration'],
      pactActManifestNumber: json['pactActManifestNumber'],
      stateTransitPermitNumber: json['stateTransitPermitNumber'],
      stateTransitPermitState: json['stateTransitPermitState'],
      containsMultipleBatches: json['containsMultipleBatches'] ?? false,
      primaryBatchNumber: json['primaryBatchNumber'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (ssccId != null) 'ssccId': ssccId,
      if (ssccCode != null) 'ssccCode': ssccCode,
      if (euTransportUnitId != null) 'euTransportUnitId': euTransportUnitId,
      if (euRouteAuthorizationNumber != null)
        'euRouteAuthorizationNumber': euRouteAuthorizationNumber,
      if (euRouteAuthorizationDate != null)
        'euRouteAuthorizationDate':
            euRouteAuthorizationDate!.toIso8601String().split('T').first,
      if (euRouteAuthorizationExpiry != null)
        'euRouteAuthorizationExpiry':
            euRouteAuthorizationExpiry!.toIso8601String().split('T').first,
      'euFirstRetailOutlet': euFirstRetailOutlet,
      if (taxStampAggregationLevel != null)
        'taxStampAggregationLevel': taxStampAggregationLevel,
      if (aggregatedStampCount != null)
        'aggregatedStampCount': aggregatedStampCount,
      if (taxStampAuthorityId != null)
        'taxStampAuthorityId': taxStampAuthorityId,
      if (customsDeclarationNumber != null)
        'customsDeclarationNumber': customsDeclarationNumber,
      if (customsDeclarationDate != null)
        'customsDeclarationDate':
            customsDeclarationDate!.toIso8601String().split('T').first,
      if (exportLicenseNumber != null)
        'exportLicenseNumber': exportLicenseNumber,
      if (exportLicenseDate != null)
        'exportLicenseDate':
            exportLicenseDate!.toIso8601String().split('T').first,
      if (exportLicenseExpiry != null)
        'exportLicenseExpiry':
            exportLicenseExpiry!.toIso8601String().split('T').first,
      if (importPermitNumber != null) 'importPermitNumber': importPermitNumber,
      if (importPermitDate != null)
        'importPermitDate':
            importPermitDate!.toIso8601String().split('T').first,
      if (countryOfOrigin != null) 'countryOfOrigin': countryOfOrigin,
      if (countryOfDestination != null)
        'countryOfDestination': countryOfDestination,
      if (sealNumber != null) 'sealNumber': sealNumber,
      if (sealType != null) 'sealType': sealType,
      if (sealedBy != null) 'sealedBy': sealedBy,
      if (sealedDate != null) 'sealedDate': sealedDate!.toIso8601String(),
      if (carrierLicenseNumber != null)
        'carrierLicenseNumber': carrierLicenseNumber,
      if (carrierTobaccoPermitNumber != null)
        'carrierTobaccoPermitNumber': carrierTobaccoPermitNumber,
      if (driverId != null) 'driverId': driverId,
      if (vehicleRegistration != null)
        'vehicleRegistration': vehicleRegistration,
      if (pactActManifestNumber != null)
        'pactActManifestNumber': pactActManifestNumber,
      if (stateTransitPermitNumber != null)
        'stateTransitPermitNumber': stateTransitPermitNumber,
      if (stateTransitPermitState != null)
        'stateTransitPermitState': stateTransitPermitState,
      'containsMultipleBatches': containsMultipleBatches,
      if (primaryBatchNumber != null) 'primaryBatchNumber': primaryBatchNumber,
    };
  }

  SSCCTobaccoExtension copyWith({
    int? id,
    int? ssccId,
    String? ssccCode,
    String? euTransportUnitId,
    String? euRouteAuthorizationNumber,
    DateTime? euRouteAuthorizationDate,
    DateTime? euRouteAuthorizationExpiry,
    bool? euFirstRetailOutlet,
    String? taxStampAggregationLevel,
    int? aggregatedStampCount,
    String? taxStampAuthorityId,
    String? customsDeclarationNumber,
    DateTime? customsDeclarationDate,
    String? exportLicenseNumber,
    DateTime? exportLicenseDate,
    DateTime? exportLicenseExpiry,
    String? importPermitNumber,
    DateTime? importPermitDate,
    String? countryOfOrigin,
    String? countryOfDestination,
    String? sealNumber,
    String? sealType,
    String? sealedBy,
    DateTime? sealedDate,
    String? carrierLicenseNumber,
    String? carrierTobaccoPermitNumber,
    String? driverId,
    String? vehicleRegistration,
    String? pactActManifestNumber,
    String? stateTransitPermitNumber,
    String? stateTransitPermitState,
    bool? containsMultipleBatches,
    String? primaryBatchNumber,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SSCCTobaccoExtension(
      id: id ?? this.id,
      ssccId: ssccId ?? this.ssccId,
      ssccCode: ssccCode ?? this.ssccCode,
      euTransportUnitId: euTransportUnitId ?? this.euTransportUnitId,
      euRouteAuthorizationNumber:
          euRouteAuthorizationNumber ?? this.euRouteAuthorizationNumber,
      euRouteAuthorizationDate:
          euRouteAuthorizationDate ?? this.euRouteAuthorizationDate,
      euRouteAuthorizationExpiry:
          euRouteAuthorizationExpiry ?? this.euRouteAuthorizationExpiry,
      euFirstRetailOutlet: euFirstRetailOutlet ?? this.euFirstRetailOutlet,
      taxStampAggregationLevel:
          taxStampAggregationLevel ?? this.taxStampAggregationLevel,
      aggregatedStampCount: aggregatedStampCount ?? this.aggregatedStampCount,
      taxStampAuthorityId: taxStampAuthorityId ?? this.taxStampAuthorityId,
      customsDeclarationNumber:
          customsDeclarationNumber ?? this.customsDeclarationNumber,
      customsDeclarationDate:
          customsDeclarationDate ?? this.customsDeclarationDate,
      exportLicenseNumber: exportLicenseNumber ?? this.exportLicenseNumber,
      exportLicenseDate: exportLicenseDate ?? this.exportLicenseDate,
      exportLicenseExpiry: exportLicenseExpiry ?? this.exportLicenseExpiry,
      importPermitNumber: importPermitNumber ?? this.importPermitNumber,
      importPermitDate: importPermitDate ?? this.importPermitDate,
      countryOfOrigin: countryOfOrigin ?? this.countryOfOrigin,
      countryOfDestination: countryOfDestination ?? this.countryOfDestination,
      sealNumber: sealNumber ?? this.sealNumber,
      sealType: sealType ?? this.sealType,
      sealedBy: sealedBy ?? this.sealedBy,
      sealedDate: sealedDate ?? this.sealedDate,
      carrierLicenseNumber: carrierLicenseNumber ?? this.carrierLicenseNumber,
      carrierTobaccoPermitNumber:
          carrierTobaccoPermitNumber ?? this.carrierTobaccoPermitNumber,
      driverId: driverId ?? this.driverId,
      vehicleRegistration: vehicleRegistration ?? this.vehicleRegistration,
      pactActManifestNumber:
          pactActManifestNumber ?? this.pactActManifestNumber,
      stateTransitPermitNumber:
          stateTransitPermitNumber ?? this.stateTransitPermitNumber,
      stateTransitPermitState:
          stateTransitPermitState ?? this.stateTransitPermitState,
      containsMultipleBatches:
          containsMultipleBatches ?? this.containsMultipleBatches,
      primaryBatchNumber: primaryBatchNumber ?? this.primaryBatchNumber,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        ssccId,
        ssccCode,
        euTransportUnitId,
        euRouteAuthorizationNumber,
        euRouteAuthorizationDate,
        euRouteAuthorizationExpiry,
        euFirstRetailOutlet,
        taxStampAggregationLevel,
        aggregatedStampCount,
        taxStampAuthorityId,
        customsDeclarationNumber,
        customsDeclarationDate,
        exportLicenseNumber,
        exportLicenseDate,
        exportLicenseExpiry,
        importPermitNumber,
        importPermitDate,
        countryOfOrigin,
        countryOfDestination,
        sealNumber,
        sealType,
        sealedBy,
        sealedDate,
        carrierLicenseNumber,
        carrierTobaccoPermitNumber,
        driverId,
        vehicleRegistration,
        pactActManifestNumber,
        stateTransitPermitNumber,
        stateTransitPermitState,
        containsMultipleBatches,
        primaryBatchNumber,
        createdAt,
        updatedAt,
      ];
}

/// Enum for seal types
enum SealType {
  bolt,
  cable,
  padlock,
  rfid,
  tamperEvident,
  other,
}

/// Enum for tax stamp aggregation level
enum TaxStampAggregationLevel {
  caseLevel,
  pallet,
  container,
  shipper,
}
