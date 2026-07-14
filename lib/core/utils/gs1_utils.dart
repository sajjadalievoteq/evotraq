import 'package:traqtrace_app/core/utils/gs1/check_digit_utils.dart';
import 'package:traqtrace_app/core/utils/gs1/gs1_converter.dart';

/// Legacy GS1 helpers for SSCC check-digit utilities.
///
/// For EPC URI generation use [Gs1Converter] / [EPCURIConverter] instead.
class GS1Utils {
  static const Map<String, int> _aiLengths = {
    '00': 18,
    '01': 14,
    '02': 14,
    '10': -1,
    '11': 6,
    '15': 6,
    '17': 6,
    '21': -1,
    '30': -1,
    '37': -1,
    '251': -1,
    '253': -1,
    '254': -1,
    '414': 13,
    '415': 13,
  };

  static String convertToSGTIN(String gtin, String serialNumber) {
    return Gs1Converter.gtinSerialToEpc(gtin, serialNumber) ??
        'https://id.gs1.org/01/${gtin.padLeft(14, '0')}/21/$serialNumber';
  }

  static String convertToGTINClassEPC(String gtin) {
    return Gs1Converter.gtinToClassEpc(gtin) ??
        'https://id.gs1.org/01/${gtin.padLeft(14, '0')}';
  }

  static String convertToSSCCEPC(String sscc) {
    final padded = sscc.padLeft(18, '0');
    return Gs1Converter.ssccToEpc(padded) ?? 'https://id.gs1.org/00/$padded';
  }

  static String convertToGLNEPC(String gln, [String? extension]) {
    return Gs1Converter.glnToEpc(gln, extension: extension ?? '0') ??
        'https://id.gs1.org/414/${gln.padLeft(13, '0')}';
  }

  static Map<String, String> parseGS1Data(String barcodeData) {
    final Map<String, String> result = {};
    
    if (barcodeData.contains('(') && barcodeData.contains(')')) {
      return _parseGS1ElementString(barcodeData);
    }
    
    int currentPosition = 0;
    
    while (currentPosition < barcodeData.length) {
      bool foundAI = false;
      
      for (final entry in _aiLengths.entries) {
        final ai = entry.key;
        
        if (currentPosition + ai.length <= barcodeData.length) {
          final potentialAI = barcodeData.substring(currentPosition, currentPosition + ai.length);
          
          if (potentialAI == ai) {
            currentPosition += ai.length;
            final int dataLength = entry.value;
            
            if (dataLength > 0) {
              if (currentPosition + dataLength <= barcodeData.length) {
                final String value = barcodeData.substring(currentPosition, currentPosition + dataLength);
                result[ai] = value;
                currentPosition += dataLength;
                foundAI = true;
              }
            } else {
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
      
      if (!foundAI) {
        currentPosition++;
      }
    }
    
    return result;
  }

  static Map<String, String> _parseGS1ElementString(String elementString) {
    final Map<String, String> result = {};
    
    final RegExp aiPattern = RegExp(r'\(([0-9]+)\)([^\(]+)');
    final matches = aiPattern.allMatches(elementString);
    
    for (final match in matches) {
      final String ai = match.group(1)!;
      String value = match.group(2)!;
      
      value = value.replaceAll(RegExp(r'[\x1D\u001d]'), '');
      
      result[ai] = value;
    }
    
    return result;
  }

  static String calculateCheckDigit(String digits) {
    return CheckDigitUtils.calculateMod10String(digits);
  }

  static bool validateCheckDigit(String identifier) {
    if (identifier.isEmpty) return false;
    return CheckDigitUtils.isValidMod10(identifier);
  }

  static String calculateGS1CheckDigit(String digits) => calculateCheckDigit(digits);

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

  static String? extractGLNCode(String glnInput) {
    if (glnInput.length == 13 && RegExp(r'^\d{13}$').hasMatch(glnInput)) {
      return glnInput;
    }
    return extractGLNFromFormat(glnInput);
  }

  static String generateSSCC(
    String companyPrefix,
    String extensionDigit, {
    String? serialReference,
  }) {
    if (companyPrefix.length < 6 || companyPrefix.length > 10) {
      throw FormatException('Company Prefix must be 6-10 digits', companyPrefix);
    }
    if (extensionDigit.length != 1 || !RegExp(r'^\d$').hasMatch(extensionDigit)) {
      throw FormatException('Extension Digit must be a single digit', extensionDigit);
    }

    final serialReferenceLength = 16 - companyPrefix.length;
    final actualSerialReference =
        serialReference ?? _generateRandomSerialReference(serialReferenceLength);
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
    final glnCode = extractGLNCode(glnInput);
    if (glnCode == null || glnCode.isEmpty) {
      throw FormatException('Could not extract a valid GLN from the input', glnInput);
    }
    final companyPrefix = extractCompanyPrefixFromGLN(glnCode);
    return generateSSCC(companyPrefix, extensionDigit);
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
      }
      return codeWithoutCheck + calculatedCheckDigit;
    }
    if (ssccCode.length == 17 && RegExp(r'^\d{17}$').hasMatch(ssccCode)) {
      final checkDigit = calculateGS1CheckDigit(ssccCode);
      return ssccCode + checkDigit;
    }
    return null;
  }
}