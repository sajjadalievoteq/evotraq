import 'package:equatable/equatable.dart';

import 'package:traqtrace_app/data/models/gs1/gln/gln_pharmaceutical_types.dart';


List<String>? _stringListFromJson(dynamic v) {
  if (v == null) return null;
  if (v is List) {
    final out = v
        .map((e) => e.toString().trim())
        .where((e) => e.isNotEmpty)
        .toList();
    return out.isEmpty ? null : out;
  }
  if (v is String) {
    final parts = v
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    return parts.isEmpty ? null : parts;
  }
  return null;
}

class GLNPharmaceuticalExtension extends Equatable {
  final int? id;
  final int glnId;
  final String? glnCode;
  final String? locationName;

  final String? fdaEstablishmentId;
  final String? fdaRegistrationNumber;
  final DateTime? fdaRegistrationDate;
  final DateTime? fdaRegistrationExpiry;
  final String? fdaEstablishmentType;

  final String? deaRegistrationNumber;
  final DateTime? deaRegistrationExpiry;
  final String? deaScheduleAuthorization;
  final String? deaBusinessActivity;

  final String? stateLicenseNumber;
  final String? stateLicenseType;
  final DateTime? stateLicenseExpiry;
  final String? stateLicenseState;

  final String? wholesaleLicenseNumber;
  final DateTime? wholesaleLicenseExpiry;
  final bool isAuthorizedTradingPartner;
  final DateTime? atpVerificationDate;
  final bool vawdAccredited;
  final String? vawdAccreditationNumber;
  final DateTime? vawdExpiryDate;

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

  final bool isClinicalTrialSite;
  final String? clinicalTrialPhaseAuthorized;
  final String? irbApprovalNumber;
  final DateTime? irbApprovalExpiry;

  final bool isDscsaCompliant;
  final DateTime? dscsaComplianceDate;
  final bool hasSerializationCapability;
  final bool hasAggregationCapability;
  final String? interoperabilitySystem;

  final HealthcareFacilityType? healthcareFacilityType;
  final String? npiNumber;
  final String? ncpdpId;
  final String? medicareProviderNumber;
  final String? medicaidProviderNumber;

  final bool isIsoCertified;
  final String? isoCertificationType;
  final String? isoCertificationNumber;
  final DateTime? isoCertificationExpiry;
  final bool jcahoAccredited;
  final String? jcahoAccreditationNumber;
  final DateTime? jcahoAccreditationExpiry;

  final String? emaSiteId;
  final String? pmdaSiteId;
  final String? anvisaSiteId;
  final String? nmpaSiteId;

  final String? receivingHours;
  final String? dispatchHours;
  final bool hasWeighbridge;
  final bool hasLoadingDock;
  final bool hasForkliftCapability;
  final bool canReceiveHazmat;

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

  final String? brandsyncPartyId;
  final String? tatmeenPartyCode;

  final String? pharmacovigilanceEmail;
  final String? recallContactEmail;
  final String? recallContactPhone;

  final String? epcisCaptureEndpointUrl;

  final String? licensedAgentAuthorisationNumber;

  final String? authorisedPrincipalMahGlns;

  final bool mahQualificationIndicator;

  final List<String>? mahTargetMarkets;

  final String? mahRegulatoryRegistrationNumber;

  final List<Map<String, dynamic>>? additionalLicenses;
  final List<Map<String, dynamic>>? certifications;
  final List<String>? serviceAreas;

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
    this.brandsyncPartyId,
    this.tatmeenPartyCode,
    this.pharmacovigilanceEmail,
    this.recallContactEmail,
    this.recallContactPhone,
    this.epcisCaptureEndpointUrl,
    this.licensedAgentAuthorisationNumber,
    this.authorisedPrincipalMahGlns,
    this.mahQualificationIndicator = false,
    this.mahTargetMarkets,
    this.mahRegulatoryRegistrationNumber,
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
      coldStorageMinTempCelsius: (json['coldStorageMinTempCelsius'] as num?)
          ?.toDouble(),
      coldStorageMaxTempCelsius: (json['coldStorageMaxTempCelsius'] as num?)
          ?.toDouble(),
      hasFreezerCapability: json['hasFreezerCapability'] as bool? ?? false,
      freezerMinTempCelsius: (json['freezerMinTempCelsius'] as num?)
          ?.toDouble(),
      freezerMaxTempCelsius: (json['freezerMaxTempCelsius'] as num?)
          ?.toDouble(),
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
        json['healthcareFacilityType'] as String?,
      ),
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
      brandsyncPartyId: json['brandsyncPartyId'] as String?,
      tatmeenPartyCode: json['tatmeenPartyCode'] as String?,
      pharmacovigilanceEmail: json['pharmacovigilanceEmail'] as String?,
      recallContactEmail: json['recallContactEmail'] as String?,
      recallContactPhone: json['recallContactPhone'] as String?,
      epcisCaptureEndpointUrl: json['epcisCaptureEndpointUrl'] as String?,
      licensedAgentAuthorisationNumber:
          json['licensedAgentAuthorisationNumber'] as String?,
      authorisedPrincipalMahGlns: json['authorisedPrincipalMahGlns'] as String?,
      mahQualificationIndicator:
          json['mahQualificationIndicator'] as bool? ?? false,
      mahTargetMarkets: _stringListFromJson(json['mahTargetMarkets']),
      mahRegulatoryRegistrationNumber:
          json['mahRegulatoryRegistrationNumber'] as String?,
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
