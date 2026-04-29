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

  static String? validateLicensedAgentGlns(String? value) =>
      _validateDelimitedGln13List(
        value,
        fieldName: 'licensed_agent_glns',
        maxLen: 500,
      );

  static String? validateRegulatoryStatus(String? value) =>
      _validateCodeInSet(
        value,
        fieldName: 'regulatory_status',
        allowedCodes: regulatoryStatusCodes,
      );

  static const Set<String> regulatoryStatusCodes = {
    'REGISTERED',
    'UNREGISTERED',
    'SUSPENDED',
    'WITHDRAWN',
    'RECALLED',
  };

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
    if (!controlled) return null;
    if (v.isEmpty) return 'controlled_substance_sched is required when controlled_substance is true';
    if (!controlledSubstanceScheduleCodes.contains(v)) {
      return 'Invalid controlled_substance_sched';
    }
    return null;
  }

  static const Set<String> controlledSubstanceScheduleCodes = {
    // Common US DEA schedules.
    'CI',
    'CII',
    'CIII',
    'CIV',
    'CV',
    // Common UAE-style placeholders.
    'NARCOTIC_CLASS_A',
    'NARCOTIC_CLASS_B',
    'NARCOTIC_CLASS_C',
  };

  static String? _validateDelimitedGln13List(
    String? value, {
    required String fieldName,
    required int maxLen,
  }) {
    final raw = (value ?? '').trim();
    if (raw.isEmpty) return null;
    final lenErr = optionalText(raw, fieldName: fieldName, maxLen: maxLen);
    if (lenErr != null) return lenErr;

    final items =
        raw.split(RegExp(r'[\s,;\n]+')).map((e) => e.trim()).where((e) => e.isNotEmpty);
    for (final gln in items) {
      final err = GtinFieldValidators.validateGln13(
        gln,
        fieldName: fieldName,
        required: false,
      );
      if (err != null) return '$fieldName contains invalid GLN "$gln"';
    }
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

  /// FDA NDC directory values are 10 digits in 3 segment patterns.
  /// We also allow normalized 11-digit (5-4-2 equivalent) forms.
  static String? validateNdcNumber(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return null;

    final compact = v.replaceAll('-', '');
    if (!RegExp(r'^\d+$').hasMatch(compact)) {
      return 'ndc_number must contain digits (optional hyphens)';
    }
    if (compact.length != 10 && compact.length != 11) {
      return 'ndc_number must be 10 or 11 digits';
    }

    // If hyphens are provided, enforce common 10-digit segment formats.
    if (v.contains('-')) {
      final validDashed =
          RegExp(r'^\d{4}-\d{4}-\d{2}$').hasMatch(v) || // 4-4-2
              RegExp(r'^\d{5}-\d{3}-\d{2}$').hasMatch(v) || // 5-3-2
              RegExp(r'^\d{5}-\d{4}-\d{1}$').hasMatch(v); // 5-4-1
      if (!validDashed) {
        return 'ndc_number hyphen format must be 4-4-2, 5-3-2, or 5-4-1';
      }
    }
    return null;
  }

  /// Health Canada DIN is an 8-digit numeric identifier.
  static String? validateDinNumber(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return null;
    if (!RegExp(r'^\d{8}$').hasMatch(v)) {
      return 'din_number must be exactly 8 digits';
    }
    return null;
  }

  /// EAN pharma code uses GTIN-13 check-digit logic.
  static String? validateEanPharmaCode(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return null;
    return GtinFieldValidators.validateGln13(
      v,
      fieldName: 'ean_pharma_code',
      required: false,
    );
  }

  static String? validateDrugClass(String? value) =>
      optionalText(value, fieldName: 'drug_class', maxLen: 100);

  static String? validateTherapeuticClass(String? value) =>
      optionalText(value, fieldName: 'therapeutic_class', maxLen: 100);

  static String? validatePharmacologicalClass(String? value) =>
      optionalText(value, fieldName: 'pharmacological_class', maxLen: 100);

  static String? validateControlClass(String? value) =>
      optionalText(value, fieldName: 'control_class', maxLen: 80);

  static String? validatePrescriptionType(String? value) =>
      optionalText(value, fieldName: 'prescription_type', maxLen: 50);

  static String? validateFdaApplicationNumber(String? value) =>
      optionalText(value, fieldName: 'fda_application_number', maxLen: 50);

  static String? validateEmaProcedureNumber(String? value) =>
      optionalText(value, fieldName: 'ema_procedure_number', maxLen: 50);

  static String? validateBlackBoxWarningText(String? value) =>
      optionalText(value, fieldName: 'black_box_warning_text', maxLen: 1000);

  static String? validateContraindications(String? value) =>
      optionalText(value, fieldName: 'contraindications', maxLen: 1000);

  static String? validateDrugInteractions(String? value) =>
      optionalText(value, fieldName: 'drug_interactions', maxLen: 1000);

  static String? validateNhmnGermanyPzn(String? value) =>
      optionalText(value, fieldName: 'nhmn_germany_pzn', maxLen: 20);

  static String? validateNhmnFranceCip(String? value) =>
      optionalText(value, fieldName: 'nhmn_france_cip', maxLen: 20);

  static String? validateNhmnSpainCn(String? value) =>
      optionalText(value, fieldName: 'nhmn_spain_cn', maxLen: 20);

  static String? validateNhmnBrazilAnvisa(String? value) =>
      optionalText(value, fieldName: 'nhmn_brazil_anvisa', maxLen: 30);

  static String? validateNhmnPortugalAim(String? value) =>
      optionalText(value, fieldName: 'nhmn_portugal_aim', maxLen: 20);

  static String? validateNhmnUsaNdc(String? value) =>
      optionalText(value, fieldName: 'nhmn_usa_ndc', maxLen: 20);

  static String? validateNhmnItalyAifa(String? value) =>
      optionalText(value, fieldName: 'nhmn_italy_aifa', maxLen: 20);

  static String? validateLocalDrugCodeUaeGcc(String? value) =>
      optionalText(value, fieldName: 'local_drug_code_uae_gcc', maxLen: 30);

  static String? validateDataCarrierTypeCode(String? value) =>
      _validateCodeInSet(
        value,
        fieldName: 'data_carrier_type_code',
        allowedCodes: dataCarrierTypeCodes,
      );

  static const Set<String> dataCarrierTypeCodes = {
    'GS1_DATAMATRIX',
    'GS1_128',
    'EAN_13',
    'ITF_14',
    'GS1_QR_CODE',
  };

  /// WHO ATC codes are 7 chars in canonical form; allow up to 10 to preserve
  /// existing tenant data while enforcing uppercase alphanumeric format.
  static String? validateAtcCode(String? value) {
    final v = (value ?? '').trim().toUpperCase();
    if (v.isEmpty) return null;
    if (v.length > 10) return 'atc_code must be at most 10 characters';
    if (!RegExp(r'^[A-Z0-9]+$').hasMatch(v)) {
      return 'atc_code must be uppercase alphanumeric';
    }
    return null;
  }

  static String? validateAdditionalAtcCodes(String? value) {
    final raw = (value ?? '').trim();
    if (raw.isEmpty) return null;
    final items =
        raw.split(RegExp(r'[\s,;\n]+')).map((e) => e.trim()).where((e) => e.isNotEmpty);
    for (final code in items) {
      final err = validateAtcCode(code);
      if (err != null) return 'additional_atc_codes contains invalid entry "$code"';
    }
    return null;
  }

  static String? _validateCodeInSet(
    String? value, {
    required String fieldName,
    required Set<String> allowedCodes,
  }) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return '$fieldName is required';
    if (!allowedCodes.contains(v)) return 'Invalid $fieldName';
    return null;
  }
}

