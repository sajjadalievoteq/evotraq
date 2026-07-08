import 'epcis_event.dart';
import 'epcis_types.dart' as types;
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/data/models/epcis/sensor_element.dart';
import 'package:traqtrace_app/data/models/epcis/certification_info.dart';

class ObjectEvent extends EPCISEvent {
  final List<String>? epcList;
  
  final List<String>? epcClassList;
  
  final List<types.QuantityElement>? quantityList;
  
  final Map<String, dynamic>? ilmd;
  
  final String? action;
  
  final List<types.SourceDestination>? sourceList;
  
  final List<types.SourceDestination>? destinationList;
  
  final String? persistentDisposition;
  
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
    
    json['eventType'] = 'ObjectEvent';
    
    if (epcList != null && epcList!.isNotEmpty) {
      json['epcList'] = epcList;
    } else {
      json.remove('epcList');
    }
    
    
    if (epcList == null || epcList!.isEmpty) {
      if (quantityList != null && quantityList!.isNotEmpty) {
        json['quantityList'] = quantityList!.map((q) => q.toJson()).toList();
      } else {
        json['quantityList'] = [];
      }
    } else {
      json['quantityList'] = [];
    }
    
    if (action != null) {
      json['action'] = action;
    }
    
    if (ilmd != null && ilmd!.isNotEmpty) {
      json['ilmd'] = ilmd;
    }
    
    if (sourceList != null && sourceList!.isNotEmpty) {
      json['sourceList'] = sourceList!.map((s) => {
        'sourceType': s.type,
        'sourceID': s.id
      }).toList();
    }
    
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

    if (certificationInfo != null && certificationInfo!.isNotEmpty) {
      json['certificationInfo'] = certificationInfo!.map((cert) => cert.toJson()).toList();
    } else {
      json['certificationInfo'] = [{
        "certificationId": "default",
        "certificationStandard": "none",
        "certificationAgency": "none"
      }];
    }
    
    return json;
  }
  factory ObjectEvent.fromJson(Map<String, dynamic> json) {
    return ObjectEvent(
      id: json['id']?.toString(),
      eventId: json['eventId']?.toString() ?? '',
      eventTime: json['eventTime'] != null ? DateTime.parse(json['eventTime']) : DateTime.now(),
      recordTime: json['recordTime'] != null ? DateTime.parse(json['recordTime']) : DateTime.now(),
      eventTimeZone: json['eventTimeZone']?.toString() ?? json['eventTimeZoneOffset']?.toString() ?? '+00:00',
      epcisVersion: json['epcisVersion'] != null 
          ? (json['epcisVersion'].toString() == '2.0' || json['epcisVersion'].toString().toLowerCase() == 'v2_0' 
             ? EPCISVersion.v2_0 : EPCISVersion.v1_3)
          : EPCISVersion.v1_3,
      action: json['action']?.toString(),
      disposition: json['disposition']?.toString(),
      businessStep: json['businessStep']?.toString() ?? json['bizStep']?.toString(),
      readPoint: json['readPoint'] != null 
          ? (json['readPoint'] is String 
              ? (json['readPoint'] as String).isNotEmpty ? GLN.fromCode(json['readPoint']) : null
              : GLN.fromJson(Map<String, dynamic>.from(json['readPoint'] as Map))) 
          : null,
      businessLocation: json['businessLocation'] != null 
          ? (json['businessLocation'] is String 
              ? (json['businessLocation'] as String).isNotEmpty ? GLN.fromCode(json['businessLocation']) : null
              : GLN.fromJson(Map<String, dynamic>.from(json['businessLocation'] as Map)))
          : null,
      eventHash: json['eventHash']?.toString(),
      bizData: _parseStringMap(json['bizData']),
      extensions: _parseStringMap(json['extensions']),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      epcList: json['epcList'] != null ? List<String>.from(json['epcList']) : null,
      epcClassList: json['epcClassList'] != null ? List<String>.from(json['epcClassList']) : null,
      quantityList: json['quantityList'] != null 
          ? (json['quantityList'] as List).map((q) => types.QuantityElement.fromJson(Map<String, dynamic>.from(q as Map))).toList() 
          : null,
      ilmd: json['ilmd'] is Map ? Map<String, dynamic>.from(json['ilmd'] as Map) : null,
      sourceList: json['sourceList'] != null 
          ? (json['sourceList'] as List).map((s) => types.SourceDestination.fromJson(Map<String, dynamic>.from(s as Map))).toList() 
          : null,
      destinationList: json['destinationList'] != null 
          ? (json['destinationList'] as List).map((d) => types.SourceDestination.fromJson(Map<String, dynamic>.from(d as Map))).toList() 
          : null,
      persistentDisposition: _parsePersistentDisposition(json['persistentDisposition']),
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
  
  String? get epcClass => epcClassList?.isNotEmpty == true ? epcClassList!.first : null;
  double? get quantity => quantityList?.isNotEmpty == true ? quantityList!.first.quantity : null;
  String? get uom => quantityList?.isNotEmpty == true ? quantityList!.first.uom : null;
}

String? _parsePersistentDisposition(dynamic value) {
  if (value == null) return null;
  if (value is String) return value.isEmpty ? null : value;
  if (value is Map) {
    final setValues = value['set'];
    final unsetValues = value['unset'];
    final parts = <String>[];

    if (setValues is List && setValues.isNotEmpty) {
      parts.add('set: ${setValues.map((item) => item.toString()).join(', ')}');
    }
    if (unsetValues is List && unsetValues.isNotEmpty) {
      parts.add('unset: ${unsetValues.map((item) => item.toString()).join(', ')}');
    }

    return parts.isEmpty ? null : parts.join('; ');
  }

  return value.toString();
}

Map<String, String>? _parseStringMap(dynamic value) {
  if (value == null || value is! Map) return null;
  return value.map(
    (key, item) => MapEntry(key.toString(), item?.toString() ?? ''),
  );
}
