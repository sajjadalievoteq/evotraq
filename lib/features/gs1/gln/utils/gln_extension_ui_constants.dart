abstract final class GlnExtensionSharedUiConstants {
  static const selectState = 'Select State';
  static const selectCountry = 'Select Country';
  static const dateNotSet = 'Not set';
}

abstract final class GlnPharmaceuticalExtensionUiConstants {
  static const expansionTitle = 'Pharmaceutical Extension';
  static const badgeSaved = 'Saved';

  static const sectionUaeRegistry = 'Registry & National IDs';
  static const labelBrandSyncPartyId = 'BrandSync Party ID';
  static const labelTatmeenPartyCode = 'Tatmeen Party Code';

  static const sectionMahTargetMarkets = 'MAH & Target Markets';
  static const labelMahQualificationIndicator = 'MAH Qualification Indicator';
  static const labelMahTargetMarketsIso = 'MAH Target Markets (ISO numeric)';
  static const hintMahTargetMarketsIso = 'Comma-Separated, e.g. 784 for UAE';
  static const labelMahRegulatoryRegistrationNumber =
      'MAH Regulatory Registration Number';

  static const sectionLicensedAgent = 'Licensed Agent (Import Markets)';
  static const labelLicensedAgentAuthorisationNumber =
      'Licensed Agent Authorisation Number';
  static const labelAuthorisedPrincipalMahGlns =
      'Authorised Principal MAH GLNs';
  static const hintAuthorisedPrincipalMahGlns = 'Comma-Separated 13-digit GLNs';

  static const sectionPharmacovigilance = 'Pharmacovigilance & Recall';
  static const labelPharmacovigilanceEmail = 'Pharmacovigilance Contact Email';
  static const labelRecallContactEmail = 'Recall Contact Email (24/7)';
  static const labelRecallContactPhone = 'Recall Contact Phone';

  static const sectionEpicsDataExchange = 'EPCIS & Data Exchange';
  static const labelEpicsCaptureEndpointUrl = 'EPCIS Capture Endpoint URL';
  static const hintHttpsUrl = 'https://…';

  static const cardHealthcareFacilityType = 'Healthcare Facility Type';
  static const labelFacilityType = 'Facility Type';

  static const cardFdaEstablishment = 'FDA Establishment Data';
  static const labelFdaEstablishmentId = 'FDA Establishment ID';
  static const labelFdaRegistrationNumber = 'FDA Registration Number';
  static const labelFdaEstablishmentType = 'FDA Establishment Type';
  static const labelRegistrationDate = 'Registration Date';
  static const labelRegistrationExpiry = 'Registration Expiry';

  static const cardDeaRegistration = 'DEA Registration';
  static const labelDeaRegistrationNumber = 'DEA Registration Number';
  static const labelDeaRegistrationExpiry = 'DEA Registration Expiry';
  static const labelDeaScheduleAuthorization = 'DEA Schedule Authorization';
  static const hintDeaSchedule = 'e.g., II, III, IV, V';
  static const labelDeaBusinessActivity = 'DEA Business Activity';

  static const cardStateProvincialLicense = 'State/Provincial License';
  static const labelLicenseNumber = 'License Number';
  static const labelStateDropdown = 'State';
  static const labelLicenseType = 'License Type';
  static const labelLicenseExpiry = 'License Expiry';

  static const cardWholesaleDistribution = 'Wholesale Distribution';
  static const labelWholesaleLicenseNumber = 'Wholesale License Number';
  static const labelWholesaleLicenseExpiry = 'Wholesale License Expiry';
  static const labelAuthorizedTradingPartner =
      'Authorized Trading Partner (ATP)';
  static const labelAtpVerificationDate = 'ATP Verification Date';
  static const labelVawdAccredited = 'VAWD Accredited';
  static const labelVawdAccreditationNumber = 'VAWD Accreditation Number';
  static const labelVawdExpiryDate = 'VAWD Expiry Date';

  static const cardColdChainStorage = 'Cold Chain & Storage Capabilities';
  static const labelColdChainCapability = 'Cold Chain Capability';
  static const labelMinTempC = 'Min Temp (°C)';
  static const labelMaxTempC = 'Max Temp (°C)';
  static const labelFreezerCapability = 'Freezer Capability';
  static const labelFreezerMinC = 'Freezer Min (°C)';
  static const labelFreezerMaxC = 'Freezer Max (°C)';
  static const labelControlledRoomTemperature = 'Controlled Room Temperature';
  static const labelCrtMinC = 'CRT Min (°C)';
  static const labelCrtMaxC = 'CRT Max (°C)';
  static const labelHumidityControl = 'Humidity Control';
  static const labelMinHumidityPct = 'Min Humidity (%)';
  static const labelMaxHumidityPct = 'Max Humidity (%)';
  static const labelGdpCertified = 'GDP Certified';
  static const labelGdpCertificationNumber = 'GDP Certification Number';
  static const labelGdpCertificationExpiry = 'GDP Certification Expiry';

  static const cardClinicalTrialSite = 'Clinical Trial Site';
  static const labelClinicalTrialSiteSwitch = 'Clinical Trial Site';
  static const labelClinicalTrialPhaseAuthorized =
      'Clinical Trial Phase Authorized';
  static const hintClinicalTrialPhase = 'e.g., Phase I, II, III, IV';
  static const labelIrbApprovalNumber = 'IRB Approval Number';
  static const labelIrbApprovalExpiry = 'IRB Approval Expiry';

  static const cardDscsaCompliance = 'DSCSA Compliance';
  static const labelDscsaCompliant = 'DSCSA Compliant';
  static const labelDscsaComplianceDate = 'DSCSA Compliance Date';
  static const labelSerializationCapability = 'Serialization Capability';
  static const labelAggregationCapability = 'Aggregation Capability';
  static const labelInteroperabilitySystem = 'Interoperability System';

  static const cardHealthcareIdentifiers = 'Healthcare Identifiers';
  static const labelNpiNumber = 'NPI Number';
  static const labelNcpdpId = 'NCPDP ID';
  static const labelMedicareProviderNumber = 'Medicare Provider Number';
  static const labelMedicaidProviderNumber = 'Medicaid Provider Number';

  static const cardCertificationsAccreditations =
      'Certifications & Accreditations';
  static const labelIsoCertified = 'ISO Certified';
  static const labelIsoCertificationType = 'ISO Certification Type';
  static const hintIsoCertificationType = 'e.g., ISO 9001, ISO 13485';
  static const labelIsoCertificationNumber = 'ISO Certification Number';
  static const labelIsoCertificationExpiry = 'ISO Certification Expiry';
  static const labelJcahoAccredited = 'JCAHO Accredited';
  static const labelJcahoAccreditationNumber = 'JCAHO Accreditation Number';
  static const labelJcahoAccreditationExpiry = 'JCAHO Accreditation Expiry';

  static const cardInternationalRegulatoryIds = 'International Regulatory IDs';
  static const labelEmaSiteId = 'EMA Site ID (Europe)';
  static const labelPmdaSiteId = 'PMDA Site ID (Japan)';
  static const labelAnvisaSiteId = 'ANVISA Site ID (Brazil)';
  static const labelNmpaSiteId = 'NMPA Site ID (China)';

  static const cardOperationalDetails = 'Operational Details';
  static const labelReceivingHours = 'Receiving Hours';
  static const labelDispatchHours = 'Dispatch Hours';
  static const labelHasWeighbridge = 'Has Weighbridge';
  static const labelHasLoadingDock = 'Has Loading Dock';
  static const labelHasForkliftCapability = 'Has Forklift Capability';
  static const labelCanReceiveHazmat = 'Can Receive Hazmat';

  static const cardContactInformation = 'Contact Information';
  static const headingPharmacistInCharge = 'Pharmacist in Charge';
  static const headingResponsiblePerson = 'Responsible Person';
  static const headingQualityContact = 'Quality Contact';
  static const headingRegulatoryContact = 'Regulatory Contact';
  static const labelName = 'Name';
  static const labelEmail = 'Email';
  static const labelPhone = 'Phone';
}
