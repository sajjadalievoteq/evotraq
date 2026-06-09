import 'package:traqtrace_app/features/gs1/gtin/utils/gtin_format.dart';

abstract final class SsccFormat {
  static final RegExp _numeric18 = RegExp(r'^\d{18}$');

  static String stripSsccInput(String? raw) {
    if (raw == null) return '';
    return raw.replaceAll(RegExp(r'[\s\u00A0\-\u2010-\u2015\.\/]'), '').trim();
  }

  static bool isValidSscc(String stripped) {
    if (!_numeric18.hasMatch(stripped)) return false;
    final body = stripped.substring(0, 17);
    final want = int.parse(stripped[17]);
    final got = GtinFormat.calculateCheckDigitForBody(body);
    return got >= 0 && want == got;
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
