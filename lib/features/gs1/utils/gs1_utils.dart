class GS1Utils {
  static String extractCompanyPrefixFromGLN(String glnCode) {
    if (glnCode.length != 13) {
      throw FormatException('GLN must be 13 digits', glnCode);
    }
    
    return glnCode.substring(0, 7);
  }
  
  static String? extractGLNFromFormat(String input) {
    final barcodeRegex = RegExp(r'\(414\)(\d{13})');
    final barcodeMatch = barcodeRegex.firstMatch(input);
    
    if (barcodeMatch != null) {
      return barcodeMatch.group(1);
    }
    
    final urnRegex = RegExp(r'urn:epc:id:sgln:(\d{7,10})\.(\d{1,5})\.(\d)');
    final urnMatch = urnRegex.firstMatch(input);
    
    if (urnMatch != null) {
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
  
  static String calculateGS1CheckDigit(String digits) {
    int sum = 0;
    
    for (int i = 0; i < digits.length; i++) {
      final digit = int.parse(digits[digits.length - 1 - i]);
      sum += (i % 2 == 0) ? digit * 3 : digit;
    }
    
    final checkDigit = (10 - (sum % 10)) % 10;
    return checkDigit.toString();
  }
  
  static String generateSSCC(String companyPrefix, String extensionDigit, {String? serialReference}) {
    if (companyPrefix.length < 6 || companyPrefix.length > 10) {
      throw FormatException('Company Prefix must be 6-10 digits', companyPrefix);
    }
    
    if (extensionDigit.length != 1 || !RegExp(r'^\d$').hasMatch(extensionDigit)) {
      throw FormatException('Extension Digit must be a single digit', extensionDigit);
    }
    
    final serialReferenceLength = 16 - companyPrefix.length;
    
    final actualSerialReference = serialReference ?? _generateRandomSerialReference(serialReferenceLength);
    
    final ssccWithoutCheck = extensionDigit + companyPrefix + actualSerialReference;
    
    final checkDigit = calculateGS1CheckDigit(ssccWithoutCheck);
    
    return ssccWithoutCheck + checkDigit;
  }
  
  static String _generateRandomSerialReference(int length) {
    final chars = '0123456789';
    final random = StringBuffer();
    for (int i = 0; i < length; i++) {
      random.write(chars[DateTime.now().microsecond % chars.length]);
    }
    return random.toString();
  }
  
  static String generateSSCCFromGLN(String glnInput, String extensionDigit) {
    String? glnCode = extractGLNCode(glnInput);
    
    if (glnCode == null || glnCode.isEmpty) {
      throw FormatException('Could not extract a valid GLN from the input', glnInput);
    }
    
    final companyPrefix = extractCompanyPrefixFromGLN(glnCode);
    
    return generateSSCC(companyPrefix, extensionDigit);
  }
  
  static String? extractGLNCode(String glnInput) {
    if (glnInput.length == 13 && RegExp(r'^\d{13}$').hasMatch(glnInput)) {
      return glnInput;
    }
    
    return extractGLNFromFormat(glnInput);
  }

  static String? validateAndFixSSCC(String? ssccCode) {
    if (ssccCode == null) {
      return null;
    }

    if (ssccCode.length == 18 && RegExp(r'^\d{18}$').hasMatch(ssccCode)) {
      final codeWithoutCheck = ssccCode.substring(0, 17);
      final providedCheckDigit = ssccCode[17];
      final calculatedCheckDigit = calculateGS1CheckDigit(codeWithoutCheck);
      
      if (providedCheckDigit == calculatedCheckDigit) {
        return ssccCode;
      } else {
        print('Fixing incorrect check digit on SSCC: $ssccCode');
        return codeWithoutCheck + calculatedCheckDigit;
      }
    }
    
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
    
    return null;
  }
}
