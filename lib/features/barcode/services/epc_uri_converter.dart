import 'package:flutter/foundation.dart';
import 'package:traqtrace_app/core/utils/gs1/check_digit_utils.dart';
import 'package:traqtrace_app/features/barcode/services/gs1_barcode_parser.dart';

class EPCURIConverter {
  
  static String? convertToEPCUri(String barcode) {
    if (barcode.isEmpty) return null;

    if (barcode.startsWith('urn:epc:')) {
      return barcode;
    }

    if (barcode.startsWith('https://id.gs1.org/')) {
      return _convertGs1DlToEpcUri(barcode);
    }

    if (RegExp(r'^\d{18}$').hasMatch(barcode)) {
      debugPrint('EPCURIConverter: Detected raw 18-digit SSCC: $barcode');
      return convertSSCCToEPCUri(barcode);
    }

    final parsed = GS1BarcodeParser.parseGS1Barcode(barcode);
    
    if (parsed['valid'] == true) {
      if (parsed['SSCC'] != null) {
        return convertSSCCToEPCUri(parsed['SSCC']);
      }
      
      if (parsed['GTIN'] != null && parsed['SERIAL'] != null) {
        return convertGTINSerialToEPCUri(
          parsed['GTIN'],
          parsed['SERIAL'],
          gcpLength: _gcpLengthFromParsed(parsed),
        );
      }

      final lot = parsed['BATCH'] ?? parsed['LOT'];
      if (parsed['GTIN'] != null && lot != null && lot.toString().isNotEmpty) {
        return convertGTINLotToLGTINEpcUri(
          parsed['GTIN'].toString(),
          lot.toString(),
          gcpLength: _gcpLengthFromParsed(parsed),
        );
      }
      
      if (parsed['GTIN'] != null) {
        return convertGTINToClassEPCUri(
          parsed['GTIN'],
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

      final resolvedGcpLength =
          gcpLength ?? _resolveGcpLength(normalizedGtin);
      final companyPrefix =
          normalizedGtin.substring(1, 1 + resolvedGcpLength);
      final indicatorAndItemRef =
          normalizedGtin[0] + normalizedGtin.substring(1 + resolvedGcpLength, 13);

      return 'urn:epc:id:sgtin:$companyPrefix.$indicatorAndItemRef.$serialNumber';
    } catch (e) {
      debugPrint('EPCURIConverter: Error converting GTIN/Serial to EPC URI: $e');
      return null;
    }
  }

  static int _resolveGcpLength(String gtin14) {
    if (gtin14.length != 14) return 7;

    final body = gtin14.substring(1, 13);

    if (_matchesAny(body, const ['0000000000', '0000000001'])) return 12;

    return 7;
  }

  static bool _matchesAny(String value, List<String> prefixes) =>
      prefixes.any((prefix) => value.startsWith(prefix));

  static int? _gcpLengthFromParsed(Map<String, dynamic> parsed) {
    final raw = parsed['gs1CompanyPrefixLength'];
    if (raw == null) return null;
    return int.tryParse(raw.toString());
  }
  
  static String? convertSSCCToEPCUri(String sscc) {
    if (sscc.isEmpty) return null;
    
    try {
      String normalizedSscc = sscc.padLeft(18, '0');
      
      
      String extensionDigit = normalizedSscc.substring(0, 1);
      String companyPrefix = normalizedSscc.substring(1, 8);
      String serialReference = normalizedSscc.substring(8, 17);
      
      String fullSerialRef = extensionDigit + serialReference;
      
      return 'urn:epc:id:sscc:$companyPrefix.$fullSerialRef';
    } catch (e) {
      debugPrint('EPCURIConverter: Error converting SSCC to EPC URI: $e');
      return null;
    }
  }
  
  static String? convertGLNToEPCUri(String gln, {String extension = '0'}) {
    if (gln.isEmpty) return null;
    
    try {
      String normalizedGln = gln.padLeft(13, '0');
      
      
      String companyPrefix = normalizedGln.substring(0, 7);
      String locationReference = normalizedGln.substring(7, 12);
      
      return 'urn:epc:id:sgln:$companyPrefix.$locationReference.$extension';
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

      final resolvedGcpLength =
          gcpLength ?? _resolveGcpLength(normalizedGtin);
      final companyPrefix =
          normalizedGtin.substring(1, 1 + resolvedGcpLength);
      final indicatorAndItemRef =
          normalizedGtin[0] + normalizedGtin.substring(1 + resolvedGcpLength, 13);

      return 'urn:epc:id:lgtin:$companyPrefix.$indicatorAndItemRef.$lotNumber';
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

      final resolvedGcpLength =
          gcpLength ?? _resolveGcpLength(normalizedGtin);
      final companyPrefix =
          normalizedGtin.substring(1, 1 + resolvedGcpLength);
      final indicatorAndItemRef =
          normalizedGtin[0] + normalizedGtin.substring(1 + resolvedGcpLength, 13);

      return 'urn:epc:idpat:sgtin:$companyPrefix.$indicatorAndItemRef.*';
    } catch (e) {
      debugPrint('EPCURIConverter: Error converting GTIN to Class EPC URI: $e');
      return null;
    }
  }
  
  static String? getEPCType(String epcUri) {
    if (epcUri.startsWith('urn:epc:id:sgtin:')) return 'sgtin';
    if (epcUri.startsWith('urn:epc:idpat:sgtin:')) return 'sgtin-class';
    if (epcUri.startsWith('urn:epc:id:sscc:')) return 'sscc';
    if (epcUri.startsWith('urn:epc:id:sgln:')) return 'sgln';
    return null;
  }
  
  static Map<String, List<String>> convertBatchToEPCUri(List<String> barcodes) {
    List<String> successful = [];
    List<String> failed = [];
    
    for (String barcode in barcodes) {
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
    
    final sgtinPattern = RegExp(r'^urn:epc:id:sgtin:\d+\.\d+\.\w+$');
    
    final sgtinClassPattern = RegExp(r'^urn:epc:idpat:sgtin:\d+\.\d+\.\*$');
    
    final ssccPattern = RegExp(r'^urn:epc:id:sscc:\d+\.\d+$');
    
    final sglnPattern = RegExp(r'^urn:epc:id:sgln:\d+\.\d+\.\w*$');
    
    return sgtinPattern.hasMatch(uri) ||
           sgtinClassPattern.hasMatch(uri) ||
           ssccPattern.hasMatch(uri) ||
           sglnPattern.hasMatch(uri);
  }
  

  static String? extractGTINFromEPCUri(String epcUri) {
    if (!epcUri.startsWith('urn:epc:id:sgtin:')) return null;

    try {
      final parts = epcUri.substring('urn:epc:id:sgtin:'.length).split('.');
      if (parts.length >= 2) {
        final gcp = parts[0];
        final indicatorPlusRef = parts[1];
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

  static String? _convertGs1DlToEpcUri(String dlUrl) {
    final sgtinRe = RegExp(
      r'^https://id\.gs1\.org/01/(\d{14})/21/([A-Za-z0-9!"%()*+,\-./:;<=>?_`{|}~]+)$',
      caseSensitive: false,
    );
    final sgtinMatch = sgtinRe.firstMatch(dlUrl);
    if (sgtinMatch != null) {
      return convertGTINSerialToEPCUri(sgtinMatch.group(1)!, sgtinMatch.group(2)!);
    }

    final gtinClassRe = RegExp(
      r'^https://id\.gs1\.org/01/(\d{14})$',
      caseSensitive: false,
    );
    final gtinClassMatch = gtinClassRe.firstMatch(dlUrl);
    if (gtinClassMatch != null) {
      return convertGTINToClassEPCUri(gtinClassMatch.group(1)!);
    }

    final lgtinRe = RegExp(
      r'^https://id\.gs1\.org/01/(\d{14})/10/([!%-?A-Z_a-z"]+)$',
      caseSensitive: false,
    );
    final lgtinMatch = lgtinRe.firstMatch(dlUrl);
    if (lgtinMatch != null) {
      return convertGTINLotToLGTINEpcUri(
        lgtinMatch.group(1)!,
        lgtinMatch.group(2)!,
      );
    }

    final ssccRe = RegExp(
      r'^https://id\.gs1\.org/00/(\d{18})$',
      caseSensitive: false,
    );
    final ssccMatch = ssccRe.firstMatch(dlUrl);
    if (ssccMatch != null) {
      return convertSSCCToEPCUri(ssccMatch.group(1)!);
    }

    debugPrint('EPCURIConverter: Unrecognised GS1 DL URL: $dlUrl');
    return null;
  }

  static String? extractSerialFromEPCUri(String epcUri) {
    if (!epcUri.startsWith('urn:epc:id:sgtin:')) return null;
    
    try {
      final parts = epcUri.substring('urn:epc:id:sgtin:'.length).split('.');
      if (parts.length >= 3) {
        return parts[2];
      }
    } catch (e) {
      debugPrint('EPCURIConverter: Error extracting serial from EPC URI: $e');
    }
    return null;
  }
}
