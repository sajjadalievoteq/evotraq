import 'package:traqtrace_app/core/utils/gs1/check_digit_utils.dart';

abstract final class NdcGtinConverter {
  
  static const supportedFormats = {'4-4-2', '5-3-2', '5-4-1', '5-4-2'};

  static String digitsOnly(String? raw) => CheckDigitUtils.digitsOnly(raw);

  static String? toNdc11(String? ndc, {String format = '5-4-2'}) {
    final digits = digitsOnly(ndc);
    if (digits.length == 11) return digits;
    if (digits.length != 10) return null;

    switch (format) {
      case '4-4-2':
        
        return '0${digits.substring(0, 4)}${digits.substring(4)}';
      case '5-3-2':
        
        return '${digits.substring(0, 5)}0${digits.substring(5)}';
      case '5-4-1':
        
        return '${digits.substring(0, 9)}0${digits.substring(9)}';
      case '5-4-2':
        
        return null;
      default:
        return null;
    }
  }

  static String? ndcToGtin14(String? ndc, {String format = '5-4-2'}) {
    final ndc11 = toNdc11(ndc, format: format);
    if (ndc11 == null) return null;
    
    final body = '003${ndc11.substring(0, 10)}';
    if (body.length != 13) return null;
    final cd = CheckDigitUtils.calculateMod10String(body);
    return '$body$cd';
  }

  static String? gtin14ToNdc11(String? gtin) {
    final digits = CheckDigitUtils.digitsOnly(gtin);
    if (digits.length != 14) return null;
    if (!digits.startsWith('003')) return null;
    if (!CheckDigitUtils.isValidMod10(digits)) return null;
    
    final ndc10 = digits.substring(3, 13);
    
    return ndc10.length == 10 ? '0$ndc10' : ndc10;
  }

  static String? validateNdc(String? ndc, {String format = '5-4-2'}) {
    final digits = digitsOnly(ndc);
    if (digits.isEmpty) return 'NDC is required';
    if (digits.length == 11) return null;
    if (digits.length == 10 && supportedFormats.contains(format)) return null;
    return 'NDC must be 10 or 11 digits (format $format for 10-digit)';
  }
}