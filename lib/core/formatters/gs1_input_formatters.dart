import 'package:flutter/services.dart';

abstract final class Gs1InputFormatters {
  static List<TextInputFormatter> gtin({int maxLength = 14}) => [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(maxLength),
      ];

  static List<TextInputFormatter> gln({int maxLength = 13}) => [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(maxLength),
      ];

  /// Digits-only formatter limited to 18 chars.
  /// Use [ssccOrUri] when the field must also accept URN / Digital Link form.
  static List<TextInputFormatter> sscc({int maxLength = 18}) => [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(maxLength),
      ];

  /// Smart SSCC formatter that accepts all SSCC input forms:
  /// - Raw 18-digit SSCC codes (digits-only, max 18 chars)
  /// - GS1 AI element string starting with `(`  e.g. `(00)262920000003000196`
  /// - EPC URN `urn:epc:id:sscc:…`
  /// - GS1 Digital Link `https://id.gs1.org/00/…`
  ///
  /// Use this in fields where users may paste a full EPC URI.
  static List<TextInputFormatter> ssccOrUri() => [const _SsccUriAwareFormatter()];

  static List<TextInputFormatter> serial({int maxLength = 20}) => [
        LengthLimitingTextInputFormatter(maxLength),
      ];
}

/// TextInputFormatter that passes URN / Digital Link / AI element-string input
/// through unchanged, while still enforcing digits-only and max-18 for plain
/// numeric SSCC entry.
class _SsccUriAwareFormatter extends TextInputFormatter {
  const _SsccUriAwareFormatter();

  static final _urnPrefix =
      RegExp(r'^urn:epc:id:sscc:', caseSensitive: false);
  static final _dlPrefix =
      RegExp(r'^https://id\.gs1\.org/00/', caseSensitive: false);
  static final _aiPrefix = RegExp(r'^\(');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;

    // Allow URN, Digital Link and AI bracket notation through unchanged.
    if (_urnPrefix.hasMatch(text) ||
        _dlPrefix.hasMatch(text) ||
        _aiPrefix.hasMatch(text)) {
      return newValue;
    }

    // For plain numeric input: digits only, max 18 characters.
    final digitsOnly = text.replaceAll(RegExp(r'\D'), '');
    final limited =
        digitsOnly.length > 18 ? digitsOnly.substring(0, 18) : digitsOnly;

    if (limited == text) return newValue; // nothing changed

    return newValue.copyWith(
      text: limited,
      selection: TextSelection.collapsed(offset: limited.length),
      composing: TextRange.empty,
    );
  }
}
