/// Shared GS1 Mod-10 check-digit helpers for GTIN/GLN/SSCC style identifiers.
abstract final class CheckDigitUtils {
  /// Calculates GS1 Mod-10 check digit for [bodyDigits] (without check digit).
  static int calculateMod10(String bodyDigits) {
    var sum = 0;
    var multiplyBy3 = true;
    for (var i = bodyDigits.length - 1; i >= 0; i--) {
      final digit = int.parse(bodyDigits[i]);
      sum += multiplyBy3 ? digit * 3 : digit;
      multiplyBy3 = !multiplyBy3;
    }
    return (10 - (sum % 10)) % 10;
  }

  static String calculateMod10String(String bodyDigits) {
    return calculateMod10(bodyDigits).toString();
  }

  /// Validates [identifierWithCheckDigit] using GS1 Mod-10.
  static bool isValidMod10(String identifierWithCheckDigit) {
    if (identifierWithCheckDigit.length < 2) return false;
    final body =
        identifierWithCheckDigit.substring(0, identifierWithCheckDigit.length - 1);
    final provided = int.tryParse(
      identifierWithCheckDigit[identifierWithCheckDigit.length - 1],
    );
    if (provided == null) return false;
    return calculateMod10(body) == provided;
  }
}
