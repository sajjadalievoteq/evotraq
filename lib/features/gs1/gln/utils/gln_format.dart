import 'package:traqtrace_app/features/gs1/gtin/utils/gtin_format.dart';

abstract final class GlnFormat {
  static final RegExp _numeric13 = RegExp(r'^\d{13}$');

  static String stripGlnInput(String? raw) {
    if (raw == null) return '';
    return raw.replaceAll(RegExp(r'[\s\u00A0\-\u2010-\u2015\.\/]'), '').trim();
  }

  static bool isValidGln(String stripped) {
    if (!_numeric13.hasMatch(stripped)) return false;
    final body = stripped.substring(0, 12);
    final want = int.parse(stripped[12]);
    final got = GtinFormat.calculateCheckDigitForBody(body);
    return got >= 0 && want == got;
  }

  static bool isValidLei(String normalized20) {
    if (normalized20.length != 20) return false;
    if (!RegExp(r'^[0-9A-Z]{20}$').hasMatch(normalized20)) return false;
    return _mod97LeiExpanded(normalized20) == 1;
  }

  static int _mod97LeiExpanded(String lei20) {
    final buf = StringBuffer();
    for (var i = 0; i < lei20.length; i++) {
      final c = lei20.codeUnitAt(i);
      if (c >= 48 && c <= 57) {
        buf.writeCharCode(c);
      } else if (c >= 65 && c <= 90) {
        buf.write((c - 55).toString());
      } else {
        return -1;
      }
    }
    final digits = buf.toString();
    var r = 0;
    for (var i = 0; i < digits.length; i++) {
      r = (r * 10 + digits.codeUnitAt(i) - 48) % 97;
    }
    return r;
  }
}
