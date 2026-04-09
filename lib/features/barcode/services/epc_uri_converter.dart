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
    
    // If already in EPC URI format, return as-is
    if (barcode.startsWith('urn:epc:id:')) {
      return barcode;
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
      // Normalize GTIN to 14 digits
      String normalizedGtin = gtin.padLeft(14, '0');
      
      // Remove leading zero (indicator digit) for EPC conversion
      // GTIN-14: [indicator][company prefix (variable)][item reference][check digit]
      // We'll use a simplified approach with 7-digit company prefix
      
      // Extract components (assuming 7-digit company prefix which is common)
      // Position 0: Indicator digit (removed for EPC)
      // Position 1-7: Company prefix (7 digits)
      // Position 8-12: Item reference (5 digits)
      // Position 13: Check digit (not included in EPC)
      
      String companyPrefix = normalizedGtin.substring(1, 8);
      String itemReference = normalizedGtin.substring(8, 13);
      
      // Clean serial number (remove any special characters)
      String cleanSerial = serialNumber.replaceAll(RegExp(r'[^A-Za-z0-9]'), '');
      
      return 'urn:epc:id:sgtin:$companyPrefix.$itemReference.$cleanSerial';
    } catch (e) {
      debugPrint('EPCURIConverter: Error converting GTIN/Serial to EPC URI: $e');
      return null;
    }
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
      // Normalize GTIN to 14 digits
      String normalizedGtin = gtin.padLeft(14, '0');
      
      String companyPrefix = normalizedGtin.substring(1, 8);
      String itemReference = normalizedGtin.substring(8, 13);
      
      return 'urn:epc:idpat:sgtin:$companyPrefix.$itemReference.*';
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
  
  /// Extract GTIN from an SGTIN EPC URI
  static String? extractGTINFromEPCUri(String epcUri) {
    if (!epcUri.startsWith('urn:epc:id:sgtin:')) return null;
    
    try {
      final parts = epcUri.substring('urn:epc:id:sgtin:'.length).split('.');
      if (parts.length >= 2) {
        String companyPrefix = parts[0];
        String itemReference = parts[1];
        
        // Reconstruct GTIN (without check digit - would need to calculate)
        String gtinWithoutCheck = '0$companyPrefix$itemReference';
        
        // Calculate check digit
        int sum = 0;
        for (int i = 0; i < gtinWithoutCheck.length; i++) {
          int digit = int.parse(gtinWithoutCheck[i]);
          sum += (i % 2 == 0) ? digit : digit * 3;
        }
        int checkDigit = (10 - (sum % 10)) % 10;
        
        return '$gtinWithoutCheck$checkDigit';
      }
    } catch (e) {
      debugPrint('EPCURIConverter: Error extracting GTIN from EPC URI: $e');
    }
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
