import 'package:traqtrace_app/core/utils/gs1/gs1_converter.dart';


final _aiElement = RegExp(r'\((\d{2,4})\)([^(]*)');

const _fnc1Prefixes = [']C1', ']e0', ']Q3'];

const _gs = '';

bool isGS1AiNotation(String input) {
  final s = _stripFnc1Prefix(input.trim());
  return s.startsWith('(');
}

String? gs1AiToEpcUri(String input) {
  final trimmed = _stripFnc1Prefix(input.trim());
  if (!trimmed.startsWith('(')) return null;

  final ais = _parseAis(trimmed);
  if (ais.isEmpty) return null;

  final sscc = ais['00'];
  final gtin = ais['01'];
  final lot = ais['10'];
  final serial = ais['21'];

  if (sscc != null && sscc.isNotEmpty) {
    final s18 = sscc.padLeft(18, '0');
    if (!RegExp(r'^\d{18}$').hasMatch(s18)) return null;
    return Gs1Converter.ssccToEpc(s18);
  }

  if (gtin != null && gtin.isNotEmpty) {
    final gtin14 = gtin.padLeft(14, '0');
    if (!RegExp(r'^\d{14}$').hasMatch(gtin14)) return null;

    if (serial != null && serial.isNotEmpty) {
      return Gs1Converter.gtinSerialToEpc(gtin14, serial);
    }

    if (lot != null && lot.isNotEmpty) {
      return Gs1Converter.gtinLotToLgtinEpc(gtin14, lot);
    }

    return Gs1Converter.gtinToClassEpc(gtin14);
  }

  return null;
}

String normalizeEpcInput(String input) {
  final trimmed = input.trim();
  if (isGS1AiNotation(trimmed)) {
    return gs1AiToEpcUri(trimmed) ?? trimmed;
  }
  if (trimmed.startsWith('https://id.gs1.org/')) {
    return Gs1Converter.barcodeToEpc(trimmed) ?? trimmed;
  }
  return trimmed;
}


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
    if (value.endsWith(_gs)) value = value.substring(0, value.length - 1);
    result[ai] = value;
  }
  return result;
}
