import 'package:traqtrace_app/core/utils/gs1_ai_normalizer.dart'
    as ai_normalizer;
import 'package:traqtrace_app/core/utils/gs1/gs1_formatter.dart';

/// Unified GS1 normalization facade.
///
/// Keeps existing normalization behavior by delegating to current helpers.
abstract final class Gs1Normalizer {
  /// Normalizes a scanner input to canonical EPC URI when possible.
  static String normalizeEpcInput(String input) {
    return ai_normalizer.normalizeEpcInput(input);
  }

  /// Alias for EPC normalization.
  static String normalizeEpc(String input) {
    return ai_normalizer.normalizeEpcInput(input);
  }

  static String normalizeGTIN(String? raw) => Gs1Formatter.normalizeGTIN(raw);
  static String normalizeGLN(String? raw) => Gs1Formatter.normalizeGLN(raw);
  static String normalizeSSCC(String? raw) => Gs1Formatter.normalizeSSCC(raw);
}
