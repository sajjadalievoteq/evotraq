import 'package:flutter/foundation.dart';
import 'package:traqtrace_app/core/utils/gs1/check_digit_utils.dart';
import 'package:traqtrace_app/core/utils/gs1/gs1_ai_table.dart';
import 'package:traqtrace_app/core/utils/gs1/gs1_date_utils.dart';

class GS1BarcodeParser {
  static Map<String, String>? parseAIString(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty || !trimmed.contains('(')) {
      return null;
    }

    final serialMatch = RegExp(r'\(21\)([^()]*)').firstMatch(trimmed);
    if (serialMatch == null) {
      return null;
    }
    final serial = serialMatch.group(1)?.trim() ?? '';
    if (serial.isEmpty) {
      return null;
    }

    final gtin01Match = RegExp(r'\(01\)([^()]*)').firstMatch(trimmed);
    final gtin00Match = RegExp(r'\(00\)([^()]*)').firstMatch(trimmed);

    String? gtinRaw;
    if (gtin01Match != null) {
      gtinRaw = gtin01Match.group(1)?.trim();
    } else if (gtin00Match != null) {
      gtinRaw = gtin00Match.group(1)?.trim();
    }

    if (gtinRaw == null || gtinRaw.isEmpty) {
      return null;
    }

    final gtinDigits = gtinRaw.replaceAll(RegExp(r'\D'), '');
    if (gtinDigits.isEmpty) {
      return null;
    }

    return {
      'GTIN': gtinDigits.padLeft(14, '0'),
      'SERIAL': serial,
    };
  }

  static Map<String, dynamic> parseGS1Barcode(String rawBarcode) {
    debugPrint('Parsing GS1 barcode: $rawBarcode');
    Gs1AiTable.ensureSynced();

    try {
      final String normalizedBarcode = _normalizeBarcode(rawBarcode);

      final parsedData = _parseGS1Data(normalizedBarcode);

      final humanReadable = _createHumanReadable(parsedData);

      final Map<String, String> standardFields = {};

      if (parsedData.containsKey('01')) {
        standardFields['GTIN'] = parsedData['01']!;
      }

      if (parsedData.containsKey('17')) {
        final expiryValue = parsedData['17']!;
        standardFields['EXPIRY'] = expiryValue;
        final iso = Gs1DateUtils.toIsoDate(expiryValue);
        if (iso != null) {
          standardFields['EXPIRY_FORMATTED'] = iso;
        }
      }

      if (parsedData.containsKey('10')) {
        standardFields['BATCH'] = parsedData['10']!;
      }

      if (parsedData.containsKey('21')) {
        standardFields['SERIAL'] = parsedData['21']!;
      }

      if (parsedData.containsKey('11')) {
        standardFields['PROD_DATE'] = parsedData['11']!;
      }
      final gtin = standardFields['GTIN'];
      final sscc = parsedData['00'];
      final gln = parsedData['414'];
      final checkDigitErrors = <String>[];
      if (gtin != null &&
          CheckDigitUtils.validateGS1CheckDigit(
                gtin,
                allowedLengths: CheckDigitUtils.gtinLengths,
                label: 'GTIN',
              ) !=
              null) {
        checkDigitErrors.add('GTIN check digit invalid');
      }
      if (sscc != null &&
          CheckDigitUtils.validateGS1CheckDigit(
                sscc,
                allowedLengths: CheckDigitUtils.ssccLengths,
                label: 'SSCC',
              ) !=
              null) {
        checkDigitErrors.add('SSCC check digit invalid');
      }
      if (gln != null &&
          CheckDigitUtils.validateGS1CheckDigit(
                gln,
                allowedLengths: CheckDigitUtils.glnLengths,
                label: 'GLN',
              ) !=
              null) {
        checkDigitErrors.add('GLN check digit invalid');
      }

      return {
        'valid': parsedData.isNotEmpty && checkDigitErrors.isEmpty,
        'checkDigitErrors': checkDigitErrors,
        'gs1ElementString': normalizedBarcode,
        'rawBarcode': rawBarcode,
        'parsedData': parsedData,
        'humanReadable': humanReadable,
        'standardFields': standardFields,
        'GTIN': gtin,
        'EXPIRY': standardFields['EXPIRY'],
        'EXPIRY_FORMATTED': standardFields['EXPIRY_FORMATTED'],
        'BATCH': standardFields['BATCH'],
        'SERIAL': standardFields['SERIAL'],
        'PROD_DATE': standardFields['PROD_DATE'],
        'SSCC': sscc,
        'CONTENT_GTIN': parsedData['02'],
        'GLN': gln,
      };
    } catch (e) {
      debugPrint('Error parsing GS1 barcode: $e');
      return {
        'valid': false,
        'gs1ElementString': rawBarcode,
        'rawBarcode': rawBarcode,
        'error': e.toString(),
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

  static String _normalizeBarcode(String barcode) {
    if (barcode.contains(RegExp(r'\(\d{2,4}\)'))) {
      return barcode;
    }

    
    String normalized = barcode
        .replaceAll(String.fromCharCode(29), '<GS>')
        .replaceAll('|', '<GS>');

    while (normalized.startsWith('<GS>')) {
      normalized = normalized.substring(4);
    }

    if (normalized.length >= 16 && normalized.startsWith("01") && RegExp(r'^\d{16}').hasMatch(normalized.substring(0, 16))) {
      int position = 16;
      String result = '(01)${normalized.substring(2, 16)}';
      
      if (normalized.length >= position + 8 && normalized.substring(position, position+2) == "17") {
        result += '(17)${normalized.substring(position+2, position+8)}';
        position += 8;
      }
      
      if (normalized.length >= position + 2 && normalized.substring(position, position+2) == "10") {
        int batchEnd = normalized.indexOf("21", position + 2);
        int gsIndex = normalized.indexOf("<GS>", position + 2);
        
        if (gsIndex != -1 && (batchEnd == -1 || gsIndex < batchEnd)) {
          batchEnd = gsIndex;
        }

        if (batchEnd == -1) {
          result += '(10)${normalized.substring(position+2)}';
          return result;
        } else {
          result += '(10)${normalized.substring(position+2, batchEnd)}';
          position = batchEnd;
        }
      }
      
      if (position < normalized.length && normalized.substring(position).startsWith('<GS>')) {
        position += 4;
      }
      
      if (normalized.length >= position + 2 && normalized.substring(position, position+2) == "21") {
        result += '(21)${normalized.substring(position+2)}';
      } else if (position < normalized.length) {
        result += _formatRemainder(normalized.substring(position));
      }
      
      return result;
    }
    
    if (normalized.length >= 14 && RegExp(r'^\d{14}').hasMatch(normalized)) {
      return '(01)${normalized.substring(0, 14)}${normalized.length > 14 ? _formatRemainder(normalized.substring(14)) : ''}';
    }
    
    return normalized.contains('<GS>') ? normalized : barcode;
  }
  static String _formatRemainder(String remainder) {
    String formattedRemainder = '';
    int position = 0;
    
    
    if (remainder.length >= position + 6 && 
        RegExp(r'^\d{6}').hasMatch(remainder.substring(position))) {
      formattedRemainder += '(17)${remainder.substring(position, position + 6)}';
      position += 6;
    }
    
    if (position < remainder.length) {
      RegExp batchPattern = RegExp(r'^([A-Za-z0-9]{1,20})');
      final batchMatch = batchPattern.firstMatch(remainder.substring(position));
      
      if (batchMatch != null) {
        final batchValue = batchMatch.group(1);
        formattedRemainder += '(10)$batchValue';
        position += batchValue!.length;
      }
    }
    
    if (position < remainder.length) {
      formattedRemainder += '(21)${remainder.substring(position)}';
    }
    
    return formattedRemainder;
  }
  
  static Map<String, String> _parseGS1Data(String gs1ElementString) {
    Map<String, String> result = {};

    RegExp aiPattern = RegExp(r'\((\d{2,4})\)|(\d{2,4})');
    int currentPosition = 0;
    
    while (currentPosition < gs1ElementString.length) {
      Match? match = aiPattern.firstMatch(gs1ElementString.substring(currentPosition));
      
      if (match == null) break;
      
      String ai = match.group(1) ?? match.group(2)!;
      
      currentPosition += match.end;
      
      if (Gs1AiTable.isFixedLength(ai)) {
        final total = Gs1AiTable.fixedAiPlusValueLength(ai)!;
        final valueLength = total - ai.length;

        if (currentPosition + valueLength <= gs1ElementString.length) {
          result[ai] = gs1ElementString.substring(
            currentPosition,
            currentPosition + valueLength,
          );
          currentPosition += valueLength;
        } else {
          result[ai] = gs1ElementString.substring(currentPosition);
          currentPosition = gs1ElementString.length;
        }
      } else {
        int nextAI = gs1ElementString.indexOf('(', currentPosition);
        int nextGS = gs1ElementString.indexOf('<GS>', currentPosition);
        
        int nextPipe = gs1ElementString.indexOf('|', currentPosition);

        int endOfValue = gs1ElementString.length;
        for (final idx in [nextAI, nextGS, nextPipe]) {
          if (idx != -1 && idx < endOfValue) endOfValue = idx;
        }

        result[ai] = gs1ElementString.substring(currentPosition, endOfValue);
        currentPosition = endOfValue;

        if (currentPosition < gs1ElementString.length &&
            gs1ElementString.substring(currentPosition).startsWith('<GS>')) {
          currentPosition += 4;
        } else if (currentPosition < gs1ElementString.length &&
            gs1ElementString[currentPosition] == '|') {
          currentPosition += 1;
        }
      }
    }
    
    return result;
  }
  static Map<String, String> _createHumanReadable(Map<String, String> parsedData) {
    final humanReadable = <String, String>{};

    parsedData.forEach((ai, value) {
      final description = Gs1AiTable.titleFor(ai);

      if (ai == '17') {
        humanReadable[description] = Gs1DateUtils.toIsoDate(value) ?? value;
      } else if (ai == '10') {
        humanReadable['BATCH/LOT'] = value;
      } else if (ai == '21') {
        humanReadable['SERIAL'] = value;
      } else if (ai == '01') {
        humanReadable['GTIN'] = value;
      } else {
        humanReadable[description] = value;
      }
    });

    return humanReadable;
  }
}
