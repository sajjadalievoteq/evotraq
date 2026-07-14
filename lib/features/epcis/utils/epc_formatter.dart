import 'package:traqtrace_app/core/utils/gs1/gs1_converter.dart';
import 'package:traqtrace_app/core/utils/gs1/gs1_parser.dart';
import 'package:traqtrace_app/features/barcode/services/epc_uri_converter.dart';

/// Formats identifiers to the project-canonical GS1 Digital Link form.
class EPCFormatter {
  static String? formatToEPCUri(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return null;

    // Bare Pure Identity body → wrap as URN then normalize to Digital Link.
    if (!trimmed.contains(':') &&
        RegExp(r'^\d+\.[0-9A-Za-z]+\.[A-Za-z0-9 !"%-?_\.\-]+$')
            .hasMatch(trimmed)) {
      return EPCURIConverter.normalizeForStorage('urn:epc:id:sgtin:$trimmed');
    }

    final normalized = EPCURIConverter.normalizeForStorage(trimmed);
    if (normalized.startsWith('https://id.gs1.org/')) {
      return normalized;
    }

    if (trimmed.contains('(21)') || trimmed.contains('(00)')) {
      final parsed = Gs1Parser.parseAiString(trimmed);
      if (parsed != null) {
        final gtin = parsed['GTIN'];
        final serial = parsed['SERIAL'];
        final sscc = parsed['SSCC'];
        if (sscc != null && sscc.replaceAll(RegExp(r'\D'), '').length == 18) {
          return Gs1Converter.ssccToEpc(sscc);
        }
        if (gtin != null && serial != null) {
          return Gs1Converter.gtinSerialToEpc(gtin, serial);
        }
      }
      return Gs1Converter.barcodeToEpc(trimmed);
    }

    return Gs1Converter.barcodeToEpc(trimmed);
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
