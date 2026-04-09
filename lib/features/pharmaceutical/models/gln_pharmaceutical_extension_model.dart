import 'package:equatable/equatable.dart';

/// Healthcare facility type enum
enum HealthcareFacilityType {
  hospital,
  pharmacy,
  clinic,
  longTermCare,
  homeHealthcare,
  wholesaler,
  distributor,
  manufacturer,
  repackager,
  other,
}

extension HealthcareFacilityTypeExtension on HealthcareFacilityType {
  String get value {
    switch (this) {
      case HealthcareFacilityType.hospital:
        return 'HOSPITAL';
      case HealthcareFacilityType.pharmacy:
        return 'PHARMACY';
      case HealthcareFacilityType.clinic:
        return 'CLINIC';
      case HealthcareFacilityType.longTermCare:
        return 'LONG_TERM_CARE';
      case HealthcareFacilityType.homeHealthcare:
        return 'HOME_HEALTHCARE';
      case HealthcareFacilityType.wholesaler:
        return 'WHOLESALER';
      case HealthcareFacilityType.distributor:
        return 'DISTRIBUTOR';
      case HealthcareFacilityType.manufacturer:
        return 'MANUFACTURER';
      case HealthcareFacilityType.repackager:
        return 'REPACKAGER';
      case HealthcareFacilityType.other:
        return 'OTHER';
    }
  }

  String get displayName {
    switch (this) {
      case HealthcareFacilityType.hospital:
        return 'Hospital';
      case HealthcareFacilityType.pharmacy:
        return 'Pharmacy';
      case HealthcareFacilityType.clinic:
        return 'Clinic';
      case HealthcareFacilityType.longTermCare:
        return 'Long Term Care';
      case HealthcareFacilityType.homeHealthcare:
        return 'Home Healthcare';
      case HealthcareFacilityType.wholesaler:
        return 'Wholesaler';
      case HealthcareFacilityType.distributor:
        return 'Distributor';
      case HealthcareFacilityType.manufacturer:
        return 'Manufacturer';
      case HealthcareFacilityType.repackager:
        return 'Repackager';
      case HealthcareFacilityType.other:
        return 'Other';
    }
  }

  static HealthcareFacilityType fromString(String? value) {
    if (value == null || value.isEmpty) return HealthcareFacilityType.other;
    switch (value.toUpperCase()) {
      case 'HOSPITAL':
        return HealthcareFacilityType.hospital;
      case 'PHARMACY':
        return HealthcareFacilityType.pharmacy;
      case 'CLINIC':
        return HealthcareFacilityType.clinic;
      case 'LONG_TERM_CARE':
        return HealthcareFacilityType.longTermCare;
      case 'HOME_HEALTHCARE':
        return HealthcareFacilityType.homeHealthcare;
      case 'WHOLESALER':
        return HealthcareFacilityType.wholesaler;
      case 'DISTRIBUTOR':
        return HealthcareFacilityType.distributor;
      case 'MANUFACTURER':
        return HealthcareFacilityType.manufacturer;
      case 'REPACKAGER':
        return HealthcareFacilityType.repackager;
      default:
        return HealthcareFacilityType.other;
    }
  }
}

/// GLN Pharmaceutical Extension model
/// Based on GS1 Healthcare GLN Implementation Guideline
class GLNPharmaceuticalExtension extends Equatable {
  final int? id;
  final int glnId;
  final String? glnCode;
  final String? locationName;

  // FDA Establishment Data
  final String? fdaEstablishmentId;
  final String? fdaRegistrationNumber;
  final DateTime? fdaRegistrationDate;
  final DateTime? fdaRegistrationExpiry;
  final String? fdaEstablishmentType;

  // DEA Registration
  final String? deaRegistrationNumber;
  final DateTime? deaRegistrationExpiry;
  final String? deaScheduleAuthorization;
  final String? deaBusinessActivity;

  // State/Provincial Licensing
  final String? stateLicenseNumber;
  final String? stateLicenseType;
  final DateTime? stateLicenseExpiry;
  final String? stateLicenseState;

  // Wholesale Distribution
  final String? wholesaleLicenseNumber;
  final DateTime? wholesaleLicenseExpiry;
  final bool isAuthorizedTradingPartner;
  final DateTime? atpVerificationDate;
  final bool vawdAccredited;
  final String? vawdAccreditationNumber;
  final DateTime? vawdExpiryDate;

  // Cold Chain & Storage Capabilities
  final bool hasColdChainCapability;
  final double? coldStorageMinTempCelsius;
  final double? coldStorageMaxTempCelsius;
  final bool hasFreezerCapability;
  final double? freezerMinTempCelsius;
  final double? freezerMaxTempCelsius;
  final bool hasControlledRoomTemp;
  final double? crtMinTempCelsius;
  final double? crtMaxTempCelsius;
  final bool hasHumidityControl;
  final double? humidityRangeMin;
  final double? humidityRangeMax;
  final bool gdpCertified;
  final String? gdpCertificationNumber;
  final DateTime? gdpCertificationExpiry;

  // Clinical Trial Site
  final bool isClinicalTrialSite;
  final String? clinicalTrialPhaseAuthorized;
  final String? irbApprovalNumber;
  final DateTime? irbApprovalExpiry;

  // Serialization & DSCSA Compliance
  final bool isDscsaCompliant;
  final DateTime? dscsaComplianceDate;
  final bool hasSerializationCapability;
  final bool hasAggregationCapability;
  final String? interoperabilitySystem;

  // Healthcare Facility Type
  final HealthcareFacilityType? healthcareFacilityType;
  final String? npiNumber;
  final String? ncpdpId;
  final String? medicareProviderNumber;
  final String? medicaidProviderNumber;

  // Certifications
  final bool isIsoCertified;
  final String? isoCertificationType;
  final String? isoCertificationNumber;
  final DateTime? isoCertificationExpiry;
  final bool jcahoAccredited;
  final String? jcahoAccreditationNumber;
  final DateTime? jcahoAccreditationExpiry;

  // International Regulatory
  final String? emaSiteId;
  final String? pmdaSiteId;
  final String? anvisaSiteId;
  final String? nmpaSiteId;

  // Operational Details
  final String? receivingHours;
  final String? dispatchHours;
  final bool hasWeighbridge;
  final bool hasLoadingDock;
  final bool hasForkliftCapability;
  final bool canReceiveHazmat;

  // Contact Information
  final String? pharmacistInCharge;
  final String? picLicenseNumber;
  final String? responsiblePersonName;
  final String? responsiblePersonEmail;
  final String? responsiblePersonPhone;
  final String? qualityContactName;
  final String? qualityContactEmail;
  final String? qualityContactPhone;
  final String? regulatoryContactName;
  final String? regulatoryContactEmail;
  final String? regulatoryContactPhone;

  // Additional Data
  final List<Map<String, dynamic>>? additionalLicenses;
  final List<Map<String, dynamic>>? certifications;
  final List<String>? serviceAreas;

  // Audit Fields
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const GLNPharmaceuticalExtension({
    this.id,
    required this.glnId,
    this.glnCode,
    this.locationName,
    this.fdaEstablishmentId,
    this.fdaRegistrationNumber,
    this.fdaRegistrationDate,
    this.fdaRegistrationExpiry,
    this.fdaEstablishmentType,
    this.deaRegistrationNumber,
    this.deaRegistrationExpiry,
    this.deaScheduleAuthorization,
    this.deaBusinessActivity,
    this.stateLicenseNumber,
    this.stateLicenseType,
    this.stateLicenseExpiry,
    this.stateLicenseState,
    this.wholesaleLicenseNumber,
    this.wholesaleLicenseExpiry,
    this.isAuthorizedTradingPartner = false,
    this.atpVerificationDate,
    this.vawdAccredited = false,
    this.vawdAccreditationNumber,
    this.vawdExpiryDate,
    this.hasColdChainCapability = false,
    this.coldStorageMinTempCelsius,
    this.coldStorageMaxTempCelsius,
    this.hasFreezerCapability = false,
    this.freezerMinTempCelsius,
    this.freezerMaxTempCelsius,
    this.hasControlledRoomTemp = false,
    this.crtMinTempCelsius,
    this.crtMaxTempCelsius,
    this.hasHumidityControl = false,
    this.humidityRangeMin,
    this.humidityRangeMax,
    this.gdpCertified = false,
    this.gdpCertificationNumber,
    this.gdpCertificationExpiry,
    this.isClinicalTrialSite = false,
    this.clinicalTrialPhaseAuthorized,
    this.irbApprovalNumber,
    this.irbApprovalExpiry,
    this.isDscsaCompliant = false,
    this.dscsaComplianceDate,
    this.hasSerializationCapability = false,
    this.hasAggregationCapability = false,
    this.interoperabilitySystem,
    this.healthcareFacilityType,
    this.npiNumber,
    this.ncpdpId,
    this.medicareProviderNumber,
    this.medicaidProviderNumber,
    this.isIsoCertified = false,
    this.isoCertificationType,
    this.isoCertificationNumber,
    this.isoCertificationExpiry,
    this.jcahoAccredited = false,
    this.jcahoAccreditationNumber,
    this.jcahoAccreditationExpiry,
    this.emaSiteId,
    this.pmdaSiteId,
    this.anvisaSiteId,
    this.nmpaSiteId,
    this.receivingHours,
    this.dispatchHours,
    this.hasWeighbridge = false,
    this.hasLoadingDock = false,
    this.hasForkliftCapability = false,
    this.canReceiveHazmat = false,
    this.pharmacistInCharge,
    this.picLicenseNumber,
    this.responsiblePersonName,
    this.responsiblePersonEmail,
    this.responsiblePersonPhone,
    this.qualityContactName,
    this.qualityContactEmail,
    this.qualityContactPhone,
    this.regulatoryContactName,
    this.regulatoryContactEmail,
    this.regulatoryContactPhone,
    this.additionalLicenses,
    this.certifications,
    this.serviceAreas,
    this.createdAt,
    this.updatedAt,
  });

  factory GLNPharmaceuticalExtension.fromJson(Map<String, dynamic> json) {
    return GLNPharmaceuticalExtension(
      id: json['id'] as int?,
      glnId: json['glnId'] as int,
      glnCode: json['glnCode'] as String?,
      locationName: json['locationName'] as String?,
      fdaEstablishmentId: json['fdaEstablishmentId'] as String?,
      fdaRegistrationNumber: json['fdaRegistrationNumber'] as String?,
      fdaRegistrationDate: json['fdaRegistrationDate'] != null
          ? DateTime.parse(json['fdaRegistrationDate'])
          : null,
      fdaRegistrationExpiry: json['fdaRegistrationExpiry'] != null
          ? DateTime.parse(json['fdaRegistrationExpiry'])
          : null,
      fdaEstablishmentType: json['fdaEstablishmentType'] as String?,
      deaRegistrationNumber: json['deaRegistrationNumber'] as String?,
      deaRegistrationExpiry: json['deaRegistrationExpiry'] != null
          ? DateTime.parse(json['deaRegistrationExpiry'])
          : null,
      deaScheduleAuthorization: json['deaScheduleAuthorization'] as String?,
      deaBusinessActivity: json['deaBusinessActivity'] as String?,
      stateLicenseNumber: json['stateLicenseNumber'] as String?,
      stateLicenseType: json['stateLicenseType'] as String?,
      stateLicenseExpiry: json['stateLicenseExpiry'] != null
          ? DateTime.parse(json['stateLicenseExpiry'])
          : null,
      stateLicenseState: json['stateLicenseState'] as String?,
      wholesaleLicenseNumber: json['wholesaleLicenseNumber'] as String?,
      wholesaleLicenseExpiry: json['wholesaleLicenseExpiry'] != null
          ? DateTime.parse(json['wholesaleLicenseExpiry'])
          : null,
      isAuthorizedTradingPartner:
          json['isAuthorizedTradingPartner'] as bool? ?? false,
      atpVerificationDate: json['atpVerificationDate'] != null
          ? DateTime.parse(json['atpVerificationDate'])
          : null,
      vawdAccredited: json['vawdAccredited'] as bool? ?? false,
      vawdAccreditationNumber: json['vawdAccreditationNumber'] as String?,
      vawdExpiryDate: json['vawdExpiryDate'] != null
          ? DateTime.parse(json['vawdExpiryDate'])
          : null,
      hasColdChainCapability: json['hasColdChainCapability'] as bool? ?? false,
      coldStorageMinTempCelsius:
          (json['coldStorageMinTempCelsius'] as num?)?.toDouble(),
      coldStorageMaxTempCelsius:
          (json['coldStorageMaxTempCelsius'] as num?)?.toDouble(),
      hasFreezerCapability: json['hasFreezerCapability'] as bool? ?? false,
      freezerMinTempCelsius:
          (json['freezerMinTempCelsius'] as num?)?.toDouble(),
      freezerMaxTempCelsius:
          (json['freezerMaxTempCelsius'] as num?)?.toDouble(),
      hasControlledRoomTemp: json['hasControlledRoomTemp'] as bool? ?? false,
      crtMinTempCelsius: (json['crtMinTempCelsius'] as num?)?.toDouble(),
      crtMaxTempCelsius: (json['crtMaxTempCelsius'] as num?)?.toDouble(),
      hasHumidityControl: json['hasHumidityControl'] as bool? ?? false,
      humidityRangeMin: (json['humidityRangeMin'] as num?)?.toDouble(),
      humidityRangeMax: (json['humidityRangeMax'] as num?)?.toDouble(),
      gdpCertified: json['gdpCertified'] as bool? ?? false,
      gdpCertificationNumber: json['gdpCertificationNumber'] as String?,
      gdpCertificationExpiry: json['gdpCertificationExpiry'] != null
          ? DateTime.parse(json['gdpCertificationExpiry'])
          : null,
      isClinicalTrialSite: json['isClinicalTrialSite'] as bool? ?? false,
      clinicalTrialPhaseAuthorized:
          json['clinicalTrialPhaseAuthorized'] as String?,
      irbApprovalNumber: json['irbApprovalNumber'] as String?,
      irbApprovalExpiry: json['irbApprovalExpiry'] != null
          ? DateTime.parse(json['irbApprovalExpiry'])
          : null,
      isDscsaCompliant: json['isDscsaCompliant'] as bool? ?? false,
      dscsaComplianceDate: json['dscsaComplianceDate'] != null
          ? DateTime.parse(json['dscsaComplianceDate'])
          : null,
      hasSerializationCapability:
          json['hasSerializationCapability'] as bool? ?? false,
      hasAggregationCapability:
          json['hasAggregationCapability'] as bool? ?? false,
      interoperabilitySystem: json['interoperabilitySystem'] as String?,
      healthcareFacilityType: HealthcareFacilityTypeExtension.fromString(
          json['healthcareFacilityType'] as String?),
      npiNumber: json['npiNumber'] as String?,
      ncpdpId: json['ncpdpId'] as String?,
      medicareProviderNumber: json['medicareProviderNumber'] as String?,
      medicaidProviderNumber: json['medicaidProviderNumber'] as String?,
      isIsoCertified: json['isIsoCertified'] as bool? ?? false,
      isoCertificationType: json['isoCertificationType'] as String?,
      isoCertificationNumber: json['isoCertificationNumber'] as String?,
      isoCertificationExpiry: json['isoCertificationExpiry'] != null
          ? DateTime.parse(json['isoCertificationExpiry'])
          : null,
      jcahoAccredited: json['jcahoAccredited'] as bool? ?? false,
      jcahoAccreditationNumber: json['jcahoAccreditationNumber'] as String?,
      jcahoAccreditationExpiry: json['jcahoAccreditationExpiry'] != null
          ? DateTime.parse(json['jcahoAccreditationExpiry'])
          : null,
      emaSiteId: json['emaSiteId'] as String?,
      pmdaSiteId: json['pmdaSiteId'] as String?,
      anvisaSiteId: json['anvisaSiteId'] as String?,
      nmpaSiteId: json['nmpaSiteId'] as String?,
      receivingHours: json['receivingHours'] as String?,
      dispatchHours: json['dispatchHours'] as String?,
      hasWeighbridge: json['hasWeighbridge'] as bool? ?? false,
      hasLoadingDock: json['hasLoadingDock'] as bool? ?? false,
      hasForkliftCapability: json['hasForkliftCapability'] as bool? ?? false,
      canReceiveHazmat: json['canReceiveHazmat'] as bool? ?? false,
      pharmacistInCharge: json['pharmacistInCharge'] as String?,
      picLicenseNumber: json['picLicenseNumber'] as String?,
      responsiblePersonName: json['responsiblePersonName'] as String?,
      responsiblePersonEmail: json['responsiblePersonEmail'] as String?,
      responsiblePersonPhone: json['responsiblePersonPhone'] as String?,
      qualityContactName: json['qualityContactName'] as String?,
      qualityContactEmail: json['qualityContactEmail'] as String?,
      qualityContactPhone: json['qualityContactPhone'] as String?,
      regulatoryContactName: json['regulatoryContactName'] as String?,
      regulatoryContactEmail: json['regulatoryContactEmail'] as String?,
      regulatoryContactPhone: json['regulatoryContactPhone'] as String?,
      additionalLicenses: (json['additionalLicenses'] as List<dynamic>?)
          ?.map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
      certifications: (json['certifications'] as List<dynamic>?)
          ?.map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
      serviceAreas: (json['serviceAreas'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
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
      'glnId': glnId,
      if (glnCode != null) 'glnCode': glnCode,
      if (locationName != null) 'locationName': locationName,
      if (fdaEstablishmentId != null) 'fdaEstablishmentId': fdaEstablishmentId,
      if (fdaRegistrationNumber != null)
        'fdaRegistrationNumber': fdaRegistrationNumber,
      if (fdaRegistrationDate != null)
        'fdaRegistrationDate': fdaRegistrationDate!.toIso8601String(),
      if (fdaRegistrationExpiry != null)
        'fdaRegistrationExpiry': fdaRegistrationExpiry!.toIso8601String(),
      if (fdaEstablishmentType != null)
        'fdaEstablishmentType': fdaEstablishmentType,
      if (deaRegistrationNumber != null)
        'deaRegistrationNumber': deaRegistrationNumber,
      if (deaRegistrationExpiry != null)
        'deaRegistrationExpiry': deaRegistrationExpiry!.toIso8601String(),
      if (deaScheduleAuthorization != null)
        'deaScheduleAuthorization': deaScheduleAuthorization,
      if (deaBusinessActivity != null) 'deaBusinessActivity': deaBusinessActivity,
      if (stateLicenseNumber != null) 'stateLicenseNumber': stateLicenseNumber,
      if (stateLicenseType != null) 'stateLicenseType': stateLicenseType,
      if (stateLicenseExpiry != null)
        'stateLicenseExpiry': stateLicenseExpiry!.toIso8601String(),
      if (stateLicenseState != null) 'stateLicenseState': stateLicenseState,
      if (wholesaleLicenseNumber != null)
        'wholesaleLicenseNumber': wholesaleLicenseNumber,
      if (wholesaleLicenseExpiry != null)
        'wholesaleLicenseExpiry': wholesaleLicenseExpiry!.toIso8601String(),
      'isAuthorizedTradingPartner': isAuthorizedTradingPartner,
      if (atpVerificationDate != null)
        'atpVerificationDate': atpVerificationDate!.toIso8601String(),
      'vawdAccredited': vawdAccredited,
      if (vawdAccreditationNumber != null)
        'vawdAccreditationNumber': vawdAccreditationNumber,
      if (vawdExpiryDate != null)
        'vawdExpiryDate': vawdExpiryDate!.toIso8601String(),
      'hasColdChainCapability': hasColdChainCapability,
      if (coldStorageMinTempCelsius != null)
        'coldStorageMinTempCelsius': coldStorageMinTempCelsius,
      if (coldStorageMaxTempCelsius != null)
        'coldStorageMaxTempCelsius': coldStorageMaxTempCelsius,
      'hasFreezerCapability': hasFreezerCapability,
      if (freezerMinTempCelsius != null)
        'freezerMinTempCelsius': freezerMinTempCelsius,
      if (freezerMaxTempCelsius != null)
        'freezerMaxTempCelsius': freezerMaxTempCelsius,
      'hasControlledRoomTemp': hasControlledRoomTemp,
      if (crtMinTempCelsius != null) 'crtMinTempCelsius': crtMinTempCelsius,
      if (crtMaxTempCelsius != null) 'crtMaxTempCelsius': crtMaxTempCelsius,
      'hasHumidityControl': hasHumidityControl,
      if (humidityRangeMin != null) 'humidityRangeMin': humidityRangeMin,
      if (humidityRangeMax != null) 'humidityRangeMax': humidityRangeMax,
      'gdpCertified': gdpCertified,
      if (gdpCertificationNumber != null)
        'gdpCertificationNumber': gdpCertificationNumber,
      if (gdpCertificationExpiry != null)
        'gdpCertificationExpiry': gdpCertificationExpiry!.toIso8601String(),
      'isClinicalTrialSite': isClinicalTrialSite,
      if (clinicalTrialPhaseAuthorized != null)
        'clinicalTrialPhaseAuthorized': clinicalTrialPhaseAuthorized,
      if (irbApprovalNumber != null) 'irbApprovalNumber': irbApprovalNumber,
      if (irbApprovalExpiry != null)
        'irbApprovalExpiry': irbApprovalExpiry!.toIso8601String(),
      'isDscsaCompliant': isDscsaCompliant,
      if (dscsaComplianceDate != null)
        'dscsaComplianceDate': dscsaComplianceDate!.toIso8601String(),
      'hasSerializationCapability': hasSerializationCapability,
      'hasAggregationCapability': hasAggregationCapability,
      if (interoperabilitySystem != null)
        'interoperabilitySystem': interoperabilitySystem,
      if (healthcareFacilityType != null)
        'healthcareFacilityType': healthcareFacilityType!.value,
      if (npiNumber != null) 'npiNumber': npiNumber,
      if (ncpdpId != null) 'ncpdpId': ncpdpId,
      if (medicareProviderNumber != null)
        'medicareProviderNumber': medicareProviderNumber,
      if (medicaidProviderNumber != null)
        'medicaidProviderNumber': medicaidProviderNumber,
      'isIsoCertified': isIsoCertified,
      if (isoCertificationType != null)
        'isoCertificationType': isoCertificationType,
      if (isoCertificationNumber != null)
        'isoCertificationNumber': isoCertificationNumber,
      if (isoCertificationExpiry != null)
        'isoCertificationExpiry': isoCertificationExpiry!.toIso8601String(),
      'jcahoAccredited': jcahoAccredited,
      if (jcahoAccreditationNumber != null)
        'jcahoAccreditationNumber': jcahoAccreditationNumber,
      if (jcahoAccreditationExpiry != null)
        'jcahoAccreditationExpiry': jcahoAccreditationExpiry!.toIso8601String(),
      if (emaSiteId != null) 'emaSiteId': emaSiteId,
      if (pmdaSiteId != null) 'pmdaSiteId': pmdaSiteId,
      if (anvisaSiteId != null) 'anvisaSiteId': anvisaSiteId,
      if (nmpaSiteId != null) 'nmpaSiteId': nmpaSiteId,
      if (receivingHours != null) 'receivingHours': receivingHours,
      if (dispatchHours != null) 'dispatchHours': dispatchHours,
      'hasWeighbridge': hasWeighbridge,
      'hasLoadingDock': hasLoadingDock,
      'hasForkliftCapability': hasForkliftCapability,
      'canReceiveHazmat': canReceiveHazmat,
      if (pharmacistInCharge != null) 'pharmacistInCharge': pharmacistInCharge,
      if (picLicenseNumber != null) 'picLicenseNumber': picLicenseNumber,
      if (responsiblePersonName != null)
        'responsiblePersonName': responsiblePersonName,
      if (responsiblePersonEmail != null)
        'responsiblePersonEmail': responsiblePersonEmail,
      if (responsiblePersonPhone != null)
        'responsiblePersonPhone': responsiblePersonPhone,
      if (qualityContactName != null) 'qualityContactName': qualityContactName,
      if (qualityContactEmail != null)
        'qualityContactEmail': qualityContactEmail,
      if (qualityContactPhone != null)
        'qualityContactPhone': qualityContactPhone,
      if (regulatoryContactName != null)
        'regulatoryContactName': regulatoryContactName,
      if (regulatoryContactEmail != null)
        'regulatoryContactEmail': regulatoryContactEmail,
      if (regulatoryContactPhone != null)
        'regulatoryContactPhone': regulatoryContactPhone,
      if (additionalLicenses != null) 'additionalLicenses': additionalLicenses,
      if (certifications != null) 'certifications': certifications,
      if (serviceAreas != null) 'serviceAreas': serviceAreas,
    };
  }

  GLNPharmaceuticalExtension copyWith({
    int? id,
    int? glnId,
    String? glnCode,
    String? locationName,
    String? fdaEstablishmentId,
    String? fdaRegistrationNumber,
    DateTime? fdaRegistrationDate,
    DateTime? fdaRegistrationExpiry,
    String? fdaEstablishmentType,
    String? deaRegistrationNumber,
    DateTime? deaRegistrationExpiry,
    String? deaScheduleAuthorization,
    String? deaBusinessActivity,
    String? stateLicenseNumber,
    String? stateLicenseType,
    DateTime? stateLicenseExpiry,
    String? stateLicenseState,
    String? wholesaleLicenseNumber,
    DateTime? wholesaleLicenseExpiry,
    bool? isAuthorizedTradingPartner,
    DateTime? atpVerificationDate,
    bool? vawdAccredited,
    String? vawdAccreditationNumber,
    DateTime? vawdExpiryDate,
    bool? hasColdChainCapability,
    double? coldStorageMinTempCelsius,
    double? coldStorageMaxTempCelsius,
    bool? hasFreezerCapability,
    double? freezerMinTempCelsius,
    double? freezerMaxTempCelsius,
    bool? hasControlledRoomTemp,
    double? crtMinTempCelsius,
    double? crtMaxTempCelsius,
    bool? hasHumidityControl,
    double? humidityRangeMin,
    double? humidityRangeMax,
    bool? gdpCertified,
    String? gdpCertificationNumber,
    DateTime? gdpCertificationExpiry,
    bool? isClinicalTrialSite,
    String? clinicalTrialPhaseAuthorized,
    String? irbApprovalNumber,
    DateTime? irbApprovalExpiry,
    bool? isDscsaCompliant,
    DateTime? dscsaComplianceDate,
    bool? hasSerializationCapability,
    bool? hasAggregationCapability,
    String? interoperabilitySystem,
    HealthcareFacilityType? healthcareFacilityType,
    String? npiNumber,
    String? ncpdpId,
    String? medicareProviderNumber,
    String? medicaidProviderNumber,
    bool? isIsoCertified,
    String? isoCertificationType,
    String? isoCertificationNumber,
    DateTime? isoCertificationExpiry,
    bool? jcahoAccredited,
    String? jcahoAccreditationNumber,
    DateTime? jcahoAccreditationExpiry,
    String? emaSiteId,
    String? pmdaSiteId,
    String? anvisaSiteId,
    String? nmpaSiteId,
    String? receivingHours,
    String? dispatchHours,
    bool? hasWeighbridge,
    bool? hasLoadingDock,
    bool? hasForkliftCapability,
    bool? canReceiveHazmat,
    String? pharmacistInCharge,
    String? picLicenseNumber,
    String? responsiblePersonName,
    String? responsiblePersonEmail,
    String? responsiblePersonPhone,
    String? qualityContactName,
    String? qualityContactEmail,
    String? qualityContactPhone,
    String? regulatoryContactName,
    String? regulatoryContactEmail,
    String? regulatoryContactPhone,
    List<Map<String, dynamic>>? additionalLicenses,
    List<Map<String, dynamic>>? certifications,
    List<String>? serviceAreas,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GLNPharmaceuticalExtension(
      id: id ?? this.id,
      glnId: glnId ?? this.glnId,
      glnCode: glnCode ?? this.glnCode,
      locationName: locationName ?? this.locationName,
      fdaEstablishmentId: fdaEstablishmentId ?? this.fdaEstablishmentId,
      fdaRegistrationNumber:
          fdaRegistrationNumber ?? this.fdaRegistrationNumber,
      fdaRegistrationDate: fdaRegistrationDate ?? this.fdaRegistrationDate,
      fdaRegistrationExpiry:
          fdaRegistrationExpiry ?? this.fdaRegistrationExpiry,
      fdaEstablishmentType: fdaEstablishmentType ?? this.fdaEstablishmentType,
      deaRegistrationNumber:
          deaRegistrationNumber ?? this.deaRegistrationNumber,
      deaRegistrationExpiry:
          deaRegistrationExpiry ?? this.deaRegistrationExpiry,
      deaScheduleAuthorization:
          deaScheduleAuthorization ?? this.deaScheduleAuthorization,
      deaBusinessActivity: deaBusinessActivity ?? this.deaBusinessActivity,
      stateLicenseNumber: stateLicenseNumber ?? this.stateLicenseNumber,
      stateLicenseType: stateLicenseType ?? this.stateLicenseType,
      stateLicenseExpiry: stateLicenseExpiry ?? this.stateLicenseExpiry,
      stateLicenseState: stateLicenseState ?? this.stateLicenseState,
      wholesaleLicenseNumber:
          wholesaleLicenseNumber ?? this.wholesaleLicenseNumber,
      wholesaleLicenseExpiry:
          wholesaleLicenseExpiry ?? this.wholesaleLicenseExpiry,
      isAuthorizedTradingPartner:
          isAuthorizedTradingPartner ?? this.isAuthorizedTradingPartner,
      atpVerificationDate: atpVerificationDate ?? this.atpVerificationDate,
      vawdAccredited: vawdAccredited ?? this.vawdAccredited,
      vawdAccreditationNumber:
          vawdAccreditationNumber ?? this.vawdAccreditationNumber,
      vawdExpiryDate: vawdExpiryDate ?? this.vawdExpiryDate,
      hasColdChainCapability:
          hasColdChainCapability ?? this.hasColdChainCapability,
      coldStorageMinTempCelsius:
          coldStorageMinTempCelsius ?? this.coldStorageMinTempCelsius,
      coldStorageMaxTempCelsius:
          coldStorageMaxTempCelsius ?? this.coldStorageMaxTempCelsius,
      hasFreezerCapability: hasFreezerCapability ?? this.hasFreezerCapability,
      freezerMinTempCelsius:
          freezerMinTempCelsius ?? this.freezerMinTempCelsius,
      freezerMaxTempCelsius:
          freezerMaxTempCelsius ?? this.freezerMaxTempCelsius,
      hasControlledRoomTemp:
          hasControlledRoomTemp ?? this.hasControlledRoomTemp,
      crtMinTempCelsius: crtMinTempCelsius ?? this.crtMinTempCelsius,
      crtMaxTempCelsius: crtMaxTempCelsius ?? this.crtMaxTempCelsius,
      hasHumidityControl: hasHumidityControl ?? this.hasHumidityControl,
      humidityRangeMin: humidityRangeMin ?? this.humidityRangeMin,
      humidityRangeMax: humidityRangeMax ?? this.humidityRangeMax,
      gdpCertified: gdpCertified ?? this.gdpCertified,
      gdpCertificationNumber:
          gdpCertificationNumber ?? this.gdpCertificationNumber,
      gdpCertificationExpiry:
          gdpCertificationExpiry ?? this.gdpCertificationExpiry,
      isClinicalTrialSite: isClinicalTrialSite ?? this.isClinicalTrialSite,
      clinicalTrialPhaseAuthorized:
          clinicalTrialPhaseAuthorized ?? this.clinicalTrialPhaseAuthorized,
      irbApprovalNumber: irbApprovalNumber ?? this.irbApprovalNumber,
      irbApprovalExpiry: irbApprovalExpiry ?? this.irbApprovalExpiry,
      isDscsaCompliant: isDscsaCompliant ?? this.isDscsaCompliant,
      dscsaComplianceDate: dscsaComplianceDate ?? this.dscsaComplianceDate,
      hasSerializationCapability:
          hasSerializationCapability ?? this.hasSerializationCapability,
      hasAggregationCapability:
          hasAggregationCapability ?? this.hasAggregationCapability,
      interoperabilitySystem:
          interoperabilitySystem ?? this.interoperabilitySystem,
      healthcareFacilityType:
          healthcareFacilityType ?? this.healthcareFacilityType,
      npiNumber: npiNumber ?? this.npiNumber,
      ncpdpId: ncpdpId ?? this.ncpdpId,
      medicareProviderNumber:
          medicareProviderNumber ?? this.medicareProviderNumber,
      medicaidProviderNumber:
          medicaidProviderNumber ?? this.medicaidProviderNumber,
      isIsoCertified: isIsoCertified ?? this.isIsoCertified,
      isoCertificationType: isoCertificationType ?? this.isoCertificationType,
      isoCertificationNumber:
          isoCertificationNumber ?? this.isoCertificationNumber,
      isoCertificationExpiry:
          isoCertificationExpiry ?? this.isoCertificationExpiry,
      jcahoAccredited: jcahoAccredited ?? this.jcahoAccredited,
      jcahoAccreditationNumber:
          jcahoAccreditationNumber ?? this.jcahoAccreditationNumber,
      jcahoAccreditationExpiry:
          jcahoAccreditationExpiry ?? this.jcahoAccreditationExpiry,
      emaSiteId: emaSiteId ?? this.emaSiteId,
      pmdaSiteId: pmdaSiteId ?? this.pmdaSiteId,
      anvisaSiteId: anvisaSiteId ?? this.anvisaSiteId,
      nmpaSiteId: nmpaSiteId ?? this.nmpaSiteId,
      receivingHours: receivingHours ?? this.receivingHours,
      dispatchHours: dispatchHours ?? this.dispatchHours,
      hasWeighbridge: hasWeighbridge ?? this.hasWeighbridge,
      hasLoadingDock: hasLoadingDock ?? this.hasLoadingDock,
      hasForkliftCapability:
          hasForkliftCapability ?? this.hasForkliftCapability,
      canReceiveHazmat: canReceiveHazmat ?? this.canReceiveHazmat,
      pharmacistInCharge: pharmacistInCharge ?? this.pharmacistInCharge,
      picLicenseNumber: picLicenseNumber ?? this.picLicenseNumber,
      responsiblePersonName:
          responsiblePersonName ?? this.responsiblePersonName,
      responsiblePersonEmail:
          responsiblePersonEmail ?? this.responsiblePersonEmail,
      responsiblePersonPhone:
          responsiblePersonPhone ?? this.responsiblePersonPhone,
      qualityContactName: qualityContactName ?? this.qualityContactName,
      qualityContactEmail: qualityContactEmail ?? this.qualityContactEmail,
      qualityContactPhone: qualityContactPhone ?? this.qualityContactPhone,
      regulatoryContactName:
          regulatoryContactName ?? this.regulatoryContactName,
      regulatoryContactEmail:
          regulatoryContactEmail ?? this.regulatoryContactEmail,
      regulatoryContactPhone:
          regulatoryContactPhone ?? this.regulatoryContactPhone,
      additionalLicenses: additionalLicenses ?? this.additionalLicenses,
      certifications: certifications ?? this.certifications,
      serviceAreas: serviceAreas ?? this.serviceAreas,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if FDA registration is valid
  bool get isFdaRegistrationValid {
    if (fdaRegistrationExpiry == null) return fdaRegistrationNumber != null;
    return fdaRegistrationExpiry!.isAfter(DateTime.now());
  }

  /// Check if DEA registration is valid
  bool get isDeaRegistrationValid {
    if (deaRegistrationExpiry == null) return deaRegistrationNumber != null;
    return deaRegistrationExpiry!.isAfter(DateTime.now());
  }

  /// Check if location has any cold chain capability
  bool get hasColdChain =>
      hasColdChainCapability || hasFreezerCapability || hasControlledRoomTemp;

  /// Check if fully DSCSA compliant with serialization
  bool get isFullyDscsaCompliant =>
      isDscsaCompliant && hasSerializationCapability;

  @override
  List<Object?> get props => [
        id,
        glnId,
        glnCode,
        fdaEstablishmentId,
        deaRegistrationNumber,
        npiNumber,
      ];
}
