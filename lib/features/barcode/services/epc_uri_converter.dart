import 'package:flutter/foundation.dart';
import 'package:traqtrace_app/core/utils/gs1/check_digit_utils.dart';
import 'package:traqtrace_app/features/barcode/services/gs1_barcode_parser.dart';


class EPCURIConverter {
  static const String _dlBase = 'https://id.gs1.org';

  
  static String normalizeForStorage(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return trimmed;
    if (trimmed.startsWith('$_dlBase/')) return trimmed;

    final converted = convertToEPCUri(trimmed);
    if (converted != null) return converted;

    return _urnToDigitalLink(trimmed) ?? trimmed;
  }

  static String? convertToEPCUri(String barcode) {
    if (barcode.isEmpty) return null;

    if (barcode.startsWith('$_dlBase/')) {
      return barcode;
    }

    if (barcode.startsWith('urn:epc:')) {
      return _urnToDigitalLink(barcode);
    }

    if (RegExp(r'^\d{18}$').hasMatch(barcode)) {
      final gtin14 = barcode.substring(0, 14);
      final serial = barcode.substring(14);
      
      
      if (CheckDigitUtils.isValidMod10(gtin14) && serial.isNotEmpty) {
        return convertGTINSerialToEPCUri(gtin14, serial);
      }
      return convertSSCCToEPCUri(barcode);
    }

    final parsed = GS1BarcodeParser.parseGS1Barcode(barcode);
    if (parsed['valid'] == true) {
      final ssccRaw = parsed['SSCC']?.toString();
      final ssccDigits = ssccRaw?.replaceAll(RegExp(r'\D'), '') ?? '';
      final serial = parsed['SERIAL']?.toString();
      final gtinRaw = parsed['GTIN']?.toString();

      
      if (ssccDigits.length == 18) {
        return convertSSCCToEPCUri(ssccDigits);
      }

      var gtin = gtinRaw;
      if ((gtin == null || gtin.isEmpty) &&
          ssccDigits.isNotEmpty &&
          serial != null &&
          serial.isNotEmpty &&
          const {8, 12, 13, 14}.contains(ssccDigits.length)) {
        gtin = ssccDigits;
      }

      if (gtin != null && serial != null) {
        return convertGTINSerialToEPCUri(
          gtin,
          serial,
          gcpLength: _gcpLengthFromParsed(parsed),
        );
      }

      final lot = parsed['BATCH'] ?? parsed['LOT'];
      if (gtin != null && lot != null && lot.toString().isNotEmpty) {
        return convertGTINLotToLGTINEpcUri(
          gtin.toString(),
          lot.toString(),
          gcpLength: _gcpLengthFromParsed(parsed),
        );
      }

      if (gtin != null) {
        return convertGTINToClassEPCUri(
          gtin,
          gcpLength: _gcpLengthFromParsed(parsed),
        );
      }
    }

    debugPrint('EPCURIConverter: Unable to convert barcode to EPC URI: $barcode');
    return null;
  }

  static String? convertGTINSerialToEPCUri(
    String gtin,
    String serialNumber, {
    int? gcpLength,
  }) {
    if (gtin.isEmpty || serialNumber.isEmpty) return null;

    try {
      final normalizedGtin = gtin.padLeft(14, '0');
      if (normalizedGtin.length != 14) return null;

      final cleanSerial = serialNumber.replaceAll(
        RegExp(r'[^A-Za-z0-9!"%()*+,\-./:;<=>?_`{|}~]'),
        '',
      );
      return '$_dlBase/01/$normalizedGtin/21/$cleanSerial';
    } catch (e) {
      debugPrint('EPCURIConverter: Error converting GTIN/Serial to EPC URI: $e');
      return null;
    }
  }

  static String? convertSSCCToEPCUri(String sscc) {
    if (sscc.isEmpty) return null;

    try {
      final normalizedSscc = sscc.replaceAll(RegExp(r'[^0-9]'), '');
      
      if (normalizedSscc.length != 18) return null;
      return '$_dlBase/00/$normalizedSscc';
    } catch (e) {
      debugPrint('EPCURIConverter: Error converting SSCC to EPC URI: $e');
      return null;
    }
  }

  static String? convertGLNToEPCUri(String gln, {String extension = '0'}) {
    if (gln.isEmpty) return null;

    try {
      final normalizedGln = gln.replaceAll(RegExp(r'[^0-9]'), '').padLeft(13, '0');
      if (normalizedGln.length != 13) return null;

      if (extension.isNotEmpty && extension != '0') {
        return '$_dlBase/414/$normalizedGln/254/$extension';
      }
      return '$_dlBase/414/$normalizedGln';
    } catch (e) {
      debugPrint('EPCURIConverter: Error converting GLN to EPC URI: $e');
      return null;
    }
  }

  static String? convertGTINLotToLGTINEpcUri(
    String gtin,
    String lotNumber, {
    int? gcpLength,
  }) {
    if (gtin.isEmpty || lotNumber.isEmpty) return null;

    try {
      final normalizedGtin = gtin.padLeft(14, '0');
      if (normalizedGtin.length != 14) return null;
      return '$_dlBase/01/$normalizedGtin/10/$lotNumber';
    } catch (e) {
      debugPrint('EPCURIConverter: Error converting GTIN/Lot to LGTIN EPC URI: $e');
      return null;
    }
  }

  static String? convertGTINToClassEPCUri(String gtin, {int? gcpLength}) {
    if (gtin.isEmpty) return null;

    try {
      final normalizedGtin = gtin.padLeft(14, '0');
      if (normalizedGtin.length != 14) return null;
      return '$_dlBase/01/$normalizedGtin';
    } catch (e) {
      debugPrint('EPCURIConverter: Error converting GTIN to Class EPC URI: $e');
      return null;
    }
  }

  static String? getEPCType(String epcUri) {
    if (epcUri.startsWith('$_dlBase/01/') && epcUri.contains('/21/')) {
      return 'sgtin';
    }
    if (epcUri.startsWith('$_dlBase/01/') && epcUri.contains('/10/')) {
      return 'lgtin';
    }
    if (epcUri.startsWith('$_dlBase/01/')) return 'sgtin-class';
    if (epcUri.startsWith('$_dlBase/00/')) return 'sscc';
    if (epcUri.startsWith('$_dlBase/414/')) return 'sgln';

    if (epcUri.startsWith('urn:epc:id:sgtin:')) return 'sgtin';
    if (epcUri.startsWith('urn:epc:idpat:sgtin:')) return 'sgtin-class';
    if (epcUri.startsWith('urn:epc:id:lgtin:')) return 'lgtin';
    if (epcUri.startsWith('urn:epc:id:sscc:')) return 'sscc';
    if (epcUri.startsWith('urn:epc:id:sgln:')) return 'sgln';
    return null;
  }

  static Map<String, List<String>> convertBatchToEPCUri(List<String> barcodes) {
    final successful = <String>[];
    final failed = <String>[];

    for (final barcode in barcodes) {
      final epcUri = convertToEPCUri(barcode);
      if (epcUri != null) {
        successful.add(epcUri);
      } else {
        failed.add(barcode);
      }
    }

    return {
      'successful': successful,
      'failed': failed,
    };
  }

  static bool isValidEPCUri(String uri) {
    if (uri.isEmpty) return false;

    final dlSgtin = RegExp(
      r'^https://id\.gs1\.org/01/\d{14}/21/[!%-?A-Z_a-z"]{1,20}$',
    );
    final dlClass = RegExp(r'^https://id\.gs1\.org/01/\d{14}$');
    final dlLgtin = RegExp(
      r'^https://id\.gs1\.org/01/\d{14}/10/[!%-?A-Z_a-z"]{1,20}$',
    );
    final dlSscc = RegExp(r'^https://id\.gs1\.org/00/\d{18}$');
    final dlSgln = RegExp(r'^https://id\.gs1\.org/414/\d{13}(/254/.+)?$');

    final sgtinUrn = RegExp(r'^urn:epc:id:sgtin:\d+\.\d+\.\w+$');
    final sgtinClassUrn = RegExp(r'^urn:epc:idpat:sgtin:\d+\.\d+\.\*$');
    final ssccUrn = RegExp(r'^urn:epc:id:sscc:\d+\.\d+$');
    final sglnUrn = RegExp(r'^urn:epc:id:sgln:\d+\.\d+\.\w*$');

    return dlSgtin.hasMatch(uri) ||
        dlClass.hasMatch(uri) ||
        dlLgtin.hasMatch(uri) ||
        dlSscc.hasMatch(uri) ||
        dlSgln.hasMatch(uri) ||
        sgtinUrn.hasMatch(uri) ||
        sgtinClassUrn.hasMatch(uri) ||
        ssccUrn.hasMatch(uri) ||
        sglnUrn.hasMatch(uri);
  }

  static String? extractGTINFromEPCUri(String epcUri) {
    final dlSgtin = RegExp(r'^https://id\.gs1\.org/01/(\d{14})(?:/21/|/10/|$)');
    final dlMatch = dlSgtin.firstMatch(epcUri);
    if (dlMatch != null) return dlMatch.group(1);

    if (!epcUri.startsWith('urn:epc:id:sgtin:') &&
        !epcUri.startsWith('urn:epc:idpat:sgtin:') &&
        !epcUri.startsWith('urn:epc:id:lgtin:')) {
      return null;
    }

    try {
      final prefix = epcUri.startsWith('urn:epc:id:lgtin:')
          ? 'urn:epc:id:lgtin:'
          : epcUri.startsWith('urn:epc:idpat:sgtin:')
              ? 'urn:epc:idpat:sgtin:'
              : 'urn:epc:id:sgtin:';
      final parts = epcUri.substring(prefix.length).split('.');
      if (parts.length >= 2) {
        final gcp = parts[0];
        final indicatorPlusRef = parts[1].replaceAll('.*', '');
        if (indicatorPlusRef.isEmpty) return null;

        final indicator = indicatorPlusRef[0];
        final itemRef = indicatorPlusRef.substring(1);
        final body = '$indicator$gcp$itemRef';
        final checkDigit = CheckDigitUtils.calculateMod10(body);
        return '$body$checkDigit';
      }
    } catch (e) {
      debugPrint('EPCURIConverter: Error extracting GTIN from EPC URI: $e');
    }
    return null;
  }

  static String? extractSerialFromEPCUri(String epcUri) {
    final dlMatch = RegExp(
      r'^https://id\.gs1\.org/01/\d{14}/21/(.+)$',
    ).firstMatch(epcUri);
    if (dlMatch != null) {
      try {
        return Uri.decodeComponent(dlMatch.group(1)!);
      } catch (_) {
        return dlMatch.group(1);
      }
    }

    if (!epcUri.startsWith('urn:epc:id:sgtin:')) return null;

    try {
      final parts = epcUri.substring('urn:epc:id:sgtin:'.length).split('.');
      if (parts.length >= 3) return parts.sublist(2).join('.');
    } catch (e) {
      debugPrint('EPCURIConverter: Error extracting serial from EPC URI: $e');
    }
    return null;
  }

  
  static String? extractSSCCFromEPCUri(String epcUri) {
    final dlMatch =
        RegExp(r'^https://id\.gs1\.org/00/(\d{18})$').firstMatch(epcUri);
    if (dlMatch != null) return dlMatch.group(1);

    final urnMatch =
        RegExp(r'^urn:epc:id:sscc:(\d+)\.(\d+)$').firstMatch(epcUri);
    if (urnMatch == null) return null;
    try {
      final ext = urnMatch.group(2)![0];
      final remaining = urnMatch.group(2)!.substring(1);
      final body = '$ext${urnMatch.group(1)}$remaining';
      final checkDigit = CheckDigitUtils.calculateMod10(body);
      return '$body$checkDigit';
    } catch (e) {
      debugPrint('EPCURIConverter: Error extracting SSCC from EPC URI: $e');
      return null;
    }
  }

  static int? _gcpLengthFromParsed(Map<String, dynamic> parsed) {
    final raw = parsed['gs1CompanyPrefixLength'];
    if (raw == null) return null;
    return int.tryParse(raw.toString());
  }

  static String? _urnToDigitalLink(String urn) {
    if (urn.startsWith('$_dlBase/')) return urn;

    final sgtinUrn = RegExp(
      r'^urn:epc:id:sgtin:(\d+)\.(\d+)\.(.+)$',
    ).firstMatch(urn);
    if (sgtinUrn != null) {
      final gtin = _gtinFromUrnSegments(sgtinUrn.group(1)!, sgtinUrn.group(2)!);
      if (gtin == null) return null;
      return convertGTINSerialToEPCUri(gtin, sgtinUrn.group(3)!);
    }

    final classUrn = RegExp(
      r'^urn:epc:idpat:sgtin:(\d+)\.(\d+)\.\*$',
    ).firstMatch(urn);
    if (classUrn != null) {
      final gtin = _gtinFromUrnSegments(classUrn.group(1)!, classUrn.group(2)!);
      if (gtin == null) return null;
      return convertGTINToClassEPCUri(gtin);
    }

    if (urn.startsWith('urn:epc:idpat:sgtin:') && urn.endsWith('.*')) {
      final body = urn.substring('urn:epc:idpat:sgtin:'.length, urn.length - 2);
      if (RegExp(r'^\d{14}$').hasMatch(body)) {
        return convertGTINToClassEPCUri(body);
      }
    }

    final lgtinUrn = RegExp(
      r'^urn:epc:id:lgtin:(\d+)\.(\d+)\.(.+)$',
    ).firstMatch(urn);
    if (lgtinUrn != null) {
      final gtin = _gtinFromUrnSegments(lgtinUrn.group(1)!, lgtinUrn.group(2)!);
      if (gtin == null) return null;
      return convertGTINLotToLGTINEpcUri(gtin, lgtinUrn.group(3)!);
    }

    final ssccUrn = RegExp(r'^urn:epc:id:sscc:(\d+)\.(\d+)$').firstMatch(urn);
    if (ssccUrn != null) {
      final ext = ssccUrn.group(2)![0];
      final remaining = ssccUrn.group(2)!.substring(1);
      final body = '$ext${ssccUrn.group(1)}$remaining';
      final checkDigit = CheckDigitUtils.calculateMod10(body);
      return convertSSCCToEPCUri('$body$checkDigit');
    }

    final sglnUrn = RegExp(
      r'^urn:epc:id:sgln:(\d+)\.(\d+)\.(.*)$',
    ).firstMatch(urn);
    if (sglnUrn != null) {
      final body = '${sglnUrn.group(1)}${sglnUrn.group(2)}';
      final checkDigit = CheckDigitUtils.calculateMod10(body);
      return convertGLNToEPCUri(
        '$body$checkDigit',
        extension: sglnUrn.group(3) ?? '0',
      );
    }

    return null;
  }

  static String? _gtinFromUrnSegments(String gcp, String indicatorAndItemRef) {
    if (indicatorAndItemRef.isEmpty) return null;
    final indicator = indicatorAndItemRef[0];
    final itemRef = indicatorAndItemRef.substring(1);
    final body = '$indicator$gcp$itemRef';
    final checkDigit = CheckDigitUtils.calculateMod10(body);
    return '$body$checkDigit';
  }
}
