import 'package:equatable/equatable.dart';

/// Represents a Global Trade Item Number (GTIN)
class GTIN extends Equatable {
  final String gtinCode;
  final String productName;
  final String? manufacturer;
  // Derived identification (chips)
  final int? gs1CompanyPrefixLength;
  final String? gs1CompanyPrefix;
  final String? itemReference;

  // Core spec fields (Groups 2–9)
  final String? functionalName;
  final String? tradeItemDescription;
  final String? packagingType;
  final String? unitOfMeasure;
  final String? unitDescriptor;

  final bool? isBaseUnit;
  final bool? isConsumerUnit;
  final bool? isOrderableUnit;
  final bool? isDespatchUnit;
  final bool? isInvoiceUnit;
  final bool? isVariableUnit;

  final int? quantityOfChildren;
  final int? totalQtyNextLower;
  final String? nextLowerLevelGtin;
  final int? nextLowerLevelQuantity;

  final double? netContentValue;
  final String? netContentUom;
  final double? grossWeightValue;
  final String? grossWeightUom;
  final double? heightValue;
  final double? widthValue;
  final double? depthValue;
  final String? dimUom;

  final String? gpcBrickCode;
  final String? targetMarketCountry;
  final String? countryOfOrigin;

  final String? informationProviderGln;
  final String? informationProviderName;
  final String? manufacturerGln;

  final String? tradeItemStatus; // ADD/CHN/COR
  final DateTime? effectiveDate;
  final DateTime? startAvailDate;
  final DateTime? endAvailDate;
  final DateTime? publicationDate; // date-only in backend; keep DateTime for simplicity

  final String? hasBatchNumberIndicator;
  final String? hasSerialNumberIndicator;

  final String? createdBy;
  final String? updatedBy;

  final DateTime? launchDate;
  final int? quantityPerParent;
  final String? packagingLevel; // Primary, Secondary, Tertiary, Case, Pallet
  final int? packSize;
  final String? status; // Active, Inactive, Withdrawn, Suspended
  final String? registrationNumber;
  final String? parentGTIN; // For packaging hierarchy
  final String? marketAuthorization;
  final String? authorizationCountry;
  final DateTime? registrationDate;
  final DateTime? expirationDate;
  final DateTime? authorizationExpiry;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Flag indicating if this GTIN is a tobacco product.
  /// Used for seamless tobacco workflow integration in EPCIS events.
  final bool isTobaccoProduct;

  /// Flag indicating if this GTIN is a pharmaceutical product.
  /// Used for pharmaceutical-specific workflows.
  final bool isPharmaceuticalProduct;

  const GTIN({
    required this.gtinCode,
    required this.productName,
    this.manufacturer,
    this.gs1CompanyPrefixLength,
    this.gs1CompanyPrefix,
    this.itemReference,
    this.functionalName,
    this.tradeItemDescription,
    this.packagingType,
    this.unitOfMeasure,
    this.unitDescriptor,
    this.isBaseUnit,
    this.isConsumerUnit,
    this.isOrderableUnit,
    this.isDespatchUnit,
    this.isInvoiceUnit,
    this.isVariableUnit,
    this.quantityOfChildren,
    this.totalQtyNextLower,
    this.nextLowerLevelGtin,
    this.nextLowerLevelQuantity,
    this.netContentValue,
    this.netContentUom,
    this.grossWeightValue,
    this.grossWeightUom,
    this.heightValue,
    this.widthValue,
    this.depthValue,
    this.dimUom,
    this.gpcBrickCode,
    this.targetMarketCountry,
    this.countryOfOrigin,
    this.informationProviderGln,
    this.informationProviderName,
    this.manufacturerGln,
    this.tradeItemStatus,
    this.effectiveDate,
    this.startAvailDate,
    this.endAvailDate,
    this.publicationDate,
    this.hasBatchNumberIndicator,
    this.hasSerialNumberIndicator,
    this.createdBy,
    this.updatedBy,
    this.launchDate,
    this.quantityPerParent,
    this.packagingLevel,
    this.packSize,
    this.status,
    this.registrationNumber,
    this.parentGTIN,
    this.marketAuthorization,
    this.authorizationCountry,
    this.registrationDate,
    this.expirationDate,
    this.authorizationExpiry,
    this.createdAt,
    this.updatedAt,
    this.isTobaccoProduct = false,
    this.isPharmaceuticalProduct = false,
  });

  @override
  List<Object?> get props => [
        gtinCode,
        productName,
        manufacturer,
        gs1CompanyPrefixLength,
        gs1CompanyPrefix,
        itemReference,
        functionalName,
        tradeItemDescription,
        packagingType,
        unitOfMeasure,
        unitDescriptor,
        isBaseUnit,
        isConsumerUnit,
        isOrderableUnit,
        isDespatchUnit,
        isInvoiceUnit,
        isVariableUnit,
        quantityOfChildren,
        totalQtyNextLower,
        nextLowerLevelGtin,
        nextLowerLevelQuantity,
        netContentValue,
        netContentUom,
        grossWeightValue,
        grossWeightUom,
        heightValue,
        widthValue,
        depthValue,
        dimUom,
        gpcBrickCode,
        targetMarketCountry,
        countryOfOrigin,
        informationProviderGln,
        informationProviderName,
        manufacturerGln,
        tradeItemStatus,
        effectiveDate,
        startAvailDate,
        endAvailDate,
        publicationDate,
        hasBatchNumberIndicator,
        hasSerialNumberIndicator,
        createdBy,
        updatedBy,
        launchDate,
        quantityPerParent,
        packagingLevel,
        packSize,
        status,
        registrationNumber,
        parentGTIN,
        marketAuthorization,
        authorizationCountry,
        registrationDate,
        expirationDate,
        authorizationExpiry,
        createdAt,
        updatedAt,
        isTobaccoProduct,
        isPharmaceuticalProduct,
      ];

  /// Create a copy of this GTIN with updated fields
  GTIN copyWith({
    String? gtinCode,
    String? productName,
    String? manufacturer,
    int? gs1CompanyPrefixLength,
    String? gs1CompanyPrefix,
    String? itemReference,
    String? functionalName,
    String? tradeItemDescription,
    String? packagingType,
    String? unitOfMeasure,
    String? unitDescriptor,
    bool? isBaseUnit,
    bool? isConsumerUnit,
    bool? isOrderableUnit,
    bool? isDespatchUnit,
    bool? isInvoiceUnit,
    bool? isVariableUnit,
    int? quantityOfChildren,
    int? totalQtyNextLower,
    String? nextLowerLevelGtin,
    int? nextLowerLevelQuantity,
    double? netContentValue,
    String? netContentUom,
    double? grossWeightValue,
    String? grossWeightUom,
    double? heightValue,
    double? widthValue,
    double? depthValue,
    String? dimUom,
    String? gpcBrickCode,
    String? targetMarketCountry,
    String? countryOfOrigin,
    String? informationProviderGln,
    String? informationProviderName,
    String? manufacturerGln,
    String? tradeItemStatus,
    DateTime? effectiveDate,
    DateTime? startAvailDate,
    DateTime? endAvailDate,
    DateTime? publicationDate,
    String? hasBatchNumberIndicator,
    String? hasSerialNumberIndicator,
    String? createdBy,
    String? updatedBy,
    DateTime? launchDate,
    int? quantityPerParent,
    String? packagingLevel,
    int? packSize,
    String? status,
    String? registrationNumber,
    String? parentGTIN,
    String? marketAuthorization,
    String? authorizationCountry,
    DateTime? registrationDate,
    DateTime? expirationDate,
    DateTime? authorizationExpiry,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isTobaccoProduct,
    bool? isPharmaceuticalProduct,
  }) {
    return GTIN(
      gtinCode: gtinCode ?? this.gtinCode,
      productName: productName ?? this.productName,
      manufacturer: manufacturer ?? this.manufacturer,
      gs1CompanyPrefixLength:
          gs1CompanyPrefixLength ?? this.gs1CompanyPrefixLength,
      gs1CompanyPrefix: gs1CompanyPrefix ?? this.gs1CompanyPrefix,
      itemReference: itemReference ?? this.itemReference,
      functionalName: functionalName ?? this.functionalName,
      tradeItemDescription: tradeItemDescription ?? this.tradeItemDescription,
      packagingType: packagingType ?? this.packagingType,
      unitOfMeasure: unitOfMeasure ?? this.unitOfMeasure,
      unitDescriptor: unitDescriptor ?? this.unitDescriptor,
      isBaseUnit: isBaseUnit ?? this.isBaseUnit,
      isConsumerUnit: isConsumerUnit ?? this.isConsumerUnit,
      isOrderableUnit: isOrderableUnit ?? this.isOrderableUnit,
      isDespatchUnit: isDespatchUnit ?? this.isDespatchUnit,
      isInvoiceUnit: isInvoiceUnit ?? this.isInvoiceUnit,
      isVariableUnit: isVariableUnit ?? this.isVariableUnit,
      quantityOfChildren: quantityOfChildren ?? this.quantityOfChildren,
      totalQtyNextLower: totalQtyNextLower ?? this.totalQtyNextLower,
      nextLowerLevelGtin: nextLowerLevelGtin ?? this.nextLowerLevelGtin,
      nextLowerLevelQuantity:
          nextLowerLevelQuantity ?? this.nextLowerLevelQuantity,
      netContentValue: netContentValue ?? this.netContentValue,
      netContentUom: netContentUom ?? this.netContentUom,
      grossWeightValue: grossWeightValue ?? this.grossWeightValue,
      grossWeightUom: grossWeightUom ?? this.grossWeightUom,
      heightValue: heightValue ?? this.heightValue,
      widthValue: widthValue ?? this.widthValue,
      depthValue: depthValue ?? this.depthValue,
      dimUom: dimUom ?? this.dimUom,
      gpcBrickCode: gpcBrickCode ?? this.gpcBrickCode,
      targetMarketCountry: targetMarketCountry ?? this.targetMarketCountry,
      countryOfOrigin: countryOfOrigin ?? this.countryOfOrigin,
      informationProviderGln:
          informationProviderGln ?? this.informationProviderGln,
      informationProviderName:
          informationProviderName ?? this.informationProviderName,
      manufacturerGln: manufacturerGln ?? this.manufacturerGln,
      tradeItemStatus: tradeItemStatus ?? this.tradeItemStatus,
      effectiveDate: effectiveDate ?? this.effectiveDate,
      startAvailDate: startAvailDate ?? this.startAvailDate,
      endAvailDate: endAvailDate ?? this.endAvailDate,
      publicationDate: publicationDate ?? this.publicationDate,
      hasBatchNumberIndicator:
          hasBatchNumberIndicator ?? this.hasBatchNumberIndicator,
      hasSerialNumberIndicator:
          hasSerialNumberIndicator ?? this.hasSerialNumberIndicator,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      launchDate: launchDate ?? this.launchDate,
      quantityPerParent: quantityPerParent ?? this.quantityPerParent,
      packagingLevel: packagingLevel ?? this.packagingLevel,
      packSize: packSize ?? this.packSize,
      status: status ?? this.status,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      parentGTIN: parentGTIN ?? this.parentGTIN,
      marketAuthorization: marketAuthorization ?? this.marketAuthorization,
      authorizationCountry: authorizationCountry ?? this.authorizationCountry,
      registrationDate: registrationDate ?? this.registrationDate,
      expirationDate: expirationDate ?? this.expirationDate,
      authorizationExpiry: authorizationExpiry ?? this.authorizationExpiry,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isTobaccoProduct: isTobaccoProduct ?? this.isTobaccoProduct,
      isPharmaceuticalProduct:
          isPharmaceuticalProduct ?? this.isPharmaceuticalProduct,
    );
  }

  /// Convert GTIN to JSON format
  Map<String, dynamic> toJson() {
    return {
      'gtin': gtinCode, // Use 'gtin' field name expected by backend
      'productName': productName,
      // Backend `gtins.manufacturer` is NOT NULL; send empty string when the UI leaves it blank.
      'manufacturer': manufacturer ?? '',
      if (gs1CompanyPrefixLength != null)
        'gs1CompanyPrefixLength': gs1CompanyPrefixLength,
      if (gs1CompanyPrefix != null) 'gs1CompanyPrefix': gs1CompanyPrefix,
      if (itemReference != null) 'itemReference': itemReference,
      if (functionalName != null) 'functionalName': functionalName,
      if (tradeItemDescription != null)
        'tradeItemDescription': tradeItemDescription,
      if (packagingType != null) 'packagingType': packagingType,
      if (unitOfMeasure != null) 'unitOfMeasure': unitOfMeasure,
      if (unitDescriptor != null) 'unitDescriptor': unitDescriptor,
      if (isBaseUnit != null) 'isBaseUnit': isBaseUnit,
      if (isConsumerUnit != null) 'isConsumerUnit': isConsumerUnit,
      if (isOrderableUnit != null) 'isOrderableUnit': isOrderableUnit,
      if (isDespatchUnit != null) 'isDespatchUnit': isDespatchUnit,
      if (isInvoiceUnit != null) 'isInvoiceUnit': isInvoiceUnit,
      if (isVariableUnit != null) 'isVariableUnit': isVariableUnit,
      if (quantityOfChildren != null) 'quantityOfChildren': quantityOfChildren,
      if (totalQtyNextLower != null) 'totalQtyNextLower': totalQtyNextLower,
      if (nextLowerLevelGtin != null)
        'nextLowerLevelGtin': nextLowerLevelGtin,
      if (nextLowerLevelQuantity != null)
        'nextLowerLevelQuantity': nextLowerLevelQuantity,
      if (netContentValue != null) 'netContentValue': netContentValue,
      if (netContentUom != null) 'netContentUom': netContentUom,
      if (grossWeightValue != null) 'grossWeightValue': grossWeightValue,
      if (grossWeightUom != null) 'grossWeightUom': grossWeightUom,
      if (heightValue != null) 'heightValue': heightValue,
      if (widthValue != null) 'widthValue': widthValue,
      if (depthValue != null) 'depthValue': depthValue,
      if (dimUom != null) 'dimUom': dimUom,
      if (gpcBrickCode != null) 'gpcBrickCode': gpcBrickCode,
      if (targetMarketCountry != null)
        'targetMarketCountry': targetMarketCountry,
      if (countryOfOrigin != null) 'countryOfOrigin': countryOfOrigin,
      if (informationProviderGln != null)
        'informationProviderGln': informationProviderGln,
      if (informationProviderName != null)
        'informationProviderName': informationProviderName,
      if (manufacturerGln != null) 'manufacturerGln': manufacturerGln,
      if (tradeItemStatus != null) 'tradeItemStatus': tradeItemStatus,
      if (effectiveDate != null)
        'effectiveDate': _formatDateWithTimezone(effectiveDate!),
      if (startAvailDate != null)
        'startAvailDate': _formatDateWithTimezone(startAvailDate!),
      if (endAvailDate != null)
        'endAvailDate': _formatDateWithTimezone(endAvailDate!),
      if (publicationDate != null)
        'publicationDate': publicationDate!.toIso8601String().split('T').first,
      if (hasBatchNumberIndicator != null)
        'hasBatchNumberIndicator': hasBatchNumberIndicator,
      if (hasSerialNumberIndicator != null)
        'hasSerialNumberIndicator': hasSerialNumberIndicator,
      if (createdBy != null) 'createdBy': createdBy,
      if (updatedBy != null) 'updatedBy': updatedBy,
      if (launchDate != null)
        'launchDate': _formatDateWithTimezone(launchDate!),
      if (quantityPerParent != null) 'quantityPerParent': quantityPerParent,
      if (packagingLevel != null) 'packagingLevel': packagingLevel,
      if (packSize != null) 'packSize': packSize,
      if (status != null)
        'productStatus': status, // Use 'productStatus' expected by backend
      if (registrationNumber != null)
        'marketingAuthorizationNumber':
            registrationNumber, // Use field name expected by backend
      if (parentGTIN != null) 'parentGTIN': parentGTIN,
      if (marketAuthorization != null)
        'marketAuthorizations': {
          'DEFAULT': marketAuthorization // Convert to map format expected by backend
        },
      if (registrationDate != null)
        'marketingAuthorizationDate':
            _formatDateWithTimezone(registrationDate!),
      if (expirationDate != null)
        'discontinuationDate': _formatDateWithTimezone(expirationDate!),
      if (authorizationExpiry != null && registrationDate == null)
        'marketingAuthorizationDate':
            _formatDateWithTimezone(authorizationExpiry!),
      // Industry extension flags are read-only from backend (set by triggers), don't send them
    };
  }

  /// Create GTIN from JSON
  factory GTIN.fromJson(Map<String, dynamic> json) {
    // Handle marketAuthorizations map from backend
    String? marketAuth;
    if (json['marketAuthorizations'] != null &&
        json['marketAuthorizations'] is Map) {
      var auths = json['marketAuthorizations'] as Map;
      if (auths.isNotEmpty) {
        // Just take the first value from the map
        marketAuth = auths.values.first?.toString();
      }
    }

    return GTIN(
      gtinCode: json['gtinCode'] ?? json['gtin'] ?? '', // Handle both field names
      productName: json['productName'] ?? '',
      manufacturer: json['manufacturer'],
      gs1CompanyPrefixLength: json['gs1CompanyPrefixLength'] != null
          ? int.tryParse(json['gs1CompanyPrefixLength'].toString())
          : null,
      gs1CompanyPrefix: json['gs1CompanyPrefix'],
      itemReference: json['itemReference'],
      functionalName: json['functionalName'],
      tradeItemDescription: json['tradeItemDescription'],
      packagingType: json['packagingType'],
      unitOfMeasure: json['unitOfMeasure'],
      unitDescriptor: json['unitDescriptor'],
      isBaseUnit: json['isBaseUnit'] == null ? null : json['isBaseUnit'] == true,
      isConsumerUnit:
          json['isConsumerUnit'] == null ? null : json['isConsumerUnit'] == true,
      isOrderableUnit:
          json['isOrderableUnit'] == null ? null : json['isOrderableUnit'] == true,
      isDespatchUnit:
          json['isDespatchUnit'] == null ? null : json['isDespatchUnit'] == true,
      isInvoiceUnit:
          json['isInvoiceUnit'] == null ? null : json['isInvoiceUnit'] == true,
      isVariableUnit:
          json['isVariableUnit'] == null ? null : json['isVariableUnit'] == true,
      quantityOfChildren: json['quantityOfChildren'] != null
          ? int.tryParse(json['quantityOfChildren'].toString())
          : null,
      totalQtyNextLower: json['totalQtyNextLower'] != null
          ? int.tryParse(json['totalQtyNextLower'].toString())
          : null,
      nextLowerLevelGtin: json['nextLowerLevelGtin'],
      nextLowerLevelQuantity: json['nextLowerLevelQuantity'] != null
          ? int.tryParse(json['nextLowerLevelQuantity'].toString())
          : null,
      netContentValue: json['netContentValue'] != null
          ? double.tryParse(json['netContentValue'].toString())
          : null,
      netContentUom: json['netContentUom'],
      grossWeightValue: json['grossWeightValue'] != null
          ? double.tryParse(json['grossWeightValue'].toString())
          : null,
      grossWeightUom: json['grossWeightUom'],
      heightValue: json['heightValue'] != null
          ? double.tryParse(json['heightValue'].toString())
          : null,
      widthValue: json['widthValue'] != null
          ? double.tryParse(json['widthValue'].toString())
          : null,
      depthValue: json['depthValue'] != null
          ? double.tryParse(json['depthValue'].toString())
          : null,
      dimUom: json['dimUom'],
      gpcBrickCode: json['gpcBrickCode'],
      targetMarketCountry: json['targetMarketCountry'],
      countryOfOrigin: json['countryOfOrigin'],
      informationProviderGln: json['informationProviderGln'],
      informationProviderName: json['informationProviderName'],
      manufacturerGln: json['manufacturerGln'],
      tradeItemStatus: json['tradeItemStatus'],
      effectiveDate: json['effectiveDate'] != null
          ? DateTime.parse(json['effectiveDate'])
          : null,
      startAvailDate: json['startAvailDate'] != null
          ? DateTime.parse(json['startAvailDate'])
          : null,
      endAvailDate:
          json['endAvailDate'] != null ? DateTime.parse(json['endAvailDate']) : null,
      publicationDate: json['publicationDate'] != null
          ? DateTime.parse(json['publicationDate'])
          : null,
      hasBatchNumberIndicator: json['hasBatchNumberIndicator'],
      hasSerialNumberIndicator: json['hasSerialNumberIndicator'],
      createdBy: json['createdBy'],
      updatedBy: json['updatedBy'],
      launchDate:
          json['launchDate'] != null ? DateTime.parse(json['launchDate']) : null,
      quantityPerParent: json['quantityPerParent'] != null
          ? int.tryParse(json['quantityPerParent'].toString())
          : null,
      packagingLevel: json['packagingLevel'],
      packSize: json['packSize'] != null
          ? int.tryParse(json['packSize'].toString())
          : null,
      status: json['status'] ?? json['productStatus'], // Handle both field names
      registrationNumber:
          json['registrationNumber'] ?? json['marketingAuthorizationNumber'],
      parentGTIN: json['parentGTIN'],
      marketAuthorization: marketAuth ?? json['marketAuthorization'],
      authorizationCountry: json['authorizationCountry'],
      registrationDate: json['marketingAuthorizationDate'] != null
          ? DateTime.parse(json['marketingAuthorizationDate'])
          : json['registrationDate'] != null
              ? DateTime.parse(json['registrationDate'])
              : null,
      // Map discontinuationDate (backend) to expirationDate (frontend)
      expirationDate: json['discontinuationDate'] != null
          ? DateTime.parse(json['discontinuationDate'])
          : json['expirationDate'] != null
              ? DateTime.parse(json['expirationDate'])
              : null,
      authorizationExpiry: json['authorizationExpiry'] != null
          ? DateTime.parse(json['authorizationExpiry'])
          : json['marketingAuthorizationDate'] != null
              ? DateTime.parse(json['marketingAuthorizationDate'])
              : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      // Parse industry extension flags - automatically set by database triggers
      isTobaccoProduct: json['isTobaccoProduct'] == true,
      isPharmaceuticalProduct: json['isPharmaceuticalProduct'] == true,
    );
  }

  /// Packaging level enum values
  static const String packagingLevelItem = 'ITEM';
  static const String packagingLevelInnerPack = 'INNER_PACK';
  static const String packagingLevelPack = 'PACK';
  static const String packagingLevelCase = 'CASE';
  static const String packagingLevelPallet = 'PALLET';

  /// Product status enum values
  static const String statusActive = 'ACTIVE';
  static const String statusWithdrawn = 'WITHDRAWN';
  static const String statusSuspended = 'SUSPENDED';
  static const String statusDiscontinued = 'DISCONTINUED';

  // Helper method to format dates with timezone information
  String _formatDateWithTimezone(DateTime dateTime) {
    // Convert to format that Java's ZonedDateTime can parse
    // Example format: 2025-05-13T14:52:02.114Z or 2025-05-13T14:52:02.114+00:00
    final String iso8601String = dateTime.toIso8601String();

    // Check if the string already has timezone information
    if (iso8601String.endsWith('Z') || iso8601String.contains('+')) {
      return iso8601String;
    }

    // Add UTC timezone marker if missing
    return '${iso8601String}Z';
  }
}
