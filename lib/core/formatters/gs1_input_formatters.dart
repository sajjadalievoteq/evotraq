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

  static List<TextInputFormatter> serial({int maxLength = 20}) => [
        LengthLimitingTextInputFormatter(maxLength),
      ];
}
