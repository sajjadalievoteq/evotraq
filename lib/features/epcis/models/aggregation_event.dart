import 'package:traqtrace_app/features/gs1/models/gln_model.dart';
import 'epcis_event.dart';
import 'package:traqtrace_app/features/epcis/models/sensor_element.dart';

/// AggregationEvent represents EPCIS events that establish parent-child relationships
/// between containers (like pallets, cases) and their contents
class AggregationEvent extends EPCISEvent {
  final String parentID;
  final List<String> childEPCs;
  final String action;
  final List<Map<String, Object>>? childQuantityList;
  final List<Map<String, dynamic>>? sourceList;
  final List<Map<String, dynamic>>? destinationList;
  @override
  final List<SensorElement>? sensorElementList;
  AggregationEvent({
    String? id,
    required String eventId,
    required DateTime eventTime,
    required DateTime recordTime,
    required String eventTimeZone,
    EPCISVersion? epcisVersion,
    String? disposition,
    String? businessStep,
    GLN? readPoint,
    GLN? businessLocation,
    String? eventHash,
    Map<String, String>? bizData,
    Map<String, String>? extensions,
    DateTime? createdAt,
    required this.action,
    required this.parentID,
    List<String>? childEPCs,
    this.childQuantityList,
    this.sourceList,
    this.destinationList,
    this.sensorElementList,
  }) : childEPCs = childEPCs ?? [],
       super(
         id: id,
         eventId: eventId,
         eventTime: eventTime,
         recordTime: recordTime,
         eventTimeZone: eventTimeZone,
         epcisVersion: epcisVersion,
         disposition: disposition,
         businessStep: businessStep,
         readPoint: readPoint,
         businessLocation: businessLocation,
         eventHash: eventHash,
         bizData: bizData,
         extensions: extensions,
         createdAt: createdAt,
       );

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['parentID'] = parentID;
    json['action'] = action;
    
    // Handle oneOf constraint: only include one of childEPCs or childQuantityList, never both
    if (childEPCs.isNotEmpty) {
      json['childEPCs'] = childEPCs;
      // Do NOT include childQuantityList to satisfy oneOf constraint
    } else if (childQuantityList != null && childQuantityList!.isNotEmpty) {
      json['childQuantityList'] = childQuantityList;
      // Do NOT include childEPCs to satisfy oneOf constraint
    } else if (action == 'DELETE') {
      // For DELETE action, include childEPCs even if empty (per schema)
      json['childEPCs'] = childEPCs;
    }
    
    if (sourceList != null && sourceList!.isNotEmpty) {
      json['sourceList'] = sourceList;
    }
    
    if (destinationList != null && destinationList!.isNotEmpty) {
      json['destinationList'] = destinationList;
    }
    
    if (sensorElementList != null && sensorElementList!.isNotEmpty) {
      json['sensorElementList'] = sensorElementList;
    }
    
    return json;
  }  /// Create an AggregationEvent from a JSON object
  factory AggregationEvent.fromJson(Map<String, dynamic> json) {
    // Debug: print GLN-related fields for troubleshooting
    print('JSON contains readPoint: ${json['readPoint']}');
    print('JSON contains businessLocation: ${json['businessLocation']}');
    print('JSON contains bizLocation: ${json['bizLocation']}');
    print('JSON contains locationGLN: ${json['locationGLN']}');
    
    // Handle GLN objects for locations
    GLN? readPointGln;
    if (json['readPoint'] != null) {
      if (json['readPoint'] is String) {
        readPointGln = GLN.fromCode(json['readPoint']);
      } else if (json['readPoint'] is Map) {
        readPointGln = GLN.fromJson(Map<String, dynamic>.from(json['readPoint']));
      }
    }
    
    GLN? businessLocationGln;
    if (json['businessLocation'] != null) {
      if (json['businessLocation'] is String) {
        businessLocationGln = GLN.fromCode(json['businessLocation']);
      } else if (json['businessLocation'] is Map) {
        businessLocationGln = GLN.fromJson(Map<String, dynamic>.from(json['businessLocation']));
      }
    } else if (json['bizLocation'] != null) {
      if (json['bizLocation'] is String) {
        businessLocationGln = GLN.fromCode(json['bizLocation']);
      } else if (json['bizLocation'] is Map) {
        businessLocationGln = GLN.fromJson(Map<String, dynamic>.from(json['bizLocation']));
      }
    } else if (json['locationGLN'] != null && json['locationGLN'] is String) {
      // Use locationGLN as fallback if it exists
      businessLocationGln = GLN.fromCode(json['locationGLN']);
    }
    
    return AggregationEvent(
      id: json['id'],
      eventId: json['eventId'] ?? '',
      eventTime: json['eventTime'] != null ? DateTime.parse(json['eventTime']) : DateTime.now(),
      recordTime: json['recordTime'] != null ? DateTime.parse(json['recordTime']) : DateTime.now(),
      eventTimeZone: json['eventTimeZone'] ?? json['eventTimeZoneOffset'] ?? '+00:00',
      epcisVersion: json['epcisVersion'] != null 
          ? EPCISVersion.values.firstWhere(
              (e) => e.toString().split('.').last.toUpperCase() == 
                    json['epcisVersion'].toString().toUpperCase(),
              orElse: () => EPCISVersion.v2_0)
          : EPCISVersion.v2_0,
      disposition: json['disposition'],
      businessStep: json['businessStep'] ?? json['bizStep'],
      readPoint: readPointGln,
      businessLocation: businessLocationGln,
      action: json['action'],
      parentID: json['parentID'],
      childEPCs: json['childEPCs'] != null ? List<String>.from(json['childEPCs']) : [],
      childQuantityList: json['childQuantityList'] != null 
          ? List<Map<String, Object>>.from(json['childQuantityList']) 
          : null,
      sourceList: json['sourceList'] != null 
          ? (json['sourceList'] as List).map((item) => 
              Map<String, dynamic>.from(item as Map<String, dynamic>)).toList()
          : null,
      destinationList: json['destinationList'] != null 
          ? (json['destinationList'] as List).map((item) => 
              Map<String, dynamic>.from(item as Map<String, dynamic>)).toList()
          : null,
      sensorElementList: json['sensorElementList'] != null 
          ? (json['sensorElementList'] as List).map((e) => SensorElement.fromJson(e)).toList()
          : null,
      bizData: json['bizData'] != null ? Map<String, String>.from(json['bizData']) : null,
      extensions: json['extensions'] != null ? Map<String, String>.from(json['extensions']) : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }
    /// Create a copy of this AggregationEvent with the given fields replaced
  AggregationEvent copyWith({
    String? id,
    String? eventId,
    DateTime? eventTime,
    DateTime? recordTime,
    String? eventTimeZone,
    EPCISVersion? epcisVersion,
    String? disposition,
    String? businessStep,
    GLN? readPoint,
    GLN? businessLocation,
    String? eventHash,
    Map<String, String>? bizData,
    Map<String, String>? extensions,
    DateTime? createdAt,
    String? action,
    String? parentID,
    List<String>? childEPCs,
    List<Map<String, Object>>? childQuantityList,
    List<Map<String, dynamic>>? sourceList,
    List<Map<String, dynamic>>? destinationList,
    List<Map<String, Object>>? sensorElementList,
  }) {
    return AggregationEvent(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      eventTime: eventTime ?? this.eventTime,
      recordTime: recordTime ?? this.recordTime,
      eventTimeZone: eventTimeZone ?? this.eventTimeZone,
      epcisVersion: epcisVersion ?? this.epcisVersion,
      disposition: disposition ?? this.disposition,
      businessStep: businessStep ?? this.businessStep,
      readPoint: readPoint ?? this.readPoint,
      businessLocation: businessLocation ?? this.businessLocation,
      eventHash: eventHash ?? this.eventHash,
      bizData: bizData ?? this.bizData,
      extensions: extensions ?? this.extensions,
      createdAt: createdAt ?? this.createdAt,
      action: action ?? this.action,
      parentID: parentID ?? this.parentID,
      childEPCs: childEPCs ?? this.childEPCs,
      childQuantityList: childQuantityList ?? this.childQuantityList,
      sourceList: sourceList ?? this.sourceList,
      destinationList: destinationList ?? this.destinationList,
      sensorElementList: sensorElementList as List<SensorElement>? ?? this.sensorElementList,
    );
  }
}