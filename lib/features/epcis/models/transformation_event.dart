import 'package:traqtrace_app/features/epcis/models/epcis_event.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/epcis/models/certification_info.dart';

/// TransformationEvent represents EPCIS events that track transformation processes
/// where inputs are transformed into outputs (e.g., manufacturing, processing)
class TransformationEvent extends EPCISEvent {
  final String transformationID;
  final List<String> inputEPCList;
  final List<String> outputEPCList;
  final List<Map<String, dynamic>> inputQuantityList;
  final List<Map<String, dynamic>> outputQuantityList;
  final Map<String, dynamic> ilmd;
  final List<CertificationInfo>? certificationInfo;
    /// Constructor for TransformationEvent
  TransformationEvent({
    String? id,
    required String eventId,
    required DateTime eventTime,
    required DateTime recordTime,
    required String eventTimeZoneOffset,
    String? bizStep,
    String? disposition,
    dynamic readPoint,
    dynamic bizLocation,
    Map<String, String>? bizData,
    required this.transformationID,
    List<String>? inputEPCList,
    List<String>? outputEPCList,
    List<Map<String, dynamic>>? inputQuantityList,
    List<Map<String, dynamic>>? outputQuantityList,
    Map<String, dynamic>? ilmd,
    this.certificationInfo,
  }) : this.inputEPCList = inputEPCList ?? [],
       this.outputEPCList = outputEPCList ?? [],
       this.inputQuantityList = inputQuantityList ?? [],
       this.outputQuantityList = outputQuantityList ?? [],
       this.ilmd = ilmd ?? {},
       super(
         id: id,
         eventId: eventId,
         eventTime: eventTime,
         recordTime: recordTime,
         eventTimeZone: eventTimeZoneOffset,
         businessStep: bizStep,
         disposition: disposition,
         readPoint: readPoint,
         businessLocation: bizLocation,
         bizData: bizData,
       );
    /// Create a TransformationEvent from JSON
  factory TransformationEvent.fromJson(Map<String, dynamic> json) {
    // Parse certification info if available
    List<CertificationInfo>? certInfo;
    if (json['certificationInfo'] != null) {
      try {
        if (json['certificationInfo'] is List) {
          certInfo = (json['certificationInfo'] as List)
              .map((info) => CertificationInfo.fromJson(Map<String, dynamic>.from(info)))
              .toList();
        }
      } catch (e) {
        print("Error parsing certification info in TransformationEvent: $e");
        certInfo = [];
      }
    }
    
    return TransformationEvent(
      id: json['id'],
      eventId: json['eventId'] ?? 'unknown',
      eventTime: json['eventTime'] != null ? DateTime.parse(json['eventTime']) : DateTime.now(),
      recordTime: json['recordTime'] != null ? DateTime.parse(json['recordTime']) : DateTime.now(),
      eventTimeZoneOffset: json['eventTimeZoneOffset'] ?? json['eventTimeZone'] ?? '',
      bizStep: json['businessStep'] ?? json['bizStep'],
      disposition: json['disposition'],
      // Handle readPoint - can be string GLN code or GLN object
      readPoint: json['readPoint'] != null 
          ? (json['readPoint'] is String 
              ? GLN.fromCode(json['readPoint'])
              : GLN.fromJson(json['readPoint']))
          : null,
      // Handle businessLocation - can be string GLN code or GLN object  
      bizLocation: json['businessLocation'] != null 
          ? (json['businessLocation'] is String 
              ? GLN.fromCode(json['businessLocation'])
              : GLN.fromJson(json['businessLocation']))
          : null,
      bizData: json['bizData'] != null ? Map<String, String>.from(json['bizData']) : null,
      transformationID: json['transformationID'],
      inputEPCList: json['inputEPCList'] != null ? List<String>.from(json['inputEPCList']) : [],
      outputEPCList: json['outputEPCList'] != null ? List<String>.from(json['outputEPCList']) : [],
      inputQuantityList: json['inputQuantityList'] != null 
          ? (json['inputQuantityList'] as List).map((item) => Map<String, dynamic>.from(item)).toList()
          : [],
      outputQuantityList: json['outputQuantityList'] != null 
          ? (json['outputQuantityList'] as List).map((item) => Map<String, dynamic>.from(item)).toList()
          : [],
      ilmd: json['ilmd'] != null ? Map<String, dynamic>.from(json['ilmd']) : {},
      certificationInfo: certInfo,
    );
  }

  /// Convert the TransformationEvent to a JSON object
  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    
    // Add eventType for enhanced validation
    json['eventType'] = 'TransformationEvent';
    
    // Add transformation-specific fields
    json['transformationID'] = transformationID;
    
    // Schema validation requires EXACTLY ONE of inputEPCList OR inputQuantityList (not both, not neither)
    // and EXACTLY ONE of outputEPCList OR outputQuantityList (not both, not neither)
    // The fields not chosen must NOT be present in the JSON at all (not even as empty arrays)
    
    // Handle input: either inputEPCList OR inputQuantityList (not both, not neither)
    if (inputEPCList.isNotEmpty) {
      json['inputEPCList'] = inputEPCList;
      // Do NOT include inputQuantityList at all
    } else if (inputQuantityList.isNotEmpty) {
      json['inputQuantityList'] = inputQuantityList;
      // Do NOT include inputEPCList at all
    } else {
      // Must have at least one - default to a single dummy EPC to satisfy minItems: 1
      json['inputEPCList'] = ['urn:epc:id:sgtin:0000000.000000.000000000000'];
    }
    
    // Handle output: either outputEPCList OR outputQuantityList (not both, not neither)  
    if (outputEPCList.isNotEmpty) {
      json['outputEPCList'] = outputEPCList;
      // Do NOT include outputQuantityList at all
    } else if (outputQuantityList.isNotEmpty) {
      json['outputQuantityList'] = outputQuantityList;
      // Do NOT include outputEPCList at all
    } else {
      // Must have at least one - default to a single dummy EPC to satisfy minItems: 1
      json['outputEPCList'] = ['urn:epc:id:sgtin:0000000.000000.000000000000'];
    }
    
    // Include ILMD if present
    if (ilmd.isNotEmpty) {
      json['ilmd'] = ilmd;
    }
    
    return json;
  }
  
  /// Create a copy of this TransformationEvent with the given fields replaced
  TransformationEvent copyWith({    String? id,
    String? eventId,
    DateTime? eventTime,
    DateTime? recordTime,
    String? eventTimeZoneOffset,
    String? bizStep,
    String? disposition,
    dynamic readPoint,
    dynamic bizLocation,
    Map<String, String>? bizData,
    String? transformationID,
    List<String>? inputEPCList,
    List<String>? outputEPCList,
    List<Map<String, dynamic>>? inputQuantityList,
    List<Map<String, dynamic>>? outputQuantityList,
    Map<String, dynamic>? ilmd,
    List<CertificationInfo>? certificationInfo,
  }) {
    return TransformationEvent(      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      eventTime: eventTime ?? this.eventTime,
      recordTime: recordTime ?? this.recordTime,
      eventTimeZoneOffset: eventTimeZoneOffset ?? this.eventTimeZone,
      bizStep: bizStep ?? this.businessStep,
      disposition: disposition ?? this.disposition,
      readPoint: readPoint ?? this.readPoint,
      bizLocation: bizLocation ?? this.businessLocation,
      bizData: bizData ?? this.bizData,
      transformationID: transformationID ?? this.transformationID,
      inputEPCList: inputEPCList ?? this.inputEPCList,
      outputEPCList: outputEPCList ?? this.outputEPCList,
      inputQuantityList: inputQuantityList ?? this.inputQuantityList,
      outputQuantityList: outputQuantityList ?? this.outputQuantityList,
      ilmd: ilmd ?? this.ilmd,
      certificationInfo: certificationInfo ?? this.certificationInfo,
    );
  }
}
