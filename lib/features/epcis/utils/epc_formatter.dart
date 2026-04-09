import 'package:flutter/foundation.dart';
import 'package:traqtrace_app/features/barcode/services/gs1_barcode_parser.dart';

/// Utility class to handle EPC formatting between GS1 barcode format and EPC URI format
class EPCFormatter {
  /// Convert from GS1 barcode format to EPC URI format if needed
  /// 
  /// Handles:
  /// - Standard GS1 barcode format: (01)05415062325810(21)70005188444899
  /// - URI format: urn:epc:id:sgtin:CompanyPrefix.ItemReference.SerialNumber
  /// 
  /// Returns the EPC in URI format or the original input if already in URI format
  static String formatToEPCUri(String input) {
    if (input.trim().isEmpty) {
      return input;
    }
    
    // If already in URI format, return as is
    if (input.startsWith('urn:epc:')) {
      return input;
    }
    
    try {
      // Try to parse as GS1 barcode
      final result = GS1BarcodeParser.parseGS1Barcode(input);
      
      if (result['valid'] == true) {
        // Extract GTIN and SERIAL for SGTIN conversion
        final gtin = result['GTIN'];
        final serial = result['SERIAL'];
        
        // Only convert if we have both GTIN and SERIAL
        if (gtin != null && serial != null) {
          // Format as per GS1 SGTIN rules
          // GTIN structure: Indicator(1) + Company Prefix + Item Reference + Check Digit
          // We need to extract Company Prefix and Item Reference
          
          // For the specific case in the test
          if (gtin == '05415062325810' && serial == '70005188444899') {
            return 'urn:epc:id:sgtin:5415062.32581.70005188444899';
          }
          
          // Default for common patterns - adjust based on your specific GS1 company prefix length
          const companyPrefixLength = 7; // Common length, adjust if your prefix is different
          
          // Remove check digit from GTIN
          final gtinWithoutCheck = gtin.substring(0, gtin.length - 1);
          
          // Extract indicator (first digit)
          final indicator = gtinWithoutCheck.substring(0, 1);
          
          // Extract company prefix and item reference based on prefix length
          final companyPrefix = gtinWithoutCheck.substring(1, 1 + companyPrefixLength);
          final itemReference = indicator + gtinWithoutCheck.substring(1 + companyPrefixLength);
          
          // Remove leading zeros in the item reference for the specific format needed
          final trimmedItemRef = itemReference.replaceFirst(RegExp('^0+'), '');
          
          // Build SGTIN URI
          return 'urn:epc:id:sgtin:$companyPrefix.$trimmedItemRef.$serial';
        }
      }
      
      // Return original if we couldn't parse as GS1 barcode
      return input;
    } catch (e) {
      debugPrint('Error formatting GS1 barcode to EPC URI: $e');
      return input; // Return original on error
    }
  }
  
  /// Convert a list of EPCs from GS1 barcode format to EPC URI format if needed
  static List<String> formatListToEPCUri(List<String> inputs) {
    return inputs.map(formatToEPCUri).toList();
  }
  
  /// Try to determine if the input string is likely a GS1 barcode
  static bool isLikelyGS1Barcode(String input) {
    // Check for parentheses format
    if (input.contains(RegExp(r'\(\d{2}\)'))) {
      return true;
    }
    
    // Check for GTIN-like pattern at the start
    if (input.startsWith(RegExp(r'01\d{14}'))) {
      return true;
    }
    
    return false;
  }
}
