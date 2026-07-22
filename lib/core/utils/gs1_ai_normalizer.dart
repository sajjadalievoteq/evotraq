import 'package:traqtrace_app/core/utils/gs1/gs1_converter.dart';
import 'package:traqtrace_app/features/barcode/services/epc_uri_converter.dart';
import 'package:traqtrace_app/features/gs1/gtin/utils/gtin_format.dart';
import 'package:traqtrace_app/features/gs1/sscc/utils/sscc_format.dart';

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

  final ai00 = ais['00'];
  final gtin = ais['01'];
  final lot = ais['10'];
  final serial = ais['21'];

  final ai00Digits = ai00?.replaceAll(RegExp(r'\D'), '') ?? '';

  
  
  if (ai00Digits.length == 18 && SsccFormat.isValidSscc(ai00Digits)) {
    return Gs1Converter.ssccToEpc(ai00Digits);
  }

  
  var gtinCandidate = gtin?.replaceAll(RegExp(r'\D'), '') ?? '';
  if (gtinCandidate.isEmpty &&
      ai00Digits.isNotEmpty &&
      serial != null &&
      serial.isNotEmpty &&
      const {8, 12, 13, 14}.contains(ai00Digits.length)) {
    gtinCandidate = ai00Digits;
  }

  if (gtinCandidate.isNotEmpty) {
    if (!GtinFormat.isValidGtin(gtinCandidate) &&
        !RegExp(r'^\d{8}$|^\d{12}$|^\d{13}$|^\d{14}$').hasMatch(gtinCandidate)) {
      return null;
    }
    final gtin14 = gtinCandidate.length == 14
        ? gtinCandidate
        : gtinCandidate.padLeft(14, '0');
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
  if (trimmed.isEmpty) return trimmed;

  if (isGS1AiNotation(trimmed)) {
    final fromAi = gs1AiToEpcUri(trimmed);
    if (fromAi != null) return EPCURIConverter.normalizeForStorage(fromAi);
    return trimmed;
  }

  if (trimmed.startsWith('https://id.gs1.org/') ||
      trimmed.startsWith('urn:epc:')) {
    return EPCURIConverter.normalizeForStorage(trimmed);
  }

  final converted = Gs1Converter.barcodeToEpc(trimmed);
  if (converted != null) return converted;

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
