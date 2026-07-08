import 'package:traqtrace_app/core/utils/gs1/gs1_converter.dart';
import 'package:traqtrace_app/core/utils/gs1/gs1_parser.dart';
import 'package:traqtrace_app/core/utils/epc_uri_validators.dart';
import 'package:traqtrace_app/core/utils/gs1_ai_normalizer.dart';
import 'package:traqtrace_app/core/widgets/epc_input_widget/epc_types.dart';
import 'package:traqtrace_app/features/gs1/gtin/utils/gtin_format.dart';
import 'package:traqtrace_app/features/gs1/sscc/utils/sscc_format.dart';

String? normalizeGS1AiToEpcUrn(String input) => gs1AiToEpcUri(input);

EPCParseResult parseToEPC(String input) {
  final raw = input.trim();
  if (raw.isEmpty) {
    throw EPCParseException('EPC input is empty');
  }

  if (raw.startsWith('urn:epc:tag:')) {
    final pureIdentity = _tagUriToPureIdentity(raw);
    if (pureIdentity == null || !isValidEpcUri(pureIdentity)) {
      throw EPCParseException(
        'EPC Tag URI could not be converted to a Pure Identity URI',
      );
    }
    return _fromEpcUri(
      pureIdentity,
      raw: raw,
      detectedFormat: 'EPC Tag URI',
    );
  }

  if (raw.startsWith('urn:epc:')) {
    if (!isValidEpcUri(raw)) {
      throw EPCParseException('Invalid EPC URI format');
    }
    return _fromEpcUri(raw, raw: raw, detectedFormat: 'EPC URN');
  }

  if (raw.startsWith('http://') || raw.startsWith('https://')) {
    final epc = normalizeEpcInput(raw);
    if (!isValidEpcUri(epc)) {
      throw EPCParseException('Invalid GS1 Digital Link URI format');
    }
    return _fromEpcUri(epc, raw: raw, detectedFormat: 'GS1 Digital Link');
  }

  if (raw.contains('(') && raw.contains(')')) {
    final epc = normalizeGS1AiToEpcUrn(raw);
    if (epc == null || !isValidEpcUri(epc)) {
      throw EPCParseException(
        'GS1 barcode could not be converted to a valid EPC URI',
      );
    }
    return _fromEpcUri(epc, raw: raw, detectedFormat: 'GS1 AI notation');
  }

  if (raw.startsWith('00')) {
    final stripped = SsccFormat.stripSsccInput(raw);
    if (stripped.length == 18 && SsccFormat.isValidSscc(stripped)) {
      return _fromSsccDigits(stripped, raw: raw, detectedFormat: 'SSCC');
    }
  }

  final digitsOnly = GtinFormat.stripGtinInput(raw);
  if (RegExp(r'^\d+$').hasMatch(digitsOnly) &&
      const {8, 12, 13, 14}.contains(digitsOnly.length)) {
    if (GtinFormat.isValidGtin(digitsOnly)) {
      final gtin14 = GtinFormat.normalizeGtinTo14(digitsOnly);
      final epc = Gs1Converter.gtinToClassEpc(gtin14);
      if (epc == null) {
        throw EPCParseException('Could not convert GTIN to EPC URI');
      }
      return EPCParseResult(
        type: EPCType.gtin,
        epc: epc,
        gtin: gtin14,
        raw: raw,
        detectedFormat: 'GTIN',
      );
    }
  }

  final parsed = Gs1Parser.parseBarcode(raw);
  if (parsed['valid'] == true) {
    final epc = Gs1Converter.barcodeToEpc(raw);
    if (epc != null && isValidEpcUri(epc)) {
      return _fromEpcUri(
        epc,
        raw: raw,
        detectedFormat: 'GS1 element string',
        parsed: parsed,
      );
    }
  }

  throw EPCParseException('Unrecognized barcode format: $raw');
}

String? _tagUriToPureIdentity(String tagUri) {
  if (tagUri.startsWith('urn:epc:tag:sgtin-')) {
    final schemeEnd = 'urn:epc:tag:sgtin-'.length;
    final colon = tagUri.indexOf(':', schemeEnd);
    if (colon < 0) return null;
    final rest = tagUri.substring(colon + 1);
    final parts = rest.split('.');
    if (parts.length < 4) return null;
    final gcp = parts[1];
    final itemRef = parts[2];
    final serial = parts.sublist(3).join('.');
    return 'urn:epc:id:sgtin:$gcp.$itemRef.$serial';
  }
  if (tagUri.startsWith('urn:epc:tag:sscc-')) {
    final schemeEnd = 'urn:epc:tag:sscc-'.length;
    final colon = tagUri.indexOf(':', schemeEnd);
    if (colon < 0) return null;
    final rest = tagUri.substring(colon + 1);
    final parts = rest.split('.');
    if (parts.length < 3) return null;
    final gcp = parts[1];
    final serialRef = parts[2];
    return 'urn:epc:id:sscc:$gcp.$serialRef';
  }
  return null;
}

EPCParseResult _fromSsccDigits(
  String sscc18, {
  required String raw,
  required String detectedFormat,
}) {
  final epc = Gs1Converter.ssccToEpc(sscc18);
  if (epc == null) {
    throw EPCParseException('Could not convert SSCC to EPC URI');
  }
  return EPCParseResult(
    type: EPCType.sscc,
    epc: epc,
    sscc: sscc18,
    raw: raw,
    detectedFormat: detectedFormat,
  );
}

EPCParseResult _fromEpcUri(
  String epc, {
  required String raw,
  required String detectedFormat,
  Map<String, dynamic>? parsed,
}) {
  String? gtin;
  String? serial;
  String? sscc;
  String? companyPrefix;
  int? gcpLength;

  if (epc.startsWith('urn:epc:id:sgtin:')) {
    final tail = epc.substring('urn:epc:id:sgtin:'.length);
    final parts = tail.split('.');
    if (parts.isNotEmpty) {
      companyPrefix = parts[0];
      gcpLength = parts[0].length;
    }
    if (parts.length == 3) {
      serial = parts[2];
    }
    gtin = _gtinFromParsedOrAi(raw, parsed);
  } else if (epc.startsWith('urn:epc:id:sscc:')) {
    final tail = epc.substring('urn:epc:id:sscc:'.length);
    final parts = tail.split('.');
    if (parts.isNotEmpty) {
      companyPrefix = parts[0];
      gcpLength = parts[0].length;
    }
    sscc = _ssccFromParsedOrAi(raw, parsed);
  } else if (epc.startsWith('urn:epc:id:lgtin:')) {
    final tail = epc.substring('urn:epc:id:lgtin:'.length);
    final parts = tail.split('.');
    if (parts.isNotEmpty) {
      companyPrefix = parts[0];
      gcpLength = parts[0].length;
    }
    gtin = _gtinFromParsedOrAi(raw, parsed);
  } else if (epc.startsWith('urn:epc:idpat:sgtin:')) {
    final tail = epc.substring('urn:epc:idpat:sgtin:'.length);
    final parts = tail.split('.');
    if (parts.isNotEmpty) {
      companyPrefix = parts[0];
      gcpLength = parts[0].length;
    }
    gtin = _gtinFromParsedOrAi(raw, parsed);
  } else if (parsed != null) {
    gtin = parsed['GTIN'] as String?;
    serial = parsed['SERIAL'] as String?;
    sscc = parsed['SSCC'] as String?;
  }

  if (gtin == null && raw.contains('(01)')) {
    gtin = _gtinFromParsedOrAi(raw, parsed);
  }
  if (serial == null && raw.contains('(21)')) {
    final aiParsed = Gs1Parser.parseBarcode(raw);
    serial = aiParsed['SERIAL'] as String?;
    gtin ??= aiParsed['GTIN'] as String?;
  }
  if (sscc == null && raw.contains('(00)')) {
    sscc = _ssccFromParsedOrAi(raw, parsed);
  }

  final type = _resolveType(epc, gtin: gtin, serial: serial, sscc: sscc);

  return EPCParseResult(
    type: type,
    epc: epc,
    gtin: gtin,
    serial: serial,
    sscc: sscc,
    gcpLength: gcpLength,
    companyPrefix: companyPrefix,
    raw: raw,
    detectedFormat: detectedFormat,
  );
}

String? _gtinFromParsedOrAi(String raw, Map<String, dynamic>? parsed) {
  final fromParsed = parsed?['GTIN'] as String?;
  if (fromParsed != null && fromParsed.isNotEmpty) return fromParsed;

  if (raw.startsWith('http://') || raw.startsWith('https://')) {
    final dlGtin = RegExp(r'/01/(\d{14})').firstMatch(raw)?.group(1);
    if (dlGtin != null) return dlGtin;
  }

  if (!raw.startsWith('http://') && !raw.startsWith('https://')) {
    final aiParsed = Gs1Parser.parseBarcode(raw);
    final gtin = aiParsed['GTIN'] as String?;
    if (gtin != null && gtin.isNotEmpty) return gtin.padLeft(14, '0');
  }

  final dlMatch = RegExp(r'/01/(\d{14})').firstMatch(raw);
  return dlMatch?.group(1);
}

String? _ssccFromParsedOrAi(String raw, Map<String, dynamic>? parsed) {
  final fromParsed = parsed?['SSCC'] as String?;
  if (fromParsed != null && fromParsed.isNotEmpty) {
    return fromParsed.padLeft(18, '0');
  }

  if (raw.startsWith('http://') || raw.startsWith('https://')) {
    final dlSscc = RegExp(r'/00/(\d{18})').firstMatch(raw)?.group(1);
    if (dlSscc != null) return dlSscc;
  }

  if (!raw.startsWith('http://') && !raw.startsWith('https://')) {
    final aiParsed = Gs1Parser.parseBarcode(raw);
    final sscc = aiParsed['SSCC'] as String?;
    if (sscc != null && sscc.isNotEmpty) return sscc.padLeft(18, '0');
  }

  final dlMatch = RegExp(r'/00/(\d{18})').firstMatch(raw);
  return dlMatch?.group(1);
}

EPCType _resolveType(
  String epc, {
  String? gtin,
  String? serial,
  String? sscc,
}) {
  if (epc.startsWith('urn:epc:id:sgtin:')) return EPCType.sgtin;
  if (epc.startsWith('urn:epc:id:sscc:')) return EPCType.sscc;
  if (epc.startsWith('urn:epc:id:lgtin:') ||
      epc.startsWith('urn:epc:idpat:sgtin:') ||
      epc.startsWith('urn:epc:class:lgtin:')) {
    return EPCType.gtin;
  }
  if (serial != null && serial.isNotEmpty) return EPCType.sgtin;
  if (sscc != null && sscc.isNotEmpty) return EPCType.sscc;
  if (gtin != null && gtin.isNotEmpty) return EPCType.gtin;
  return EPCType.unknown;
}
