/// Centralized SSCC validators mirroring backend GS1 / XSC rules.
///
/// All validators follow the Flutter form-field convention: return `null` when
/// the value is valid, or a non-null error message string when it is not.

import 'package:traqtrace_app/data/models/gs1/serialization/sscc/sscc_model.dart';
import 'package:traqtrace_app/features/gs1/gln/utils/gln_field_validators.dart';
import 'package:traqtrace_app/features/gs1/gtin/utils/gtin_format.dart';
import 'package:traqtrace_app/features/gs1/sscc/utils/sscc_format.dart';
import 'package:traqtrace_app/features/gs1/sscc/utils/sscc_status_rules.dart'
    as status_rules;

/// SSCC EPC URN — e.g. urn:epc:id:sscc:6291000.1000000123
final RegExp _ssccEpcUrnRegex = RegExp(
  r'^urn:epc:id:sscc:([0-9]{4,12})\.([0-9]{1,13})$',
);

/// GS1 Digital Link URI for SSCC — https://id.gs1.org/00/<18digits>
final RegExp _ssccGs1DlRegex = RegExp(
  r'^https://id\.gs1\.org/00/(\d{18})$',
);

/// Validates an 18-digit SSCC (AI 00) including Mod-10 check digit (XSC-001).
String? validateSsccCode(String? value) {
  final s = SsccFormat.stripSsccInput(value);
  if (s.isEmpty) return 'SSCC is required';
  if (!RegExp(r'^\d{18}$').hasMatch(s)) {
    return 'SSCC must be exactly 18 numeric digits';
  }
  if (!SsccFormat.isValidSscc(s)) {
    return 'Invalid SSCC check digit. Verify the code or use a check-digit calculator.';
  }
  return null;
}

/// Optional SSCC validation (empty allowed).
String? validateSsccCodeOptional(String? value) {
  final s = SsccFormat.stripSsccInput(value);
  if (s.isEmpty) return null;
  return validateSsccCode(s);
}

/// Validates extension digit (position 1 of SSCC).
String? validateExtensionDigit(String? value) {
  if (value == null || value.isEmpty) {
    return 'Extension digit is required';
  }
  if (!RegExp(r'^[0-9]$').hasMatch(value)) {
    return 'Extension digit must be a single digit (0–9)';
  }
  return null;
}

/// Validates a GLN used for SSCC issuing / ship-from / ship-to (AI 410–413).
String? validateGln(String? value, {String fieldName = 'GLN'}) {
  final err = GlnFieldValidators.validateGlnCodeOptional(value);
  if (err == null) return null;
  return err.replaceFirst('GLN', fieldName);
}

String? validateIssuingGlnRequired(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Issuing GLN is required to generate an SSCC';
  }
  return GlnFieldValidators.validateGlnCode(value);
}

/// Validates SSCC EPC URI (URN form, check digit omitted).
String? validateEpcUri(String? value) {
  if (value == null || value.isEmpty) return null;
  if (!_ssccEpcUrnRegex.hasMatch(value)) {
    return 'Invalid SSCC EPC URI — expected urn:epc:id:sscc:<prefix>.<extension+serial>';
  }
  return null;
}

/// Validates GS1 Digital Link URI for SSCC.
String? validateGs1DigitalLinkUri(String? value) {
  if (value == null || value.isEmpty) return null;
  if (!_ssccGs1DlRegex.hasMatch(value)) {
    return 'Invalid GS1 Digital Link URI — expected https://id.gs1.org/00/<18digits>';
  }
  return null;
}

/// Parent SSCC must not equal own SSCC (XSC-007 partial).
String? validateParentSscc(String? parentSscc, String? ownSsccCode) {
  if (parentSscc == null || parentSscc.isEmpty) return null;
  final parent = SsccFormat.stripSsccInput(parentSscc);
  final own = SsccFormat.stripSsccInput(ownSsccCode);
  if (own.isNotEmpty && parent == own) {
    return 'An SSCC cannot be nested inside itself';
  }
  return validateSsccCodeOptional(parent);
}

/// Validates logistic unit status transition (spec lifecycle).
String? validateStatusTransition(LogisticUnitStatus from, LogisticUnitStatus to) {
  return status_rules.validateTransition(from, to);
}

/// Positive contained quantity for homogeneous units (AI 37).
String? validateContainedQuantity(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  final n = int.tryParse(value.trim());
  if (n == null) return 'Contained quantity must be a whole number';
  if (n <= 0) return 'Contained quantity must be greater than 0';
  if (n > 99999999) return 'Contained quantity must be at most 8 digits';
  return null;
}

/// Purchase order (AI 400) — up to 30 chars.
String? validatePurchaseOrderNumber(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  if (value.length > 30) {
    return 'Purchase order number must be at most 30 characters';
  }
  return null;
}

/// GSIN (AI 402) — 17 digits with Mod-10 check digit.
String? validateGsin(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  final s = value.replaceAll(RegExp(r'\s'), '');
  if (!RegExp(r'^\d{17}$').hasMatch(s)) {
    return 'GSIN must be exactly 17 digits';
  }
  final body = s.substring(0, 16);
  final want = int.parse(s[16]);
  final got = GtinFormat.calculateCheckDigitForBody(body);
  if (got < 0 || want != got) {
    return 'GSIN has an invalid check digit';
  }
  return null;
}
