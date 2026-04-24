/// Normalization, structure, and check-digit rules aligned with
/// [com.traqtrace.api.features.master_data.gtin.util.GtinValidationUtil] (8/12/13/14 + GS1 Mod-10).
abstract final class GtinFormat {
  static final RegExp _numericOnly = RegExp(r'^\d+$');
  static final RegExp _validLengths = RegExp(
    r'^(?:\d{8}|\d{12}|\d{13}|\d{14})$',
  );

  /// Removes spaces, hyphens, and common group separators. Does not trim inner spaces before strip.
  static String stripGtinInput(String? raw) {
    if (raw == null) return '';
    return raw
        .replaceAll(RegExp(r'[\s\u00A0\-\u2010-\u2015\.\/]'), '')
        .trim();
  }

  /// GS1 Mod-10 check digit for the string **without** the final check digit
  /// (same loop as [GtinValidationUtil.calculateCheckDigit]).
  static int calculateCheckDigitForBody(String bodyWithoutCheckDigit) {
    if (bodyWithoutCheckDigit.isEmpty || !_numericOnly.hasMatch(bodyWithoutCheckDigit)) {
      return -1;
    }
    var sum = 0;
    var multiplyBy3 = true;
    for (var i = bodyWithoutCheckDigit.length - 1; i >= 0; i--) {
      final digit = int.parse(bodyWithoutCheckDigit[i]);
      if (multiplyBy3) {
        sum += digit * 3;
      } else {
        sum += digit;
      }
      multiplyBy3 = !multiplyBy3;
    }
    return (10 - (sum % 10)) % 10;
  }

  /// `true` when [stripped] is 8, 12, 13, or 14 digits and the last digit matches Mod-10.
  static bool isValidGtin(String stripped) {
    if (!_validLengths.hasMatch(stripped)) {
      return false;
    }
    if (!_numericOnly.hasMatch(stripped)) {
      return false;
    }
    final body = stripped.substring(0, stripped.length - 1);
    final want = int.parse(stripped[stripped.length - 1]);
    final got = calculateCheckDigitForBody(body);
    return want == got;
  }

  /// Pads 8, 12, or 13 digits to 14. [validGtin] must pass [isValidGtin] first.
  static String normalizeGtinTo14(String validGtin) {
    if (!isValidGtin(validGtin)) {
      throw ArgumentError.value(validGtin, 'validGtin', 'not a valid GTIN');
    }
    switch (validGtin.length) {
      case 14:
        return validGtin;
      case 13:
        return '0$validGtin';
      case 12:
        return '00$validGtin';
      case 8:
        return '000000$validGtin';
      default:
        throw ArgumentError('GTIN must be 8, 12, 13, or 14 digits (was ${validGtin.length})');
    }
  }

  /// Label for the **source** data structure, based on stripped length: `GTIN-8` … `GTIN-14`.
  static String? structureLabelForStrippedInput(String stripped) {
    if (!isValidGtin(stripped)) return null;
    return switch (stripped.length) {
      8 => 'GTIN-8',
      12 => 'GTIN-12',
      13 => 'GTIN-13',
      14 => 'GTIN-14',
      _ => null,
    };
  }

  /// First character of a 14-digit canonical string (Indicator digit / leading pad).
  static String? indicatorFromCanonical14(String canonical14) {
    if (canonical14.length != 14) return null;
    return canonical14[0];
  }
}
