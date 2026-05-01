import 'epcis_event.dart';
import 'epcis_types.dart' as types;
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/epcis/models/sensor_element.dart';
import 'package:traqtrace_app/features/epcis/models/certification_info.dart';

/// ObjectEvent represents EPCIS object events with instance or class-level identifiers
/// Follows GS1 EPCIS 2.0/1.3 standards for tracking and tracing
class ObjectEvent extends EPCISEvent {
  /// List of EPCs involved in this event (instance-level identification)
  final List<String>? epcList;
  
  /// List of EPC classes involved in this event (class-level identification)
  final List<String>? epcClassList;
  
  /// Quantities with their respective units and EPC classes
  final List<types.QuantityElement>? quantityList;
  
  /// Instance/Lot Master Data (for commissioning events)
  final Map<String, dynamic>? ilmd;
  
  /// Action: ADD, OBSERVE, or DELETE (as per GS1 standard)
  final String? action;
  
  /// Source list for products (EPCIS 2.0)
  final List<types.SourceDestination>? sourceList;
  
  /// Destination list for products (EPCIS 2.0)
  final List<types.SourceDestination>? destinationList;
  
  /// Persistent disposition (EPCIS 2.0)
  final String? persistentDisposition;
  
  /// Sensor element list (EPCIS 2.0)
  @override
  final List<SensorElement>? sensorElementList;
  ObjectEvent({
    super.id,
    required super.eventId,
    required super.eventTime,
    required super.recordTime,
    required super.eventTimeZone,
    super.epcisVersion,
    super.disposition,
    super.businessStep,
    super.readPoint,
    super.businessLocation,
    super.eventHash,
    super.bizData,
    super.extensions,
    super.createdAt,
    this.epcList,
    this.epcClassList,
    this.quantityList,
    this.ilmd,
    this.action,
    this.sourceList,
    this.destinationList,
    this.persistentDisposition,
    this.sensorElementList,
    super.certificationInfo,
  });
  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    
    // Always set the event type for ObjectEvent
    json['eventType'] = 'ObjectEvent';
    
    // Schema has a oneOf constraint requiring either epcList or quantityList, but not both
    // Prioritize epcList if present
    if (epcList != null && epcList!.isNotEmpty) {
      json['epcList'] = epcList;
    } else {
      // Remove epcList field completely if empty
      json.remove('epcList');
    }
    
    // Note: epcClassList is not sent to backend as it uses quantityList for class-level events
    
    // Handle quantityList based on epcList presence
    // For the schema oneOf constraint: either use epcList or quantityList, but not both
    if (epcList == null || epcList!.isEmpty) {
      // When no epcList, always include a quantityList (never null) to satisfy schema
      if (quantityList != null && quantityList!.isNotEmpty) {
        json['quantityList'] = quantityList!.map((q) => q.toJson()).toList();
      } else {
        json['quantityList'] = []; // Empty array instead of null or omitting
      }
    } else {
      // If epcList is present, include an empty quantityList array
      // Schema validation allows empty arrays, but not null or missing
      json['quantityList'] = [];
    }
    
    if (action != null) {
      json['action'] = action;
    }
    
    if (ilmd != null && ilmd!.isNotEmpty) {
      json['ilmd'] = ilmd;
    }
    
    // Handle sourceList - ensure each item has sourceType and sourceID fields as required by schema
    if (sourceList != null && sourceList!.isNotEmpty) {
      json['sourceList'] = sourceList!.map((s) => {
        'sourceType': s.type,
        'sourceID': s.id
      }).toList();
    }
    
    // Handle destinationList - ensure each item has destinationType and destinationID fields as required by schema
    if (destinationList != null && destinationList!.isNotEmpty) {
      json['destinationList'] = destinationList!.map((d) => {
        'destinationType': d.type,
        'destinationID': d.id
      }).toList();
    }
    
    if (persistentDisposition != null && persistentDisposition!.isNotEmpty) {
      json['persistentDisposition'] = persistentDisposition;
    }
    
    if (sensorElementList != null && sensorElementList!.isNotEmpty) {
      json['sensorElementList'] = sensorElementList!.map((e) => e.toJson()).toList();
    }
    
    // For certification info, ensure it's an array of objects (not a single object)
    // The backend expects an array of CertificationInfoDTO objects
    if (certificationInfo != null && certificationInfo!.isNotEmpty) {
      json['certificationInfo'] = certificationInfo!.map((cert) => cert.toJson()).toList();
    } else {
      // Provide a default array with one object to satisfy schema
      json['certificationInfo'] = [{
        "certificationId": "default",
        "certificationStandard": "none",
        "certificationAgency": "none"
      }];
    }
    
    return json;
  }
    /// Create an ObjectEvent from a JSON object
  factory ObjectEvent.fromJson(Map<String, dynamic> json) {
    return ObjectEvent(
      id: json['id'],
      eventId: json['eventId'] ?? '',
      eventTime: json['eventTime'] != null ? DateTime.parse(json['eventTime']) : DateTime.now(),
      recordTime: json['recordTime'] != null ? DateTime.parse(json['recordTime']) : DateTime.now(),
      eventTimeZone: json['eventTimeZone'] ?? json['eventTimeZoneOffset'] ?? '+00:00', // Use same logic as parent class
      epcisVersion: json['epcisVersion'] != null 
          ? (json['epcisVersion'].toString() == '2.0' || json['epcisVersion'].toString().toLowerCase() == 'v2_0' 
             ? EPCISVersion.v2_0 : EPCISVersion.v1_3)
          : EPCISVersion.v1_3,
      action: json['action'],
      disposition: json['disposition'],
      businessStep: json['businessStep'],
      readPoint: json['readPoint'] != null 
          ? (json['readPoint'] is String 
              ? (json['readPoint'] as String).isNotEmpty ? GLN.fromCode(json['readPoint']) : null
              : GLN.fromJson(json['readPoint'])) 
          : null,
      businessLocation: json['businessLocation'] != null 
          ? (json['businessLocation'] is String 
              ? (json['businessLocation'] as String).isNotEmpty ? GLN.fromCode(json['businessLocation']) : null
              : GLN.fromJson(json['businessLocation']))
          : null,
      eventHash: json['eventHash'],
      bizData: json['bizData'] != null ? Map<String, String>.from(json['bizData']) : null,
      extensions: json['extensions'] != null ? Map<String, String>.from(json['extensions']) : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      epcList: json['epcList'] != null ? List<String>.from(json['epcList']) : null,
      epcClassList: json['epcClassList'] != null ? List<String>.from(json['epcClassList']) : null,
      quantityList: json['quantityList'] != null 
          ? (json['quantityList'] as List).map((q) => types.QuantityElement.fromJson(q)).toList() 
          : null,
      ilmd: json['ilmd'],
      sourceList: json['sourceList'] != null 
          ? (json['sourceList'] as List).map((s) => types.SourceDestination.fromJson(s)).toList() 
          : null,
      destinationList: json['destinationList'] != null 
          ? (json['destinationList'] as List).map((d) => types.SourceDestination.fromJson(d)).toList() 
          : null,
      persistentDisposition: json['persistentDisposition'],
      sensorElementList: json['sensorElementList'] != null 
          ? (() {
              try {
                final sensorList = json['sensorElementList'] as List;
                return sensorList.map<SensorElement>((e) {
                  if (e is Map<String, dynamic>) {
                    return SensorElement.fromJson(e);
                  } else if (e is Map) {
                    return SensorElement.fromJson(Map<String, dynamic>.from(e));
                  } else {
                    // Return an empty sensor element for non-map items
                    return SensorElement(measurements: []);
                  }
                }).toList();
              } catch (error) {
                return <SensorElement>[];
              }
            })()
          : null,
      certificationInfo: json['certificationInfo'] != null 
          ? (() {
              try {
                final certList = json['certificationInfo'] as List;
                return certList.map<CertificationInfo>((c) {
                  if (c is Map<String, dynamic>) {
                    return CertificationInfo.fromJson(c);
                  } else if (c is Map) {
                    return CertificationInfo.fromJson(Map<String, dynamic>.from(c));
                  } else {
                    return const CertificationInfo();
                  }
                }).toList();
              } catch (error) {
                return <CertificationInfo>[];
              }
            })()
          : null,
    );
  }
    /// Create a copy of this ObjectEvent with the given fields replaced
  ObjectEvent copyWith({
    String? id,
    String? eventId,
    DateTime? eventTime,
    DateTime? recordTime,
    String? eventTimeZone,
    EPCISVersion? epcisVersion,
    String? action,
    String? disposition,
    String? businessStep,
    GLN? readPoint,
    GLN? businessLocation,
    String? eventHash,
    Map<String, String>? bizData,
    Map<String, String>? extensions,
    DateTime? createdAt,
    List<String>? epcList,
    List<String>? epcClassList,
    List<types.QuantityElement>? quantityList,
    Map<String, dynamic>? ilmd,
    List<types.SourceDestination>? sourceList,
    List<types.SourceDestination>? destinationList,
    String? persistentDisposition,
    List<SensorElement>? sensorElementList,
  }) {
    return ObjectEvent(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      eventTime: eventTime ?? this.eventTime,
      recordTime: recordTime ?? this.recordTime,
      eventTimeZone: eventTimeZone ?? this.eventTimeZone,
      epcisVersion: epcisVersion ?? this.epcisVersion,
      action: action ?? this.action,
      disposition: disposition ?? this.disposition,
      businessStep: businessStep ?? this.businessStep,
      readPoint: readPoint ?? this.readPoint,
      businessLocation: businessLocation ?? this.businessLocation,
      eventHash: eventHash ?? this.eventHash,
      bizData: bizData ?? this.bizData,
      extensions: extensions ?? this.extensions,
      createdAt: createdAt ?? this.createdAt,
      epcList: epcList ?? this.epcList,
      epcClassList: epcClassList ?? this.epcClassList,
      quantityList: quantityList ?? this.quantityList,
      ilmd: ilmd ?? this.ilmd,
      sourceList: sourceList ?? this.sourceList,
      destinationList: destinationList ?? this.destinationList,
      persistentDisposition: persistentDisposition ?? this.persistentDisposition,
      sensorElementList: sensorElementList ?? this.sensorElementList,
    );
  }
  
  // For backward compatibility with existing service implementations
  String? get epcClass => epcClassList?.isNotEmpty == true ? epcClassList!.first : null;
  double? get quantity => quantityList?.isNotEmpty == true ? quantityList!.first.quantity : null;
  String? get uom => quantityList?.isNotEmpty == true ? quantityList!.first.uom : null;
}
