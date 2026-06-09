
import 'dart:math';

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
    if (gtin.length < 14) {
      gtin = gtin.padLeft(14, '0');
    }

    final String companyPrefix = gtin.substring(1, 8);
    final String itemRef = gtin.substring(8, 13);
    
    return 'urn:epc:id:sgtin:$companyPrefix.$itemRef.$serialNumber';
  }

  static String convertToGTINClassEPC(String gtin) {
    if (gtin.length < 14) {
      gtin = gtin.padLeft(14, '0');
    }

    final String companyPrefix = gtin.substring(1, 8);
    final String itemRef = gtin.substring(8, 13);
    
    return 'urn:epc:idpat:sgtin:$companyPrefix.$itemRef.*';
  }

  static String convertToSSCCEPC(String sscc) {
    if (sscc.length < 18) {
      sscc = sscc.padLeft(18, '0');
    }

    final String extensionDigit = sscc[0];
    final String companyPrefix = sscc.substring(1, 8);
    final String serialRef = sscc.substring(8, 17);
    
    return 'urn:epc:id:sscc:$companyPrefix.$extensionDigit$serialRef';
  }

  static String convertToGLNEPC(String gln, [String? extension]) {
    if (gln.length < 13) {
      gln = gln.padLeft(13, '0');
    }

    final String companyPrefix = gln.substring(0, 7);
    final String locationRef = gln.substring(7, 12);
    
    return 'urn:epc:id:sgln:$companyPrefix.$locationRef.${extension ?? ""}';
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
    int sum = 0;
    int factor;
    
    for (int i = digits.length - 1; i >= 0; i--) {
      final int digit = int.parse(digits[i]);
      
      factor = ((digits.length - i) % 2 == 0) ? 3 : 1;
      sum += digit * factor;
    }
    
    final int checkDigit = (10 - (sum % 10)) % 10;
    return checkDigit.toString();
  }

  static bool validateCheckDigit(String identifier) {
    if (identifier.isEmpty) return false;
    
    final String mainDigits = identifier.substring(0, identifier.length - 1);
    final String providedCheckDigit = identifier[identifier.length - 1];
    
    final String calculatedCheckDigit = calculateCheckDigit(mainDigits);
    
    return providedCheckDigit == calculatedCheckDigit;
  }
}