import 'package:equatable/equatable.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_pharmaceutical_extension_model.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_tobacco_extension_model.dart';
import 'package:traqtrace_app/data/models/epcis/geospatial_coordinates.dart';

enum LocationType {
  manufacturing_site,
  warehouse,
  distribution_center,
  pharmacy,
  hospital,
  wholesaler,
  clinic,
  regulatory_body,
  other
}

class GLN extends Equatable {
  final String glnCode;

  final String locationName;

  final String addressLine1;

  final String? addressLine2;

  final String city;

  final String stateProvince;

  final String postalCode;

  final String country;

  final String? contactName;

  final String? contactEmail;

  final String? contactPhone;

  final LocationType locationType;

  final GLN? parentGln;

  final String? licenseNumber;

  final String? licenseType;

  final DateTime? licenseValidFrom;

  final DateTime? licenseExpiry;

  final bool active;

  final GeospatialCoordinates? coordinates;

  final String? operatingStatus;

  final DateTime? effectiveFrom;
  final DateTime? effectiveTo;
  final DateTime? nonReuseUntil;

  final String? gs1CompanyPrefix;
  final String? locationReferenceDigits;
  final String? checkDigit;

  final int? gs1CompanyPrefixLength;

  final String? registeredLegalName;
  final String? tradingName;
  final String? leiCode;
  final String? taxRegistrationNumber;
  final String? countryOfIncorporationNumeric;
  final String? website;

  final String? digitalAddressType;
  final String? digitalAddressValue;

  final String? glnExtensionComponent;

  final String? industryClassification;
  final String? glnSource;

  final String? mobility;
  final String? mobileLocationIdentifier;

  final List<String> glnTypes;

  final List<String> supplyChainRoles;
  final List<String> locationRoles;

  final GLNPharmaceuticalExtension? pharmaceuticalExtension;

  final GLNTobaccoExtension? tobaccoExtension;

  const GLN({
    required this.glnCode,
    required this.locationName,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.stateProvince,
    required this.postalCode,
    required this.country,
    this.contactName,
    this.contactEmail,
    this.contactPhone,
    required this.locationType,
    this.parentGln,
    this.licenseNumber,
    this.licenseType,
    this.licenseValidFrom,
    this.licenseExpiry,
    required this.active,
    this.coordinates,
    this.operatingStatus,
    this.effectiveFrom,
    this.effectiveTo,
    this.nonReuseUntil,
    this.gs1CompanyPrefix,
    this.locationReferenceDigits,
    this.checkDigit,
    this.gs1CompanyPrefixLength,
    this.registeredLegalName,
    this.tradingName,
    this.leiCode,
    this.taxRegistrationNumber,
    this.countryOfIncorporationNumeric,
    this.website,
    this.digitalAddressType,
    this.digitalAddressValue,
    this.glnExtensionComponent,
    this.industryClassification,
    this.glnSource,
    this.mobility,
    this.mobileLocationIdentifier,
    this.glnTypes = const [],
    this.supplyChainRoles = const [],
    this.locationRoles = const [],
    this.pharmaceuticalExtension,
    this.tobaccoExtension,
  });

  factory GLN.fromCode(String code) {
    return GLN(
      glnCode: code,
      locationName: 'Unknown Location',
      addressLine1: 'Unknown Address',
      city: 'Unknown City',
      stateProvince: 'Unknown State',
      postalCode: 'Unknown',
      country: 'Unknown Country',
      locationType: LocationType.other,
      active: true,
      operatingStatus: 'ACTIVE',
      coordinates: null,
    );
  }

  GLN copyWith({
    String? glnCode,
    String? locationName,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? stateProvince,
    String? postalCode,
    String? country,
    String? contactName,
    String? contactEmail,
    String? contactPhone,
    LocationType? locationType,
    GLN? parentGln,
    String? licenseNumber,
    String? licenseType,
    DateTime? licenseValidFrom,
    DateTime? licenseExpiry,
    bool? active,
    GeospatialCoordinates? coordinates,
    String? operatingStatus,
    DateTime? effectiveFrom,
    DateTime? effectiveTo,
    DateTime? nonReuseUntil,
    String? gs1CompanyPrefix,
    String? locationReferenceDigits,
    String? checkDigit,
    int? gs1CompanyPrefixLength,
    String? registeredLegalName,
    String? tradingName,
    String? leiCode,
    String? taxRegistrationNumber,
    String? countryOfIncorporationNumeric,
    String? website,
    String? digitalAddressType,
    String? digitalAddressValue,
    String? glnExtensionComponent,
    String? industryClassification,
    String? glnSource,
    String? mobility,
    String? mobileLocationIdentifier,
    List<String>? glnTypes,
    List<String>? supplyChainRoles,
    List<String>? locationRoles,
    GLNPharmaceuticalExtension? pharmaceuticalExtension,
    GLNTobaccoExtension? tobaccoExtension,
  }) {
    return GLN(
      glnCode: glnCode ?? this.glnCode,
      locationName: locationName ?? this.locationName,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      city: city ?? this.city,
      stateProvince: stateProvince ?? this.stateProvince,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      contactName: contactName ?? this.contactName,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhone: contactPhone ?? this.contactPhone,
      locationType: locationType ?? this.locationType,
      parentGln: parentGln ?? this.parentGln,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      licenseType: licenseType ?? this.licenseType,
      licenseValidFrom: licenseValidFrom ?? this.licenseValidFrom,
      licenseExpiry: licenseExpiry ?? this.licenseExpiry,
      active: active ?? this.active,
      coordinates: coordinates ?? this.coordinates,
      operatingStatus: operatingStatus ?? this.operatingStatus,
      effectiveFrom: effectiveFrom ?? this.effectiveFrom,
      effectiveTo: effectiveTo ?? this.effectiveTo,
      nonReuseUntil: nonReuseUntil ?? this.nonReuseUntil,
      gs1CompanyPrefix: gs1CompanyPrefix ?? this.gs1CompanyPrefix,
      locationReferenceDigits:
          locationReferenceDigits ?? this.locationReferenceDigits,
      checkDigit: checkDigit ?? this.checkDigit,
      gs1CompanyPrefixLength:
          gs1CompanyPrefixLength ?? this.gs1CompanyPrefixLength,
      registeredLegalName: registeredLegalName ?? this.registeredLegalName,
      tradingName: tradingName ?? this.tradingName,
      leiCode: leiCode ?? this.leiCode,
      taxRegistrationNumber:
          taxRegistrationNumber ?? this.taxRegistrationNumber,
      countryOfIncorporationNumeric:
          countryOfIncorporationNumeric ?? this.countryOfIncorporationNumeric,
      website: website ?? this.website,
      digitalAddressType: digitalAddressType ?? this.digitalAddressType,
      digitalAddressValue: digitalAddressValue ?? this.digitalAddressValue,
      glnExtensionComponent:
          glnExtensionComponent ?? this.glnExtensionComponent,
      industryClassification:
          industryClassification ?? this.industryClassification,
      glnSource: glnSource ?? this.glnSource,
      mobility: mobility ?? this.mobility,
      mobileLocationIdentifier:
          mobileLocationIdentifier ?? this.mobileLocationIdentifier,
      glnTypes: glnTypes ?? this.glnTypes,
      supplyChainRoles: supplyChainRoles ?? this.supplyChainRoles,
      locationRoles: locationRoles ?? this.locationRoles,
      pharmaceuticalExtension:
          pharmaceuticalExtension ?? this.pharmaceuticalExtension,
      tobaccoExtension: tobaccoExtension ?? this.tobaccoExtension,
    );
  }

  factory GLN.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('id') && json.length == 1) {
      return GLN.fromCode(json['id'].toString());
    }

    if (json.containsKey('code') && json.length <= 3) {
      return GLN.fromCode(json['code'].toString());
    }

    if (json.containsKey('glnCode') && json['glnCode'] is String && json.length == 1) {
      return GLN.fromCode(json['glnCode'] as String);
    }

    if (json.isEmpty) {
      return GLN.fromCode('Unknown');
    }

    String? operatingStatus;
    if (json['operatingStatus'] != null &&
        json['operatingStatus'].toString().isNotEmpty) {
      operatingStatus = json['operatingStatus'].toString().toUpperCase();
    }

    bool active = true;
    if (json['locationStatus'] != null) {
      active = json['locationStatus'].toString().toLowerCase() == 'active';
    }
    operatingStatus ??= active ? 'ACTIVE' : 'INACTIVE';

    DateTime? licenseExpiry;
    if (json['licenseValidUntil'] != null &&
        json['licenseValidUntil'].toString().isNotEmpty) {
      try {
        licenseExpiry = DateTime.parse(json['licenseValidUntil'].toString());
      } catch (_) {}
    }

    DateTime? licenseValidFrom;
    if (json['licenseValidFrom'] != null &&
        json['licenseValidFrom'].toString().isNotEmpty) {
      try {
        licenseValidFrom =
            DateTime.parse(json['licenseValidFrom'].toString());
      } catch (_) {}
    }

    GeospatialCoordinates? coordinates;
    if (json['coordinates'] != null) {
      coordinates =
          GeospatialCoordinates.fromJson(json['coordinates'] as Map<String, dynamic>);
    } else if (json['geospatialCoordinates'] != null) {
      coordinates = GeospatialCoordinates.fromJson(
          json['geospatialCoordinates'] as Map<String, dynamic>);
    } else if (json['latitude'] != null && json['longitude'] != null) {
      coordinates = GeospatialCoordinates(
        latitude: double.parse(json['latitude'].toString()),
        longitude: double.parse(json['longitude'].toString()),
      );
    }

    GLN? parentGln;
    final parentRaw = json['parentGLN'];
    if (parentRaw != null && parentRaw.toString().isNotEmpty) {
      parentGln = GLN.fromCode(parentRaw.toString());
    }

    GLNPharmaceuticalExtension? pharmaceuticalExtension;
    final pharmaRaw = json['pharmaceuticalExtension'];
    if (pharmaRaw is Map<String, dynamic>) {
      pharmaceuticalExtension =
          GLNPharmaceuticalExtension.fromJson(pharmaRaw);
    }

    GLNTobaccoExtension? tobaccoExtension;
    final tobaccoRaw = json['tobaccoExtension'];
    if (tobaccoRaw is Map<String, dynamic>) {
      tobaccoExtension = GLNTobaccoExtension.fromJson(tobaccoRaw);
    }

    return GLN(
      glnCode: json['glnCode']?.toString() ?? '',
      locationName: json['locationName']?.toString() ?? '',
      addressLine1: json['addressLine1']?.toString() ?? '',
      addressLine2: json['addressLine2']?.toString(),
      city: json['city']?.toString() ?? '',
      stateProvince: json['stateProvince']?.toString() ?? '',
      postalCode: json['postalCode']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
      contactName: json['contactName']?.toString(),
      contactEmail: json['email']?.toString(),
      contactPhone: json['phone']?.toString(),
      locationType: _parseLocationType(json['locationType']?.toString()),
      parentGln: parentGln,
      licenseNumber: json['licenseNumber']?.toString(),
      licenseType: json['licenseType']?.toString(),
      licenseValidFrom: licenseValidFrom,
      licenseExpiry: licenseExpiry,
      active: active,
      coordinates: coordinates,
      operatingStatus: operatingStatus,
      effectiveFrom: _parseDate(json['effectiveFrom']),
      effectiveTo: _parseDate(json['effectiveTo']),
      nonReuseUntil: _parseDate(json['nonReuseUntil']),
      gs1CompanyPrefix: json['gs1CompanyPrefix']?.toString(),
      locationReferenceDigits: json['locationReference']?.toString() ??
          json['locationReferenceDigits']?.toString(),
      checkDigit: json['checkDigit']?.toString(),
      gs1CompanyPrefixLength: (json['gs1CompanyPrefixLength'] as num?)?.toInt(),
      registeredLegalName: json['registeredLegalName']?.toString(),
      tradingName: json['tradingName']?.toString(),
      leiCode: json['leiCode']?.toString(),
      taxRegistrationNumber: json['taxRegistrationNumber']?.toString(),
      countryOfIncorporationNumeric:
          json['countryOfIncorporation']?.toString() ??
              json['countryOfIncorporationNumeric']?.toString(),
      website: json['website']?.toString(),
      digitalAddressType: json['digitalAddressType']?.toString(),
      digitalAddressValue: json['digitalAddressValue']?.toString(),
      glnExtensionComponent:
          json['glnExtensionComponent']?.toString() ??
              json['extensionComponent']?.toString(),
      industryClassification: json['industryClassification']?.toString(),
      glnSource: json['glnSource']?.toString(),
      mobility: json['mobility']?.toString(),
      mobileLocationIdentifier:
          json['mobileLocationIdentifier']?.toString(),
      glnTypes: _stringListFromJson(json['glnTypes']),
      supplyChainRoles: _stringListFromJson(json['supplyChainRoles']),
      locationRoles: _stringListFromJson(json['locationRoles']),
      pharmaceuticalExtension: pharmaceuticalExtension,
      tobaccoExtension: tobaccoExtension,
    );
  }

  Map<String, dynamic> toJson() {
    final status = operatingStatus ?? (active ? 'ACTIVE' : 'INACTIVE');
    final locationStatus = status == 'ACTIVE' ? 'active' : 'inactive';

    final json = <String, dynamic>{
      'glnCode': glnCode,
      'locationName': locationName,
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'city': city,
      'stateProvince': stateProvince,
      'postalCode': postalCode,
      'country': country,
      'contactName': contactName ?? '',
      'email': contactEmail ?? '',
      'phone': contactPhone ?? '',
      'locationType': locationType.toString().split('.').last.toUpperCase(),
      'parentGLN': parentGln?.glnCode,
      'licenseNumber': licenseNumber ?? '',
      'licenseType': licenseType ?? '',
      'licenseValidUntil':
          licenseExpiry != null ? _formatDateWithTimezone(licenseExpiry!) : null,
      'locationStatus': locationStatus,
      'operatingStatus': status,
    };

    if (licenseValidFrom != null) {
      json['licenseValidFrom'] = _formatDateWithTimezone(licenseValidFrom!);
    }
    if (effectiveFrom != null) {
      json['effectiveFrom'] = _formatDateWithTimezone(effectiveFrom!);
    }
    if (effectiveTo != null) {
      json['effectiveTo'] = _formatDateWithTimezone(effectiveTo!);
    }
    if (nonReuseUntil != null) {
      json['nonReuseUntil'] = nonReuseUntil!.toIso8601String().split('T').first;
    }
    if (gs1CompanyPrefix != null) json['gs1CompanyPrefix'] = gs1CompanyPrefix;
    if (locationReferenceDigits != null) {
      json['locationReference'] = locationReferenceDigits;
    }
    if (checkDigit != null) json['checkDigit'] = checkDigit;
    if (registeredLegalName != null) {
      json['registeredLegalName'] = registeredLegalName;
    }
    if (tradingName != null) json['tradingName'] = tradingName;
    if (leiCode != null) json['leiCode'] = leiCode;
    if (taxRegistrationNumber != null) {
      json['taxRegistrationNumber'] = taxRegistrationNumber;
    }
    if (countryOfIncorporationNumeric != null) {
      json['countryOfIncorporation'] = countryOfIncorporationNumeric;
    }
    if (website != null) json['website'] = website;
    if (digitalAddressType != null) {
      json['digitalAddressType'] = digitalAddressType;
    }
    if (digitalAddressValue != null) {
      json['digitalAddressValue'] = digitalAddressValue;
    }
    if (glnExtensionComponent != null) {
      json['glnExtensionComponent'] = glnExtensionComponent;
    }
    if (industryClassification != null) {
      json['industryClassification'] = industryClassification;
    }
    if (glnSource != null) json['glnSource'] = glnSource;
    if (mobility != null) json['mobility'] = mobility;
    if (mobileLocationIdentifier != null) {
      json['mobileLocationIdentifier'] = mobileLocationIdentifier;
    }
    if (glnTypes.isNotEmpty) json['glnTypes'] = glnTypes;
    if (supplyChainRoles.isNotEmpty) {
      json['supplyChainRoles'] = supplyChainRoles;
    }
    if (locationRoles.isNotEmpty) json['locationRoles'] = locationRoles;
    if (coordinates != null) json['coordinates'] = coordinates!.toJson();
    if (pharmaceuticalExtension != null) {
      json['pharmaceuticalExtension'] = pharmaceuticalExtension!.toJson();
    }
    if (tobaccoExtension != null) {
      json['tobaccoExtension'] = tobaccoExtension!.toJson();
    }

    return json;
  }

  static DateTime? _parseDate(dynamic v) {
    if (v == null || v.toString().isEmpty) return null;
    try {
      return DateTime.parse(v.toString());
    } catch (_) {
      return null;
    }
  }

  static List<String> _stringListFromJson(dynamic v) {
    if (v == null) return [];
    if (v is List) {
      return v.map((e) => e.toString().trim()).where((s) => s.isNotEmpty).toList();
    }
    if (v is String && v.trim().isNotEmpty) {
      return v
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    }
    return [];
  }

  static LocationType _parseLocationType(String? type) {
    if (type == null) return LocationType.other;

    switch (type.toLowerCase()) {
      case 'manufacturing_site':
        return LocationType.manufacturing_site;
      case 'warehouse':
        return LocationType.warehouse;
      case 'distribution_center':
        return LocationType.distribution_center;
      case 'pharmacy':
        return LocationType.pharmacy;
      case 'hospital':
        return LocationType.hospital;
      case 'wholesaler':
        return LocationType.wholesaler;
      case 'clinic':
        return LocationType.clinic;
      case 'regulatory_body':
        return LocationType.regulatory_body;
      default:
        return LocationType.other;
    }
  }

  String _formatDateWithTimezone(DateTime dateTime) {
    final String iso8601String = dateTime.toIso8601String();
    if (iso8601String.endsWith('Z') || iso8601String.contains('+')) {
      return iso8601String;
    }
    return '${iso8601String}Z';
  }

  @override
  List<Object?> get props => [
        glnCode,
        locationName,
        addressLine1,
        addressLine2,
        city,
        stateProvince,
        postalCode,
        country,
        contactName,
        contactEmail,
        contactPhone,
        locationType,
        parentGln,
        licenseNumber,
        licenseType,
        licenseValidFrom,
        licenseExpiry,
        active,
        coordinates,
        operatingStatus,
        effectiveFrom,
        effectiveTo,
        glnTypes,
        pharmaceuticalExtension,
        tobaccoExtension,
      ];
}
