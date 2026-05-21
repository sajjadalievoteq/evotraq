/// Field-level validators for the commissioning operation form.
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

  /// Required. GS1 GTIN format check — must be 8, 12, 13, or 14 digits.
  static String? validateGtinRequired(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'GTIN is required';
    if (!RegExp(r'^\d{8}$|^\d{12,14}$').hasMatch(v)) {
      return 'Invalid GTIN format. Must be 8, 12, 13 or 14 digits.';
    }
    return null;
  }

  /// Required. GS1 batch/lot identifier (AI 10), max 50 chars.
  static String? validateBatchLotNumberRequired(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'Batch/Lot Number is required';
    if (v.length > 50) return 'Batch/Lot Number must be at most 50 characters';
    if (_controlChars.hasMatch(v)) {
      return 'Batch/Lot Number contains invalid control characters';
    }
    return null;
  }

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
