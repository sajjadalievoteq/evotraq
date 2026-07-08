import 'package:traqtrace_app/core/utils/gs1_ai_normalizer.dart'
    as ai_normalizer;
import 'package:traqtrace_app/core/utils/gs1/gs1_formatter.dart';

abstract final class Gs1Normalizer {
  static String normalizeEpcInput(String input) {
    return ai_normalizer.normalizeEpcInput(input);
  }

  static String normalizeEpc(String input) {
    return ai_normalizer.normalizeEpcInput(input);
  }

  static String normalizeGTIN(String? raw) => Gs1Formatter.normalizeGTIN(raw);
  static String normalizeGLN(String? raw) => Gs1Formatter.normalizeGLN(raw);
  static String normalizeSSCC(String? raw) => Gs1Formatter.normalizeSSCC(raw);
}
