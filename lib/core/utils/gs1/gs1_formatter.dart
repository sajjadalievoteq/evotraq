import 'package:traqtrace_app/features/gs1/gln/utils/gln_format.dart';
import 'package:traqtrace_app/features/gs1/gtin/utils/gtin_format.dart';
import 'package:traqtrace_app/features/gs1/sscc/utils/sscc_format.dart';

/// Unified GS1 formatting facade.
///
/// This API normalizes and strips identifier inputs through existing
/// format-specific utilities.
abstract final class Gs1Formatter {
  static String normalizeGTIN(String? raw) {
    return GtinFormat.stripGtinInput(raw);
  }

  static String normalizeGLN(String? raw) {
    return GlnFormat.stripGlnInput(raw);
  }

  static String normalizeSSCC(String? raw) {
    return SsccFormat.stripSsccInput(raw);
  }

  static String? formatGTIN14(String validGtin) {
    if (!GtinFormat.isValidGtin(validGtin)) return null;
    return GtinFormat.normalizeGtinTo14(validGtin);
  }

  static String formatGTIN(String? raw) => normalizeGTIN(raw);
  static String formatGLN(String? raw) => normalizeGLN(raw);
  static String formatSSCC(String? raw) => normalizeSSCC(raw);
}
