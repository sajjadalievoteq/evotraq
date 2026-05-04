import 'package:traqtrace_app/features/gs1/gln/utils/gln_format.dart';
import 'package:traqtrace_app/features/gs1/gln/utils/gln_ui_constants.dart';
import 'package:traqtrace_app/features/gs1/gtin/utils/gtin_field_validators.dart';

/// Callback for GLN core groups to report field errors (same shape as GTIN detail forms).
typedef GlnFormSetFieldError = void Function(String field, String? error);

/// GLN master-data **input** validation for forms (parallel to [GtinFieldValidators]).
///
/// Frontend-only rules aligned with GS1 General Specifications (GLN, AI 254), ISO 17442 (LEI),
/// ISO 3166-1 numeric country, and typical DB string limits (255). Pure functions only.
abstract final class GlnFieldValidators {
  // --- Length / charset (align with VARCHAR(255) and GS1 field sizes) ---

  static const int _maxDbVarchar = 255;
  static const int _maxAi254 = 20;
  static const int _maxDigitalAddressValue = 2000;
  static const int _maxPhoneChars = 40;
  static const int _minPhoneChars = 7;

  static final RegExp _controlChars = RegExp(r'[\x00-\x1F\x7F]');

  /// GS1 AI 254: max 20; subset of 82-character alphanumeric (practical: [A–Z0–9] + common separators).
  static final RegExp _ai254Charset = RegExp(r'^[A-Za-z0-9\-_./&+ ]+$');

  /// Optional comma-separated codes (uppercase GS1-style tokens).
  static final RegExp _roleToken = RegExp(r'^[A-Z][A-Z0-9_]{1,63}$');

  static String? _rejectControlOrTooLong(String v, int max, String fieldLabel) {
    if (_controlChars.hasMatch(v)) {
      return GlnValidationConstants.invalidControlChars(fieldLabel);
    }
    if (v.length > max) {
      return GlnValidationConstants.mustBeAtMostChars(fieldLabel, max);
    }
    return null;
  }

  // --- GLN code (primary key) ---

  /// Required GLN: strip separators, length 13, GS1 Mod-10.
  static String? validateGlnCode(String? value) {
    final s = GlnFormat.stripGlnInput(value);
    if (s.isEmpty) {
      return GlnValidationConstants.glnCodeRequired;
    }
    if (!RegExp(r'^\d{13}$').hasMatch(s)) {
      return GlnValidationConstants.glnMustBe13Digits;
    }
    if (!GlnFormat.isValidGln(s)) {
      return GlnValidationConstants.glnInvalidCheckDigit;
    }
    return null;
  }

  /// Optional GLN (e.g. parent). Empty is valid.
  static String? validateGlnCodeOptional(String? value) {
    final s = GlnFormat.stripGlnInput(value);
    if (s.isEmpty) return null;
    return validateGlnCode(s);
  }

  static bool isGlnCodeValid(String? value) => validateGlnCode(value) == null;

  // --- Parent / hierarchy ---

  static String? validateParentGlnOptional(String? value) {
    final s = GlnFormat.stripGlnInput(value);
    if (s.isEmpty) return null;
    return validateGlnCode(s);
  }

  // --- ISO / registry-style fields (reuse GTIN helpers where aligned) ---

  /// Optional ISO 3166-1 numeric (3 digits). Empty allowed.
  static String? validateCountryOfIncorporationOptional(String? value) =>
      GtinFieldValidators.validateCountryOfOrigin(value);

  /// Required location display name.
  static String? validateLocationNameRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return GlnValidationConstants.locationNameRequired;
    }
    final v = value.trim();
    return _rejectControlOrTooLong(
      v,
      _maxDbVarchar,
      GlnValidationConstants.fieldLocationName,
    );
  }

  /// Required single address line.
  static String? validateAddressLine1Required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return GlnValidationConstants.addressLine1Required;
    }
    final v = value.trim();
    return _rejectControlOrTooLong(
      v,
      _maxDbVarchar,
      GlnValidationConstants.fieldAddressLine1,
    );
  }

  /// Optional second address line (same DB limit as line 1).
  static String? validateAddressLine2Optional(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return null;
    return _rejectControlOrTooLong(
      v,
      _maxDbVarchar,
      GlnValidationConstants.fieldAddressLine2,
    );
  }

  static String? validateCityRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return GlnValidationConstants.cityRequired;
    }
    final v = value.trim();
    return _rejectControlOrTooLong(
      v,
      _maxDbVarchar,
      GlnValidationConstants.fieldCity,
    );
  }

  /// DB schema: `state_province VARCHAR(255)` — column is nullable (not NOT NULL),
  /// but the form treats it as required for postal address completeness.
  static String? validateStateProvinceRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return GlnValidationConstants.stateProvinceRequired;
    }
    final v = value.trim();
    return _rejectControlOrTooLong(
      v,
      _maxDbVarchar,
      GlnValidationConstants.fieldStateProvince,
    );
  }

  static String? validatePostalCodeRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return GlnValidationConstants.postalCodeRequired;
    }
    final v = value.trim();
    return _rejectControlOrTooLong(
      v,
      64,
      GlnValidationConstants.fieldPostalCode,
    );
  }

  static String? validateCountryRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return GlnValidationConstants.countryRequired;
    }
    final v = value.trim();
    return _rejectControlOrTooLong(
      v,
      _maxDbVarchar,
      GlnValidationConstants.fieldCountry,
    );
  }

  // --- Contact ---

  static String? validateEmailOptional(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return null;
    if (v.length > 254) return GlnValidationConstants.emailMaxLength;
    if (_controlChars.hasMatch(v)) return GlnValidationConstants.emailInvalidChars;
    // Practical RFC 5322 subset for forms
    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(v)) {
      return GlnValidationConstants.emailInvalidFormat;
    }
    return null;
  }

  /// Optional contact name.
  static String? validateContactNameOptional(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return null;
    return _rejectControlOrTooLong(
      v,
      _maxDbVarchar,
      GlnValidationConstants.fieldContactName,
    );
  }

  /// Optional phone — international-friendly (E.164-ish display, not strict E.164).
  static String? validateContactPhoneOptional(String? value) {
    final raw = (value ?? '').trim();
    if (raw.isEmpty) return null;
    if (_controlChars.hasMatch(raw)) {
      return 'Phone contains invalid control characters';
    }
    if (raw.length > _maxPhoneChars) {
      return 'Phone must be at most $_maxPhoneChars characters';
    }
    final compact = raw.replaceAll(RegExp(r'[\s\-().]'), '');
    if (compact.length < _minPhoneChars) {
      return GlnValidationConstants.phoneTooShort;
    }
    if (!RegExp(r'^\+?[0-9]+$').hasMatch(compact)) {
      return GlnValidationConstants.phoneFormatHint;
    }
    return null;
  }

  // --- GS1 AI 254 (extension component) ---

  /// GS1 AI 254: internal sub-location; max 20 characters; alphanumeric + limited punctuation (GS1 subset).
  static String? validateGlnExtensionComponentOptional(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return null;
    if (v.length > _maxAi254) {
      return GlnValidationConstants.extensionAi254Max(_maxAi254);
    }
    if (!_ai254Charset.hasMatch(v)) {
      return GlnValidationConstants.extensionAi254Charset;
    }
    return null;
  }

  // --- LEI (ISO 17442) ---

  /// Optional LEI: 20 characters, ISO 7064 Mod 97-10.
  static String? validateLeiOptional(String? value) {
    final v = (value ?? '').trim().toUpperCase();
    if (v.isEmpty) return null;
    if (v.length != 20) {
      return GlnValidationConstants.leiLength;
    }
    if (!RegExp(r'^[0-9A-Z]{20}$').hasMatch(v)) {
      return GlnValidationConstants.leiAlphanumeric;
    }
    if (!GlnFormat.isValidLei(v)) {
      return GlnValidationConstants.leiInvalidCheck;
    }
    return null;
  }

  // --- Names / tax ---

  static String? validateRegisteredLegalNameOptional(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return null;
    return _rejectControlOrTooLong(v, _maxDbVarchar, 'Registered legal name');
  }

  static String? validateTradingNameOptional(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return null;
    return _rejectControlOrTooLong(
      v,
      _maxDbVarchar,
      GlnValidationConstants.fieldTradingName,
    );
  }

  /// Free-text tax / VAT ID (no country-specific rules on frontend).
  static String? validateTaxRegistrationOptional(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return null;
    return _rejectControlOrTooLong(
      v,
      _maxDbVarchar,
      GlnValidationConstants.taxVatField,
    );
  }

  // --- URL ---

  /// `http` or `https` with host; empty allowed.
  static String? validateHttpsUrlOptional(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return null;
    if (v.length > 2000) return GlnValidationConstants.urlMax;
    final uri = Uri.tryParse(v);
    if (uri == null || !uri.hasScheme) {
      return GlnValidationConstants.urlValidWithScheme;
    }
    final s = uri.scheme.toLowerCase();
    if (s != 'http' && s != 'https') {
      return GlnValidationConstants.urlHttpHttpsOnly;
    }
    if (!uri.hasAuthority || uri.host.isEmpty) {
      return GlnValidationConstants.urlHostRequired;
    }
    return null;
  }

  // --- Comma-separated role lists ---

  /// Comma-separated uppercase role codes (e.g. MANUFACTURER, DISTRIBUTOR). Empty allowed.
  static String? validateCommaSeparatedRolesOptional(String? value) {
    final raw = (value ?? '').trim();
    if (raw.isEmpty) return null;
    if (raw.length > _maxDbVarchar) {
      return GlnValidationConstants.rolesMaxLen(_maxDbVarchar);
    }
    final parts = raw.split(',').map((s) => s.trim().toUpperCase()).where((s) => s.isNotEmpty);
    for (final token in parts) {
      if (!_roleToken.hasMatch(token)) {
        return 'Each role must be a code like MANUFACTURER (letters, digits, underscore)';
      }
    }
    return null;
  }

  // --- Informational GLN structure fields ---

  /// GS1 Company Prefix: digits only, typical allocation length 4–12 (GS1).
  static String? validateGs1CompanyPrefixOptional(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return null;
    if (!RegExp(r'^\d+$').hasMatch(v)) {
      return GlnValidationConstants.gs1PrefixDigitsOnly;
    }
    if (v.length < 4 || v.length > 12) {
      return GlnValidationConstants.gs1PrefixLength;
    }
    return null;
  }

  /// Location reference digits (informational); numeric, up to 11 digits.
  static String? validateLocationReferenceOptional(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return null;
    if (!RegExp(r'^\d{1,11}$').hasMatch(v)) {
      return GlnValidationConstants.locationRefDigits;
    }
    return null;
  }

  /// Standalone check digit field: single 0–9 or empty.
  static String? validateCheckDigitOptional(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return null;
    if (!RegExp(r'^\d$').hasMatch(v)) {
      return GlnValidationConstants.checkDigitSingle;
    }
    return null;
  }

  /// Mobile / vehicle / vessel identifier — free text within limit.
  static String? validateMobileLocationIdOptional(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return null;
    return _rejectControlOrTooLong(
      v,
      128,
      GlnValidationConstants.fieldMobileLocationId,
    );
  }

  /// Digital address value: length cap; if it looks like a URL or email, validate loosely.
  static String? validateDigitalAddressValueOptional(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return null;
    if (v.length > _maxDigitalAddressValue) {
      return GlnValidationConstants.digitalAddressMaxLen(_maxDigitalAddressValue);
    }
    if (_controlChars.hasMatch(v)) {
      return GlnValidationConstants.invalidControlChars(
        GlnValidationConstants.fieldDigitalAddress,
      );
    }
    final lower = v.toLowerCase();
    if (lower.startsWith('http://') || lower.startsWith('https://')) {
      return validateHttpsUrlOptional(v);
    }
    if (v.contains('@') && !v.contains(' ')) {
      return validateEmailOptional(v);
    }
    return null;
  }

  // --- License ---

  static String? validateLicenseNumberOptional(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return null;
    return _rejectControlOrTooLong(
      v,
      _maxDbVarchar,
      GlnValidationConstants.fieldLicenseNumber,
    );
  }

  static String? validateLicenseTypeOptional(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return null;
    return _rejectControlOrTooLong(
      v,
      _maxDbVarchar,
      GlnValidationConstants.fieldLicenseType,
    );
  }
}
