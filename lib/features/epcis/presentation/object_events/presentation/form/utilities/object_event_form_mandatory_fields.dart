import 'package:traqtrace_app/data/models/epcis/epcis_event.dart';

/// Determines whether a form field is mandatory for the current event context.
class ObjectEventFormMandatoryFields {
  ObjectEventFormMandatoryFields._();

  static bool isFieldMandatory({
    required String fieldName,
    required EPCISVersion epcisVersion,
    required String? action,
    required bool epcListEmpty,
    required bool quantityListEmpty,
  }) {
    final bool isEpcis20 = epcisVersion == EPCISVersion.v2_0;

    const alwaysMandatory = ['action', 'eventTime', 'eventTimeZone'];
    if (alwaysMandatory.contains(fieldName)) {
      return true;
    }

    if (['businessStep', 'disposition'].contains(fieldName)) {
      return true;
    }

    if (fieldName == 'epcList' || fieldName == 'quantityList') {
      return epcListEmpty && quantityListEmpty;
    }

    if (action == 'ADD') {
      if (fieldName == 'ilmd' || fieldName == 'lotNumber') {
        return true;
      }
      if (fieldName == 'bizData') {
        return false;
      }
    }

    if (action == 'OBSERVE' && fieldName == 'readPointGLN') {
      return true;
    }

    if (fieldName == 'businessLocationGLN') {
      return true;
    }

    if (isEpcis20) {
      if (fieldName == 'readPointGLN') {
        return true;
      }
      if (fieldName == 'certificationInfo' || fieldName == 'sensorElementList') {
        return false;
      }
    }

    return false;
  }
}
