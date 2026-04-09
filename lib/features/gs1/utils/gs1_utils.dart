import 'package:traqtrace_app/features/gs1/models/gln_model.dart';

/// Utility functions for GS1 standards implementation
class GS1Utils {
  /// Extracts GS1 Company Prefix from a GLN code
  /// GLN is 13 digits, where the first 7-10 digits typically form the GS1 Company Prefix
  static String extractCompanyPrefixFromGLN(String glnCode) {
    if (glnCode.length != 13) {
      throw FormatException('GLN must be 13 digits', glnCode);
    }
    
    // Standard GS1 prefixes are 7-10 digits
    // For simplicity, we'll extract the first 7 digits as the company prefix
    // In a real implementation, this would need to check against the actual 
    // assigned company prefix length for the organization
    return glnCode.substring(0, 7);
  }
  
  /// Parses a GS1 barcode or URN format and extracts the GLN
  /// Examples: 
  /// - GS1 Barcode: (414)1234567890128
  /// - URN format: urn:epc:id:sgln:1234567.89012.0
  static String? extractGLNFromFormat(String input) {
    // Check for GS1 barcode format with AI (414) for GLN
    final barcodeRegex = RegExp(r'\(414\)(\d{13})');
    final barcodeMatch = barcodeRegex.firstMatch(input);
    
    if (barcodeMatch != null) {
      return barcodeMatch.group(1);
    }
    
    // Check for URN format for GLN
    final urnRegex = RegExp(r'urn:epc:id:sgln:(\d{7,10})\.(\d{1,5})\.(\d)');
    final urnMatch = urnRegex.firstMatch(input);
    
    if (urnMatch != null) {
      // Combine the parts and calculate check digit
      final companyPrefix = urnMatch.group(1);
      final locationReference = urnMatch.group(2)?.padLeft(5, '0');
      
      if (companyPrefix != null && locationReference != null) {
        final glnWithoutCheck = companyPrefix + locationReference;
        final checkDigit = calculateGS1CheckDigit(glnWithoutCheck);
        return glnWithoutCheck + checkDigit;
      }
    }
    
    return null;
  }
  
  /// Calculate the GS1 check digit
  /// This is used for GTIN, GLN, SSCC, etc.
  static String calculateGS1CheckDigit(String digits) {
    int sum = 0;
    
    // Apply the weighting factors (3 and 1)
    for (int i = 0; i < digits.length; i++) {
      final digit = int.parse(digits[digits.length - 1 - i]);
      sum += (i % 2 == 0) ? digit * 3 : digit;
    }
    
    // Calculate the check digit
    final checkDigit = (10 - (sum % 10)) % 10;
    return checkDigit.toString();
  }
  
  /// Generate an SSCC from Company Prefix and other components
  static String generateSSCC(String companyPrefix, String extensionDigit, {String? serialReference}) {
    if (companyPrefix.length < 6 || companyPrefix.length > 10) {
      throw FormatException('Company Prefix must be 6-10 digits', companyPrefix);
    }
    
    if (extensionDigit.length != 1 || !RegExp(r'^\d$').hasMatch(extensionDigit)) {
      throw FormatException('Extension Digit must be a single digit', extensionDigit);
    }
    
    // Calculate the serial reference length based on company prefix length
    // SSCC = Extension Digit (1) + Company Prefix (7-10) + Serial Reference (Variable) + Check Digit (1)
    // Total must be 18 digits
    final serialReferenceLength = 16 - companyPrefix.length;
    
    // Generate a random serial reference if not provided
    final actualSerialReference = serialReference ?? _generateRandomSerialReference(serialReferenceLength);
    
    // Combine them
    final ssccWithoutCheck = extensionDigit + companyPrefix + actualSerialReference;
    
    // Calculate check digit
    final checkDigit = calculateGS1CheckDigit(ssccWithoutCheck);
    
    return ssccWithoutCheck + checkDigit;
  }
  
  /// Generates a random serial reference of the specified length
  static String _generateRandomSerialReference(int length) {
    final chars = '0123456789';
    final random = StringBuffer();
    for (int i = 0; i < length; i++) {
      random.write(chars[DateTime.now().microsecond % chars.length]);
    }
    return random.toString();
  }
  
  /// Generates an SSCC code from a GLN input and extension digit
  /// The GLN can be in any supported format (plain 13-digit, GS1 barcode, or URN)
  static String generateSSCCFromGLN(String glnInput, String extensionDigit) {
    // First, try to extract the GLN from the input format
    String? glnCode = extractGLNCode(glnInput);
    
    if (glnCode == null || glnCode.isEmpty) {
      throw FormatException('Could not extract a valid GLN from the input', glnInput);
    }
    
    // Extract company prefix from the GLN
    final companyPrefix = extractCompanyPrefixFromGLN(glnCode);
    
    // Generate SSCC using the company prefix and extension digit
    return generateSSCC(companyPrefix, extensionDigit);
  }
  
  /// Extracts GLN code from various formats, including direct GLN code
  static String? extractGLNCode(String glnInput) {
    // Check if it's already a plain 13-digit GLN
    if (glnInput.length == 13 && RegExp(r'^\d{13}$').hasMatch(glnInput)) {
      return glnInput;
    }
    
    // Try to extract from barcode or URN format
    return extractGLNFromFormat(glnInput);
  }

  /// Validates an SSCC code and fixes it if possible by adding the check digit
  /// Returns the fixed SSCC code if it was fixed, or null if it couldn't be fixed
  static String? validateAndFixSSCC(String? ssccCode) {
    if (ssccCode == null) {
      return null;
    }

    // Check if the SSCC code is already a valid 18-digit code
    if (ssccCode.length == 18 && RegExp(r'^\d{18}$').hasMatch(ssccCode)) {
      // Validate the check digit as well for additional security
      final codeWithoutCheck = ssccCode.substring(0, 17);
      final providedCheckDigit = ssccCode[17];
      final calculatedCheckDigit = calculateGS1CheckDigit(codeWithoutCheck);
      
      if (providedCheckDigit == calculatedCheckDigit) {
        return ssccCode; // Already valid with correct check digit
      } else {
        // Fixed incorrect check digit
        print('Fixing incorrect check digit on SSCC: $ssccCode');
        return codeWithoutCheck + calculatedCheckDigit;
      }
    }
    
    // If it's 17 digits, we can add the check digit
    if (ssccCode.length == 17 && RegExp(r'^\d{17}$').hasMatch(ssccCode)) {
      print('SSCC is 17 digits, calculating check digit');
      try {
        final checkDigit = calculateGS1CheckDigit(ssccCode);
        final fixedSSCC = ssccCode + checkDigit;
        print('Fixed SSCC: $fixedSSCC (added check digit: $checkDigit)');
        return fixedSSCC;
      } catch (e) {
        print('Error calculating check digit: $e');
        return null;
      }
    }
    
    // If not 17 or 18 digits, or not all digits, we can't fix it
    return null;
  }
}
