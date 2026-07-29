import 'package:traqtrace_app/core/utils/gs1/gs1_ai_table.dart';

/// Builds GS1 element strings (FNC1 between variable-length AIs).
/// Fixed vs variable length comes from [Gs1AiTable] (same source as the parser).
abstract final class Gs1ElementStringBuilder {
  static const fnc1 = '\u001D';

  static Set<String> get fixedLengthAis => Gs1AiTable.fixedLengthAiCodes;

  /// Returns (rawWithFnc1, humanReadable).
  static ({String raw, String human}) build(Map<String, String> ais) {
    Gs1AiTable.ensureSynced();
    final cleaned = <String, String>{};
    for (final e in ais.entries) {
      final ai = e.key.trim();
      final value = e.value.trim();
      if (ai.isEmpty || value.isEmpty) continue;
      cleaned[ai] = value;
    }
    final buffer = StringBuffer();
    final human = StringBuffer();
    var first = true;
    cleaned.forEach((ai, value) {
      if (!first && !Gs1AiTable.isFixedLength(ai)) {
        buffer.write(fnc1);
      }
      buffer.write(ai);
      buffer.write(value);
      human.write('($ai)$value');
      first = false;
    });
    return (raw: buffer.toString(), human: human.toString());
  }
}
