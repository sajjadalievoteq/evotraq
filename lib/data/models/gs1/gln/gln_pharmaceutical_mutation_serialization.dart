part of 'gln_pharmaceutical_extension_model.dart';

extension GlnPharmaceuticalMutationSerialization on GLNPharmaceuticalExtension {
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
      if (deaBusinessActivity != null)
        'deaBusinessActivity': deaBusinessActivity,
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
      if (brandsyncPartyId != null) 'brandsyncPartyId': brandsyncPartyId,
      if (tatmeenPartyCode != null) 'tatmeenPartyCode': tatmeenPartyCode,
      if (pharmacovigilanceEmail != null)
        'pharmacovigilanceEmail': pharmacovigilanceEmail,
      if (recallContactEmail != null) 'recallContactEmail': recallContactEmail,
      if (recallContactPhone != null) 'recallContactPhone': recallContactPhone,
      if (epcisCaptureEndpointUrl != null)
        'epcisCaptureEndpointUrl': epcisCaptureEndpointUrl,
      if (licensedAgentAuthorisationNumber != null)
        'licensedAgentAuthorisationNumber': licensedAgentAuthorisationNumber,
      if (authorisedPrincipalMahGlns != null)
        'authorisedPrincipalMahGlns': authorisedPrincipalMahGlns,
      'mahQualificationIndicator': mahQualificationIndicator,
      if (mahTargetMarkets != null && mahTargetMarkets!.isNotEmpty)
        'mahTargetMarkets': mahTargetMarkets,
      if (mahRegulatoryRegistrationNumber != null)
        'mahRegulatoryRegistrationNumber': mahRegulatoryRegistrationNumber,
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
    String? brandsyncPartyId,
    String? tatmeenPartyCode,
    String? pharmacovigilanceEmail,
    String? recallContactEmail,
    String? recallContactPhone,
    String? epcisCaptureEndpointUrl,
    String? licensedAgentAuthorisationNumber,
    String? authorisedPrincipalMahGlns,
    bool? mahQualificationIndicator,
    List<String>? mahTargetMarkets,
    String? mahRegulatoryRegistrationNumber,
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
      brandsyncPartyId: brandsyncPartyId ?? this.brandsyncPartyId,
      tatmeenPartyCode: tatmeenPartyCode ?? this.tatmeenPartyCode,
      pharmacovigilanceEmail:
          pharmacovigilanceEmail ?? this.pharmacovigilanceEmail,
      recallContactEmail: recallContactEmail ?? this.recallContactEmail,
      recallContactPhone: recallContactPhone ?? this.recallContactPhone,
      epcisCaptureEndpointUrl:
          epcisCaptureEndpointUrl ?? this.epcisCaptureEndpointUrl,
      licensedAgentAuthorisationNumber:
          licensedAgentAuthorisationNumber ??
          this.licensedAgentAuthorisationNumber,
      authorisedPrincipalMahGlns:
          authorisedPrincipalMahGlns ?? this.authorisedPrincipalMahGlns,
      mahQualificationIndicator:
          mahQualificationIndicator ?? this.mahQualificationIndicator,
      mahTargetMarkets: mahTargetMarkets ?? this.mahTargetMarkets,
      mahRegulatoryRegistrationNumber:
          mahRegulatoryRegistrationNumber ??
          this.mahRegulatoryRegistrationNumber,
      additionalLicenses: additionalLicenses ?? this.additionalLicenses,
      certifications: certifications ?? this.certifications,
      serviceAreas: serviceAreas ?? this.serviceAreas,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isFdaRegistrationValid {
    if (fdaRegistrationExpiry == null) return fdaRegistrationNumber != null;
    return fdaRegistrationExpiry!.isAfter(DateTime.now());
  }

  bool get isDeaRegistrationValid {
    if (deaRegistrationExpiry == null) return deaRegistrationNumber != null;
    return deaRegistrationExpiry!.isAfter(DateTime.now());
  }

  bool get hasColdChain =>
      hasColdChainCapability || hasFreezerCapability || hasControlledRoomTemp;

  bool get isFullyDscsaCompliant =>
      isDscsaCompliant && hasSerializationCapability;
}
