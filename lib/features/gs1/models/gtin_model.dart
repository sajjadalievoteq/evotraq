import 'package:equatable/equatable.dart';

/// Represents a Global Trade Item Number (GTIN)
class GTIN extends Equatable {
  final String gtinCode;
  final String productName;
  final String? manufacturer;
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
      isPharmaceuticalProduct: isPharmaceuticalProduct ?? this.isPharmaceuticalProduct,
    );
  }
  
  /// Convert GTIN to JSON format
  Map<String, dynamic> toJson() {
    return {
      'gtin': gtinCode, // Use 'gtin' field name expected by backend
      'productName': productName,
      if (manufacturer != null) 'manufacturer': manufacturer,
      if (packagingLevel != null) 'packagingLevel': packagingLevel,
      if (packSize != null) 'packSize': packSize,
      if (status != null) 'productStatus': status, // Use 'productStatus' expected by backend
      if (registrationNumber != null) 'marketingAuthorizationNumber': registrationNumber, // Use field name expected by backend
      if (parentGTIN != null) 'parentGTIN': parentGTIN,
      if (marketAuthorization != null) 'marketAuthorizations': {
        'DEFAULT': marketAuthorization // Convert to map format expected by backend
      },
      if (registrationDate != null) 'marketingAuthorizationDate': _formatDateWithTimezone(registrationDate!),
      if (expirationDate != null) 'discontinuationDate': _formatDateWithTimezone(expirationDate!),
      if (authorizationExpiry != null && registrationDate == null) 'marketingAuthorizationDate': _formatDateWithTimezone(authorizationExpiry!),
      // Industry extension flags are read-only from backend (set by triggers), don't send them
    };
  }

  /// Create GTIN from JSON
  factory GTIN.fromJson(Map<String, dynamic> json) {
    // Debug print to see what date fields we're receiving
    print('GTIN fromJson - date fields: marketingAuthorizationDate=${json['marketingAuthorizationDate']}, discontinuationDate=${json['discontinuationDate']}, expirationDate=${json['expirationDate']}');
    
    // Handle marketAuthorizations map from backend
    String? marketAuth;
    if (json['marketAuthorizations'] != null && json['marketAuthorizations'] is Map) {
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
      packagingLevel: json['packagingLevel'],
      packSize: json['packSize'] != null ? int.tryParse(json['packSize'].toString()) : null,
      status: json['status'] ?? json['productStatus'], // Handle both field names
      registrationNumber: json['registrationNumber'] ?? json['marketingAuthorizationNumber'],
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