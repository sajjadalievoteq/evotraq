import 'package:traqtrace_app/features/epcis/models/certification_info.dart';
import 'package:traqtrace_app/features/epcis/models/sensor_element.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:uuid/uuid.dart';

/// Base class for EPCIS event models
class EPCISEvent {
  /// Database ID of the event
  final String? id;

  /// Unique event identifier
  final String eventId;

  /// Time when the event occurred
  final DateTime eventTime;

  /// Time when the event was recorded in the system
  final DateTime recordTime;

  /// Timezone of the event time
  final String eventTimeZone;

  /// EPCIS version (1.3 or 2.0)
  final EPCISVersion? epcisVersion;

  /// Disposition of the objects in the event
  final String? disposition;

  /// Business step in the process
  final String? businessStep;
  
  /// Specific location where the event was recorded
  final GLN? readPoint;

  /// Business location context for the event
  final GLN? businessLocation;

  /// Hash value for event integrity
  final String? eventHash;

  /// Business data associated with the event
  final Map<String, String>? bizData;

  /// Extension data for the event
  final Map<String, String>? extensions;

  /// When the event record was created
  final DateTime? createdAt;
  
  /// EPCIS 2.0: Sensor data associated with the event
  final List<SensorElement>? sensorElementList;
  
  /// EPCIS 2.0: Certification information associated with the event
  final List<CertificationInfo>? certificationInfo;

  /// Constructor
  EPCISEvent({
    this.id,
    required this.eventId,
    required this.eventTime,
    required this.recordTime,
    required this.eventTimeZone,
    this.epcisVersion,
    this.disposition,
    this.businessStep,
    this.readPoint,
    this.businessLocation,
    this.eventHash,
    this.bizData,
    this.extensions,
    this.createdAt,
    this.sensorElementList,
    this.certificationInfo,
  });
  /// Create from JSON
  factory EPCISEvent.fromJson(Map<String, dynamic> json) {
    // Parse sensor elements if available
    List<SensorElement>? sensorElements;
    if (json['sensorElementList'] != null) {
      sensorElements = (json['sensorElementList'] as List)
          .map((element) => SensorElement.fromJson(element))
          .toList();
    }
    
    // Parse certification info if available - ensure it's always handled as an array
    List<CertificationInfo>? certInfo;
    if (json['certificationInfo'] != null) {
      try {
        print("Processing certification info in EPCISEvent: ${json['certificationInfo']}");
        
        if (json['certificationInfo'] is List) {
          // Handle as array (expected format)
          certInfo = (json['certificationInfo'] as List)
              .map((info) {
                // Convert to Map<String, dynamic> if it's not already
                if (info is Map<String, dynamic>) {
                  return CertificationInfo.fromJson(info);
                } else if (info is Map) {
                  return CertificationInfo.fromJson(Map<String, dynamic>.from(info));
                } else {
                  print("Unexpected certification info item type: ${info.runtimeType}");
                  throw FormatException("Invalid certification info format");
                }
              })
              .toList();
        } else if (json['certificationInfo'] is Map) {
          // Handle as single object (convert to array with one item)
          final info = json['certificationInfo'] as Map;
          certInfo = [CertificationInfo.fromJson(Map<String, dynamic>.from(info))];
        } else {
          print("Unexpected certification info type: ${json['certificationInfo'].runtimeType}");
          certInfo = [];
        }
        
        print("Created ${certInfo.length} certification info items");
      } catch (e) {
        print("Error parsing certification info: $e");
        certInfo = [];
      }
    }
    
    return EPCISEvent(
      id: json['id'],
      // Ensure eventId is never null or empty
      eventId: (json['eventId'] != null && json['eventId'].toString().isNotEmpty) 
            ? json['eventId'] 
            : 'urn:epcglobal:cbv:epcis:event:${Uuid().v4()}',
      eventTime: DateTime.parse(json['eventTime']),
      recordTime: DateTime.parse(json['recordTime']),
      eventTimeZone: json['eventTimeZone'] ?? json['eventTimeZoneOffset'] ?? '+00:00',
      epcisVersion: json['epcisVersion'] != null 
          ? (json['epcisVersion'].toString() == '1.3' 
              ? EPCISVersion.v1_3 
              : EPCISVersion.v2_0)
          : EPCISVersion.v2_0, // Default to 2.0
      disposition: json['disposition'],
      businessStep: json['businessStep'] ?? json['bizStep'],
      readPoint: json['readPoint'] != null 
          ? (json['readPoint'] is String 
              ? GLN.fromCode(json['readPoint'])
              : GLN.fromJson(json['readPoint']))
          : null,
      businessLocation: json['businessLocation'] != null 
          ? (json['businessLocation'] is String 
              ? GLN.fromCode(json['businessLocation'])
              : GLN.fromJson(json['businessLocation']))
          : null,
      eventHash: json['eventHash'],
      bizData: json['bizData'] != null ? Map<String, String>.from(json['bizData']) : null,
      extensions: json['extensions'] != null ? Map<String, String>.from(json['extensions']) : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      sensorElementList: sensorElements,
      certificationInfo: certInfo,
    );
  }  /// Convert to JSON
  Map<String, dynamic> toJson() {
    // Format timezone for the backend - ensure it's never null
    final String formattedEventTimeZone = eventTimeZone.isNotEmpty ? eventTimeZone : '+00:00';
      
    // Make sure dates have appropriate timezone information
    final String formattedEventTime = _formatDateWithTimezone(eventTime);
    final String formattedRecordTime = _formatDateWithTimezone(recordTime);
      
    final Map<String, dynamic> data = {
      'eventId': eventId,
      'eventTime': formattedEventTime,
      'recordTime': formattedRecordTime,
      'eventTimeZoneOffset': formattedEventTimeZone,  // Backend DTO expects this field name
      'eventTimeZone': formattedEventTimeZone,  // Add both field names to be safe
    };
    
    if (id != null) data['id'] = id;
    
    // Always provide EPCIS version with the exact format required by schema
    // The schema requires either "1.3" or "2.0" as strings
    if (epcisVersion != null) {
      if (epcisVersion == EPCISVersion.v1_3) {
        data['epcisVersion'] = '1.3';
      } else {
        data['epcisVersion'] = '2.0';
      }
    } else {
      data['epcisVersion'] = '2.0'; // Default to 2.0
    }
    
    // Extract the final part from the disposition URN
    if (disposition != null) {
      // For full URNs like "urn:epcglobal:cbv:disp:active", extract just "active"
      if (disposition!.contains(':')) {
        data['disposition'] = disposition!.split(':').last;
      } else {
        data['disposition'] = disposition;
      }
    }
    
    // Extract the final part from the businessStep URN
    if (businessStep != null) {
      // For full URNs like "urn:epcglobal:cbv:bizstep:commissioning", extract just "commissioning"
      if (businessStep!.contains(':')) {
        data['businessStep'] = businessStep!.split(':').last;
      } else {
        data['businessStep'] = businessStep;
      }
    }
    
    // Handle readPoint properly
    if (readPoint != null) {
      data['readPoint'] = readPoint!.glnCode; // Send just the GLN code as string
    } else if (businessLocation != null) {
      // If no readPoint specified but businessLocation exists, use businessLocation as readPoint
      // This is common for transformation events where read and business location are the same
      data['readPoint'] = businessLocation!.glnCode;
    }
    // If neither readPoint nor businessLocation is available, don't include readPoint field
    
    // Handle businessLocation properly - based on schema it should be a string
    if (businessLocation != null) {
      data['businessLocation'] = businessLocation!.glnCode; // Send just the GLN code as string
    }
    if (eventHash != null) data['eventHash'] = eventHash;
    if (bizData != null && bizData!.isNotEmpty) {
      data['bizData'] = bizData;
    } else {
      // Initialize empty object to satisfy schema
      data['bizData'] = {};
    }
    if (extensions != null) data['extensions'] = extensions;
    if (createdAt != null) data['createdAt'] = _formatDateWithTimezone(createdAt!);
    
    // Add EPCIS 2.0 extensions
    if (sensorElementList != null && sensorElementList!.isNotEmpty) {
      data['sensorElementList'] = sensorElementList!.map((element) => element.toJson()).toList();
    }
    
    // Handle certification info - backend expects an array of certification objects
    if (certificationInfo != null && certificationInfo!.isNotEmpty) {
      // Convert certification info objects to a JSON array
      data['certificationInfo'] = certificationInfo!.map((cert) => cert.toJson()).toList();
    } else {
      // Always provide a default certification info array
      // This follows GS1 EPCIS 2.0 standard for certification extensions
      data['certificationInfo'] = [{
        "certificateNumber": "default",
        "certificationStandard": "none",
        "certificationAgency": "none"
      }];
    }
    
    return data;
  }  /// Helper method to format dates with timezone information
  String _formatDateWithTimezone(DateTime dateTime) {
    // Format date according to ISO 8601 with timezone
    // This creates a format like "2025-06-20T15:30:45.123Z" for UTC
    // or "2025-06-20T15:30:45.123+02:00" for specific timezone
    
    // Generate ISO string with timezone information
    String iso8601String = dateTime.toIso8601String();
    
    // Check if the string already has timezone information
    if (iso8601String.endsWith('Z') || iso8601String.contains('+') || iso8601String.contains('-', iso8601String.length - 6)) {
      return iso8601String;
    }
    
    // If the datetime doesn't have timezone information, we need to add it
    // For local time, get the current timezone offset
    final offset = dateTime.timeZoneOffset;
    final hours = offset.inHours.abs();
    final minutes = (offset.inMinutes.abs() % 60);
    final sign = offset.isNegative ? '-' : '+';
    final offsetString = '$sign${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
    
    // Return ISO string with timezone offset
    return '${iso8601String}${offsetString}';
  }
}

/// EPCIS version enum
enum EPCISVersion {
  /// EPCIS v1.3
  v1_3,

  /// EPCIS v2.0
  v2_0,
}