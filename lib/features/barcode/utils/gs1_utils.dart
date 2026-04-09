/// Utility class for GS1 standards handling
class GS1Utils {
  // Regular expressions for validating identifiers
  static final RegExp _gtinPattern = RegExp(r'^\d{8}$|^\d{12,14}$');
  static final RegExp _ssccPattern = RegExp(r'^\d{18}$');
  static final RegExp _glnPattern = RegExp(r'^\d{13}$');
  
  // EPC URI patterns
  static final RegExp _sgtinEpcPattern = RegExp(r'^urn:epc:id:sgtin:(\d+)\.(\d+)\.(.+)$');
  static final RegExp _ssccEpcPattern = RegExp(r'^urn:epc:id:sscc:(\d+)\.(\d+)$');
  static final RegExp _glnEpcPattern = RegExp(r'^urn:epc:id:sgln:(\d+)\.(\d+)\.(.*)$');
  
  /// Validate a GTIN (8, 12, 13, or 14 digits)
  bool isValidGTIN(String gtin) {
    if (!_gtinPattern.hasMatch(gtin)) {
      return false;
    }
    
    return _validateCheckDigit(gtin);
  }
  
  /// Validate an SSCC (18 digits)
  bool isValidSSCC(String sscc) {
    if (!_ssccPattern.hasMatch(sscc)) {
      return false;
    }
    
    return _validateCheckDigit(sscc);
  }
  
  /// Validate a GLN (13 digits)
  bool isValidGLN(String gln) {
    if (!_glnPattern.hasMatch(gln)) {
      return false;
    }
    
    return _validateCheckDigit(gln);
  }
  
  /// Convert a GTIN and serial number to an SGTIN EPC URI
  String convertGTINToEPC(String gtin, String serialNumber) {
    if (!isValidGTIN(gtin)) {
      throw ArgumentError('Invalid GTIN: $gtin');
    }
    
    // Pad GTIN to 14 digits if needed
    String paddedGTIN = gtin;
    if (paddedGTIN.length == 8) {
      paddedGTIN = '000000$paddedGTIN';
    } else if (paddedGTIN.length == 12) {
      paddedGTIN = '00$paddedGTIN';
    } else if (paddedGTIN.length == 13) {
      paddedGTIN = '0$paddedGTIN';
    }
    
    // Extract company prefix (assume first 7 digits - may vary in practice)
    String companyPrefix = paddedGTIN.substring(1, 8); // Skip first digit, take next 7
    
    // Extract item reference
    String itemReference = paddedGTIN.substring(8, 13); // Take 5 digits after company prefix
    
    return 'urn:epc:id:sgtin:$companyPrefix.$itemReference.$serialNumber';
  }
  
  /// Convert an EPC URI to a GTIN
  String convertEPCToGTIN(String epc) {
    final match = _sgtinEpcPattern.firstMatch(epc);
    if (match == null) {
      throw ArgumentError('Invalid SGTIN EPC URI: $epc');
    }
    
    String companyPrefix = match.group(1)!;
    String itemReference = match.group(2)!;
    
    // Reconstruct GTIN-14
    String gtin = '0$companyPrefix$itemReference';
    
    // Calculate check digit
    int checkDigit = _calculateCheckDigit(gtin.substring(0, 13));
    
    return gtin.substring(0, 13) + checkDigit.toString();
  }
  
  /// Convert GTIN to class-level EPC (for aggregation events)
  String convertGTINToClassEPC(String gtin) {
    if (!isValidGTIN(gtin)) {
      throw ArgumentError('Invalid GTIN: $gtin');
    }
    
    // Pad GTIN to 14 digits if needed
    String paddedGTIN = gtin;
    if (paddedGTIN.length == 8) {
      paddedGTIN = '000000$paddedGTIN';
    } else if (paddedGTIN.length == 12) {
      paddedGTIN = '00$paddedGTIN';
    } else if (paddedGTIN.length == 13) {
      paddedGTIN = '0$paddedGTIN';
    }
    
    // Extract company prefix (assume first 7 digits)
    String companyPrefix = paddedGTIN.substring(1, 8); // Skip first digit, take next 7
    
    // Extract item reference
    String itemReference = paddedGTIN.substring(8, 13); // Take 5 digits after company prefix
    
    return 'urn:epc:idpat:sgtin:$companyPrefix.$itemReference.*';
  }
  
  /// Convert an SSCC to an EPC URI
  String convertSSCCToEPC(String sscc) {
    if (!isValidSSCC(sscc)) {
      throw ArgumentError('Invalid SSCC: $sscc');
    }
    
    // Extract extension digit and company prefix (first 8 digits)
    String extensionDigit = sscc.substring(0, 1);
    String companyPrefix = sscc.substring(1, 8);
    
    // Extract serial reference (exclude check digit)
    String serialReference = sscc.substring(8, 17);
    
    return 'urn:epc:id:sscc:$companyPrefix.$extensionDigit$serialReference';
  }
  
  /// Convert an EPC URI to an SSCC
  String convertEPCToSSCC(String epc) {
    final match = _ssccEpcPattern.firstMatch(epc);
    if (match == null) {
      throw ArgumentError('Invalid SSCC EPC URI: $epc');
    }
    
    String companyPrefix = match.group(1)!;
    String serialWithExtension = match.group(2)!;
    String extensionDigit = serialWithExtension.substring(0, 1);
    String serial = serialWithExtension.substring(1);
    
    // Reconstruct SSCC
    String sscc = '$extensionDigit$companyPrefix$serial';
    
    // Calculate check digit
    int checkDigit = _calculateCheckDigit(sscc);
    
    return sscc + checkDigit.toString();
  }
  
  /// Convert a GLN and extension to an EPC URI
  String convertGLNToEPC(String gln, String extension) {
    if (!isValidGLN(gln)) {
      throw ArgumentError('Invalid GLN: $gln');
    }
    
    // Extract company prefix (first 7 digits)
    String companyPrefix = gln.substring(0, 7);
    
    // Extract location reference (exclude check digit)
    String locationReference = gln.substring(7, 12);
    
    return 'urn:epc:id:sgln:$companyPrefix.$locationReference.$extension';
  }
  
  /// Calculate GS1 check digit for a numeric identifier
  int _calculateCheckDigit(String digits) {
    int sum = 0;
    
    // Alternating weight algorithm (3-1-3-1...)
    for (int i = 0; i < digits.length; i++) {
      int digit = int.parse(digits[i]);
      if (i % 2 == 0) {
        sum += digit;
      } else {
        sum += digit * 3;
      }
    }
    
    // Calculate check digit: (10 - (sum % 10)) % 10
    int checkDigit = (10 - (sum % 10)) % 10;
    return checkDigit;
  }
  
  /// Validate a GS1 identifier's check digit
  bool _validateCheckDigit(String identifier) {
    String withoutCheckDigit = identifier.substring(0, identifier.length - 1);
    int expectedCheckDigit = int.parse(identifier[identifier.length - 1]);
    int calculatedCheckDigit = _calculateCheckDigit(withoutCheckDigit);
    
    return expectedCheckDigit == calculatedCheckDigit;
  }
  
  /// Extract AI (Application Identifier) data from GS1 element string
  Map<String, String> parseGS1ElementString(String elementString) {
    final Map<String, String> elementData = {};
    
    // Define AI specifications with their format length
    // Format: {AI: fixed length or -1 for variable length with max length}
    final Map<String, int> aiSpec = {
      '00': 18, // SSCC (fixed)
      '01': 14, // GTIN (fixed)
      '10': -1, // Batch/Lot (variable, up to 20)
      '11': 6,  // Production date (fixed)
      '15': 6,  // Best before date (fixed)
      '17': 6,  // Expiration date (fixed)
      '21': -1, // Serial number (variable, up to 20)
      '310': 6, // Net weight in kg (fixed)
      '400': -1, // Order number (variable)
      '414': 13, // GLN (fixed)
      '254': -1, // GLN extension (variable)
      // Add more AIs as needed
    };
    
    int position = 0;
    while (position < elementString.length) {
      // Check if we have an opening parenthesis
      if (elementString[position] == '(') {
        // Find closing parenthesis
        int closingParen = elementString.indexOf(')', position);
        if (closingParen == -1) {
          throw FormatException('Invalid GS1 element string format: missing closing parenthesis');
        }
        
        // Extract AI
        String ai = elementString.substring(position + 1, closingParen);
        position = closingParen + 1; // Move past closing parenthesis
        
        // Get AI value based on spec
        int? length = aiSpec[ai];
        if (length == null) {
          // Unknown AI, try to find next opening parenthesis
          int nextOpening = elementString.indexOf('(', position);
          if (nextOpening == -1) {
            // Take all remaining text
            elementData[ai] = elementString.substring(position);
            break;
          } else {
            elementData[ai] = elementString.substring(position, nextOpening);
            position = nextOpening;
          }
        } else if (length > 0) {
          // Fixed length
          if (position + length <= elementString.length) {
            elementData[ai] = elementString.substring(position, position + length);
            position += length;
          } else {
            // Not enough characters remaining
            elementData[ai] = elementString.substring(position);
            break;
          }
        } else {
          // Variable length (find next AI or end)
          int nextOpening = elementString.indexOf('(', position);
          if (nextOpening == -1) {
            // Take all remaining text
            elementData[ai] = elementString.substring(position);
            break;
          } else {
            elementData[ai] = elementString.substring(position, nextOpening);
            position = nextOpening;
          }
        }
      } else {
        // Invalid format, no opening parenthesis
        position++;
      }
    }
    
    return elementData;
  }
}