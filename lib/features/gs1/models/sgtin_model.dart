// SGTIN (Serialized GTIN) model class
import 'package:equatable/equatable.dart';
import 'package:traqtrace_app/features/gs1/models/gln_model.dart';
import 'package:traqtrace_app/features/gs1/models/sscc_model.dart';

class SGTIN extends Equatable {
  final String? id;
  final String gtinCode;
  final String serialNumber;
  final DateTime? expiryDate;
  final String? batchLotNumber;
  final DateTime? productionDate;
  final DateTime? bestBeforeDate;
  final ItemStatus status; 
  final GLN? currentLocation;
  final SSCC? currentSSCC;
  final String? regulatoryMarket;
  final String? regulatoryStatus;
  final String? decommissionedReason;
  final DateTime? decommissionedDate;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const SGTIN({
    this.id,
    required this.gtinCode,
    required this.serialNumber,
    this.expiryDate,
    this.batchLotNumber,
    this.productionDate,
    this.bestBeforeDate,
    required this.status,
    this.currentLocation,
    this.currentSSCC,
    this.regulatoryMarket,
    this.regulatoryStatus,
    this.decommissionedReason,
    this.decommissionedDate,
    required this.createdAt,
    this.updatedAt,
  });  
  
  factory SGTIN.fromJson(Map<String, dynamic> json) {
    // Ensure ID is always treated as String, even if null
    String? id;
    if (json['id'] != null) {
      id = json['id'].toString();
    }
    
    return SGTIN(
      id: id,
      gtinCode: json['gtin'] ?? json['gtinCode'],
      serialNumber: json['serialNumber'],
      expiryDate: json['expiryDate'] != null 
          ? DateTime.parse(json['expiryDate']) 
          : null,
      batchLotNumber: json['batchLotNumber'],
      productionDate: json['productionDate'] != null 
          ? DateTime.parse(json['productionDate']) 
          : null,
      bestBeforeDate: json['bestBeforeDate'] != null 
          ? DateTime.parse(json['bestBeforeDate']) 
          : null,
      status: _parseItemStatus(json['status']),
      currentLocation: _parseCurrentLocation(json),
      currentSSCC: json['currentSSCC'] != null 
          ? SSCC.fromJson(json['currentSSCC']) 
          : null,
      regulatoryMarket: json['regulatoryMarket'],
      regulatoryStatus: json['regulatoryStatus'],
      decommissionedReason: json['decommissionedReason'],
      decommissionedDate: json['decommissionedDate'] != null 
          ? DateTime.parse(json['decommissionedDate']) 
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(), // Provide a default if createdAt is null
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
    );
  }  
  
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id.toString(), // Always ensure ID is a String
      'gtin': gtinCode, // Use 'gtin' to match backend API
      'serialNumber': serialNumber,
      if (expiryDate != null) 'expiryDate': _formatDateWithTimezone(expiryDate!),
      if (batchLotNumber != null) 'batchLotNumber': batchLotNumber,
      if (productionDate != null) 'productionDate': _formatDateWithTimezone(productionDate!),
      if (bestBeforeDate != null) 'bestBeforeDate': _formatDateWithTimezone(bestBeforeDate!),
      'status': status.name,
      if (currentLocation != null) 'currentLocationGLN': currentLocation!.glnCode,
      if (currentSSCC != null) 'currentSSCC': currentSSCC!.id,
      if (regulatoryMarket != null) 'regulatoryMarket': regulatoryMarket,
      if (regulatoryStatus != null) 'regulatoryStatus': regulatoryStatus,
      if (decommissionedReason != null) 'decommissionedReason': decommissionedReason,
      if (decommissionedDate != null) 'decommissionedDate': _formatDateWithTimezone(decommissionedDate!),
      'createdAt': _formatDateWithTimezone(createdAt),
      if (updatedAt != null) 'updatedAt': _formatDateWithTimezone(updatedAt!),
    };
  }
  // Copy with method for creating a new instance with some updated fields
  SGTIN copyWith({
    String? id,
    String? gtinCode,
    String? serialNumber,
    DateTime? expiryDate,
    String? batchLotNumber,
    DateTime? productionDate,
    DateTime? bestBeforeDate,
    ItemStatus? status,
    GLN? currentLocation,
    SSCC? currentSSCC,
    String? regulatoryMarket,
    String? regulatoryStatus,
    String? decommissionedReason,
    DateTime? decommissionedDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SGTIN(
      id: id ?? this.id,
      gtinCode: gtinCode ?? this.gtinCode,
      serialNumber: serialNumber ?? this.serialNumber,
      expiryDate: expiryDate ?? this.expiryDate,
      batchLotNumber: batchLotNumber ?? this.batchLotNumber,
      productionDate: productionDate ?? this.productionDate,
      bestBeforeDate: bestBeforeDate ?? this.bestBeforeDate,
      status: status ?? this.status,
      currentLocation: currentLocation ?? this.currentLocation,
      currentSSCC: currentSSCC ?? this.currentSSCC,
      regulatoryMarket: regulatoryMarket ?? this.regulatoryMarket,
      regulatoryStatus: regulatoryStatus ?? this.regulatoryStatus,
      decommissionedReason: decommissionedReason ?? this.decommissionedReason,
      decommissionedDate: decommissionedDate ?? this.decommissionedDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  // Helper method to format dates with timezone information
  String _formatDateWithTimezone(DateTime dateTime) {
    // Convert local dateTime to UTC for consistent handling
    final DateTime utcDateTime = dateTime.toUtc();
    
    // Format the date to ISO 8601 format with the 'Z' timezone indicator for UTC
    // Example format: 2025-05-13T14:52:02.114Z
    final String iso8601String = utcDateTime.toIso8601String();
    
    // Ensure the string ends with Z to indicate UTC timezone for Java ZonedDateTime
    if (!iso8601String.endsWith('Z')) {
      return '${iso8601String}Z';
    }
    
    return iso8601String;
  }
  
  // Compute the full SGTIN string in the format GTIN+Serial
  String get sgtinString => '$gtinCode$serialNumber';
  
  // Compute EPC URI
  String get epcUri {
    // Pad GTIN if needed
    String paddedGTIN = gtinCode;
    if (paddedGTIN.length < 14) {
      paddedGTIN = paddedGTIN.padLeft(14, '0');
    }
    
    // Extract company prefix and item reference as per GS1 standard
    final String companyPrefix = paddedGTIN.substring(1, 8); // Standard 7-digit company prefix
    final String itemRef = paddedGTIN.substring(8, 13);
    
    return 'urn:epc:id:sgtin:$companyPrefix.$itemRef.$serialNumber';
  }
  
  @override
  List<Object?> get props => [
    id,
    gtinCode,
    serialNumber,
    expiryDate,
    batchLotNumber,
    productionDate,
    bestBeforeDate,
    status,
    currentLocation,
    currentSSCC,
    regulatoryMarket,
    regulatoryStatus,
    decommissionedReason,
    decommissionedDate,
    createdAt,
    updatedAt,
  ];
  
  static GLN? _parseCurrentLocation(Map<String, dynamic> json) {
    // Backend returns currentLocationGLN and currentLocationName as separate fields
    if (json['currentLocationGLN'] != null) {
      // Use the simple factory constructor that only requires GLN code
      return GLN(
        glnCode: json['currentLocationGLN'] as String,
        locationName: json['currentLocationName'] as String? ?? 'Unknown Location',
        addressLine1: '',
        city: '',
        stateProvince: '',
        postalCode: '',
        country: '',
        locationType: LocationType.other,
        active: true,
      );
    }
    // Fallback: try parsing as object (for backwards compatibility)
    if (json['currentLocation'] != null) {
      return GLN.fromJson(json['currentLocation']);
    }
    return null;
  }
  
  static ItemStatus _parseItemStatus(String? value) {
    if (value == null) return ItemStatus.COMMISSIONED;
    
    try {
      return ItemStatus.values.firstWhere(
        (status) => status.name == value,
        orElse: () => ItemStatus.COMMISSIONED,
      );
    } catch (_) {
      return ItemStatus.COMMISSIONED;
    }
  }
}

/// Enumeration of possible item statuses to match backend ItemStatus enum
enum ItemStatus {
  COMMISSIONED,
  PACKED,
  SHIPPED,
  IN_TRANSIT,
  RECEIVED,
  DISPENSED,
  DAMAGED,
  RECALLED,
  STOLEN,
  DESTROYED,
  SAMPLE,
  DECOMMISSIONED
}