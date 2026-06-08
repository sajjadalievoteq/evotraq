import 'package:traqtrace_app/features/gs1/sgtin/utils/sgtin_validators.dart'
    as sgtin_validators;
///
/// Follows the same abstract-final-class pattern used by [GtinFieldValidators]
/// and [GlnFieldValidators] so validators can be referenced directly in
/// [GtinValidatedField.validator] without any instance state.
abstract final class CommissioningFieldValidators {
  static final RegExp _controlChars = RegExp(r'[\x00-\x1F\x7F]');

  // ---------------------------------------------------------------------------
  // Shared helper
  // ---------------------------------------------------------------------------

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

  // ---------------------------------------------------------------------------
  // Product Info fields
  // ---------------------------------------------------------------------------

  /// Required. GS1 EPCIS requires GTIN-14 (14 digits, zero-padded).
  /// Shorter GTINs (8, 12, 13) must be padded to 14 digits before manual entry.
  static String? validateGtinRequired(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'GTIN is required';
    if (!RegExp(r'^\d{14}$').hasMatch(v)) {
      return 'GTIN must be exactly 14 digits (GTIN-14 for EPCIS EPC URIs).';
    }
    return null;
  }

  /// Required. GS1 batch/lot identifier (AI 10), 1–20 chars, file-7 charset.
  static String? validateBatchLotNumberRequired(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'Batch/Lot Number is required';
    return sgtin_validators.validateBatchLotNumber(v);
  }

  /// Required for commissioning. GS1 AI(21) serial — 1–20 chars, file-7 charset.
  static String? validateSerialNumberRequired(String? value) =>
      sgtin_validators.validateSerialNumber(value);

  /// Optional free-text commissioning reference, max 100 chars.
  static String? validateCommissioningReferenceOptional(String? value) =>
      _optionalText(value, fieldName: 'Commissioning Reference', maxLen: 100);

  // ---------------------------------------------------------------------------
  // Additional ILMD / regulatory fields
  // ---------------------------------------------------------------------------

  /// Optional. ISO 3166-1 alpha-2 country code — exactly 2 ASCII letters.
  ///
  /// Required for UAE Tatmeen submissions (AE) and similar track-and-trace
  /// regulatory mandates. Input is accepted in any case; pass
  /// [TextCapitalization.characters] on the keyboard for UX consistency.
  static String? validateCountryOfOriginAlpha2(String? value) {
    final v = (value ?? '').trim().toUpperCase();
    if (v.isEmpty) return null;
    if (!RegExp(r'^[A-Z]{2}$').hasMatch(v)) {
      return 'Must be a 2-letter ISO 3166-1 alpha-2 code (e.g. AE, SA, GB)';
    }
    return null;
  }

  /// Optional. Production/work-order reference number, max 100 chars.
  ///
  /// Stored in the EPCIS [bizTransactionList] with type
  /// `urn:epcglobal:cbv:btt:prodorder`.
  static String? validateProductionOrderOptional(String? value) =>
      _optionalText(value, fieldName: 'Production Order', maxLen: 100);

  /// Optional. Production line identifier, max 50 chars.
  static String? validateProductionLineOptional(String? value) =>
      _optionalText(value, fieldName: 'Production Line', maxLen: 50);

  /// Optional. Target regulatory market (e.g. UAE, KSA, EU), max 50 chars.
  static String? validateRegulatoryMarketOptional(String? value) =>
      _optionalText(value, fieldName: 'Regulatory Market', maxLen: 50);

  /// Known regulatory status codes.
  static const Set<String> regulatoryStatusCodes = {
    'APPROVED',
    'REGISTERED',
    'UNREGISTERED',
    'SUSPENDED',
    'WITHDRAWN',
    'RECALLED',
    'PENDING',
  };

  /// Optional. Must be one of [regulatoryStatusCodes] when provided.
  ///
  /// Input is normalised to uppercase before checking so "approved" == "APPROVED".
  static String? validateRegulatoryStatusOptional(String? value) {
    final v = (value ?? '').trim().toUpperCase();
    if (v.isEmpty) return null;
    if (!regulatoryStatusCodes.contains(v)) {
      final allowed = regulatoryStatusCodes.join(', ');
      return 'Regulatory Status must be one of: $allowed';
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Personnel / notes
  // ---------------------------------------------------------------------------

  /// Optional. Operator identifier, max 100 chars.
  static String? validateOperatorIdOptional(String? value) =>
      _optionalText(value, fieldName: 'Operator ID', maxLen: 100);

  /// Optional. Free-text notes, max 500 chars.
  static String? validateNotesOptional(String? value) =>
      _optionalText(value, fieldName: 'Notes', maxLen: 500);
}
