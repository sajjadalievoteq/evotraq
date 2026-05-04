// GLN industry extensions (pharmaceutical & tobacco location widgets).

/// Shared dropdown / date placeholder copy used by GLN extension forms.
abstract final class GlnExtensionSharedUiConstants {
  static const selectState = 'Select State';
  static const selectCountry = 'Select Country';
  static const dateNotSet = 'Not set';
}

/// [GLNPharmaceuticalExtensionWidget] — strings only (location pharma extension).
abstract final class GlnPharmaceuticalExtensionUiConstants {
  static const expansionTitle = 'Pharmaceutical extension';
  static const badgeSaved = 'Saved';

  static const sectionUaeRegistry = 'UAE registry & national IDs';
  static const labelBrandSyncPartyId = 'BrandSync Party ID';
  static const labelTatmeenPartyCode = 'Tatmeen Party Code';

  static const sectionMahTargetMarkets = 'MAH & target markets';
  static const labelMahQualificationIndicator = 'MAH qualification indicator';
  static const labelMahTargetMarketsIso = 'MAH target markets (ISO numeric)';
  static const hintMahTargetMarketsIso = 'Comma-separated, e.g. 784 for UAE';
  static const labelMahRegulatoryRegistrationNumber =
      'MAH regulatory registration number';

  static const sectionLicensedAgent = 'Licensed agent (import markets)';
  static const labelLicensedAgentAuthorisationNumber =
      'Licensed agent authorisation number';
  static const labelAuthorisedPrincipalMahGlns = 'Authorised principal MAH GLNs';
  static const hintAuthorisedPrincipalMahGlns = 'Comma-separated 13-digit GLNs';

  static const sectionPharmacovigilance = 'Pharmacovigilance & recall';
  static const labelPharmacovigilanceEmail = 'Pharmacovigilance contact email';
  static const labelRecallContactEmail = 'Recall contact email (24/7)';
  static const labelRecallContactPhone = 'Recall contact phone';

  static const sectionEpicsDataExchange = 'EPCIS & data exchange';
  static const labelEpicsCaptureEndpointUrl = 'EPCIS capture endpoint URL';
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
  static const labelAuthorizedTradingPartner = 'Authorized Trading Partner (ATP)';
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

  static const cardCertificationsAccreditations = 'Certifications & Accreditations';
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

/// [GLNTobaccoExtensionWidget] — strings only (tobacco location extension).
abstract final class GlnTobaccoExtensionUiConstants {
  static const expansionTitle = 'Tobacco Location Details';

  static const sectionEuTpd = 'EU Tobacco Products Directive (TPD)';
  static const switchEuTpdRegistered = 'EU TPD Registered';
  static const labelEuEconomicOperatorId = 'EU Economic Operator ID';
  static const helperEuEconomicOperatorId = 'EU-TPD Economic Operator Identifier';
  static const labelEuFacilityId = 'EU Facility ID';
  static const labelTpdRegistrationDate = 'TPD Registration Date';
  static const switchFirstRetailOutlet = 'First Retail Outlet';
  static const subtitleFirstRetailOutlet = 'Is this the first retail point of sale?';
  static const labelEuImporterId = 'EU Importer ID';

  static const sectionTaxStampAuthority = 'Tax Stamp Authority';
  static const labelTaxStampAuthorityId = 'Tax Stamp Authority ID';
  static const labelTaxStampAuthorityName = 'Tax Stamp Authority Name';
  static const labelAuthorizationDate = 'Authorization Date';
  static const labelAuthorizationExpiry = 'Authorization Expiry';
  static const labelAuthorizedTaxStampTypes = 'Authorized Tax Stamp Types';
  static const helperCommaSeparatedList = 'Comma-separated list';

  static const sectionFdaTobaccoUs = 'FDA Tobacco Registration (US)';
  static const labelFdaTobaccoEstablishmentId = 'FDA Tobacco Establishment ID';
  static const labelRegistrationDateGeneric = 'Registration Date';
  static const labelRegistrationExpiryGeneric = 'Registration Expiry';
  static const labelPmtaSiteListing = 'PMTA Site Listing';
  static const labelSeSiteListing = 'SE Site Listing';

  static const sectionPactActUs = 'PACT Act Compliance (US)';
  static const switchPactActRegistered = 'PACT Act Registered';
  static const subtitlePactAct = 'Prevent All Cigarette Trafficking Act';
  static const labelPactActRegistrationNumber = 'PACT Act Registration Number';
  static const labelAtfLicenseNumber = 'ATF License Number';

  static const sectionStateTobaccoLicense = 'State Tobacco License';
  static const labelStateLicenseNumber = 'State License Number';
  static const labelLicenseTypeShort = 'License Type';
  static const labelStateDropdown = 'State';
  static const labelLicenseExpiryGeneric = 'License Expiry';

  static const sectionWholesaleDistribution = 'Wholesale/Distribution';
  static const labelWholesaleLicenseNumber = 'Wholesale License Number';
  static const labelWholesaleLicenseExpiry = 'Wholesale License Expiry';
  static const switchMsaParticipant = 'Master Settlement Agreement Participant';
  static const labelMsaEscrowAccountStatus = 'MSA Escrow Account Status';

  static const sectionManufacturing = 'Manufacturing';
  static const switchManufacturingFacility = 'Manufacturing Facility';
  static const labelManufacturingLicenseNumber = 'Manufacturing License Number';
  static const labelManufacturingLicenseExpiry = 'Manufacturing License Expiry';
  static const labelManufacturingCapacity = 'Manufacturing Capacity (units/day)';
  static const labelTobaccoTypesManufactured = 'Tobacco Types Manufactured';
  static const helperTobaccoTypesManufactured =
      'e.g., Cigarettes, Cigars, RYO, etc.';

  static const sectionUniqueIdentifierIssuance = 'Unique Identifier Issuance';
  static const switchUiIssuer = 'UI Issuer';
  static const subtitleUiIssuer = 'Authorized to issue Unique Identifiers';
  static const labelUiIssuerRegistrationId = 'UI Issuer Registration ID';
  static const labelUiSystemProvider = 'UI System Provider';
  static const labelAntiTamperingDeviceProvider = 'Anti-Tampering Device Provider';

  static const sectionImportExport = 'Import/Export';
  static const labelCustomsRegistrationNumber = 'Customs Registration Number';
  static const switchAuthorizedEconomicOperator = 'Authorized Economic Operator (AEO)';
  static const labelAeoCertificateNumber = 'AEO Certificate Number';
  static const labelAeoCertificateExpiry = 'AEO Certificate Expiry';
  static const switchBondedWarehouse = 'Bonded Warehouse';
  static const labelBondedWarehouseLicenseNumber = 'Bonded Warehouse License Number';

  static const sectionSecurityCompliance = 'Security & Compliance';
  static const switchHasSecurityFeatures = 'Has Security Features';
  static const switchVideoSurveillance = 'Video Surveillance';
  static const switchAccessControlSystem = 'Access Control System';
  static const labelInventoryTrackingSystem = 'Inventory Tracking System';

  static const sectionRetail = 'Retail';
  static const switchRetailLocation = 'Retail Location';
  static const labelAgeVerificationSystem = 'Age Verification System';
  static const labelTobaccoSalesPermitNumber = 'Tobacco Sales Permit Number';
  static const labelSalesPermitExpiry = 'Sales Permit Expiry';

  static const sectionOperationalDetails = 'Operational Details';
  static const labelReceivingHours = 'Receiving Hours';
  static const labelDispatchHours = 'Dispatch Hours';
  static const labelStorageCapacityPallets = 'Storage Capacity (pallets)';
  static const switchClimateControl = 'Climate Control';
  static const labelMinTempC = 'Min Temp (°C)';
  static const labelMaxTempC = 'Max Temp (°C)';
  static const labelMinHumidityPct = 'Min Humidity (%)';
  static const labelMaxHumidityPct = 'Max Humidity (%)';

  static const sectionResponsiblePersons = 'Responsible Persons';
  static const labelResponsiblePersonName = 'Responsible Person Name';
  static const labelResponsiblePersonEmail = 'Responsible Person Email';
  static const labelResponsiblePersonPhone = 'Responsible Person Phone';
  static const labelQualityManagerName = 'Quality Manager Name';
  static const labelQualityManagerEmail = 'Quality Manager Email';
  static const labelQualityManagerPhone = 'Quality Manager Phone';
  static const labelRegulatoryAffairsContactName = 'Regulatory Affairs Contact Name';
  static const labelRegulatoryAffairsContactEmail = 'Regulatory Affairs Contact Email';
  static const labelRegulatoryAffairsContactPhone = 'Regulatory Affairs Contact Phone';

  static const sectionInternationalRegulatoryIds = 'International Regulatory IDs';
  static const labelWhoFctcPartyCountry = 'WHO FCTC Party Country';
  static const labelUkTobaccoTraceabilityId = 'UK Tobacco Traceability ID';
  static const labelCanadaTobaccoLicenseId = 'Canada Tobacco License ID';
  static const labelAustraliaTobaccoLicenseId = 'Australia Tobacco License ID';
}
