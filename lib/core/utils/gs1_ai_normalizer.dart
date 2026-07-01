import 'package:traqtrace_app/features/barcode/services/epc_uri_converter.dart';

/// GS1 Application Identifier (AI) bracket notation parser and EPC URI converter.
///
/// Converts scanner output like `(01)00629200080027(21)KOPLYPIEKV3GX70C7WMN`
/// into a canonical EPC URI for EPCIS operations:
/// `urn:epc:id:sgtin:0629200.0080027.KOPLYPIEKV3GX70C7WMN`
///
/// Supported AI combinations:
/// - `(01)` + `(21)` → SGTIN URN: `urn:epc:id:sgtin:{gcp}.{itemRef}.{serial}`
/// - `(00)`          → SSCC URN:  `urn:epc:id:sscc:{gcp}.{serialRef}`
/// - `(01)` + `(10)` → LGTIN URN: `urn:epc:id:lgtin:{gcp}.{itemRef}.{lot}`
/// - `(01)` only     → GTIN class: `urn:epc:idpat:sgtin:{gcp}.{itemRef}.*`

/// Regex that matches a single AI element, e.g. `(01)00629200080027`
final _aiElement = RegExp(r'\((\d{2,4})\)([^(]*)');

/// FNC1 / symbology-identifier prefixes that scanners sometimes prepend.
const _fnc1Prefixes = [']C1', ']e0', ']Q3'];

/// GS1 group-separator character (ASCII 0x1D).
const _gs = '';

/// Returns `true` if [input] looks like GS1 AI bracket notation.
bool isGS1AiNotation(String input) {
  final s = _stripFnc1Prefix(input.trim());
  return s.startsWith('(');
}

/// Converts GS1 AI bracket notation to a canonical EPC URI.
///
/// Returns `null` if parsing fails or the AI combination is not recognised.
/// Pass the result to [EpcUriValidators] to verify the output is a valid EPC URI.
String? gs1AiToEpcUri(String input) {
  final trimmed = _stripFnc1Prefix(input.trim());
  if (!trimmed.startsWith('(')) return null;

  final ais = _parseAis(trimmed);
  if (ais.isEmpty) return null;

  final sscc = ais['00'];
  final gtin = ais['01'];
  final lot = ais['10'];
  final serial = ais['21'];

  // SSCC (AI 00)
  if (sscc != null && sscc.isNotEmpty) {
    final s18 = sscc.padLeft(18, '0');
    if (!RegExp(r'^\d{18}$').hasMatch(s18)) return null;
    return EPCURIConverter.convertSSCCToEPCUri(s18);
  }

  // GTIN-based (AI 01)
  if (gtin != null && gtin.isNotEmpty) {
    final gtin14 = gtin.padLeft(14, '0');
    if (!RegExp(r'^\d{14}$').hasMatch(gtin14)) return null;

    // SGTIN: 01 + 21
    if (serial != null && serial.isNotEmpty) {
      return EPCURIConverter.convertGTINSerialToEPCUri(gtin14, serial);
    }

    // LGTIN: 01 + 10
    if (lot != null && lot.isNotEmpty) {
      return EPCURIConverter.convertGTINLotToLGTINEpcUri(gtin14, lot);
    }

    // GTIN class only
    return EPCURIConverter.convertGTINToClassEPCUri(gtin14);
  }

  return null;
}

/// Normalizes [input] to a canonical EPC URI.
///
/// - GS1 AI bracket notation → `urn:epc:…` URI
/// - GS1 Digital Link URL → `urn:epc:…` URI when convertible
/// - Already a URN / unrecognised format → returned trimmed unchanged
String normalizeEpcInput(String input) {
  final trimmed = input.trim();
  if (isGS1AiNotation(trimmed)) {
    return gs1AiToEpcUri(trimmed) ?? trimmed;
  }
  if (trimmed.startsWith('https://id.gs1.org/')) {
    return EPCURIConverter.convertToEPCUri(trimmed) ?? trimmed;
  }
  return trimmed;
}

// ---------------------------------------------------------------------------
// Internal helpers
// ---------------------------------------------------------------------------

String _stripFnc1Prefix(String s) {
  for (final prefix in _fnc1Prefixes) {
    if (s.startsWith(prefix)) {
      s = s.substring(prefix.length);
      break;
    }
  }
  if (s.startsWith(_gs)) s = s.substring(1);
  return s;
}

Map<String, String> _parseAis(String input) {
  final result = <String, String>{};
  for (final match in _aiElement.allMatches(input)) {
    final ai = match.group(1)!;
    var value = match.group(2)!.trim();
    // Strip trailing GS character if scanner inserted it as a separator
    if (value.endsWith(_gs)) value = value.substring(0, value.length - 1);
    result[ai] = value;
  }
  return result;
}
