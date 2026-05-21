/// Centralized SGTIN validators mirroring the backend GS1 / XS-017 rules.
///
/// All validators follow the Flutter form-field convention: return `null` when
/// the value is valid, or a non-null error message string when it is not.
library sgtin_validators;

import 'package:traqtrace_app/data/models/gs1/sgtin/sgtin_model.dart';
import 'package:traqtrace_app/features/gs1/gtin/utils/gtin_field_validators.dart';
import 'package:traqtrace_app/features/gs1/sgtin/utils/sgtin_status_rules.dart'
    as status_rules;

/// GS1 file-7 character set (space + printable ASCII 0x21–0x3F + underscore).
/// Must match backend SgtinConstants.SERIAL_REGEX.
final RegExp _serialRegex = RegExp(
    r'''^[A-Za-z0-9 !"%-?_]{1,20}$''');

/// Batch/lot number (AI(10)) uses the same file-7 charset as serial (AI(21)).
/// Must match backend SgtinConstants.BATCH_LOT_REGEX.
final RegExp _batchLotRegex = RegExp(
    r'''^[A-Za-z0-9 !"%-?_]{1,20}$''');

/// SGTIN EPC URN — e.g. urn:epc:id:sgtin:0614141.012345.abc123
final RegExp _epcUrnRegex = RegExp(
    r'''^urn:epc:id:sgtin:([0-9]{1,12})\.([0-9]{1,13})\.([A-Za-z0-9 !"%-?_]{1,20})$''');

/// GS1 Digital Link URI — https://id.gs1.org/01/<14digits>/21/<serial>
final RegExp _gs1DlRegex = RegExp(
    r'''^https://id\.gs1\.org/01/(\d{14})/21/([A-Za-z0-9!"%&'()*+,\-./:;<=>?_]{1,20})$''');

/// Validates a SGTIN serial number against the GS1 file-7 character set.
///
/// - Required, 1–20 characters.
/// - Allowed: `A-Z a-z 0-9 SPACE ! " % & ' ( ) * + , - . / : ; < = > ? _`
///
/// Note: serial number is immutable after commissioning; the UI should mark the
/// field as read-only for items that are already in status COMMISSIONED or beyond.
String? validateSerialNumber(String? value) {
  if (value == null || value.isEmpty) return 'Serial number is required';
  if (!_serialRegex.hasMatch(value)) {
    return 'Serial number must be 1–20 characters using GS1 file-7 charset '
        r'(A-Za-z0-9 space !"%-?_)';
  }
  return null;
}

/// Validates a batch / lot number (AI(10)) against the GS1 file-7 character set.
///
/// - 1–20 characters using the same charset as the serial number.
String? validateBatchLotNumber(String? value) {
  if (value == null || value.isEmpty) return null; // batch/lot is optional
  if (!_batchLotRegex.hasMatch(value)) {
    return 'Batch/lot number must be 1–20 characters using GS1 file-7 charset '
        r'(A-Za-z0-9 space !"%-?_)';
  }
  return null;
}

/// Validates an SGTIN EPC URI (URN format).
///
/// Example: `urn:epc:id:sgtin:0614141.012345.SN001`
String? validateEpcUri(String? value) {
  if (value == null || value.isEmpty) return null; // EPC URI is optional on input
  if (!_epcUrnRegex.hasMatch(value)) {
    return 'Invalid SGTIN EPC URI — expected urn:epc:id:sgtin:<prefix>.<ref>.<serial>';
  }
  return null;
}

/// Validates a GS1 Digital Link URI.
///
/// Example: `https://id.gs1.org/01/00614141123452/21/SN001`
String? validateGs1DigitalLinkUri(String? value) {
  if (value == null || value.isEmpty) return null; // optional
  if (!_gs1DlRegex.hasMatch(value)) {
    return 'Invalid GS1 Digital Link URI — expected https://id.gs1.org/01/<14digits>/21/<serial>';
  }
  return null;
}

/// Validates a GTIN code using the existing [GtinFieldValidators].
String? validateGtin(String? value) {
  return GtinFieldValidators.validateGtinCode(value);
}

/// Validates a GLN code (13 digits, Luhn check digit).
String? validateGln(String? value, {String fieldName = 'GLN'}) {
  if (value == null || value.isEmpty) return null; // GLN is optional
  if (!RegExp(r'^\d{13}$').hasMatch(value)) {
    return '$fieldName must be exactly 13 digits';
  }
  if (!_luhnCheck(value)) {
    return '$fieldName has an invalid check digit';
  }
  return null;
}

/// Validates that an expiry date is in the future.
String? validateExpiryDate(DateTime? value) {
  if (value == null) return null; // expiry is optional at input
  if (!value.isAfter(DateTime.now())) {
    return 'Expiry date must be in the future';
  }
  return null;
}

/// Validates that the expiry date is after the commissioning date.
String? validateExpiryAfterCommissioning(DateTime? expiryDate, DateTime? commissionedAt) {
  if (expiryDate == null || commissionedAt == null) return null;
  if (!expiryDate.isAfter(commissionedAt)) {
    return 'Expiry date must be after the commissioning date';
  }
  return null;
}

/// Validates aggregation hierarchy — a parent EPC cannot be the same as the
/// child EPC (no self-aggregation; XS-018).
String? validateParentEpc(String? parentEpc, String? ownEpcUri) {
  if (parentEpc == null || parentEpc.isEmpty) return null;
  if (ownEpcUri != null && parentEpc == ownEpcUri) {
    return 'An SGTIN cannot be aggregated into itself';
  }
  return null;
}

/// Validates that a status transition is allowed by the XS-017 state machine.
///
/// Delegates to [status_rules.validateTransition]. Returns `null` if the
/// transition is valid, or an error message otherwise.
String? validateStatusTransition(ItemStatus from, ItemStatus to) {
  return status_rules.validateTransition(from, to);
}

// ── Verification / Serial Governance fields ──────────────────────────────────

/// Validates [alertCount] — must be a non-negative integer.
String? validateAlertCount(int count) {
  if (count < 0) return 'Alert count must be 0 or greater';
  return null;
}

/// Validates [serialGuessingProbability] — when present, must be in [0.0, 1.0].
///
/// Mirrors the backend NUMERIC(3,2) constraint applied to similar probability
/// fields (e.g. fraud_score in SgtinPharmaceuticalExtensionValidators).
String? validateSerialGuessingProbability(double? value) {
  if (value == null) return null;
  if (value < 0.0 || value > 1.0) {
    return 'Serial guessing probability must be between 0.0 and 1.0';
  }
  return null;
}

/// Validates [serialEntropySeed] — optional free-text identifier, max 255 chars.
///
/// No special character restriction beyond control characters; mirrors
/// [optionalEventId] in SgtinPharmaceuticalExtensionValidators.
String? validateSerialEntropySeed(String? value) {
  if (value == null || value.isEmpty) return null;
  if (value.length > 255) return 'Entropy seed must be at most 255 characters';
  return null;
}

/// Validates [createdBy] — optional user / system identifier, max 255 chars.
String? validateCreatedBy(String? value) {
  if (value == null || value.isEmpty) return null;
  if (value.length > 255) return 'Created by must be at most 255 characters';
  return null;
}

// ── Pharmaceutical extension field validators ─────────────────────────────────

/// Known regulatory tracking regime codes supported by this platform.
///
/// Extend this set when new national authorities are on-boarded.
const Set<String> knownReportingRegimes = {
  'EU_FMD',
  'UAE_TATMEEN',
  'US_DSCSA',
  'NMPA',
  'SFDA',
  'CDSCO',
  'SASO',
};

/// Known submission / upload status codes used by EMVO and Tatmeen.
///
/// Must stay in sync with the backend SubmissionStatus enum.
const Set<String> knownSubmissionStatuses = {
  'ACKNOWLEDGED',
  'ACCEPTED',
  'UPLOADED',
  'SUBMITTED',
  'PENDING',
  'REJECTED',
};

/// Hex digest pattern: 8–128 hexadecimal characters (covers SHA-256 at 64,
/// SHA-512 at 128, and shorter HMAC-based hashes down to 8 chars).
final RegExp _hexHashRegex = RegExp(r'^[0-9a-fA-F]{8,128}$');

/// Original SGTIN composite ref: '<gtin>/<serialNumber>'.
/// GTIN part may be 8, 12, 13 or 14 digits; serial uses GS1 file-7 charset.
final RegExp _sgtinRefRegex = RegExp(
    r'''^(\d{8}|\d{12}|\d{13}|\d{14})/([A-Za-z0-9 !"%-?_]{1,20})$''');

/// Validates [reportingRegimes] — each code must be a known regime.
///
/// Mirrors [optionalCode] in SgtinPharmaceuticalExtensionValidators.
String? validateReportingRegimes(List<String> regimes) {
  for (final regime in regimes) {
    if (!knownReportingRegimes.contains(regime.toUpperCase())) {
      return 'Unknown reporting regime "$regime". '
          'Allowed: ${knownReportingRegimes.join(', ')}';
    }
  }
  return null;
}

/// Validates an EMVO upload status or Tatmeen submission status.
///
/// [fieldName] is used in the error message (e.g. 'EMVO upload status').
String? validateSubmissionStatus(String? value,
    {String fieldName = 'Submission status'}) {
  if (value == null || value.isEmpty) return null;
  if (!knownSubmissionStatuses.contains(value.toUpperCase())) {
    return '$fieldName must be one of: ${knownSubmissionStatuses.join(', ')}';
  }
  return null;
}

/// Validates [dscsaTransactionHash] — optional hex digest, 8–128 characters.
///
/// SHA-256 hashes are exactly 64 chars; the range accommodates alternative
/// HMAC or truncated hash schemes used by some DSCSA partners.
String? validateDscsaTransactionHash(String? value) {
  if (value == null || value.isEmpty) return null;
  if (!_hexHashRegex.hasMatch(value)) {
    return 'DSCSA transaction hash must be a hexadecimal string (8–128 characters)';
  }
  return null;
}

/// Validates [duplicateEvidenceCount] — must be a non-negative integer.
String? validateDuplicateEvidenceCount(int count) {
  if (count < 0) return 'Duplicate evidence count must be 0 or greater';
  return null;
}

/// Validates [controlledCustodyRef] — optional custody chain reference,
/// max 255 chars.
String? validateControlledCustodyRef(String? value) {
  if (value == null || value.isEmpty) return null;
  if (value.length > 255) {
    return 'Controlled custody reference must be at most 255 characters';
  }
  return null;
}

/// Validates [originalSgtinRef] — when present, must follow the
/// composite '<gtin>/<serialNumber>' format.
///
/// Mirrors the field comment in SGTINPharmaceuticalExtensionModel:
/// Format: '<gtin>/<serialNumber>'
String? validateOriginalSgtinRef(String? value) {
  if (value == null || value.isEmpty) return null;
  if (value.length > 256) {
    return 'Original SGTIN reference must be at most 256 characters';
  }
  if (!_sgtinRefRegex.hasMatch(value)) {
    return 'Original SGTIN reference must follow the format <gtin>/<serialNumber>';
  }
  return null;
}

// ── Luhn check digit algorithm ───────────────────────────────────────────────

bool _luhnCheck(String digits) {
  int sum = 0;
  bool odd = false;
  for (int i = digits.length - 1; i >= 0; i--) {
    int d = int.parse(digits[i]);
    if (odd) {
      d *= 2;
      if (d > 9) d -= 9;
    }
    sum += d;
    odd = !odd;
  }
  return sum % 10 == 0;
}
