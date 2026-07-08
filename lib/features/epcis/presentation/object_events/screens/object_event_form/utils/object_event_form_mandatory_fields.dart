import 'package:traqtrace_app/data/models/epcis/cbv_vocabulary_formatter.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/screens/object_event_form/utils/object_event_form_constants.dart';

class ObjectEventFormMandatoryFields {
  ObjectEventFormMandatoryFields._();

  static bool requiresCommissioningIlmd({
    required String? action,
    required String? businessStep,
    required List<String> epcList,
  }) {
    if (action != 'ADD') return false;
    if (!CbvVocabularyFormatter.isBizStepCommissioning(businessStep)) {
      return false;
    }
    return epcList.any((epc) => epc.toLowerCase().contains('sgtin'));
  }

  static bool requiresShippingDestination(String? businessStep) {
    return CbvVocabularyFormatter.isBizStepName(businessStep, 'shipping');
  }

  static const certificationFields = ['certificationType', 'certificationAgency'];
  static const sourceListFields = ['sourceType', 'sourceID'];
  static const destinationListFields = ['destinationType', 'destinationID'];
  static const quantityEntryFields = ['quantityEpcClass', 'quantityValue'];
  static const ilmdFields = [
    ilmdItemExpirationDateKey,
    ilmdManufacturerOfGoodsKey,
  ];

  static bool groupHasRequiredField({
    required List<String> fieldNames,
    required String? action,
    required String? businessStep,
    required bool epcListEmpty,
    required bool quantityListEmpty,
    required List<String> epcList,
  }) {
    for (final fieldName in fieldNames) {
      if (isFieldMandatory(
        fieldName: fieldName,
        action: action,
        businessStep: businessStep,
        epcListEmpty: epcListEmpty,
        quantityListEmpty: quantityListEmpty,
        epcList: epcList,
      )) {
        return true;
      }
    }
    return false;
  }

  static bool isFieldMandatory({
    required String fieldName,
    required String? action,
    required String? businessStep,
    required bool epcListEmpty,
    required bool quantityListEmpty,
    required List<String> epcList,
  }) {
    const alwaysMandatory = ['action', 'eventTime'];
    if (alwaysMandatory.contains(fieldName)) {
      return true;
    }

    if (['businessStep', 'disposition'].contains(fieldName)) {
      return true;
    }

    if (fieldName == 'epcList' || fieldName == 'quantityList') {
      return epcListEmpty && quantityListEmpty;
    }

    if (fieldName == ilmdItemExpirationDateKey ||
        fieldName == 'ilmdItemExpirationDate') {
      return requiresCommissioningIlmd(
        action: action,
        businessStep: businessStep,
        epcList: epcList,
      );
    }

    if (fieldName == ilmdManufacturerOfGoodsKey ||
        fieldName == 'ilmdManufacturerOfGoods') {
      return requiresCommissioningIlmd(
        action: action,
        businessStep: businessStep,
        epcList: epcList,
      );
    }

    if (fieldName == 'destinationList') {
      return requiresShippingDestination(businessStep);
    }

    if (fieldName == 'sourceType' ||
        fieldName == 'sourceID' ||
        fieldName == 'destinationType' ||
        fieldName == 'destinationID') {
      return true;
    }

    if (fieldName == 'certificationType' ||
        fieldName == 'certificationAgency') {
      return true;
    }

    if (fieldName == 'certificationStandard') {
      return false;
    }

    if (fieldName == 'quantityEpcClass' || fieldName == 'quantityValue') {
      return true;
    }

    return false;
  }
}
