/// Full multi-scheme GS1 EPC URI validator.
///
/// Mirrors the backend `EPCUriValidator.java` exactly, covering every scheme
/// that EPCIS 2.0 / GS1 EPC TDS 2.3 defines plus GS1 AI bracket notation
/// (which is auto-normalised before validation).
///
/// Supported schemes:
/// - SGTIN URN:          `urn:epc:id:sgtin:<prefix>.<ref>.<serial>`
/// - SGTIN Digital Link: `https://id.gs1.org/01/<14digits>/21/<serial>`
/// - SSCC URN:           `urn:epc:id:sscc:<prefix>.<serialRef>`
/// - SSCC Digital Link:  `https://id.gs1.org/00/<18digits>`
/// - LGTIN URN:          `urn:epc:id:lgtin:<prefix>.<ref>.<lot>`
/// - LGTIN Digital Link: `https://id.gs1.org/01/<14digits>/10/<lot>`
/// - GRAI URN:           `urn:epc:id:grai:<prefix>.<assetType>.<serial>`
/// - GIAI URN:           `urn:epc:id:giai:<prefix>.<asset>`
/// - SGLN URN:           `urn:epc:id:sgln:<prefix>.<locRef>.<extension>`
/// - Legacy prefixes:    `urn:epc:class:`, `urn:epc:idpat:`, `urn:epc:tag:`
/// - GS1 AI notation:    `(01)…(21)…` etc. (normalised first)
library epc_uri_validators;

import 'package:traqtrace_app/core/utils/gs1_ai_normalizer.dart';

// ---------------------------------------------------------------------------
// Patterns — GS1 file-safe character set (TDS 2.3, Table A-1, file-7):
//   A-Z a-z 0-9 space ! " % - . / : ; < = > ? _
// Expressed as character class: [!%-?A-Z_a-z"]  (covers ASCII 0x21–0x3F + extras)
// ---------------------------------------------------------------------------

/// SGTIN URN: `urn:epc:id:sgtin:<1-12 digits>.<1-13 digits>.<1-20 file-7 chars>`
final _sgtinUrn = RegExp(
  r'''^urn:epc:id:sgtin:\d{1,12}\.\d{1,13}\.[!%-?A-Z_a-z"]{1,20}$''');

/// SGTIN GS1 Digital Link: `https://id.gs1.org/01/<14digits>/21/<1-20 file-7 chars>`
final _sgtinDl = RegExp(
  r'''^https://id\.gs1\.org/01/\d{14}/21/[!%-?A-Z_a-z"]{1,20}$''');

/// SSCC URN: `urn:epc:id:sscc:<1-12 digits>.<1-17 digits>`
final _ssccUrn = RegExp(
  r'''^urn:epc:id:sscc:\d{1,12}\.\d{1,17}$''');

/// SSCC GS1 Digital Link: `https://id.gs1.org/00/<18digits>`
final _ssccDl = RegExp(
  r'''^https://id\.gs1\.org/00/\d{18}$''');

/// LGTIN URN: `urn:epc:id:lgtin:<1-12 digits>.<1-13 digits>.<1-20 file-7 chars>`
final _lgtinUrn = RegExp(
  r'''^urn:epc:id:lgtin:\d{1,12}\.\d{1,13}\.[!%-?A-Z_a-z"]{1,20}$''');

/// LGTIN GS1 Digital Link: `https://id.gs1.org/01/<14digits>/10/<1-20 file-7 chars>`
final _lgtinDl = RegExp(
  r'''^https://id\.gs1\.org/01/\d{14}/10/[!%-?A-Z_a-z"]{1,20}$''');

/// GRAI URN: `urn:epc:id:grai:<1-12>.<1-11>.<1-16 file-7>`
final _graiUrn = RegExp(
  r'''^urn:epc:id:grai:\d{1,12}\.\d{1,11}\.[!%-?A-Z_a-z"]{1,16}$''');

/// GIAI URN: `urn:epc:id:giai:<1-12>.<1-24 file-7>`
final _giaiUrn = RegExp(
  r'''^urn:epc:id:giai:\d{1,12}\.[!%-?A-Z_a-z"]{1,24}$''');

/// SGLN URN: `urn:epc:id:sgln:<prefix>.<locRef>.<extension>`
final _sglnUrn = RegExp(
  r'''^urn:epc:id:sgln:\d{1,12}\.\d{1,12}\.[!%-?A-Z_a-z"0-9]{0,20}$''');

// ---------------------------------------------------------------------------
// Public API
// ---------------------------------------------------------------------------

/// Returns `true` if [input] is a valid EPC URI (any supported scheme)
/// OR valid GS1 AI bracket notation that converts to a recognised scheme.
bool isValidEpcUri(String input) {
  if (input.isEmpty) return false;
  final normalized = normalizeEpcInput(input);
  return _isValidNormalized(normalized);
}

/// Form-field validator for EPC URI / AI notation.
///
/// Returns `null` (valid) or an error message string.
/// Pass [required]: true to reject empty values.
String? validateEpcUriField(String? value, {bool required = false}) {
  if (value == null || value.trim().isEmpty) {
    return required ? 'EPC is required' : null;
  }
  final trimmed = value.trim();
  final normalized = normalizeEpcInput(trimmed);
  if (_isValidNormalized(normalized)) return null;

  // Give a helpful error hint based on what the input looks like
  if (trimmed.startsWith('(')) {
    return 'GS1 barcode could not be converted to a valid EPC URI — '
        'check the GTIN/SSCC digits and serial number';
  }
  if (trimmed.startsWith('urn:epc:')) {
    return 'Invalid EPC URI format — check prefix, dots, and character set';
  }
  if (trimmed.startsWith('https://id.gs1.org/')) {
    return 'Invalid GS1 Digital Link URI format';
  }
  return 'Not a valid EPC URI. Accepted formats:\n'
      '• (01)<GTIN>(21)<serial>  — GS1 barcode\n'
      '• urn:epc:id:sgtin:<prefix>.<ref>.<serial>\n'
      '• https://id.gs1.org/01/<14digits>/21/<serial>\n'
      '• urn:epc:id:sscc:<prefix>.<serialRef>  (SSCC)';
}

/// Normalizes [input] to a canonical EPC URI string.
///
/// - AI bracket notation → GS1 Digital Link URI
/// - Valid URI / URN → trimmed, unchanged
/// - Unknown format → trimmed, unchanged (still invalid per [isValidEpcUri])
String normalizeEpc(String input) => normalizeEpcInput(input.trim());

/// Returns a human-readable type label for a valid EPC URI,
/// e.g. `"SGTIN"`, `"SSCC"`, `"LGTIN"`, `"GRAI"`, `"GIAI"`.
/// Returns `null` if the input is not a recognised EPC URI.
String? epcUriType(String input) {
  final n = normalizeEpcInput(input.trim());
  if (_sgtinUrn.hasMatch(n) || _sgtinDl.hasMatch(n)) return 'SGTIN';
  if (_ssccUrn.hasMatch(n) || _ssccDl.hasMatch(n)) return 'SSCC';
  if (_lgtinUrn.hasMatch(n) || _lgtinDl.hasMatch(n)) return 'LGTIN';
  if (_graiUrn.hasMatch(n)) return 'GRAI';
  if (_giaiUrn.hasMatch(n)) return 'GIAI';
  if (_sglnUrn.hasMatch(n)) return 'SGLN';
  if (_isLegacyPrefix(n)) return 'Class/Pattern';
  return null;
}

// ---------------------------------------------------------------------------
// Internal helpers
// ---------------------------------------------------------------------------

bool _isValidNormalized(String n) {
  if (n.isEmpty) return false;
  if (_sgtinUrn.hasMatch(n)) return true;
  if (_sgtinDl.hasMatch(n)) return _validateSgtinDlCheckDigit(n);
  return _ssccUrn.hasMatch(n) ||
      _ssccDl.hasMatch(n) ||
      _lgtinUrn.hasMatch(n) ||
      _lgtinDl.hasMatch(n) ||
      _graiUrn.hasMatch(n) ||
      _giaiUrn.hasMatch(n) ||
      _sglnUrn.hasMatch(n) ||
      _isLegacyPrefix(n);
}

bool _isLegacyPrefix(String n) =>
    n.startsWith('urn:epc:class:') ||
    n.startsWith('urn:epc:idpat:') ||
    n.startsWith('urn:epc:tag:');

/// Validates the GS1 Mod-10 check digit embedded in a GS1 DL SGTIN URI.
bool _validateSgtinDlCheckDigit(String uri) {
  const prefix = 'https://id.gs1.org/01/';
  if (!uri.startsWith(prefix)) return false;
  final after = uri.substring(prefix.length);
  if (after.length < 14) return false;
  final gtin14 = after.substring(0, 14);
  if (!RegExp(r'^\d{14}$').hasMatch(gtin14)) return false;
  return _isValidGtinCheckDigit(gtin14);
}

/// GS1 Mod-10 (Luhn-variant) check digit validation.
bool _isValidGtinCheckDigit(String digits) {
  if (digits.length < 2) return false;
  int sum = 0;
  for (int i = 0; i < digits.length - 1; i++) {
    final d = int.parse(digits[i]);
    // Weights alternate 3, 1 from left for GTIN-14
    sum += (i % 2 == 0) ? d * 3 : d;
  }
  final check = (10 - (sum % 10)) % 10;
  return check == int.parse(digits[digits.length - 1]);
}
