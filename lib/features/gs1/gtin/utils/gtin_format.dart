import 'package:traqtrace_app/core/utils/gs1/check_digit_utils.dart';

abstract final class GtinFormat {
  static final RegExp _numericOnly = RegExp(r'^\d+$');

  static String stripGtinInput(String? raw) {
    if (raw == null) return '';
    return raw.replaceAll(RegExp(r'[\s\u00A0\-\u2010-\u2015\.\/]'), '').trim();
  }

  static int calculateCheckDigitForBody(String bodyWithoutCheckDigit) {
    if (bodyWithoutCheckDigit.isEmpty ||
        !_numericOnly.hasMatch(bodyWithoutCheckDigit)) {
      return -1;
    }
    return CheckDigitUtils.calculateMod10(bodyWithoutCheckDigit);
  }

  static bool isValidGtin(String stripped) {
    return CheckDigitUtils.validateGS1CheckDigit(
          stripped,
          allowedLengths: CheckDigitUtils.gtinLengths,
          label: 'GTIN',
        ) ==
        null;
  }

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
        throw ArgumentError(
          'GTIN must be 8, 12, 13, or 14 digits (was ${validGtin.length})',
        );
    }
  }

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

  static String? indicatorFromCanonical14(String canonical14) {
    if (canonical14.length != 14) return null;
    return canonical14[0];
  }
}
