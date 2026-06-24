import 'package:flutter/foundation.dart';
import 'package:traqtrace_app/features/barcode/services/gs1_barcode_parser.dart';

/// Central EPC URI Conversion Service
/// 
/// This service provides unified conversion between different barcode formats
/// and EPC URIs. It should be used across the entire application for:
/// - Shipping operations
/// - Receiving operations
/// - Event posting
/// - Any other EPCIS-related operations
/// 
/// Supported conversions:
/// - GS1 Element String (AI format) → EPC URI
/// - GTIN + Serial → SGTIN EPC URI
/// - SSCC → SSCC EPC URI
/// - GLN → SGLN EPC URI
class EPCURIConverter {
  
  /// Converts a raw barcode (in any supported format) to EPC URI format
  /// 
  /// Supported input formats:
  /// - GS1 Element String: (01)03664798003376(21)13123123(17)261129(10)MOIED01
  /// - EPC URI: urn:epc:id:sgtin:3664798.00337.13123123 (returned as-is)
  /// - Raw SSCC: 18 digit SSCC code
  /// 
  /// Returns null if conversion fails
  static String? convertToEPCUri(String barcode) {
    if (barcode.isEmpty) return null;

    // If already in EPC URI format (URN), return as-is
    if (barcode.startsWith('urn:epc:id:') || barcode.startsWith('urn:epc:idpat:')) {
      return barcode;
    }

    // GS1 Digital Link URL — parse identifiers directly from the URL path without
    // passing to GS1BarcodeParser, which misparses URL separators as AI values.
    if (barcode.startsWith('https://id.gs1.org/')) {
      return _convertGs1DlToEpcUri(barcode);
    }

    // IMPORTANT: Check for raw SSCC format FIRST (18 digits) before GS1 parsing
    // This prevents 18-digit SSCC codes from being misinterpreted as GTINs
    if (RegExp(r'^\d{18}$').hasMatch(barcode)) {
      debugPrint('EPCURIConverter: Detected raw 18-digit SSCC: $barcode');
      return convertSSCCToEPCUri(barcode);
    }

    // Try to parse as GS1 barcode
    final parsed = GS1BarcodeParser.parseGS1Barcode(barcode);
    
    if (parsed['valid'] == true) {
      // Check for SSCC (AI 00)
      if (parsed['SSCC'] != null) {
        return convertSSCCToEPCUri(parsed['SSCC']);
      }
      
      // Check for SGTIN (GTIN + Serial)
      if (parsed['GTIN'] != null && parsed['SERIAL'] != null) {
        return convertGTINSerialToEPCUri(parsed['GTIN'], parsed['SERIAL']);
      }
      
      // GTIN without serial - convert to class-level EPC
      if (parsed['GTIN'] != null) {
        return convertGTINToClassEPCUri(parsed['GTIN']);
      }
    }
    
    debugPrint('EPCURIConverter: Unable to convert barcode to EPC URI: $barcode');
    return null;
  }
  
  /// Converts a GTIN and Serial Number to SGTIN EPC URI
  /// 
  /// Format: urn:epc:id:sgtin:{companyPrefix}.{itemReference}.{serialNumber}
  /// 
  /// Example:
  /// - GTIN: 03664798003376, Serial: 13123123
  /// - Result: urn:epc:id:sgtin:3664798.00337.13123123
  static String? convertGTINSerialToEPCUri(String gtin, String serialNumber) {
    if (gtin.isEmpty || serialNumber.isEmpty) return null;

    try {
      final normalizedGtin = gtin.padLeft(14, '0');
      if (normalizedGtin.length != 14) return null;

      final gcpLength = _resolveGcpLength(normalizedGtin);
      // GTIN-14: [indicator][GCP][itemRef][check]; EPC URN: <GCP>.<indicator+itemRef>.<serial>
      final companyPrefix = normalizedGtin.substring(1, 1 + gcpLength);
      final indicatorAndItemRef =
          normalizedGtin[0] + normalizedGtin.substring(1 + gcpLength, 13);

      return 'urn:epc:id:sgtin:$companyPrefix.$indicatorAndItemRef.$serialNumber';
    } catch (e) {
      debugPrint('EPCURIConverter: Error converting GTIN/Serial to EPC URI: $e');
      return null;
    }
  }

  /// Resolves GS1 Company Prefix length for SGTIN encoding from GTIN-14.
  /// TraqTrace UAE pharma demo GTINs (GCP 629200) use 6 digits; default to 7 otherwise.
  static int _resolveGcpLength(String gtin14) {
    if (gtin14.length != 14) return 7;
    if (gtin14.substring(1, 7) == '062920') return 6;
    return 7;
  }
  
  /// Converts an SSCC to SSCC EPC URI
  /// 
  /// Format: urn:epc:id:sscc:{companyPrefix}.{serialReference}
  /// 
  /// Example:
  /// - SSCC: 003664798000000011
  /// - Result: urn:epc:id:sscc:3664798.0000000011
  static String? convertSSCCToEPCUri(String sscc) {
    if (sscc.isEmpty) return null;
    
    try {
      // Normalize SSCC to 18 digits
      String normalizedSscc = sscc.padLeft(18, '0');
      
      // SSCC structure:
      // Position 0: Extension digit
      // Position 1-7: GS1 Company Prefix (assuming 7 digits)
      // Position 8-16: Serial Reference (9 digits)
      // Position 17: Check digit
      
      String extensionDigit = normalizedSscc.substring(0, 1);
      String companyPrefix = normalizedSscc.substring(1, 8);
      String serialReference = normalizedSscc.substring(8, 17);
      
      // Combine extension digit with serial reference
      String fullSerialRef = extensionDigit + serialReference;
      
      return 'urn:epc:id:sscc:$companyPrefix.$fullSerialRef';
    } catch (e) {
      debugPrint('EPCURIConverter: Error converting SSCC to EPC URI: $e');
      return null;
    }
  }
  
  /// Converts a GLN to SGLN EPC URI
  /// 
  /// Format: urn:epc:id:sgln:{companyPrefix}.{locationReference}.{extension}
  static String? convertGLNToEPCUri(String gln, {String extension = '0'}) {
    if (gln.isEmpty) return null;
    
    try {
      // Normalize GLN to 13 digits
      String normalizedGln = gln.padLeft(13, '0');
      
      // GLN structure (assuming 7-digit company prefix):
      // Position 0-6: GS1 Company Prefix (7 digits)
      // Position 7-11: Location Reference (5 digits)
      // Position 12: Check digit
      
      String companyPrefix = normalizedGln.substring(0, 7);
      String locationReference = normalizedGln.substring(7, 12);
      
      return 'urn:epc:id:sgln:$companyPrefix.$locationReference.$extension';
    } catch (e) {
      debugPrint('EPCURIConverter: Error converting GLN to EPC URI: $e');
      return null;
    }
  }
  
  /// Converts a GTIN to Class-level EPC URI (for product classes, not individual items)
  /// 
  /// Format: urn:epc:idpat:sgtin:{companyPrefix}.{itemReference}.*
  static String? convertGTINToClassEPCUri(String gtin) {
    if (gtin.isEmpty) return null;

    try {
      final normalizedGtin = gtin.padLeft(14, '0');
      if (normalizedGtin.length != 14) return null;

      final gcpLength = _resolveGcpLength(normalizedGtin);
      final companyPrefix = normalizedGtin.substring(1, 1 + gcpLength);
      final indicatorAndItemRef =
          normalizedGtin[0] + normalizedGtin.substring(1 + gcpLength, 13);

      return 'urn:epc:idpat:sgtin:$companyPrefix.$indicatorAndItemRef.*';
    } catch (e) {
      debugPrint('EPCURIConverter: Error converting GTIN to Class EPC URI: $e');
      return null;
    }
  }
  
  /// Parse an EPC URI and extract its type
  /// 
  /// Returns: 'sgtin', 'sscc', 'sgln', or null if invalid
  static String? getEPCType(String epcUri) {
    if (epcUri.startsWith('urn:epc:id:sgtin:')) return 'sgtin';
    if (epcUri.startsWith('urn:epc:idpat:sgtin:')) return 'sgtin-class';
    if (epcUri.startsWith('urn:epc:id:sscc:')) return 'sscc';
    if (epcUri.startsWith('urn:epc:id:sgln:')) return 'sgln';
    return null;
  }
  
  /// Convert a list of barcodes to EPC URIs
  /// 
  /// Returns a map with:
  /// - 'successful': List of successfully converted EPC URIs
  /// - 'failed': List of barcodes that failed to convert
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
  
  /// Validates if a string is a valid EPC URI
  static bool isValidEPCUri(String uri) {
    if (uri.isEmpty) return false;
    
    // SGTIN pattern: urn:epc:id:sgtin:{companyPrefix}.{itemRef}.{serial}
    final sgtinPattern = RegExp(r'^urn:epc:id:sgtin:\d+\.\d+\.\w+$');
    
    // SGTIN class pattern: urn:epc:idpat:sgtin:{companyPrefix}.{itemRef}.*
    final sgtinClassPattern = RegExp(r'^urn:epc:idpat:sgtin:\d+\.\d+\.\*$');
    
    // SSCC pattern: urn:epc:id:sscc:{companyPrefix}.{serialRef}
    final ssccPattern = RegExp(r'^urn:epc:id:sscc:\d+\.\d+$');
    
    // SGLN pattern: urn:epc:id:sgln:{companyPrefix}.{locRef}.{extension}
    final sglnPattern = RegExp(r'^urn:epc:id:sgln:\d+\.\d+\.\w*$');
    
    return sgtinPattern.hasMatch(uri) ||
           sgtinClassPattern.hasMatch(uri) ||
           ssccPattern.hasMatch(uri) ||
           sglnPattern.hasMatch(uri);
  }
  
  /// Extract GTIN-14 from an SGTIN EPC URI.
  ///
  /// SGTIN URN structure: urn:epc:id:sgtin:<GCP>.<indicatorDigit+itemRef>.<serial>
  ///
  /// The second dot-segment already contains the indicator digit as its first
  /// character.  The GTIN-14 body (13 chars) is therefore:
  ///   indicatorDigit(1) + GCP(n) + itemRef(remaining)
  /// NOT '0' + GCP + fullSecondSegment (which would be 14 chars before the check).
  ///
  /// Check digit uses GS1 Mod-10: rightmost body digit × 3 (matching
  /// GtinFormat.calculateCheckDigitForBody).
  static String? extractGTINFromEPCUri(String epcUri) {
    if (!epcUri.startsWith('urn:epc:id:sgtin:')) return null;

    try {
      final parts = epcUri.substring('urn:epc:id:sgtin:'.length).split('.');
      if (parts.length >= 2) {
        final gcp = parts[0];
        final indicatorPlusRef = parts[1];
        if (indicatorPlusRef.isEmpty) return null;

        // GTIN-14 body: indicator(1) + GCP(n) + itemRef = 13 chars for 6-digit GCP
        final indicator = indicatorPlusRef[0];
        final itemRef = indicatorPlusRef.substring(1);
        final body = '$indicator$gcp$itemRef';

        // GS1 Mod-10: rightmost digit × 3, alternating left
        int sum = 0;
        bool x3 = true;
        for (int i = body.length - 1; i >= 0; i--) {
          final d = int.parse(body[i]);
          sum += x3 ? d * 3 : d;
          x3 = !x3;
        }
        final checkDigit = (10 - (sum % 10)) % 10;

        return '$body$checkDigit';
      }
    } catch (e) {
      debugPrint('EPCURIConverter: Error extracting GTIN from EPC URI: $e');
    }
    return null;
  }
  
  /// Parse a GS1 Digital Link URL and convert to the appropriate EPC URI.
  ///
  /// GS1BarcodeParser cannot handle DL URLs because its normalizer does not
  /// recognise the `https://id.gs1.org/` scheme and falls through to a
  /// digit-pattern matcher that slurps URL path separators into identifier
  /// values (e.g. GTIN starts with `/`), causing int.parse to throw.
  ///
  /// Supported DL forms:
  ///   SGTIN instance: https://id.gs1.org/01/<gtin14>/21/<serial>
  ///   SGTIN class:    https://id.gs1.org/01/<gtin14>
  ///   SSCC:           https://id.gs1.org/00/<sscc18>
  static String? _convertGs1DlToEpcUri(String dlUrl) {
    // SGTIN instance (GTIN + serial)
    final sgtinRe = RegExp(
      r'^https://id\.gs1\.org/01/(\d{14})/21/([A-Za-z0-9!"%()*+,\-./:;<=>?_`{|}~]+)$',
      caseSensitive: false,
    );
    final sgtinMatch = sgtinRe.firstMatch(dlUrl);
    if (sgtinMatch != null) {
      return convertGTINSerialToEPCUri(sgtinMatch.group(1)!, sgtinMatch.group(2)!);
    }

    // SGTIN class (GTIN only, no serial)
    final gtinClassRe = RegExp(
      r'^https://id\.gs1\.org/01/(\d{14})$',
      caseSensitive: false,
    );
    final gtinClassMatch = gtinClassRe.firstMatch(dlUrl);
    if (gtinClassMatch != null) {
      return convertGTINToClassEPCUri(gtinClassMatch.group(1)!);
    }

    // SSCC
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

  /// Extract Serial Number from an SGTIN EPC URI
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
