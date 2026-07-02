/// GS1 GLN check-digit validation (13-digit GLN).
abstract final class GlnCheckDigitValidator {
  static bool isValid(String gln) {
    if (!RegExp(r'^\d{13}$').hasMatch(gln)) return false;
    var sum = 0;
    for (var i = 0; i < 12; i++) {
      final digit = int.parse(gln[i]);
      sum += i.isOdd ? digit * 3 : digit;
    }
    final checkDigit = (10 - (sum % 10)) % 10;
    return checkDigit == int.parse(gln[12]);
  }
}
