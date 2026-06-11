import 'package:traqtrace_app/data/models/epcis/certification_info.dart';
import 'package:traqtrace_app/data/models/epcis/epcis_event.dart';
import 'package:traqtrace_app/data/models/epcis/object_event.dart';
import 'package:traqtrace_app/data/models/epcis/sensor_element.dart';

/// Converts between API/event model representations and form state.
class ObjectEventFormEventMapper {
  ObjectEventFormEventMapper._();

  static List<SensorElement> mapListToSensorElementList(List<dynamic> maps) {
    final result = <SensorElement>[];

    for (final element in maps) {
      try {
        if (element is SensorElement) {
          result.add(element);
        } else if (element is Map<String, dynamic>) {
          result.add(SensorElement.fromJson(element));
        } else if (element is Map) {
          result.add(
            SensorElement.fromJson(Map<String, dynamic>.from(element)),
          );
        } else {
          result.add(SensorElement(measurements: []));
        }
      } catch (_) {
        result.add(SensorElement(measurements: []));
      }
    }

    return result;
  }

  static List<CertificationInfo> mapListToCertificationInfoList(
    List<dynamic> maps,
  ) {
    final result = <CertificationInfo>[];

    for (final map in maps) {
      try {
        if (map is CertificationInfo) {
          result.add(map);
        } else if (map is Map<String, dynamic>) {
          result.add(CertificationInfo.fromJson(map));
        } else if (map is Map) {
          result.add(
            CertificationInfo.fromJson(Map<String, dynamic>.from(map)),
          );
        }
      } catch (_) {
        // Silently skip invalid entries.
      }
    }

    return result;
  }

  static void debugObjectEvent(ObjectEvent event) {
    print('\n======== OBJECT EVENT PAYLOAD ========');
    print('Event ID: ${event.eventId}');
    print('Event Type: ObjectEvent');
    print('Event Time: ${event.eventTime}');
    print('Record Time: ${event.recordTime}');
    print('Time Zone: ${event.eventTimeZone}');
    if (event.epcisVersion == EPCISVersion.v1_3) {
      print('EPCIS Version: 1.3');
    } else {
      print('EPCIS Version: 2.0');
    }
    print('Action: ${event.action}');
    print('Business Step: ${event.businessStep}');
    print('Disposition: ${event.disposition}');
    print('Read Point: ${event.readPoint?.glnCode}');
    print('Business Location: ${event.businessLocation?.glnCode}');

    print('\n---- Schema Validation Fields ----');
    print(
      'epcList: ${event.epcList != null ? "present (${event.epcList!.length} items)" : "null"}',
    );
    print(
      'quantityList: ${event.quantityList != null ? "present (${event.quantityList!.length} items)" : "null"}',
    );

    if (event.certificationInfo != null) {
      print(
        'certificationInfo: present (${event.certificationInfo!.length} items)',
      );
      print(
        'certificationInfo format: ${event.certificationInfo!.map((c) => c.toJson()).toList()}',
      );
    } else {
      print('certificationInfo: null');
    }

    if (event.epcList != null && event.epcList!.isNotEmpty) {
      print('\nEPCs: ${event.epcList!.length} items');
      for (final epc in event.epcList!.take(3)) {
        print('  - $epc');
      }
      if (event.epcList!.length > 3) {
        print('  - ... (${event.epcList!.length - 3} more)');
      }
    }

    if (event.ilmd != null && event.ilmd!.isNotEmpty) {
      print('\nILMD: ${event.ilmd!.length} items');
      event.ilmd!.forEach((key, value) {
        print('  - $key: $value');
      });
    }

    print('\n---- JSON PAYLOAD TO BACKEND ----');
    try {
      print('Full JSON: ${event.toJson()}');
    } catch (e) {
      print('Error serializing to JSON: $e');
    }

    print('=====================================\n');
  }
}
