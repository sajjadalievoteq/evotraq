import 'package:traqtrace_app/features/gs1/sgtin/utils/sgtin_validators.dart'
    as sgtin_validators;
abstract final class CommissioningFieldValidators {
  static final RegExp _controlChars = RegExp(r'[\x00-\x1F\x7F]');

  static String? _optionalText(
    String? value, {
    required String fieldName,
    required int maxLen,
  }) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return null;
    if (v.length > maxLen) return '$fieldName must be at most $maxLen characters';
    if (_controlChars.hasMatch(v)) return '$fieldName contains invalid control characters';
    return null;
  }

  static String? validateGtinRequired(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'GTIN is required';
    if (!RegExp(r'^\d{14}$').hasMatch(v)) {
      return 'GTIN must be exactly 14 digits (GTIN-14 for EPCIS EPC URIs).';
    }
    return null;
  }

  static String? validateBatchLotNumberRequired(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'Batch/Lot Number is required';
    return sgtin_validators.validateBatchLotNumber(v);
  }

  static String? validateSerialNumberRequired(String? value) =>
      sgtin_validators.validateSerialNumber(value);

  static String? validateCommissioningReferenceOptional(String? value) =>
      _optionalText(value, fieldName: 'Commissioning Reference', maxLen: 100);

  static String? validateCountryOfOriginAlpha2(String? value) {
    final v = (value ?? '').trim().toUpperCase();
    if (v.isEmpty) return null;
    if (!RegExp(r'^[A-Z]{2}$').hasMatch(v)) {
      return 'Must be a 2-letter ISO 3166-1 alpha-2 code (e.g. AE, SA, GB)';
    }
    return null;
  }

  static String? validateProductionOrderOptional(String? value) =>
      _optionalText(value, fieldName: 'Production Order', maxLen: 100);

  static String? validateProductionLineOptional(String? value) =>
      _optionalText(value, fieldName: 'Production Line', maxLen: 50);

  static String? validateRegulatoryMarketOptional(String? value) =>
      _optionalText(value, fieldName: 'Regulatory Market', maxLen: 50);

  static const Set<String> regulatoryStatusCodes = {
    'APPROVED',
    'REGISTERED',
    'UNREGISTERED',
    'SUSPENDED',
    'WITHDRAWN',
    'RECALLED',
    'PENDING',
  };

  static String? validateRegulatoryStatusOptional(String? value) {
    final v = (value ?? '').trim().toUpperCase();
    if (v.isEmpty) return null;
    if (!regulatoryStatusCodes.contains(v)) {
      final allowed = regulatoryStatusCodes.join(', ');
      return 'Regulatory Status must be one of: $allowed';
    }
    return null;
  }

  static String? validateOperatorIdOptional(String? value) =>
      _optionalText(value, fieldName: 'Operator ID', maxLen: 100);

  static String? validateNotesOptional(String? value) =>
      _optionalText(value, fieldName: 'Notes', maxLen: 500);
}
