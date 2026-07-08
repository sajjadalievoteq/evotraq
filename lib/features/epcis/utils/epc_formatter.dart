import 'package:traqtrace_app/core/utils/gs1/gs1_converter.dart';
import 'package:traqtrace_app/core/utils/gs1/gs1_parser.dart';

class EPCFormatter {
  static String? formatToEPCUri(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return null;

    if (trimmed.startsWith('urn:epc:')) return trimmed;

    if (!trimmed.contains(':') &&
        RegExp(r'^\d+\.[0-9A-Za-z]+\.[A-Za-z0-9 !"%-?_\.\-]+$')
            .hasMatch(trimmed)) {
      return 'urn:epc:id:sgtin:$trimmed';
    }

    if (trimmed.contains('(21)')) {
      final parsed = Gs1Parser.parseAiString(trimmed);
      if (parsed != null &&
          parsed['GTIN'] != null &&
          parsed['SERIAL'] != null) {
        return Gs1Converter.gtinSerialToEpc(
          parsed['GTIN']!,
          parsed['SERIAL']!,
        );
      }
      return null;
    }

    return null;
  }

  static List<String> formatListToEPCUri(List<String> inputs) {
    return inputs.map((input) => formatToEPCUri(input) ?? input).toList();
  }

  static bool isLikelyGS1Barcode(String input) {
    if (input.contains(RegExp(r'\(\d{2}\)'))) {
      return true;
    }

    if (input.startsWith(RegExp(r'01\d{14}'))) {
      return true;
    }

    return false;
  }
}
