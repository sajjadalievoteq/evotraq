import 'package:traqtrace_app/core/utils/gs1/check_digit_utils.dart';

abstract final class SsccFormat {
  static String stripSsccInput(String? raw) {
    if (raw == null) return '';
    return raw.replaceAll(RegExp(r'[\s\u00A0\-\u2010-\u2015\.\/]'), '').trim();
  }

  static bool isValidSscc(String stripped) {
    return CheckDigitUtils.validateGS1CheckDigit(
          stripped,
          allowedLengths: CheckDigitUtils.ssccLengths,
          label: 'SSCC',
        ) ==
        null;
  }

  static String? extensionDigit(String stripped) {
    if (stripped.length != 18) return null;
    return stripped[0];
  }

  static String? checkDigit(String stripped) {
    if (stripped.length != 18) return null;
    return stripped[17];
  }
}
