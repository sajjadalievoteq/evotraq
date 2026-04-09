// ignore_for_file: unused_import

import 'dart:math';

/// Utility class for working with GS1 identifiers and data
class GS1Utils {
  /// Map of GS1 application identifiers to their lengths
  /// Value of -1 means variable length (terminated by separator or end of data)
  static const Map<String, int> _aiLengths = {
    '00': 18, // SSCC
    '01': 14, // GTIN
    '02': 14, // CONTENT GTIN
    '10': -1, // BATCH/LOT (variable length)
    '11': 6, // PROD DATE (YYMMDD)
    '15': 6, // BEST BEFORE (YYMMDD)
    '17': 6, // EXPIRY (YYMMDD)
    '21': -1, // SERIAL (variable length)
    '30': -1, // COUNT (variable length)
    '37': -1, // COUNT (variable length)
    '251': -1, // REFERENCE (variable length)
    '253': -1, // GDTI (variable length)
    '254': -1, // GLN EXTENSION (variable length)
    '414': 13, // LOCATION (GLN)
    '415': 13, // PAYMENT GLN
  };

  /// Convert a GTIN and Serial Number to an SGTIN URI
  static String convertToSGTIN(String gtin, String serialNumber) {
    // Pad GTIN if needed
    if (gtin.length < 14) {
      gtin = gtin.padLeft(14, '0');
    }

    // Split GTIN into components for SGTIN URI
    final String companyPrefix = gtin.substring(1, 8); // Example company prefix length (usually configurable)
    final String itemRef = gtin.substring(8, 13);
    
    return 'urn:epc:id:sgtin:$companyPrefix.$itemRef.$serialNumber';
  }

  /// Convert a GTIN to a class-level EPC URI
  static String convertToGTINClassEPC(String gtin) {
    // Pad GTIN if needed
    if (gtin.length < 14) {
      gtin = gtin.padLeft(14, '0');
    }

    // Split GTIN into components for class URI
    final String companyPrefix = gtin.substring(1, 8); // Example company prefix length
    final String itemRef = gtin.substring(8, 13);
    
    return 'urn:epc:idpat:sgtin:$companyPrefix.$itemRef.*';
  }

  /// Convert SSCC to an SSCC EPC URI
  static String convertToSSCCEPC(String sscc) {
    // Ensure SSCC is 18 digits
    if (sscc.length < 18) {
      sscc = sscc.padLeft(18, '0');
    }

    // Extension digit is the first digit
    final String extensionDigit = sscc[0];
    // Company prefix (example length, would be configurable in a real implementation)
    final String companyPrefix = sscc.substring(1, 8);
    // Serial reference is the remaining digits before the check digit
    final String serialRef = sscc.substring(8, 17);
    
    return 'urn:epc:id:sscc:$companyPrefix.$extensionDigit$serialRef';
  }

  /// Convert GLN to a GLN EPC URI
  static String convertToGLNEPC(String gln, [String? extension]) {
    // Ensure GLN is 13 digits
    if (gln.length < 13) {
      gln = gln.padLeft(13, '0');
    }

    // Company prefix (example length, would be configurable)
    final String companyPrefix = gln.substring(0, 7);
    // Location reference 
    final String locationRef = gln.substring(7, 12);
    
    return 'urn:epc:id:sgln:$companyPrefix.$locationRef.${extension ?? ""}';
  }

  /// Parse GS1 formatted data into a map of application identifiers to values
  static Map<String, String> parseGS1Data(String barcodeData) {
    final Map<String, String> result = {};
    
    // Check if this is an element string format with parentheses 
    if (barcodeData.contains('(') && barcodeData.contains(')')) {
      return _parseGS1ElementString(barcodeData);
    }
    
    // For raw data without parentheses (often from scanner output)
    // We need to identify AIs by their prefix and expected length
    int currentPosition = 0;
    
    while (currentPosition < barcodeData.length) {
      bool foundAI = false;
      
      // Try to identify AIs
      for (final entry in _aiLengths.entries) {
        final ai = entry.key;
        
        // Check if there are enough characters left to check for this AI
        if (currentPosition + ai.length <= barcodeData.length) {
          final potentialAI = barcodeData.substring(currentPosition, currentPosition + ai.length);
          
          if (potentialAI == ai) {
            // Found an AI, extract its value
            currentPosition += ai.length;
            final int dataLength = entry.value;
            
            if (dataLength > 0) {
              // Fixed length AI
              if (currentPosition + dataLength <= barcodeData.length) {
                final String value = barcodeData.substring(currentPosition, currentPosition + dataLength);
                result[ai] = value;
                currentPosition += dataLength;
                foundAI = true;
              }
            } else {
              // Variable length AI
              // Look for the next AI or end of string
              int endPos = barcodeData.length;
              for (final nextAI in _aiLengths.keys) {
                final nextAIPos = barcodeData.indexOf(nextAI, currentPosition);
                if (nextAIPos != -1 && nextAIPos < endPos) {
                  endPos = nextAIPos;
                }
              }
              
              final String value = barcodeData.substring(currentPosition, endPos);
              result[ai] = value;
              currentPosition = endPos;
              foundAI = true;
            }
            
            break;
          }
        }
      }
      
      // If no AI was found at the current position, move to the next character
      if (!foundAI) {
        currentPosition++;
      }
    }
    
    return result;
  }

  /// Parse GS1 element string with parentheses notation
  static Map<String, String> _parseGS1ElementString(String elementString) {
    final Map<String, String> result = {};
    
    // Regular expression to match AIs in parentheses followed by their values
    final RegExp aiPattern = RegExp(r'\(([0-9]+)\)([^\(]+)');
    final matches = aiPattern.allMatches(elementString);
    
    for (final match in matches) {
      final String ai = match.group(1)!;
      String value = match.group(2)!;
      
      // Remove any GS1 separator characters
      value = value.replaceAll(RegExp(r'[\x1D\u001d]'), '');
      
      result[ai] = value;
    }
    
    return result;
  }

  /// Calculate GS1 check digit for a given identifier
  static String calculateCheckDigit(String digits) {
    int sum = 0;
    int factor;
    
    // Starting from the rightmost digit (excluding check digit)
    for (int i = digits.length - 1; i >= 0; i--) {
      final int digit = int.parse(digits[i]);
      
      // Alternate between weight 3 and weight 1
      factor = ((digits.length - i) % 2 == 0) ? 3 : 1;
      sum += digit * factor;
    }
    
    // Calculate check digit
    final int checkDigit = (10 - (sum % 10)) % 10;
    return checkDigit.toString();
  }

  /// Validate a GS1 check digit
  static bool validateCheckDigit(String identifier) {
    if (identifier.isEmpty) return false;
    
    // Extract the main digits and the check digit
    final String mainDigits = identifier.substring(0, identifier.length - 1);
    final String providedCheckDigit = identifier[identifier.length - 1];
    
    // Calculate the expected check digit
    final String calculatedCheckDigit = calculateCheckDigit(mainDigits);
    
    return providedCheckDigit == calculatedCheckDigit;
  }
}