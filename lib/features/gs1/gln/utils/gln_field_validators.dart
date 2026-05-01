import 'package:traqtrace_app/features/gs1/gln/utils/gln_format.dart';
import 'package:traqtrace_app/features/gs1/gtin/utils/gtin_field_validators.dart';

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
      return '$fieldLabel contains invalid control characters';
    }
    if (v.length > max) {
      return '$fieldLabel must be at most $max characters';
    }
    return null;
  }

  // --- GLN code (primary key) ---

  /// Required GLN: strip separators, length 13, GS1 Mod-10.
  static String? validateGlnCode(String? value) {
    final s = GlnFormat.stripGlnInput(value);
    if (s.isEmpty) {
      return 'GLN Code is required';
    }
    if (!RegExp(r'^\d{13}$').hasMatch(s)) {
      return 'GLN must be exactly 13 digits';
    }
    if (!GlnFormat.isValidGln(s)) {
      return 'Invalid check digit. Verify the GLN or use a GS1 check-digit calculator.';
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
      return 'Location Name is required';
    }
    final v = value.trim();
    return _rejectControlOrTooLong(v, _maxDbVarchar, 'Location Name');
  }

  /// Required single address line.
  static String? validateAddressLine1Required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Address Line 1 is required';
    }
    final v = value.trim();
    return _rejectControlOrTooLong(v, _maxDbVarchar, 'Address Line 1');
  }

  /// Optional second address line (same DB limit as line 1).
  static String? validateAddressLine2Optional(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return null;
    return _rejectControlOrTooLong(v, _maxDbVarchar, 'Address Line 2');
  }

  static String? validateCityRequired(String? value) {
    if (value == null || value.trim().isEmpty) return 'City is required';
    final v = value.trim();
    return _rejectControlOrTooLong(v, _maxDbVarchar, 'City');
  }

  /// DB schema: `state_province VARCHAR(255)` — column is nullable (not NOT NULL),
  /// but the form treats it as required for postal address completeness.
  static String? validateStateProvinceRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'State/Province is required';
    }
    final v = value.trim();
    return _rejectControlOrTooLong(v, _maxDbVarchar, 'State/Province');
  }

  static String? validatePostalCodeRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Postal Code is required';
    }
    final v = value.trim();
    return _rejectControlOrTooLong(v, 64, 'Postal Code');
  }

  static String? validateCountryRequired(String? value) {
    if (value == null || value.trim().isEmpty) return 'Country is required';
    final v = value.trim();
    return _rejectControlOrTooLong(v, _maxDbVarchar, 'Country');
  }

  // --- Contact ---

  static String? validateEmailOptional(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return null;
    if (v.length > 254) return 'Email must be at most 254 characters';
    if (_controlChars.hasMatch(v)) return 'Email contains invalid characters';
    // Practical RFC 5322 subset for forms
    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(v)) {
      return 'Enter a valid email';
    }
    return null;
  }

  /// Optional contact name.
  static String? validateContactNameOptional(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return null;
    return _rejectControlOrTooLong(v, _maxDbVarchar, 'Contact name');
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
      return 'Phone number is too short';
    }
    if (!RegExp(r'^\+?[0-9]+$').hasMatch(compact)) {
      return 'Use digits with optional + prefix (spaces/parentheses allowed)';
    }
    return null;
  }

  // --- GS1 AI 254 (extension component) ---

  /// GS1 AI 254: internal sub-location; max 20 characters; alphanumeric + limited punctuation (GS1 subset).
  static String? validateGlnExtensionComponentOptional(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return null;
    if (v.length > _maxAi254) {
      return 'Extension component must be at most $_maxAi254 characters (GS1 AI 254)';
    }
    if (!_ai254Charset.hasMatch(v)) {
      return 'Use letters, digits, and - _ . / & + only (GS1 character set)';
    }
    return null;
  }

  // --- LEI (ISO 17442) ---

  /// Optional LEI: 20 characters, ISO 7064 Mod 97-10.
  static String? validateLeiOptional(String? value) {
    final v = (value ?? '').trim().toUpperCase();
    if (v.isEmpty) return null;
    if (v.length != 20) {
      return 'LEI must be exactly 20 characters';
    }
    if (!RegExp(r'^[0-9A-Z]{20}$').hasMatch(v)) {
      return 'LEI must be alphanumeric (A–Z, 0–9) only';
    }
    if (!GlnFormat.isValidLei(v)) {
      return 'Invalid LEI check characters (ISO 7064 Mod 97-10)';
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
    return _rejectControlOrTooLong(v, _maxDbVarchar, 'Trading name');
  }

  /// Free-text tax / VAT ID (no country-specific rules on frontend).
  static String? validateTaxRegistrationOptional(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return null;
    return _rejectControlOrTooLong(v, _maxDbVarchar, 'Tax / VAT registration');
  }

  // --- URL ---

  /// `http` or `https` with host; empty allowed.
  static String? validateHttpsUrlOptional(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return null;
    if (v.length > 2000) return 'URL must be at most 2000 characters';
    final uri = Uri.tryParse(v);
    if (uri == null || !uri.hasScheme) {
      return 'Enter a valid URL (include http:// or https://)';
    }
    final s = uri.scheme.toLowerCase();
    if (s != 'http' && s != 'https') {
      return 'URL must use http or https';
    }
    if (!uri.hasAuthority || uri.host.isEmpty) {
      return 'URL must include a host name';
    }
    return null;
  }

  // --- Comma-separated role lists ---

  /// Comma-separated uppercase role codes (e.g. MANUFACTURER, DISTRIBUTOR). Empty allowed.
  static String? validateCommaSeparatedRolesOptional(String? value) {
    final raw = (value ?? '').trim();
    if (raw.isEmpty) return null;
    if (raw.length > _maxDbVarchar) {
      return 'Must be at most $_maxDbVarchar characters';
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
      return 'GS1 Company Prefix must contain only digits';
    }
    if (v.length < 4 || v.length > 12) {
      return 'GS1 Company Prefix must be 4–12 digits';
    }
    return null;
  }

  /// Location reference digits (informational); numeric, up to 11 digits.
  static String? validateLocationReferenceOptional(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return null;
    if (!RegExp(r'^\d{1,11}$').hasMatch(v)) {
      return 'Location reference must be 1–11 digits';
    }
    return null;
  }

  /// Standalone check digit field: single 0–9 or empty.
  static String? validateCheckDigitOptional(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return null;
    if (!RegExp(r'^\d$').hasMatch(v)) {
      return 'Check digit must be a single digit (0–9)';
    }
    return null;
  }

  /// Mobile / vehicle / vessel identifier — free text within limit.
  static String? validateMobileLocationIdOptional(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return null;
    return _rejectControlOrTooLong(v, 128, 'Mobile location ID');
  }

  /// Digital address value: length cap; if it looks like a URL or email, validate loosely.
  static String? validateDigitalAddressValueOptional(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return null;
    if (v.length > _maxDigitalAddressValue) {
      return 'Digital address must be at most $_maxDigitalAddressValue characters';
    }
    if (_controlChars.hasMatch(v)) {
      return 'Digital address contains invalid control characters';
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
    return _rejectControlOrTooLong(v, _maxDbVarchar, 'License number');
  }

  static String? validateLicenseTypeOptional(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return null;
    return _rejectControlOrTooLong(v, _maxDbVarchar, 'License type');
  }
}
