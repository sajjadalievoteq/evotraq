part of 'gtin_field_validators.dart';

abstract final class _GtinIndicatorLocationValidators {
  static const Set<String> _aiIndicatorCodes = {
    'REQUESTED_BY_LAW',
    'NOT_REQUESTED_BUT_ALLOCATED',
    'NOT_ALLOCATED',
  };

  static String _aiIndicatorUiLabel(String v) => v.replaceAll('_', ' ');

  static String? validateHasBatchNumberIndicator(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'has_batch_number_indicator is required';
    if (!_aiIndicatorCodes.contains(v)) {
      return 'Invalid Has Batch Number Indicator';
    }
    return null;
  }

  static String? validateHasSerialNumberIndicator(
    String? value, {
    required String? batchIndicator,
  }) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'has_serial_number_indicator is required';
    if (!_aiIndicatorCodes.contains(v)) {
      return 'Invalid Has Serial Number Indicator';
    }

    final b = (batchIndicator ?? '').trim();
    if (v == 'REQUESTED_BY_LAW' && b == 'NOT_ALLOCATED') {
      return 'Batch indicator cannot be ${_aiIndicatorUiLabel(b)} when Serial is ${_aiIndicatorUiLabel(v)}';
    }
    return null;
  }

  static String? validateTradeItemRoleFlags({
    required bool isBaseUnit,
    required bool isConsumerUnit,
    required bool isOrderableUnit,
    required bool isDespatchUnit,
    required bool isInvoiceUnit,
    required bool isVariableUnit,
    required String? unitDescriptor,
    required String? indicatorDigit,
    required bool isReadOnly,
  }) {
    if (isReadOnly) return null;

    if (!(isBaseUnit ||
        isConsumerUnit ||
        isOrderableUnit ||
        isDespatchUnit ||
        isInvoiceUnit ||
        isVariableUnit)) {
      return 'At least one Trade Item Role Flag must be set to true';
    }

    final ud = (unitDescriptor ?? '').trim();
    if (isBaseUnit && ud.isNotEmpty && ud != 'BASE_UNIT_OR_EACH') {
      return "When 'Is Trade Item a Base Unit?' is true, Unit Descriptor must be BASE_UNIT_OR_EACH";
    }

    final ind = (indicatorDigit ?? '').trim();
    if (isVariableUnit && ind.isNotEmpty && ind != '9') {
      return "When 'Is Trade Item a Variable Unit?' is true, Indicator Digit must be 9";
    }
    if (ind == '9' && !isVariableUnit) {
      return "Indicator Digit = 9 requires 'Is Trade Item a Variable Unit?' to be true";
    }

    return null;
  }

  static String? validatePackagingType(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return null;
    if (v.length > 70) return 'packaging_type must be at most 70 characters';
    if (RegExp(r'[\x00-\x1F\x7F]').hasMatch(v)) {
      return 'packaging_type contains invalid control characters';
    }
    return null;
  }

  static String? validateUnitOfMeasureTradeItem(String? value) {
    final v = (value ?? '').trim().toUpperCase();
    if (v.isEmpty) return null;
    if (!RegExp(r'^[A-Z0-9]{2,3}$').hasMatch(v)) {
      return 'unit_of_measure must be a UN/ECE Rec 20 code (2–3 chars)';
    }
    return null;
  }

  static String? validateParentGtin(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return null;
    return _GtinCoreValidators.validateGtinCodeOptional(v);
  }

  static String? validateQuantityPerParent(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return null;
    final n = int.tryParse(v);
    if (n == null) return 'quantity_per_parent must be numeric';
    if (n <= 0) return 'quantity_per_parent must be > 0';
    return null;
  }

  static String? validateGln13(
    String? value, {
    required String fieldName,
    bool required = false,
  }) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return required ? '$fieldName is required' : null;
    if (!RegExp(r'^\d{13}$').hasMatch(v)) {
      return '$fieldName must be exactly 13 digits';
    }

    final body = v.substring(0, 12);
    final want = int.parse(v[12]);
    final got = GtinFormat.calculateCheckDigitForBody(body);
    if (want != got) return '$fieldName has invalid check digit';
    return null;
  }

  static String? validateInformationProviderGln(String? value) => validateGln13(
    value,
    fieldName: 'information_provider_gln',
    required: true,
  );
  static String? validateManufacturerGln(String? value) =>
      validateGln13(value, fieldName: 'manufacturer_gln', required: true);

  static String? validateInformationProviderName(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return null;
    if (v.length > 200) {
      return 'information_provider_name must be at most 200 characters';
    }
    if (RegExp(r'[\x00-\x1F\x7F]').hasMatch(v)) {
      return 'information_provider_name contains invalid control characters';
    }
    return null;
  }

  static String? validateCreatedBy(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return null;
    if (v.length > 64) return 'created_by must be at most 64 characters';
    return null;
  }

  static String? validateUpdatedBy(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return null;
    if (v.length > 64) return 'updated_by must be at most 64 characters';
    return null;
  }

  static String? validateTradeItemStatus(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'Trade Item Status is required';
    if (v != 'ADD' && v != 'CHN' && v != 'COR') {
      return "Trade Item Status must be one of: ADD, CHN, COR";
    }
    return null;
  }

  static String? validateProductStatus(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'Status is required';

    const allowed = {'ACTIVE', 'WITHDRAWN', 'SUSPENDED', 'DISCONTINUED'};
    if (!allowed.contains(v)) return 'Invalid Status value';
    return null;
  }
}
