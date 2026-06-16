import 'package:traqtrace_app/data/models/epcis/epcis_event.dart';
import 'package:traqtrace_app/data/models/epcis/cbv_vocabulary_formatter.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/form/utilities/object_event_form_constants.dart';
import 'package:traqtrace_app/features/epcis/validators/epcis_gln_validators.dart';

class ObjectEventFormValidators {
  ObjectEventFormValidators._();

  static String _versionString(EPCISVersion version) =>
      version == EPCISVersion.v2_0 ? '2.0' : '1.3';

  static String parseGlnToCode(String input) =>
      EpcisGlnValidators.parseGlnToCode(input);

  static String? validateLocationGln(String? value, {bool required = true}) =>
      EpcisGlnValidators.validateLocationGln(value, required: required);

  static String? validateBusinessStepCbv(
    String? value, {
    EPCISVersion epcisVersion = EPCISVersion.v2_0,
  }) {
    if (value == null || value.isEmpty) {
      return 'Business Step is required by GS1 standard';
    }
    final versionString = _versionString(epcisVersion);
    final canonical = CbvVocabularyFormatter.canonicalBizStepUrn(value);
    if (!objectEventStandardBusinessSteps.contains(canonical) &&
        !CbvVocabularyFormatter.isValidBizStepFormat(versionString, value)) {
      if (epcisVersion == EPCISVersion.v2_0) {
        return 'Business Step should follow CBV 2.0 format: https://ref.gs1.org/cbv/BizStep-<step>';
      }
      return 'Business Step should follow CBV 1.3 format: urn:epcglobal:cbv:bizstep:<step>';
    }
    return null;
  }

  static String? validateDispositionCbv(String? value) {
    if (value == null || value.isEmpty) {
      return 'Disposition is required by GS1 standard';
    }
    return null;
  }

  static String? validateCustomBusinessStep(
    String value, {
    EPCISVersion epcisVersion = EPCISVersion.v2_0,
  }) {
    final versionString = _versionString(epcisVersion);
    if (!CbvVocabularyFormatter.isValidBizStepFormat(versionString, value)) {
      if (epcisVersion == EPCISVersion.v2_0) {
        return 'Business Step should follow CBV 2.0 format: https://ref.gs1.org/cbv/BizStep-<step>';
      }
      return 'Business Step should follow CBV 1.3 format: urn:epcglobal:cbv:bizstep:<step>';
    }
    return null;
  }

  static String? validateCustomDisposition(
    String value, {
    EPCISVersion epcisVersion = EPCISVersion.v2_0,
  }) {
    final versionString = _versionString(epcisVersion);
    if (!CbvVocabularyFormatter.isValidDispFormat(versionString, value)) {
      if (epcisVersion == EPCISVersion.v2_0) {
        return 'Disposition should follow CBV 2.0 format: https://ref.gs1.org/cbv/Disp-<disposition>';
      }
      return 'Disposition should follow CBV 1.3 format: urn:epcglobal:cbv:disp:<disposition>';
    }
    return null;
  }

  static String? validateTimeZone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Time zone is required by GS1 standard';
    }
    return null;
  }

  static String? validateAction(String? value) {
    if (value == null || value.isEmpty) {
      return 'Action is required by GS1 standard (ADD, OBSERVE, or DELETE)';
    }
    return null;
  }
}
