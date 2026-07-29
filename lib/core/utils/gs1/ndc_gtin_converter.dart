import 'package:traqtrace_app/core/utils/gs1/check_digit_utils.dart';

/// US NDC ↔ GTIN‑14 conversion (deterministic, local).
///
/// Supports common 10‑digit NDC configurations (4‑4‑2 / 5‑3‑2 / 5‑4‑1),
/// normalizes to 11‑digit NDC, then GTIN‑14 = `0` + `03` + NDC‑11 body with
/// GS1 mod‑10 check digit (via [CheckDigitUtils]).
abstract final class NdcGtinConverter {
  /// 10-digit packing schemes. Prefer 11-digit NDC (including 5-4-2) when known.
  static const supportedFormats = {'4-4-2', '5-3-2', '5-4-1', '5-4-2'};

  /// Digits only from an NDC string (strips dashes/spaces).
  static String digitsOnly(String? raw) => CheckDigitUtils.digitsOnly(raw);

  /// Normalize a 10‑digit NDC (+ format) or 11‑digit NDC to 11 digits.
  static String? toNdc11(String? ndc, {String format = '5-4-2'}) {
    final digits = digitsOnly(ndc);
    if (digits.length == 11) return digits;
    if (digits.length != 10) return null;

    switch (format) {
      case '4-4-2':
        // labeler(4) product(4) package(2) → pad labeler to 5
        return '0${digits.substring(0, 4)}${digits.substring(4)}';
      case '5-3-2':
        // labeler(5) product(3) package(2) → pad product to 4
        return '${digits.substring(0, 5)}0${digits.substring(5)}';
      case '5-4-1':
        // labeler(5) product(4) package(1) → pad package to 2
        return '${digits.substring(0, 9)}0${digits.substring(9)}';
      case '5-4-2':
        // Already the 11-digit shape; 10-digit input is ambiguous.
        return null;
      default:
        return null;
    }
  }

  /// Convert NDC → GTIN‑14 (US GS1 prefix `03`).
  static String? ndcToGtin14(String? ndc, {String format = '5-4-2'}) {
    final ndc11 = toNdc11(ndc, format: format);
    if (ndc11 == null) return null;
    // Body without check digit: 0 + 03 + first 10 of NDC-11 = 13 digits
    final body = '003${ndc11.substring(0, 10)}';
    if (body.length != 13) return null;
    final cd = CheckDigitUtils.calculateMod10String(body);
    return '$body$cd';
  }

  /// Convert a US GTIN‑14 (prefix 003…) back to NDC‑11.
  static String? gtin14ToNdc11(String? gtin) {
    final digits = CheckDigitUtils.digitsOnly(gtin);
    if (digits.length != 14) return null;
    if (!digits.startsWith('003')) return null;
    if (!CheckDigitUtils.isValidMod10(digits)) return null;
    // positions 3..12 (10 digits of NDC-10) → reconstruct 11-digit by
    // taking chars after '003' excluding check digit: indices 3..12 inclusive = 10 chars
    // NDC-11 is often the 10-digit core with an implied leading zero already in GTIN.
    // Standard reverse: NDC-11 = digit[3..13) wait — body is 003 + 10 ndc digits.
    final ndc10 = digits.substring(3, 13);
    // Prefer 11-digit form with leading 0 on labeler when 10 digits.
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
