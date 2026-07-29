abstract final class CheckDigitUtils {
  static const Set<int> gtinLengths = {8, 12, 13, 14};
  static const Set<int> glnLengths = {13};
  static const Set<int> ssccLengths = {18};

  /// GS1 AI (21) serial: 1–20 chars, GS1 File‑7 / ISO 646 subset.
  static final RegExp sgtinSerialCharset = RegExp(
    r'''^[A-Za-z0-9 !"%-?_]{1,20}$''',
  );

  static int calculateMod10(String bodyDigits) {
    var sum = 0;
    var multiplyBy3 = true;
    for (var i = bodyDigits.length - 1; i >= 0; i--) {
      final digit = int.parse(bodyDigits[i]);
      sum += multiplyBy3 ? digit * 3 : digit;
      multiplyBy3 = !multiplyBy3;
    }
    return (10 - (sum % 10)) % 10;
  }

  static String calculateMod10String(String bodyDigits) {
    return calculateMod10(bodyDigits).toString();
  }

  static bool isValidMod10(String identifierWithCheckDigit) {
    if (identifierWithCheckDigit.length < 2) return false;
    if (!RegExp(r'^\d+$').hasMatch(identifierWithCheckDigit)) return false;
    final body = identifierWithCheckDigit.substring(
      0,
      identifierWithCheckDigit.length - 1,
    );
    final provided = int.tryParse(
      identifierWithCheckDigit[identifierWithCheckDigit.length - 1],
    );
    if (provided == null) return false;
    return calculateMod10(body) == provided;
  }

  /// Digits-only strip; returns empty when input has no digits.
  static String digitsOnly(String? value) =>
      (value ?? '').replaceAll(RegExp(r'\D'), '');

  /// Validates GS1 mod-10 check digit for an identifier of allowed lengths.
  /// Returns `null` when valid; otherwise a specific reason (format vs check digit).
  static String? validateGS1CheckDigit(
    String? value, {
    required Set<int> allowedLengths,
    String label = 'Identifier',
  }) {
    final digits = digitsOnly(value);
    if (digits.isEmpty) return '$label is required';
    if (!RegExp(r'^\d+$').hasMatch(digits)) {
      return '$label must contain only digits';
    }
    if (!allowedLengths.contains(digits.length)) {
      final lengths = allowedLengths.toList()..sort();
      return '$label has invalid length (${digits.length}). '
          'Expected ${lengths.join(', ')}.';
    }
    if (!isValidMod10(digits)) {
      return '$label has an invalid check digit';
    }
    return null;
  }

  static String? validateGtin(String? value) => validateGS1CheckDigit(
        value,
        allowedLengths: gtinLengths,
        label: 'GTIN',
      );

  static String? validateGln(String? value) => validateGS1CheckDigit(
        value,
        allowedLengths: glnLengths,
        label: 'GLN',
      );

  static String? validateSscc(String? value) => validateGS1CheckDigit(
        value,
        allowedLengths: ssccLengths,
        label: 'SSCC',
      );

  /// SGTIN = valid GTIN‑8/12/13/14 + AI‑21 serial (≤20, GS1 charset).
  static String? validateSgtin(String? gtin, String? serialNumber) {
    final gtinErr = validateGtin(gtin);
    if (gtinErr != null) return gtinErr;
    final serial = (serialNumber ?? '').trim();
    if (serial.isEmpty) return 'Serial number is required';
    if (!sgtinSerialCharset.hasMatch(serial)) {
      return 'Serial number must be 1–20 characters using GS1 AI‑21 charset '
          r'(A-Za-z0-9 space !"%-?_)';
    }
    return null;
  }

  static bool isValidGtin(String? value) => validateGtin(value) == null;
  static bool isValidGln(String? value) => validateGln(value) == null;
  static bool isValidSscc(String? value) => validateSscc(value) == null;
  static bool isValidSgtin(String? gtin, String? serial) =>
      validateSgtin(gtin, serial) == null;

  /// GSRN-18 uses the same mod-10 + length rules as SSCC.
  static const Set<int> gsrnLengths = {18};

  /// GDTI numeric base is 13 digits (like GLN) before optional serial.
  static const Set<int> gdtiLengths = {13};

  /// GRAI asset type is often a 14-digit GTIN-like key (mod-10).
  static const Set<int> graiLengths = {14};

  static String? validateGsrn(String? value) => validateGS1CheckDigit(
        value,
        allowedLengths: gsrnLengths,
        label: 'GSRN',
      );

  static String? validateGdti(String? value) => validateGS1CheckDigit(
        value,
        allowedLengths: gdtiLengths,
        label: 'GDTI',
      );

  static String? validateGrai(String? value) => validateGS1CheckDigit(
        value,
        allowedLengths: graiLengths,
        label: 'GRAI',
      );

  /// GIAI / CPID are alphanumeric (AI 8004 / 8010); validate charset + length only.
  static String? validateGiai(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'GIAI is required';
    if (v.length > 30) return 'GIAI must be at most 30 characters';
    if (!RegExp(r'''^[A-Za-z0-9 !"%-?_/]+$''').hasMatch(v)) {
      return 'GIAI contains invalid characters';
    }
    return null;
  }

  static String? validateCpid(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'CPID is required';
    if (v.length > 30) return 'CPID must be at most 30 characters';
    if (!RegExp(r'''^[A-Za-z0-9 !"%-?_/]+$''').hasMatch(v)) {
      return 'CPID contains invalid characters';
    }
    return null;
  }

  static bool isValidGsrn(String? value) => validateGsrn(value) == null;
  static bool isValidGdti(String? value) => validateGdti(value) == null;
  static bool isValidGrai(String? value) => validateGrai(value) == null;
  static bool isValidGiai(String? value) => validateGiai(value) == null;
  static bool isValidCpid(String? value) => validateCpid(value) == null;

  /// Computes the check digit for a body (identifier without check digit) and
  /// returns the corrected full number when the provided value is incomplete
  /// or has a wrong trailing digit.
  static ({int checkDigit, String fullNumber, bool wasValid}) compute({
    required String input,
    required Set<int> fullLengths,
  }) {
    final digits = digitsOnly(input);
    if (digits.isEmpty) {
      return (checkDigit: -1, fullNumber: '', wasValid: false);
    }

    if (fullLengths.contains(digits.length) && isValidMod10(digits)) {
      return (
        checkDigit: int.parse(digits[digits.length - 1]),
        fullNumber: digits,
        wasValid: true,
      );
    }

    final bodyLengths = fullLengths.map((l) => l - 1).toSet();
    if (bodyLengths.contains(digits.length)) {
      final cd = calculateMod10(digits);
      return (checkDigit: cd, fullNumber: '$digits$cd', wasValid: false);
    }

    if (fullLengths.contains(digits.length)) {
      final body = digits.substring(0, digits.length - 1);
      final cd = calculateMod10(body);
      return (checkDigit: cd, fullNumber: '$body$cd', wasValid: false);
    }

    return (checkDigit: -1, fullNumber: '', wasValid: false);
  }
}
