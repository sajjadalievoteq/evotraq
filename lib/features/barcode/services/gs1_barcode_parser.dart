
import 'package:flutter/foundation.dart';

/// Local parser for GS1 barcodes without requiring API calls
/// 
/// This parser handles various GS1 barcode formats including:
/// - Standard GS1 element strings with AI in parentheses: (01)12345678901234(17)220930(10)ABC123
/// - Raw concatenated strings: 0112345678901234172209301ABC123
/// - GS1-128 and GS1 DataMatrix formats
/// 
/// Returns both the raw barcode and parsed fields in a structured format
/// with direct access to common fields (GTIN, EXPIRY, BATCH, SERIAL, etc.)
class GS1BarcodeParser {
  // Common GS1 Application Identifiers and their descriptions
  static const Map<String, String> _applicationIdentifiers = {
    '00': 'SSCC',
    '01': 'GTIN',
    '02': 'CONTENT GTIN',
    '10': 'BATCH/LOT',
    '11': 'PROD DATE',
    '13': 'PACK DATE',
    '15': 'BEST BEFORE',
    '17': 'EXPIRY',
    '21': 'SERIAL',
    '30': 'COUNT',
    '310': 'NET WEIGHT (kg)',
    '400': 'ORDER NUMBER',
    '401': 'CONSIGNMENT',
    '402': 'SHIPMENT ID',
    '414': 'GLN',
    '415': 'PAYMENT GLN',
    '420': 'SHIP TO POST',
    '421': 'SHIP TO POST+CODE',
    '422': 'ORIGIN',
  };

  // AI lengths for fixed-length AIs (AI -> length including AI)
  static const Map<String, int> _fixedLengthAIs = {
    '00': 20, // SSCC (18 digits content + 2 digits AI)
    '01': 16, // GTIN (14 digits content + 2 digits AI)
    '02': 16, // Content GTIN (14 digits content + 2 digits AI)
    '11': 8,  // Production Date (6 digits content + 2 digits AI) YYMMDD
    '12': 8,  // Due Date (6 digits content + 2 digits AI)
    '13': 8,  // Packaging Date (6 digits content + 2 digits AI)
    '15': 8,  // Best Before Date (6 digits content + 2 digits AI)
    '16': 8,  // Sell By Date (6 digits content + 2 digits AI)
    '17': 8,  // Expiration Date (6 digits content + 2 digits AI)
  };
  /// Parse a raw GS1 barcode string into structured data
  /// 
  /// Returns a Map with the following keys:
  /// - 'valid': whether the barcode was successfully parsed
  /// - 'gs1ElementString': normalized GS1 element string
  /// - 'rawBarcode': the original input string
  /// - 'parsedData': Map of all parsed Application Identifiers (AIs) and their values
  /// - 'humanReadable': Human-readable descriptions of the parsed data
  /// - 'standardFields': Structured data for standard fields
  /// 
  /// Direct access fields (null if not present):
  /// - 'GTIN': Global Trade Item Number (AI 01)
  /// - 'EXPIRY': Expiry date in YYMMDD format (AI 17)
  /// - 'EXPIRY_FORMATTED': Expiry date in YYYY-MM-DD format (if available)
  /// - 'BATCH': Batch/Lot number (AI 10)
  /// - 'SERIAL': Serial number (AI 21)
  /// - 'PROD_DATE': Production date (AI 11)
  /// - 'SSCC': Serial Shipping Container Code (AI 00)
  /// - 'CONTENT_GTIN': Content GTIN (AI 02)
  /// - 'GLN': Global Location Number (AI 414)
  static Map<String, dynamic> parseGS1Barcode(String rawBarcode) {
    debugPrint('Parsing GS1 barcode: $rawBarcode');
    
    try {
      // Normalize the input - remove common prefixes or formatting
      final String normalizedBarcode = _normalizeBarcode(rawBarcode);
      
      // Parse GS1 data
      final parsedData = _parseGS1Data(normalizedBarcode);
      
      // Format into human readable data
      final humanReadable = _createHumanReadable(parsedData);
      
      // Extract standardized fields for direct access
      final Map<String, String> standardFields = {};
      
      // GTIN (01) - Global Trade Item Number
      if (parsedData.containsKey('01')) {
        standardFields['GTIN'] = parsedData['01']!;
      }
      
      // Expiry Date (17)
      if (parsedData.containsKey('17')) {
        String expiryValue = parsedData['17']!;
        standardFields['EXPIRY'] = expiryValue;
        
        // Also include formatted expiry if possible
        if (expiryValue.length == 6) {
          try {
            final year = '20${expiryValue.substring(0, 2)}';
            final month = expiryValue.substring(2, 4);
            final day = expiryValue.substring(4, 6);
            standardFields['EXPIRY_FORMATTED'] = '$year-$month-$day';
          } catch (e) {
            // Use raw value if formatting fails
          }
        }
      }
      
      // Batch/Lot Number (10)
      if (parsedData.containsKey('10')) {
        standardFields['BATCH'] = parsedData['10']!;
      }
      
      // Serial Number (21)
      if (parsedData.containsKey('21')) {
        standardFields['SERIAL'] = parsedData['21']!;
      }
      
      // Manufacturing Date (11)
      if (parsedData.containsKey('11')) {
        standardFields['PROD_DATE'] = parsedData['11']!;
      }
        // Return all data in a structured way
      return {
        'valid': parsedData.isNotEmpty,
        'gs1ElementString': normalizedBarcode,
        'rawBarcode': rawBarcode,  // Include original raw barcode
        'parsedData': parsedData,
        'humanReadable': humanReadable,
        'standardFields': standardFields,
        // Add direct access fields for convenience
        'GTIN': standardFields['GTIN'],
        'EXPIRY': standardFields['EXPIRY'],
        'EXPIRY_FORMATTED': standardFields['EXPIRY_FORMATTED'],
        'BATCH': standardFields['BATCH'],
        'SERIAL': standardFields['SERIAL'],
        'PROD_DATE': standardFields['PROD_DATE'],
        'SSCC': parsedData['00'],        // Serial Shipping Container Code
        'CONTENT_GTIN': parsedData['02'], // Content GTIN
        'GLN': parsedData['414'],        // Global Location Number
      };    } catch (e) {
      debugPrint('Error parsing GS1 barcode: $e');
      return {
        'valid': false,
        'gs1ElementString': rawBarcode,
        'rawBarcode': rawBarcode,
        'error': e.toString(),
        // Add null values for common fields to maintain consistent return structure
        'GTIN': null,
        'EXPIRY': null,
        'EXPIRY_FORMATTED': null,
        'BATCH': null,
        'SERIAL': null,
        'SSCC': null,
        'CONTENT_GTIN': null,
        'GLN': null,
      };
    }
  }
    /// Normalize the barcode input to standard GS1 format
  static String _normalizeBarcode(String barcode) {
    // If already in AI format with parentheses, return it
    if (barcode.contains(RegExp(r'\(\d{2,4}\)'))) {
      return barcode;
    }
    
    // If it uses FNC1 character (ASCII 29) as separator, replace with group separator
    String normalized = barcode.replaceAll(String.fromCharCode(29), '<GS>');
    
    // Handle specific patterns we recognize from the example:
    // Example: 01189024111140261721022810AFG8007A210SIATXTA39607034P
    
    // Pattern 1: Starts with 01 followed by 14 digits (GTIN)
    if (barcode.length >= 16 && barcode.startsWith("01") && RegExp(r'^\d{16}').hasMatch(barcode.substring(0, 16))) {
      int position = 16; // After 01 + 14 digits for GTIN
      String result = '(01)${barcode.substring(2, 16)}';
      
      // Check for expiry date pattern (17 + 6 digits)
      if (barcode.length >= position + 8 && barcode.substring(position, position+2) == "17") {
        result += '(17)${barcode.substring(position+2, position+8)}';
        position += 8;
      }
      
      // Check for batch number pattern (10 + variable)
      if (barcode.length >= position + 2 && barcode.substring(position, position+2) == "10") {
        // Find end of batch (usually ends where serial begins with '21')
        int batchEnd = barcode.indexOf("21", position + 2);
        if (batchEnd == -1) {
          // No serial number found, assume batch goes to the end
          result += '(10)${barcode.substring(position+2)}';
          return result;
        } else {
          result += '(10)${barcode.substring(position+2, batchEnd)}';
          position = batchEnd;
        }
      }
      
      // Check for serial number pattern (21 + remainder)
      if (barcode.length >= position + 2 && barcode.substring(position, position+2) == "21") {
        result += '(21)${barcode.substring(position+2)}';
      } else if (position < barcode.length) {
        // If there's remaining data but not prefixed with known AI, try to parse it
        result += _formatRemainder(barcode.substring(position));
      }
      
      return result;
    }
    
    // Pattern 2: Generic approach for non-specific formats, if digits only and of sufficient length
    if (barcode.length >= 14 && RegExp(r'^\d{14}').hasMatch(barcode)) {
      // Likely starts with a GTIN-14
      return '(01)${barcode.substring(0, 14)}${barcode.length > 14 ? _formatRemainder(barcode.substring(14)) : ''}';
    }
    
    // If we can't determine format, just return normalized value or original as fallback
    return normalized.contains('<GS>') ? normalized : barcode;
  }
    /// Format remaining barcode digits after extracting initial identifier
  static String _formatRemainder(String remainder) {
    // Try to identify standard patterns in the remainder
    String formattedRemainder = '';
    int position = 0;
    
    // Look for common patterns in the remaining digits
    
    // Check for expiry date (typically 6 digits YYMMDD)
    if (remainder.length >= position + 6 && 
        RegExp(r'^\d{6}').hasMatch(remainder.substring(position))) {
      formattedRemainder += '(17)${remainder.substring(position, position + 6)}';
      position += 6;
    }
    
    // Check for batch/lot (variable length, typically after GTIN/expiry)
    if (position < remainder.length) {
      // Find a reasonable cutoff - if we have digits followed by letters, it's likely a batch number
      RegExp batchPattern = RegExp(r'^([A-Za-z0-9]{1,20})');
      final batchMatch = batchPattern.firstMatch(remainder.substring(position));
      
      if (batchMatch != null) {
        final batchValue = batchMatch.group(1);
        formattedRemainder += '(10)$batchValue';
        position += batchValue!.length;
      }
    }
    
    // If there's still more data, assume it's a serial number
    if (position < remainder.length) {
      formattedRemainder += '(21)${remainder.substring(position)}';
    }
    
    return formattedRemainder;
  }
  
  /// Parse GS1 element string into structured data
  static Map<String, String> _parseGS1Data(String gs1ElementString) {
    Map<String, String> result = {};
    
    // Regular expression to find AI groups - either in parentheses or not
    RegExp aiPattern = RegExp(r'\((\d{2,4})\)|(\d{2,4})');
    int currentPosition = 0;
    
    while (currentPosition < gs1ElementString.length) {
      // Find the next AI
      Match? match = aiPattern.firstMatch(gs1ElementString.substring(currentPosition));
      
      if (match == null) break;
      
      // Get the AI value (either from group 1 or 2)
      String ai = match.group(1) ?? match.group(2)!;
      
      // Move position past the AI
      currentPosition += match.end;
      
      // Check if it's a fixed-length AI
      if (_fixedLengthAIs.containsKey(ai)) {
        int valueLength = _fixedLengthAIs[ai]! - ai.length;
        
        // Make sure we don't go past the string length
        if (currentPosition + valueLength <= gs1ElementString.length) {
          result[ai] = gs1ElementString.substring(currentPosition, currentPosition + valueLength);
          currentPosition += valueLength;
        } else {
          // Not enough characters for this fixed-length AI
          result[ai] = gs1ElementString.substring(currentPosition);
          currentPosition = gs1ElementString.length;
        }
      } else {
        // Variable length - find the next AI or end of string
        int nextAI = gs1ElementString.indexOf('(', currentPosition);
        if (nextAI == -1) {
          // No more AIs, take the rest of the string
          result[ai] = gs1ElementString.substring(currentPosition);
          currentPosition = gs1ElementString.length;
        } else {
          result[ai] = gs1ElementString.substring(currentPosition, nextAI);
          currentPosition = nextAI;
        }
      }
    }
    
    return result;
  }
    /// Create human-readable labels for the parsed data
  static Map<String, String> _createHumanReadable(Map<String, String> parsedData) {
    Map<String, String> humanReadable = {};
    
    parsedData.forEach((ai, value) {
      // Get description or use AI as fallback
      final description = _applicationIdentifiers[ai] ?? 'AI ($ai)';
      
      // Format certain AIs specially
      if (ai == '17') {
        // Format expiry date
        if (value.length == 6) {
          try {
            final year = '20${value.substring(0, 2)}';
            final month = value.substring(2, 4);
            final day = value.substring(4, 6);
            humanReadable[description] = '$year-$month-$day';
          } catch (e) {
            humanReadable[description] = value;
          }
        } else {
          humanReadable[description] = value;
        }
      } else if (ai == '10') {
        // Format batch/lot
        humanReadable['BATCH/LOT'] = value;
      } else if (ai == '21') {
        // Format serial
        humanReadable['SERIAL'] = value;
      } else if (ai == '01') {
        // Format GTIN
        humanReadable['GTIN'] = value;
      } else {
        humanReadable[description] = value;
      }
    });
    
    return humanReadable;
  }
}
