import 'package:traqtrace_app/features/gs1/gtin/utils/gtin_field_validators.dart';

abstract final class PharmaFieldValidators {
  static String? requiredText(String? value, {required String fieldName, required int maxLen}) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return '$fieldName is required';
    if (v.length > maxLen) return '$fieldName must be at most $maxLen characters';
    if (RegExp(r'[\x00-\x1F\x7F]').hasMatch(v)) {
      return '$fieldName contains invalid control characters';
    }
    return null;
  }

  static String? optionalText(String? value, {required String fieldName, required int maxLen}) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return null;
    if (v.length > maxLen) return '$fieldName must be at most $maxLen characters';
    if (RegExp(r'[\x00-\x1F\x7F]').hasMatch(v)) {
      return '$fieldName contains invalid control characters';
    }
    return null;
  }

  static String? validateRegulatedProductName(String? value) =>
      requiredText(value, fieldName: 'regulated_product_name', maxLen: 200);

  static String? validateDosageFormTypeCode(String? value) =>
      requiredText(value, fieldName: 'dosage_form_code', maxLen: 30);

  static String? validateRouteOfAdministrationCode(String? value) =>
      requiredText(value, fieldName: 'route_of_administration', maxLen: 30);

  static String? validateMahGln(String? value) =>
      GtinFieldValidators.validateGln13(value, fieldName: 'mah_gln', required: true);

  static String? validateMahName(String? value) =>
      requiredText(value, fieldName: 'mah_name', maxLen: 200);

  static String? validateMahCountry(String? value) =>
      GtinFieldValidators.validateIso3166Numeric3(value, fieldName: 'mah_country');

  static String? validateMaNumber(String? value) =>
      optionalText(value, fieldName: 'ma_number', maxLen: 50);

  static String? validateRegulatoryStatus(String? value) =>
      requiredText(value, fieldName: 'regulatory_status', maxLen: 20);

  static const Set<String> prescriptionStatusCodes = {
    'RX',
    'OTC',
    'BEHIND_COUNTER',
    'HOSPITAL_ONLY',
  };

  static String? validatePrescriptionStatus(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'prescription_status is required';
    if (!prescriptionStatusCodes.contains(v)) return 'Invalid prescription_status';
    return null;
  }

  static String? validateControlledSubstanceSchedule(String? value, {required bool controlled}) {
    final v = (value ?? '').trim();
    if (!controlled) return v.isEmpty ? null : null;
    if (v.isEmpty) return 'controlled_substance_sched is required when controlled_substance is true';
    if (v.length > 10) return 'controlled_substance_sched must be at most 10 characters';
    return null;
  }

  static String? validateShelfLifeMonths(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'shelf_life_months is required';
    final n = int.tryParse(v);
    if (n == null) return 'shelf_life_months must be numeric';
    if (n < 1 || n > 360) return 'shelf_life_months must be between 1 and 360';
    return null;
  }

  static String? validateShelfLifeAfterOpenDays(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return null;
    final n = int.tryParse(v);
    if (n == null) return 'shelf_life_after_open_days must be numeric';
    if (n <= 0) return 'shelf_life_after_open_days must be > 0';
    return null;
  }

  static String? validateCountryOfManufacture(String? value) =>
      GtinFieldValidators.validateIso3166Numeric3(value, fieldName: 'country_of_manufacture');

  static String? validatePackSizeDescription(String? value) =>
      optionalText(value, fieldName: 'pack_size_description', maxLen: 100);

  static String? validateStorageTemp(String? value, {required String fieldName}) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return null;
    final n = double.tryParse(v);
    if (n == null) return '$fieldName must be numeric';
    // Spec uses NUMERIC(6,2); keep UI simple.
    return null;
  }
}

