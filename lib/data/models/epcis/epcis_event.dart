import 'package:traqtrace_app/data/models/epcis/certification_info.dart';
import 'package:traqtrace_app/data/models/epcis/cbv_vocabulary_formatter.dart';
import 'package:traqtrace_app/data/models/epcis/sensor_element.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/operations/shared/utils/operation_event_time_codec.dart';
import 'package:uuid/uuid.dart';

class EPCISEvent {
  final String? id;

  final String eventId;

  final DateTime eventTime;

  final DateTime recordTime;

  final String eventTimeZone;

  final EPCISVersion? epcisVersion;

  final String? disposition;

  final String? businessStep;
  
  final GLN? readPoint;

  final GLN? businessLocation;

  final String? eventHash;

  final Map<String, String>? bizData;

  final Map<String, String>? extensions;

  final DateTime? createdAt;
  
  final List<SensorElement>? sensorElementList;
  
  final List<CertificationInfo>? certificationInfo;

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
  factory EPCISEvent.fromJson(Map<String, dynamic> json) {
    List<SensorElement>? sensorElements;
    if (json['sensorElementList'] != null) {
      sensorElements = (json['sensorElementList'] as List)
          .map((element) => SensorElement.fromJson(element))
          .toList();
    }
    
    List<CertificationInfo>? certInfo;
    if (json['certificationInfo'] != null) {
      try {
        print("Processing certification info in EPCISEvent: ${json['certificationInfo']}");

        if (json['certificationInfo'] is List) {
          certInfo = (json['certificationInfo'] as List)
              .map((info) {
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
      eventId: (json['eventId'] != null && json['eventId'].toString().isNotEmpty)
            ? json['eventId'] 
            : 'urn:epcglobal:cbv:epcis:event:${Uuid().v4()}',
      eventTime: DateTime.parse(json['eventTime']).toLocal(),
      recordTime: DateTime.parse(json['recordTime']).toLocal(),
      eventTimeZone: json['eventTimeZone'] ?? json['eventTimeZoneOffset'] ?? '+00:00',
      epcisVersion: json['epcisVersion'] != null 
          ? (json['epcisVersion'].toString() == '1.3' 
              ? EPCISVersion.v1_3 
              : EPCISVersion.v2_0)
          : EPCISVersion.v2_0,
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
  }
  Map<String, dynamic> toJson() {
    final String formattedEventTimeZone = eventTimeZone.isNotEmpty ? eventTimeZone : '+00:00';

    final String formattedEventTime = _formatDateWithTimezone(eventTime);
    final String formattedRecordTime = _formatDateWithTimezone(recordTime);
      
    final Map<String, dynamic> data = {
      'eventId': eventId,
      'eventTime': formattedEventTime,
      'recordTime': formattedRecordTime,
      'eventTimeZoneOffset': formattedEventTimeZone,
      'eventTimeZone': formattedEventTimeZone,
    };
    
    if (id != null) data['id'] = id;
    
    if (epcisVersion != null) {
      if (epcisVersion == EPCISVersion.v1_3) {
        data['epcisVersion'] = '1.3';
      } else {
        data['epcisVersion'] = '2.0';
      }
    } else {
      data['epcisVersion'] = '2.0';
    }
    
    final versionString = epcisVersion == EPCISVersion.v1_3 ? '1.3' : '2.0';

    if (disposition != null) {
      data['disposition'] = CbvVocabularyFormatter.formatDisposition(
        versionString,
        disposition!,
      );
    }

    if (businessStep != null) {
      data['businessStep'] = CbvVocabularyFormatter.formatBizStep(
        versionString,
        businessStep!,
      );
    }
    
    if (readPoint != null) {
      data['readPoint'] = readPoint!.glnCode;
    } else if (businessLocation != null) {
      data['readPoint'] = businessLocation!.glnCode;
    }

    if (businessLocation != null) {
      data['businessLocation'] = businessLocation!.glnCode;
    }
    if (eventHash != null) data['eventHash'] = eventHash;
    if (bizData != null && bizData!.isNotEmpty) {
      data['bizData'] = bizData;
    } else {
      data['bizData'] = {};
    }
    if (extensions != null) data['extensions'] = extensions;
    if (createdAt != null) data['createdAt'] = _formatDateWithTimezone(createdAt!);
    
    if (sensorElementList != null && sensorElementList!.isNotEmpty) {
      data['sensorElementList'] = sensorElementList!.map((element) => element.toJson()).toList();
    }
    
    if (certificationInfo != null && certificationInfo!.isNotEmpty) {
      data['certificationInfo'] = certificationInfo!.map((cert) => cert.toJson()).toList();
    } else {
      data['certificationInfo'] = [{
        "certificateNumber": "default",
        "certificationStandard": "none",
        "certificationAgency": "none"
      }];
    }
    
    return data;
  }

  String _formatDateWithTimezone(DateTime dateTime) {
    return OperationEventTimeCodec.encodeLocal(dateTime);
  }
}

enum EPCISVersion {
  v1_3,

  v2_0,
}