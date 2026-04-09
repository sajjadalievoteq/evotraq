import 'package:equatable/equatable.dart';
import 'package:traqtrace_app/features/epcis/models/geospatial_coordinates.dart';

/// Enum representing the type of location
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

/// Model class representing a GLN (Global Location Number)
class GLN extends Equatable {
  /// The actual GLN code (13 digits) - primary identifier
  final String glnCode;
  
  /// Name of the location
  final String locationName;
  
  /// First line of the address
  final String addressLine1;
  
  /// Second line of the address (optional)
  final String? addressLine2;
  
  /// City
  final String city;
  
  /// State or province
  final String stateProvince;
  
  /// Postal code
  final String postalCode;
  
  /// Country
  final String country;
  
  /// Name of the contact person for this location
  final String? contactName;
  
  /// Email address of the contact person
  final String? contactEmail;
  
  /// Phone number of the contact person
  final String? contactPhone;
  
  /// Type of location (manufacturing, warehouse, etc.)
  final LocationType locationType;
  
  /// Parent GLN (if this is a child location)
  final GLN? parentGln;
  
  /// License number (if applicable)
  final String? licenseNumber;
  
  /// Type of license (if applicable)
  final String? licenseType;
  
  /// License expiry date (if applicable)
  final DateTime? licenseExpiry;
  
  /// Whether this GLN is active
  final bool active;
  
  /// EPCIS 2.0: Precise geospatial coordinates of the location
  final GeospatialCoordinates? coordinates;  /// Creates a new GLN instance
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
    this.licenseExpiry,
    required this.active,
    this.coordinates,
  });
  /// Simple constructor that creates a GLN with only the code
  /// This is used when we only have the GLN code and no other details
  factory GLN.fromCode(String code) {
    return GLN(
      // No id needed as glnCode is the primary identifier
      glnCode: code,
      locationName: "Unknown Location",
      addressLine1: "Unknown Address",
      city: "Unknown City",
      stateProvince: "Unknown State",
      postalCode: "Unknown",
      country: "Unknown Country",
      locationType: LocationType.other,
      active: true,
      coordinates: null, // No coordinates available for this basic constructor
    );
  }  /// Creates a copy of this GLN with the given fields replaced with new values
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
    DateTime? licenseExpiry,
    bool? active,
    GeospatialCoordinates? coordinates,
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
      licenseExpiry: licenseExpiry ?? this.licenseExpiry,
      active: active ?? this.active,
      coordinates: coordinates ?? this.coordinates,
    );
  }  /// Convert a JSON map to a GLN object
  factory GLN.fromJson(Map<String, dynamic> json) {
    // Special case for when we receive just a GLN code with no other fields
    if (json.containsKey('id') && json.length == 1) {
      return GLN.fromCode(json['id'].toString());
    }
    
    // If we get a very simple object with just a code
    if (json.containsKey('code') && json.length <= 3) {
      return GLN.fromCode(json['code'].toString());
    }
    
    // Handle case where the JSON is just a string directly
    if (json.containsKey('glnCode') && json['glnCode'] is String && json.length == 1) {
      return GLN.fromCode(json['glnCode']);
    }
    
    // Check for empty response
    if (json.isEmpty) {
      return GLN.fromCode('Unknown');
    }
    
    // Convert location status to active boolean
    bool active = true;
    if (json['locationStatus'] != null) {
      active = json['locationStatus'].toString().toLowerCase() == 'active';
    }
    
    // Parse license expiry dates
    DateTime? licenseExpiry;
    if (json['licenseValidUntil'] != null && json['licenseValidUntil'].toString().isNotEmpty) {
      try {
        licenseExpiry = DateTime.parse(json['licenseValidUntil']);
      } catch (e) {
        print('Failed to parse licenseValidUntil: ${e.toString()}');
      }
    }
    
    // Parse geospatial coordinates if available
    GeospatialCoordinates? coordinates;
    if (json['coordinates'] != null) {
      coordinates = GeospatialCoordinates.fromJson(json['coordinates']);
    } else if (json['latitude'] != null && json['longitude'] != null) {
      // For backward compatibility if coordinates are directly in the GLN object
      coordinates = GeospatialCoordinates(
        latitude: double.parse(json['latitude'].toString()),
        longitude: double.parse(json['longitude'].toString()),
      );
    }
    
    // Standard complete object parsing
    return GLN(
      glnCode: json['glnCode']?.toString() ?? '', // Ensure it's a non-null string
      locationName: json['locationName']?.toString() ?? '',
      addressLine1: json['addressLine1']?.toString() ?? '',
      addressLine2: json['addressLine2']?.toString(), // Optional, can be null
      city: json['city']?.toString() ?? '',
      stateProvince: json['stateProvince']?.toString() ?? '',
      postalCode: json['postalCode']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
      contactName: json['contactName']?.toString(), // Optional
      contactEmail: json['email']?.toString(), // Fixed: Maps from "email" in backend
      contactPhone: json['phone']?.toString(), // Fixed: Maps from "phone" in backend
      locationType: _parseLocationType(json['locationType']),
      parentGln: json['parentGLN'] != null ? GLN.fromCode(json['parentGLN']) : null, // Fixed: Maps from parentGLN
      licenseNumber: json['licenseNumber']?.toString(), // Optional
      licenseType: json['licenseType']?.toString(), // Optional
      licenseExpiry: licenseExpiry,
      active: active, // Use the converted active status from locationStatus
      coordinates: coordinates, // EPCIS 2.0: Include geospatial coordinates
    );
  }/// Convert a GLN object to a JSON map
  Map<String, dynamic> toJson() {
    // Convert active status to locationStatus expected by backend
    String locationStatus = active ? 'active' : 'inactive';
    
    Map<String, dynamic> json = {
      'glnCode': glnCode,  // Primary identifier
      'locationName': locationName,
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'city': city,
      'stateProvince': stateProvince,
      'postalCode': postalCode,
      'country': country,
      'contactName': contactName ?? '',
      'email': contactEmail ?? '', // Changed to match backend field name
      'phone': contactPhone ?? '', // Changed to match backend field name
      'locationType': locationType.toString().split('.').last.toUpperCase(),
      'parentGLN': parentGln?.glnCode, // Changed to match backend field name
      'licenseNumber': licenseNumber ?? '',
      'licenseType': licenseType ?? '',
      'licenseValidUntil': licenseExpiry != null ? _formatDateWithTimezone(licenseExpiry!) : null, // Changed to match backend field name
      'locationStatus': locationStatus, // Changed to match backend field name
    };
    
    // Add EPCIS 2.0 coordinates if available
    if (coordinates != null) {
      json['coordinates'] = coordinates!.toJson();
    }
    
    return json;
  }

  /// Parse location type from string (used in fromJson)
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
  /// For Equatable
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
    licenseExpiry,
    active
  ];

  /// Helper method to format dates with timezone information
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