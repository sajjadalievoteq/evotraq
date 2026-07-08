import 'package:traqtrace_app/core/utils/gs1/check_digit_utils.dart';

abstract final class GlnCheckDigitValidator {
  static bool isValid(String gln) {
    if (!RegExp(r'^\d{13}$').hasMatch(gln)) return false;
    return CheckDigitUtils.isValidMod10(gln);
  }
}
