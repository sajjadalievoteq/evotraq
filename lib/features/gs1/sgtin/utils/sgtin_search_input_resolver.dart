import 'package:traqtrace_app/core/widgets/epc_input_widget/epc_parser.dart';
import 'package:traqtrace_app/core/widgets/epc_input_widget/epc_types.dart';

/// Resolves list-search input via the shared [parseToEPC] pipeline.
class SgtinSearchInputResolver {
  const SgtinSearchInputResolver({
    required this.raw,
    this.gtinCode,
    this.serialNumber,
    this.epcUri,
    this.parseError,
  });

  final String raw;
  final String? gtinCode;
  final String? serialNumber;
  final String? epcUri;
  final String? parseError;

  bool get isEmpty => raw.isEmpty;

  bool get hasStructuredParseError =>
      parseError != null && _looksLikeStructuredIdentifier(raw);

  static SgtinSearchInputResolver resolve(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      return const SgtinSearchInputResolver(raw: '');
    }

    try {
      final parsed = parseToEPC(trimmed);
      if (parsed.type == EPCType.sscc) {
        return SgtinSearchInputResolver(
          raw: trimmed,
          parseError:
              'SSCC barcodes cannot be searched on the SGTIN screen. Use the SSCC module instead.',
        );
      }

      return SgtinSearchInputResolver(
        raw: trimmed,
        gtinCode: parsed.gtin,
        serialNumber: parsed.serial ?? _serialFromSgtinEpc(parsed.epc),
        epcUri: parsed.type == EPCType.sgtin ? parsed.epc : null,
      );
    } on EPCParseException catch (e) {
      return SgtinSearchInputResolver(
        raw: trimmed,
        serialNumber: trimmed,
        parseError: _looksLikeStructuredIdentifier(trimmed) ? e.message : null,
      );
    }
  }

  static String? _serialFromSgtinEpc(String epc) {
    if (!epc.startsWith('urn:epc:id:sgtin:')) return null;
    final parts = epc.substring('urn:epc:id:sgtin:'.length).split('.');
    if (parts.length >= 3) return parts[2];
    return null;
  }

  static bool _looksLikeStructuredIdentifier(String value) {
    if (value.startsWith('urn:') ||
        value.startsWith('http://') ||
        value.startsWith('https://')) {
      return true;
    }
    if (value.contains('(') && value.contains(')')) return true;
    if (value.startsWith('00') && value.length >= 18) return true;
    return RegExp(r'^\d{8,14}$').hasMatch(value);
  }
}
