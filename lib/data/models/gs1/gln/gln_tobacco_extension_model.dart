import 'package:equatable/equatable.dart';

/// GLN Tobacco Extension model
/// Based on EU TPD, FDA PMTA, WHO FCTC, and PACT Act requirements
class GLNTobaccoExtension extends Equatable {
  final int? id;
  final int glnId;
  final String? glnCode;
  final String? locationName;

  // EU Tobacco Products Directive (TPD)
  final String? euEconomicOperatorId;
  final String? euFacilityId;
  final bool euTpdRegistered;
  final DateTime? euTpdRegistrationDate;
  final bool euFirstRetailOutlet;
  final String? euImporterId;

  // Tax Stamp Authority
  final String? taxStampAuthorityId;
  final String? taxStampAuthorityName;
  final DateTime? taxStampAuthorizationDate;
  final DateTime? taxStampAuthorizationExpiry;
  final String? authorizedTaxStampTypes;

  // FDA/US Tobacco Regulation
  final String? fdaTobaccoEstablishmentId;
  final DateTime? fdaTobaccoRegistrationDate;
  final DateTime? fdaTobaccoRegistrationExpiry;
  final String? fdaPmtaSiteListing;
  final String? fdaSeSiteListing;

  // PACT Act Compliance (US)
  final bool pactActRegistered;
  final String? pactActRegistrationNumber;
  final DateTime? pactActRegistrationDate;
  final String? pactAtfLicenseNumber;

  // State/Regional Tobacco Licensing
  final String? stateTobaccoLicenseNumber;
  final String? stateTobaccoLicenseType;
  final DateTime? stateTobaccoLicenseExpiry;
  final String? stateTobaccoLicenseState;

  // Wholesale/Distribution
  final String? tobaccoWholesaleLicenseNumber;
  final DateTime? tobaccoWholesaleLicenseExpiry;
  final bool masterSettlementAgreementParticipant;
  final String? msaEscrowAccountStatus;

  // Manufacturing Capabilities
  final bool isManufacturingFacility;
  final String? manufacturingLicenseNumber;
  final DateTime? manufacturingLicenseExpiry;
  final int? manufacturingCapacityUnitsPerDay;
  final String? tobaccoTypesManufactured;

  // Unique Identifier (UI) Issuance
  final bool isUiIssuer;
  final String? uiIssuerRegistrationId;
  final String? uiSystemProvider;
  final String? antiTamperingDeviceProvider;

  // Import/Export
  final String? customsRegistrationNumber;
  final bool authorizedEconomicOperator;
  final String? aeoCertificateNumber;
  final DateTime? aeoCertificateExpiry;
  final bool bondedWarehouse;
  final String? bondedWarehouseLicenseNumber;

  // Security & Compliance
  final bool hasSecurityFeatures;
  final bool videoSurveillance;
  final bool accessControlSystem;
  final String? inventoryTrackingSystem;

  // Retailer-Specific
  final bool isRetailLocation;
  final String? ageVerificationSystem;
  final String? tobaccoSalesPermitNumber;
  final DateTime? tobaccoSalesPermitExpiry;

  // Operational Details
  final String? receivingHours;
  final String? dispatchHours;
  final int? storageCapacityPallets;
  final bool hasClimateControl;
  final double? climateControlTempMin;
  final double? climateControlTempMax;
  final double? climateControlHumidityMin;
  final double? climateControlHumidityMax;

  // Responsible Persons (TPD requirement)
  final String? responsiblePersonName;
  final String? responsiblePersonEmail;
  final String? responsiblePersonPhone;
  final String? qualityManagerName;
  final String? qualityManagerEmail;
  final String? qualityManagerPhone;
  final String? regulatoryAffairsContactName;
  final String? regulatoryAffairsContactEmail;
  final String? regulatoryAffairsContactPhone;

  // International Regulatory IDs
  final String? whoFctcPartyCountry;
  final String? ukTobaccoTraceabilityId;
  final String? canadaTobaccoLicenseId;
  final String? australiaTobaccoLicenseId;

  // Additional Data
  final List<Map<String, dynamic>>? additionalLicenses;
  final List<String>? authorizedBrands;
  final List<Map<String, dynamic>>? inspectionHistory;

  // Audit Fields
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const GLNTobaccoExtension({
    this.id,
    required this.glnId,
    this.glnCode,
    this.locationName,
    this.euEconomicOperatorId,
    this.euFacilityId,
    this.euTpdRegistered = false,
    this.euTpdRegistrationDate,
    this.euFirstRetailOutlet = false,
    this.euImporterId,
    this.taxStampAuthorityId,
    this.taxStampAuthorityName,
    this.taxStampAuthorizationDate,
    this.taxStampAuthorizationExpiry,
    this.authorizedTaxStampTypes,
    this.fdaTobaccoEstablishmentId,
    this.fdaTobaccoRegistrationDate,
    this.fdaTobaccoRegistrationExpiry,
    this.fdaPmtaSiteListing,
    this.fdaSeSiteListing,
    this.pactActRegistered = false,
    this.pactActRegistrationNumber,
    this.pactActRegistrationDate,
    this.pactAtfLicenseNumber,
    this.stateTobaccoLicenseNumber,
    this.stateTobaccoLicenseType,
    this.stateTobaccoLicenseExpiry,
    this.stateTobaccoLicenseState,
    this.tobaccoWholesaleLicenseNumber,
    this.tobaccoWholesaleLicenseExpiry,
    this.masterSettlementAgreementParticipant = false,
    this.msaEscrowAccountStatus,
    this.isManufacturingFacility = false,
    this.manufacturingLicenseNumber,
    this.manufacturingLicenseExpiry,
    this.manufacturingCapacityUnitsPerDay,
    this.tobaccoTypesManufactured,
    this.isUiIssuer = false,
    this.uiIssuerRegistrationId,
    this.uiSystemProvider,
    this.antiTamperingDeviceProvider,
    this.customsRegistrationNumber,
    this.authorizedEconomicOperator = false,
    this.aeoCertificateNumber,
    this.aeoCertificateExpiry,
    this.bondedWarehouse = false,
    this.bondedWarehouseLicenseNumber,
    this.hasSecurityFeatures = false,
    this.videoSurveillance = false,
    this.accessControlSystem = false,
    this.inventoryTrackingSystem,
    this.isRetailLocation = false,
    this.ageVerificationSystem,
    this.tobaccoSalesPermitNumber,
    this.tobaccoSalesPermitExpiry,
    this.receivingHours,
    this.dispatchHours,
    this.storageCapacityPallets,
    this.hasClimateControl = false,
    this.climateControlTempMin,
    this.climateControlTempMax,
    this.climateControlHumidityMin,
    this.climateControlHumidityMax,
    this.responsiblePersonName,
    this.responsiblePersonEmail,
    this.responsiblePersonPhone,
    this.qualityManagerName,
    this.qualityManagerEmail,
    this.qualityManagerPhone,
    this.regulatoryAffairsContactName,
    this.regulatoryAffairsContactEmail,
    this.regulatoryAffairsContactPhone,
    this.whoFctcPartyCountry,
    this.ukTobaccoTraceabilityId,
    this.canadaTobaccoLicenseId,
    this.australiaTobaccoLicenseId,
    this.additionalLicenses,
    this.authorizedBrands,
    this.inspectionHistory,
    this.createdAt,
    this.updatedAt,
  });

  factory GLNTobaccoExtension.fromJson(Map<String, dynamic> json) {
    return GLNTobaccoExtension(
      id: json['id'] as int?,
      glnId: json['glnId'] as int,
      glnCode: json['glnCode'] as String?,
      locationName: json['locationName'] as String?,
      euEconomicOperatorId: json['euEconomicOperatorId'] as String?,
      euFacilityId: json['euFacilityId'] as String?,
      euTpdRegistered: json['euTpdRegistered'] as bool? ?? false,
      euTpdRegistrationDate: json['euTpdRegistrationDate'] != null
          ? DateTime.parse(json['euTpdRegistrationDate'])
          : null,
      euFirstRetailOutlet: json['euFirstRetailOutlet'] as bool? ?? false,
      euImporterId: json['euImporterId'] as String?,
      taxStampAuthorityId: json['taxStampAuthorityId'] as String?,
      taxStampAuthorityName: json['taxStampAuthorityName'] as String?,
      taxStampAuthorizationDate: json['taxStampAuthorizationDate'] != null
          ? DateTime.parse(json['taxStampAuthorizationDate'])
          : null,
      taxStampAuthorizationExpiry: json['taxStampAuthorizationExpiry'] != null
          ? DateTime.parse(json['taxStampAuthorizationExpiry'])
          : null,
      authorizedTaxStampTypes: json['authorizedTaxStampTypes'] as String?,
      fdaTobaccoEstablishmentId: json['fdaTobaccoEstablishmentId'] as String?,
      fdaTobaccoRegistrationDate: json['fdaTobaccoRegistrationDate'] != null
          ? DateTime.parse(json['fdaTobaccoRegistrationDate'])
          : null,
      fdaTobaccoRegistrationExpiry:
          json['fdaTobaccoRegistrationExpiry'] != null
              ? DateTime.parse(json['fdaTobaccoRegistrationExpiry'])
              : null,
      fdaPmtaSiteListing: json['fdaPmtaSiteListing'] as String?,
      fdaSeSiteListing: json['fdaSeSiteListing'] as String?,
      pactActRegistered: json['pactActRegistered'] as bool? ?? false,
      pactActRegistrationNumber: json['pactActRegistrationNumber'] as String?,
      pactActRegistrationDate: json['pactActRegistrationDate'] != null
          ? DateTime.parse(json['pactActRegistrationDate'])
          : null,
      pactAtfLicenseNumber: json['pactAtfLicenseNumber'] as String?,
      stateTobaccoLicenseNumber: json['stateTobaccoLicenseNumber'] as String?,
      stateTobaccoLicenseType: json['stateTobaccoLicenseType'] as String?,
      stateTobaccoLicenseExpiry: json['stateTobaccoLicenseExpiry'] != null
          ? DateTime.parse(json['stateTobaccoLicenseExpiry'])
          : null,
      stateTobaccoLicenseState: json['stateTobaccoLicenseState'] as String?,
      tobaccoWholesaleLicenseNumber:
          json['tobaccoWholesaleLicenseNumber'] as String?,
      tobaccoWholesaleLicenseExpiry:
          json['tobaccoWholesaleLicenseExpiry'] != null
              ? DateTime.parse(json['tobaccoWholesaleLicenseExpiry'])
              : null,
      masterSettlementAgreementParticipant:
          json['masterSettlementAgreementParticipant'] as bool? ?? false,
      msaEscrowAccountStatus: json['msaEscrowAccountStatus'] as String?,
      isManufacturingFacility: json['isManufacturingFacility'] as bool? ?? false,
      manufacturingLicenseNumber: json['manufacturingLicenseNumber'] as String?,
      manufacturingLicenseExpiry: json['manufacturingLicenseExpiry'] != null
          ? DateTime.parse(json['manufacturingLicenseExpiry'])
          : null,
      manufacturingCapacityUnitsPerDay:
          json['manufacturingCapacityUnitsPerDay'] as int?,
      tobaccoTypesManufactured: json['tobaccoTypesManufactured'] as String?,
      isUiIssuer: json['isUiIssuer'] as bool? ?? false,
      uiIssuerRegistrationId: json['uiIssuerRegistrationId'] as String?,
      uiSystemProvider: json['uiSystemProvider'] as String?,
      antiTamperingDeviceProvider:
          json['antiTamperingDeviceProvider'] as String?,
      customsRegistrationNumber: json['customsRegistrationNumber'] as String?,
      authorizedEconomicOperator:
          json['authorizedEconomicOperator'] as bool? ?? false,
      aeoCertificateNumber: json['aeoCertificateNumber'] as String?,
      aeoCertificateExpiry: json['aeoCertificateExpiry'] != null
          ? DateTime.parse(json['aeoCertificateExpiry'])
          : null,
      bondedWarehouse: json['bondedWarehouse'] as bool? ?? false,
      bondedWarehouseLicenseNumber:
          json['bondedWarehouseLicenseNumber'] as String?,
      hasSecurityFeatures: json['hasSecurityFeatures'] as bool? ?? false,
      videoSurveillance: json['videoSurveillance'] as bool? ?? false,
      accessControlSystem: json['accessControlSystem'] as bool? ?? false,
      inventoryTrackingSystem: json['inventoryTrackingSystem'] as String?,
      isRetailLocation: json['isRetailLocation'] as bool? ?? false,
      ageVerificationSystem: json['ageVerificationSystem'] as String?,
      tobaccoSalesPermitNumber: json['tobaccoSalesPermitNumber'] as String?,
      tobaccoSalesPermitExpiry: json['tobaccoSalesPermitExpiry'] != null
          ? DateTime.parse(json['tobaccoSalesPermitExpiry'])
          : null,
      receivingHours: json['receivingHours'] as String?,
      dispatchHours: json['dispatchHours'] as String?,
      storageCapacityPallets: json['storageCapacityPallets'] as int?,
      hasClimateControl: json['hasClimateControl'] as bool? ?? false,
      climateControlTempMin:
          (json['climateControlTempMin'] as num?)?.toDouble(),
      climateControlTempMax:
          (json['climateControlTempMax'] as num?)?.toDouble(),
      climateControlHumidityMin:
          (json['climateControlHumidityMin'] as num?)?.toDouble(),
      climateControlHumidityMax:
          (json['climateControlHumidityMax'] as num?)?.toDouble(),
      responsiblePersonName: json['responsiblePersonName'] as String?,
      responsiblePersonEmail: json['responsiblePersonEmail'] as String?,
      responsiblePersonPhone: json['responsiblePersonPhone'] as String?,
      qualityManagerName: json['qualityManagerName'] as String?,
      qualityManagerEmail: json['qualityManagerEmail'] as String?,
      qualityManagerPhone: json['qualityManagerPhone'] as String?,
      regulatoryAffairsContactName:
          json['regulatoryAffairsContactName'] as String?,
      regulatoryAffairsContactEmail:
          json['regulatoryAffairsContactEmail'] as String?,
      regulatoryAffairsContactPhone:
          json['regulatoryAffairsContactPhone'] as String?,
      whoFctcPartyCountry: json['whoFctcPartyCountry'] as String?,
      ukTobaccoTraceabilityId: json['ukTobaccoTraceabilityId'] as String?,
      canadaTobaccoLicenseId: json['canadaTobaccoLicenseId'] as String?,
      australiaTobaccoLicenseId: json['australiaTobaccoLicenseId'] as String?,
      additionalLicenses: (json['additionalLicenses'] as List<dynamic>?)
          ?.map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
      authorizedBrands: (json['authorizedBrands'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      inspectionHistory: (json['inspectionHistory'] as List<dynamic>?)
          ?.map((e) => Map<String, dynamic>.from(e as Map))
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
      if (euEconomicOperatorId != null)
        'euEconomicOperatorId': euEconomicOperatorId,
      if (euFacilityId != null) 'euFacilityId': euFacilityId,
      'euTpdRegistered': euTpdRegistered,
      if (euTpdRegistrationDate != null)
        'euTpdRegistrationDate': euTpdRegistrationDate!.toIso8601String(),
      'euFirstRetailOutlet': euFirstRetailOutlet,
      if (euImporterId != null) 'euImporterId': euImporterId,
      if (taxStampAuthorityId != null)
        'taxStampAuthorityId': taxStampAuthorityId,
      if (taxStampAuthorityName != null)
        'taxStampAuthorityName': taxStampAuthorityName,
      if (taxStampAuthorizationDate != null)
        'taxStampAuthorizationDate':
            taxStampAuthorizationDate!.toIso8601String(),
      if (taxStampAuthorizationExpiry != null)
        'taxStampAuthorizationExpiry':
            taxStampAuthorizationExpiry!.toIso8601String(),
      if (authorizedTaxStampTypes != null)
        'authorizedTaxStampTypes': authorizedTaxStampTypes,
      if (fdaTobaccoEstablishmentId != null)
        'fdaTobaccoEstablishmentId': fdaTobaccoEstablishmentId,
      if (fdaTobaccoRegistrationDate != null)
        'fdaTobaccoRegistrationDate':
            fdaTobaccoRegistrationDate!.toIso8601String(),
      if (fdaTobaccoRegistrationExpiry != null)
        'fdaTobaccoRegistrationExpiry':
            fdaTobaccoRegistrationExpiry!.toIso8601String(),
      if (fdaPmtaSiteListing != null) 'fdaPmtaSiteListing': fdaPmtaSiteListing,
      if (fdaSeSiteListing != null) 'fdaSeSiteListing': fdaSeSiteListing,
      'pactActRegistered': pactActRegistered,
      if (pactActRegistrationNumber != null)
        'pactActRegistrationNumber': pactActRegistrationNumber,
      if (pactActRegistrationDate != null)
        'pactActRegistrationDate': pactActRegistrationDate!.toIso8601String(),
      if (pactAtfLicenseNumber != null)
        'pactAtfLicenseNumber': pactAtfLicenseNumber,
      if (stateTobaccoLicenseNumber != null)
        'stateTobaccoLicenseNumber': stateTobaccoLicenseNumber,
      if (stateTobaccoLicenseType != null)
        'stateTobaccoLicenseType': stateTobaccoLicenseType,
      if (stateTobaccoLicenseExpiry != null)
        'stateTobaccoLicenseExpiry':
            stateTobaccoLicenseExpiry!.toIso8601String(),
      if (stateTobaccoLicenseState != null)
        'stateTobaccoLicenseState': stateTobaccoLicenseState,
      if (tobaccoWholesaleLicenseNumber != null)
        'tobaccoWholesaleLicenseNumber': tobaccoWholesaleLicenseNumber,
      if (tobaccoWholesaleLicenseExpiry != null)
        'tobaccoWholesaleLicenseExpiry':
            tobaccoWholesaleLicenseExpiry!.toIso8601String(),
      'masterSettlementAgreementParticipant':
          masterSettlementAgreementParticipant,
      if (msaEscrowAccountStatus != null)
        'msaEscrowAccountStatus': msaEscrowAccountStatus,
      'isManufacturingFacility': isManufacturingFacility,
      if (manufacturingLicenseNumber != null)
        'manufacturingLicenseNumber': manufacturingLicenseNumber,
      if (manufacturingLicenseExpiry != null)
        'manufacturingLicenseExpiry':
            manufacturingLicenseExpiry!.toIso8601String(),
      if (manufacturingCapacityUnitsPerDay != null)
        'manufacturingCapacityUnitsPerDay': manufacturingCapacityUnitsPerDay,
      if (tobaccoTypesManufactured != null)
        'tobaccoTypesManufactured': tobaccoTypesManufactured,
      'isUiIssuer': isUiIssuer,
      if (uiIssuerRegistrationId != null)
        'uiIssuerRegistrationId': uiIssuerRegistrationId,
      if (uiSystemProvider != null) 'uiSystemProvider': uiSystemProvider,
      if (antiTamperingDeviceProvider != null)
        'antiTamperingDeviceProvider': antiTamperingDeviceProvider,
      if (customsRegistrationNumber != null)
        'customsRegistrationNumber': customsRegistrationNumber,
      'authorizedEconomicOperator': authorizedEconomicOperator,
      if (aeoCertificateNumber != null)
        'aeoCertificateNumber': aeoCertificateNumber,
      if (aeoCertificateExpiry != null)
        'aeoCertificateExpiry': aeoCertificateExpiry!.toIso8601String(),
      'bondedWarehouse': bondedWarehouse,
      if (bondedWarehouseLicenseNumber != null)
        'bondedWarehouseLicenseNumber': bondedWarehouseLicenseNumber,
      'hasSecurityFeatures': hasSecurityFeatures,
      'videoSurveillance': videoSurveillance,
      'accessControlSystem': accessControlSystem,
      if (inventoryTrackingSystem != null)
        'inventoryTrackingSystem': inventoryTrackingSystem,
      'isRetailLocation': isRetailLocation,
      if (ageVerificationSystem != null)
        'ageVerificationSystem': ageVerificationSystem,
      if (tobaccoSalesPermitNumber != null)
        'tobaccoSalesPermitNumber': tobaccoSalesPermitNumber,
      if (tobaccoSalesPermitExpiry != null)
        'tobaccoSalesPermitExpiry': tobaccoSalesPermitExpiry!.toIso8601String(),
      if (receivingHours != null) 'receivingHours': receivingHours,
      if (dispatchHours != null) 'dispatchHours': dispatchHours,
      if (storageCapacityPallets != null)
        'storageCapacityPallets': storageCapacityPallets,
      'hasClimateControl': hasClimateControl,
      if (climateControlTempMin != null)
        'climateControlTempMin': climateControlTempMin,
      if (climateControlTempMax != null)
        'climateControlTempMax': climateControlTempMax,
      if (climateControlHumidityMin != null)
        'climateControlHumidityMin': climateControlHumidityMin,
      if (climateControlHumidityMax != null)
        'climateControlHumidityMax': climateControlHumidityMax,
      if (responsiblePersonName != null)
        'responsiblePersonName': responsiblePersonName,
      if (responsiblePersonEmail != null)
        'responsiblePersonEmail': responsiblePersonEmail,
      if (responsiblePersonPhone != null)
        'responsiblePersonPhone': responsiblePersonPhone,
      if (qualityManagerName != null) 'qualityManagerName': qualityManagerName,
      if (qualityManagerEmail != null)
        'qualityManagerEmail': qualityManagerEmail,
      if (qualityManagerPhone != null)
        'qualityManagerPhone': qualityManagerPhone,
      if (regulatoryAffairsContactName != null)
        'regulatoryAffairsContactName': regulatoryAffairsContactName,
      if (regulatoryAffairsContactEmail != null)
        'regulatoryAffairsContactEmail': regulatoryAffairsContactEmail,
      if (regulatoryAffairsContactPhone != null)
        'regulatoryAffairsContactPhone': regulatoryAffairsContactPhone,
      if (whoFctcPartyCountry != null)
        'whoFctcPartyCountry': whoFctcPartyCountry,
      if (ukTobaccoTraceabilityId != null)
        'ukTobaccoTraceabilityId': ukTobaccoTraceabilityId,
      if (canadaTobaccoLicenseId != null)
        'canadaTobaccoLicenseId': canadaTobaccoLicenseId,
      if (australiaTobaccoLicenseId != null)
        'australiaTobaccoLicenseId': australiaTobaccoLicenseId,
      if (additionalLicenses != null) 'additionalLicenses': additionalLicenses,
      if (authorizedBrands != null) 'authorizedBrands': authorizedBrands,
      if (inspectionHistory != null) 'inspectionHistory': inspectionHistory,
    };
  }

  GLNTobaccoExtension copyWith({
    int? id,
    int? glnId,
    String? glnCode,
    String? locationName,
    String? euEconomicOperatorId,
    String? euFacilityId,
    bool? euTpdRegistered,
    DateTime? euTpdRegistrationDate,
    bool? euFirstRetailOutlet,
    String? euImporterId,
    String? taxStampAuthorityId,
    String? taxStampAuthorityName,
    DateTime? taxStampAuthorizationDate,
    DateTime? taxStampAuthorizationExpiry,
    String? authorizedTaxStampTypes,
    String? fdaTobaccoEstablishmentId,
    DateTime? fdaTobaccoRegistrationDate,
    DateTime? fdaTobaccoRegistrationExpiry,
    String? fdaPmtaSiteListing,
    String? fdaSeSiteListing,
    bool? pactActRegistered,
    String? pactActRegistrationNumber,
    DateTime? pactActRegistrationDate,
    String? pactAtfLicenseNumber,
    String? stateTobaccoLicenseNumber,
    String? stateTobaccoLicenseType,
    DateTime? stateTobaccoLicenseExpiry,
    String? stateTobaccoLicenseState,
    String? tobaccoWholesaleLicenseNumber,
    DateTime? tobaccoWholesaleLicenseExpiry,
    bool? masterSettlementAgreementParticipant,
    String? msaEscrowAccountStatus,
    bool? isManufacturingFacility,
    String? manufacturingLicenseNumber,
    DateTime? manufacturingLicenseExpiry,
    int? manufacturingCapacityUnitsPerDay,
    String? tobaccoTypesManufactured,
    bool? isUiIssuer,
    String? uiIssuerRegistrationId,
    String? uiSystemProvider,
    String? antiTamperingDeviceProvider,
    String? customsRegistrationNumber,
    bool? authorizedEconomicOperator,
    String? aeoCertificateNumber,
    DateTime? aeoCertificateExpiry,
    bool? bondedWarehouse,
    String? bondedWarehouseLicenseNumber,
    bool? hasSecurityFeatures,
    bool? videoSurveillance,
    bool? accessControlSystem,
    String? inventoryTrackingSystem,
    bool? isRetailLocation,
    String? ageVerificationSystem,
    String? tobaccoSalesPermitNumber,
    DateTime? tobaccoSalesPermitExpiry,
    String? receivingHours,
    String? dispatchHours,
    int? storageCapacityPallets,
    bool? hasClimateControl,
    double? climateControlTempMin,
    double? climateControlTempMax,
    double? climateControlHumidityMin,
    double? climateControlHumidityMax,
    String? responsiblePersonName,
    String? responsiblePersonEmail,
    String? responsiblePersonPhone,
    String? qualityManagerName,
    String? qualityManagerEmail,
    String? qualityManagerPhone,
    String? regulatoryAffairsContactName,
    String? regulatoryAffairsContactEmail,
    String? regulatoryAffairsContactPhone,
    String? whoFctcPartyCountry,
    String? ukTobaccoTraceabilityId,
    String? canadaTobaccoLicenseId,
    String? australiaTobaccoLicenseId,
    List<Map<String, dynamic>>? additionalLicenses,
    List<String>? authorizedBrands,
    List<Map<String, dynamic>>? inspectionHistory,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GLNTobaccoExtension(
      id: id ?? this.id,
      glnId: glnId ?? this.glnId,
      glnCode: glnCode ?? this.glnCode,
      locationName: locationName ?? this.locationName,
      euEconomicOperatorId: euEconomicOperatorId ?? this.euEconomicOperatorId,
      euFacilityId: euFacilityId ?? this.euFacilityId,
      euTpdRegistered: euTpdRegistered ?? this.euTpdRegistered,
      euTpdRegistrationDate:
          euTpdRegistrationDate ?? this.euTpdRegistrationDate,
      euFirstRetailOutlet: euFirstRetailOutlet ?? this.euFirstRetailOutlet,
      euImporterId: euImporterId ?? this.euImporterId,
      taxStampAuthorityId: taxStampAuthorityId ?? this.taxStampAuthorityId,
      taxStampAuthorityName:
          taxStampAuthorityName ?? this.taxStampAuthorityName,
      taxStampAuthorizationDate:
          taxStampAuthorizationDate ?? this.taxStampAuthorizationDate,
      taxStampAuthorizationExpiry:
          taxStampAuthorizationExpiry ?? this.taxStampAuthorizationExpiry,
      authorizedTaxStampTypes:
          authorizedTaxStampTypes ?? this.authorizedTaxStampTypes,
      fdaTobaccoEstablishmentId:
          fdaTobaccoEstablishmentId ?? this.fdaTobaccoEstablishmentId,
      fdaTobaccoRegistrationDate:
          fdaTobaccoRegistrationDate ?? this.fdaTobaccoRegistrationDate,
      fdaTobaccoRegistrationExpiry:
          fdaTobaccoRegistrationExpiry ?? this.fdaTobaccoRegistrationExpiry,
      fdaPmtaSiteListing: fdaPmtaSiteListing ?? this.fdaPmtaSiteListing,
      fdaSeSiteListing: fdaSeSiteListing ?? this.fdaSeSiteListing,
      pactActRegistered: pactActRegistered ?? this.pactActRegistered,
      pactActRegistrationNumber:
          pactActRegistrationNumber ?? this.pactActRegistrationNumber,
      pactActRegistrationDate:
          pactActRegistrationDate ?? this.pactActRegistrationDate,
      pactAtfLicenseNumber: pactAtfLicenseNumber ?? this.pactAtfLicenseNumber,
      stateTobaccoLicenseNumber:
          stateTobaccoLicenseNumber ?? this.stateTobaccoLicenseNumber,
      stateTobaccoLicenseType:
          stateTobaccoLicenseType ?? this.stateTobaccoLicenseType,
      stateTobaccoLicenseExpiry:
          stateTobaccoLicenseExpiry ?? this.stateTobaccoLicenseExpiry,
      stateTobaccoLicenseState:
          stateTobaccoLicenseState ?? this.stateTobaccoLicenseState,
      tobaccoWholesaleLicenseNumber:
          tobaccoWholesaleLicenseNumber ?? this.tobaccoWholesaleLicenseNumber,
      tobaccoWholesaleLicenseExpiry:
          tobaccoWholesaleLicenseExpiry ?? this.tobaccoWholesaleLicenseExpiry,
      masterSettlementAgreementParticipant:
          masterSettlementAgreementParticipant ??
              this.masterSettlementAgreementParticipant,
      msaEscrowAccountStatus:
          msaEscrowAccountStatus ?? this.msaEscrowAccountStatus,
      isManufacturingFacility:
          isManufacturingFacility ?? this.isManufacturingFacility,
      manufacturingLicenseNumber:
          manufacturingLicenseNumber ?? this.manufacturingLicenseNumber,
      manufacturingLicenseExpiry:
          manufacturingLicenseExpiry ?? this.manufacturingLicenseExpiry,
      manufacturingCapacityUnitsPerDay: manufacturingCapacityUnitsPerDay ??
          this.manufacturingCapacityUnitsPerDay,
      tobaccoTypesManufactured:
          tobaccoTypesManufactured ?? this.tobaccoTypesManufactured,
      isUiIssuer: isUiIssuer ?? this.isUiIssuer,
      uiIssuerRegistrationId:
          uiIssuerRegistrationId ?? this.uiIssuerRegistrationId,
      uiSystemProvider: uiSystemProvider ?? this.uiSystemProvider,
      antiTamperingDeviceProvider:
          antiTamperingDeviceProvider ?? this.antiTamperingDeviceProvider,
      customsRegistrationNumber:
          customsRegistrationNumber ?? this.customsRegistrationNumber,
      authorizedEconomicOperator:
          authorizedEconomicOperator ?? this.authorizedEconomicOperator,
      aeoCertificateNumber: aeoCertificateNumber ?? this.aeoCertificateNumber,
      aeoCertificateExpiry: aeoCertificateExpiry ?? this.aeoCertificateExpiry,
      bondedWarehouse: bondedWarehouse ?? this.bondedWarehouse,
      bondedWarehouseLicenseNumber:
          bondedWarehouseLicenseNumber ?? this.bondedWarehouseLicenseNumber,
      hasSecurityFeatures: hasSecurityFeatures ?? this.hasSecurityFeatures,
      videoSurveillance: videoSurveillance ?? this.videoSurveillance,
      accessControlSystem: accessControlSystem ?? this.accessControlSystem,
      inventoryTrackingSystem:
          inventoryTrackingSystem ?? this.inventoryTrackingSystem,
      isRetailLocation: isRetailLocation ?? this.isRetailLocation,
      ageVerificationSystem:
          ageVerificationSystem ?? this.ageVerificationSystem,
      tobaccoSalesPermitNumber:
          tobaccoSalesPermitNumber ?? this.tobaccoSalesPermitNumber,
      tobaccoSalesPermitExpiry:
          tobaccoSalesPermitExpiry ?? this.tobaccoSalesPermitExpiry,
      receivingHours: receivingHours ?? this.receivingHours,
      dispatchHours: dispatchHours ?? this.dispatchHours,
      storageCapacityPallets:
          storageCapacityPallets ?? this.storageCapacityPallets,
      hasClimateControl: hasClimateControl ?? this.hasClimateControl,
      climateControlTempMin:
          climateControlTempMin ?? this.climateControlTempMin,
      climateControlTempMax:
          climateControlTempMax ?? this.climateControlTempMax,
      climateControlHumidityMin:
          climateControlHumidityMin ?? this.climateControlHumidityMin,
      climateControlHumidityMax:
          climateControlHumidityMax ?? this.climateControlHumidityMax,
      responsiblePersonName:
          responsiblePersonName ?? this.responsiblePersonName,
      responsiblePersonEmail:
          responsiblePersonEmail ?? this.responsiblePersonEmail,
      responsiblePersonPhone:
          responsiblePersonPhone ?? this.responsiblePersonPhone,
      qualityManagerName: qualityManagerName ?? this.qualityManagerName,
      qualityManagerEmail: qualityManagerEmail ?? this.qualityManagerEmail,
      qualityManagerPhone: qualityManagerPhone ?? this.qualityManagerPhone,
      regulatoryAffairsContactName:
          regulatoryAffairsContactName ?? this.regulatoryAffairsContactName,
      regulatoryAffairsContactEmail:
          regulatoryAffairsContactEmail ?? this.regulatoryAffairsContactEmail,
      regulatoryAffairsContactPhone:
          regulatoryAffairsContactPhone ?? this.regulatoryAffairsContactPhone,
      whoFctcPartyCountry: whoFctcPartyCountry ?? this.whoFctcPartyCountry,
      ukTobaccoTraceabilityId:
          ukTobaccoTraceabilityId ?? this.ukTobaccoTraceabilityId,
      canadaTobaccoLicenseId:
          canadaTobaccoLicenseId ?? this.canadaTobaccoLicenseId,
      australiaTobaccoLicenseId:
          australiaTobaccoLicenseId ?? this.australiaTobaccoLicenseId,
      additionalLicenses: additionalLicenses ?? this.additionalLicenses,
      authorizedBrands: authorizedBrands ?? this.authorizedBrands,
      inspectionHistory: inspectionHistory ?? this.inspectionHistory,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if this location is EU TPD compliant
  bool get isEuCompliant =>
      euTpdRegistered &&
      euEconomicOperatorId != null &&
      euEconomicOperatorId!.isNotEmpty;

  /// Check if PACT Act compliant
  bool get isPactActCompliant =>
      pactActRegistered &&
      pactActRegistrationNumber != null &&
      pactActRegistrationNumber!.isNotEmpty;

  /// Check if FDA tobacco registration is valid
  bool get isFdaTobaccoRegistrationValid {
    if (fdaTobaccoRegistrationExpiry == null) {
      return fdaTobaccoEstablishmentId != null;
    }
    return fdaTobaccoRegistrationExpiry!.isAfter(DateTime.now());
  }

  /// Check if tax stamp authorization is valid
  bool get isTaxStampAuthorizationValid {
    if (taxStampAuthorizationExpiry == null) return taxStampAuthorityId != null;
    return taxStampAuthorizationExpiry!.isAfter(DateTime.now());
  }

  /// Check if can issue unique identifiers
  bool get canIssueUniqueIdentifiers =>
      isUiIssuer && uiIssuerRegistrationId != null;

  /// Check if has secure facility
  bool get hasSecureFacility =>
      hasSecurityFeatures || (videoSurveillance && accessControlSystem);

  /// Check if AEO certification is valid
  bool get isAeoValid {
    if (!authorizedEconomicOperator) return false;
    if (aeoCertificateExpiry == null) return aeoCertificateNumber != null;
    return aeoCertificateExpiry!.isAfter(DateTime.now());
  }

  @override
  List<Object?> get props => [
        id,
        glnId,
        glnCode,
        euEconomicOperatorId,
        fdaTobaccoEstablishmentId,
        pactActRegistrationNumber,
      ];
}
