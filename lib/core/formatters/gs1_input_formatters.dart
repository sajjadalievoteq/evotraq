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

  static List<TextInputFormatter> sscc({int maxLength = 18}) => [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(maxLength),
      ];

  static List<TextInputFormatter> ssccOrUri() => [const _SsccUriAwareFormatter()];

  static List<TextInputFormatter> serial({int maxLength = 20}) => [
        LengthLimitingTextInputFormatter(maxLength),
      ];
}

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

    if (_urnPrefix.hasMatch(text) ||
        _dlPrefix.hasMatch(text) ||
        _aiPrefix.hasMatch(text)) {
      return newValue;
    }

    final digitsOnly = text.replaceAll(RegExp(r'\D'), '');
    final limited =
        digitsOnly.length > 18 ? digitsOnly.substring(0, 18) : digitsOnly;

    if (limited == text) return newValue;

    return newValue.copyWith(
      text: limited,
      selection: TextSelection.collapsed(offset: limited.length),
      composing: TextRange.empty,
    );
  }
}
