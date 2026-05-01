// filepath: c:\Code\traqTrace\frontend\traqtrace_app\lib\features\gs1\models\sscc_model.dart
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';

// SSCC (Serial Shipping Container Code) model class
class SSCC {
  final String? id; // Changed from int? to String? to match UUID in backend
  final String ssccCode;
  final ContainerType containerType;
  final DateTime? packingDate;
  final ContainerStatus containerStatus;
  final DateTime? validFrom;
  final DateTime? validUntil;
  final SSCC? parentSscc;
  final String? gs1CompanyPrefix;
  final String? extensionDigit;
  final String? serialReference;
  final String? checkDigit;
  final DateTime? shippingDate;
  final DateTime? receivingDate;
  final GLN? sourceLocation;
  final GLN? destinationLocation;
  final GLN? issuingGLN; // The GLN of the location that created/issued this SSCC
  final DateTime createdAt;
  final DateTime updatedAt;

  SSCC({
    this.id,
    required this.ssccCode,
    required this.containerType,
    this.packingDate,
    required this.containerStatus,
    this.validFrom,
    this.validUntil,
    this.parentSscc,
    this.gs1CompanyPrefix,
    this.extensionDigit,
    this.serialReference,
    this.checkDigit,
    this.shippingDate,
    this.receivingDate,
    this.sourceLocation,
    this.destinationLocation,
    this.issuingGLN,
    required this.createdAt,
    required this.updatedAt,
  });  factory SSCC.fromJson(Map<String, dynamic> json) {
    // Handle different field names for SSCC code (backend uses 'sscc' while frontend uses 'ssccCode')
    final String ssccCode = json['sscc'] ?? json['ssccCode'] ?? '';
    
    // Get current timestamp for fallback
    final DateTime now = DateTime.now();
    
    // Use statusDate as a fallback for timestamps if they're missing
    final DateTime createdAt = json['createdAt'] != null
        ? DateTime.parse(json['createdAt'])
        : (json['statusDate'] != null ? DateTime.parse(json['statusDate']) : now);
    
    final DateTime updatedAt = json['updatedAt'] != null
        ? DateTime.parse(json['updatedAt'])
        : (json['statusDate'] != null ? DateTime.parse(json['statusDate']) : now);
    
    return SSCC(
      id: json['id'],
      ssccCode: ssccCode,
      containerType: _parseContainerType(json['containerType']),
        packingDate: json['packingDate'] != null 
            ? DateTime.parse(json['packingDate']) 
            : null,
      containerStatus: _parseContainerStatus(json['containerStatus']),
      validFrom: json['validFrom'] != null 
          ? DateTime.parse(json['validFrom']) 
          : null,
      validUntil: json['validUntil'] != null 
          ? DateTime.parse(json['validUntil']) 
          : null,
      parentSscc: json['parentSscc'] != null 
          ? SSCC.fromJson(json['parentSscc']) 
          : null,
      gs1CompanyPrefix: json['companyPrefix'] ?? json['gs1CompanyPrefix'], // Try both field names
      extensionDigit: json['extensionDigit'],
      serialReference: json['serialReference'],
      checkDigit: json['checkDigit'],
      shippingDate: json['shippingDate'] != null 
          ? DateTime.parse(json['shippingDate']) 
          : null,
      receivingDate: json['receivingDate'] != null 
          ? DateTime.parse(json['receivingDate']) 
          : null,
      sourceLocation: json['sourceLocation'] != null 
          ? GLN.fromJson(json['sourceLocation']) 
          : null,
      destinationLocation: json['destinationLocation'] != null 
          ? GLN.fromJson(json['destinationLocation']) 
          : null,
      issuingGLN: json['issuingGLN'] != null 
          ? _parseGLNFromJsonField(json['issuingGLN'])
          : null,
      // Use our pre-calculated timestamps that include fallbacks
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }  Map<String, dynamic> toJson() {
    // IMPORTANT: After multiple testing attempts, we've discovered that the backend only accepts
    // the absolute minimal set of fields. It rejects individual SSCC components, timestamps, etc.
    
    // Create the absolute minimal JSON object with only fields the backend accepts
    final Map<String, dynamic> jsonData = {
      // Only include ID if it's not null (for editing existing SSCCs)
      if (id != null) 'id': id,
      
      // The SSCC code using the field name from the backend (sscc not ssccCode)
      'sscc': ssccCode,
      
      // Only include these basic fields that we know the backend accepts
      'containerType': containerType.name,
      'containerStatus': containerStatus.name,
      
      // Only include packingDate if available - this appears to be accepted
      if (packingDate != null) 'packingDate': _formatDateWithTimezone(packingDate!),
      
      // GS1 compliance: Include issuing GLN for proper supply chain traceability
      if (issuingGLN != null) 'issuingGLN': issuingGLN!.glnCode,
      
      // DO NOT include createdAt/updatedAt timestamps - the backend will handle these
    };
    
    // Print the final JSON for debugging
    print('SSCC toJson output - minimal fields with GS1 compliance: $jsonData');
    print('SSCC toJson field count: ${jsonData.length}');
    print('Fields included: ${jsonData.keys.toList()}');
    if (issuingGLN != null) {
      print('Issuing GLN included for GS1 traceability: ${issuingGLN!.glnCode}');
    }
    
    return jsonData;
  }

  // Helper method to format dates with timezone information
  String _formatDateWithTimezone(DateTime dateTime) {
    // Convert to format that Java's ZonedDateTime can parse
    final String iso8601String = dateTime.toIso8601String();
    
    // Check if the string already has timezone information
    if (iso8601String.endsWith('Z') || iso8601String.contains('+')) {
      return iso8601String;
    }
    
    // Add UTC timezone marker if missing
    return '${iso8601String}Z';
  }
  
  
  /// Helper method to parse GLN from JSON field that can be either a string (GLN code) or a full GLN object
  static GLN? _parseGLNFromJsonField(dynamic glnField) {
    if (glnField == null) {
      return null;
    }
    
    // If it's a string, treat it as a GLN code and create a GLN using fromCode
    if (glnField is String) {
      return GLN.fromCode(glnField);
    }
    
    // If it's a Map, parse it as a full GLN object
    if (glnField is Map<String, dynamic>) {
      return GLN.fromJson(glnField);
    }
    
    // Unexpected format
    print('Warning: Unexpected GLN field format: ${glnField.runtimeType}, value: $glnField');
    return null;
  }

  static ContainerType _parseContainerType(String? value) {
    if (value == null) return ContainerType.OTHER;
    
    try {
      return ContainerType.values.firstWhere(
        (type) => type.name == value,
        orElse: () => ContainerType.OTHER,
      );
    } catch (_) {
      return ContainerType.OTHER;
    }
  }
  
  static ContainerStatus _parseContainerStatus(String? value) {
    if (value == null) return ContainerStatus.CREATED;
    
    try {
      return ContainerStatus.values.firstWhere(
        (status) => status.name == value,
        orElse: () => ContainerStatus.CREATED,
      );
    } catch (_) {
      return ContainerStatus.CREATED;
    }
  }
}

/// Container types for SSCC
enum ContainerType {
  PALLET,
  CASE,
  TOTE,
  CONTAINER,
  DRUM,
  CARTON,
  OTHER
}

/// Container status values for SSCC
enum ContainerStatus {
  CREATED,    // Container is created but not packed
  PACKED,     // Container is packed with items
  SHIPPED,    // Container is shipped
  IN_TRANSIT, // Container is in transit
  RECEIVED,   // Container is received at destination
  UNPACKED,   // Container is unpacked
  DAMAGED,    // Container is damaged
  DISPOSED    // Container is disposed
}