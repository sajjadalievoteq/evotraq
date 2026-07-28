import 'package:traqtrace_app/core/utils/epc_uri_validators.dart' as epc_validators;
import 'package:traqtrace_app/core/utils/gs1/check_digit_utils.dart';
import 'package:traqtrace_app/features/gs1/sgtin/utils/sgtin_validators.dart'
    as sgtin_validators;

/// Identifier validation facade — all mod-10 / length rules via [CheckDigitUtils].
abstract final class Gs1Validator {
  static bool isValidGTIN(String? value) => CheckDigitUtils.isValidGtin(value);

  static bool isValidGLN(String? value) => CheckDigitUtils.isValidGln(value);

  static bool isValidSSCC(String? value) => CheckDigitUtils.isValidSscc(value);

  static bool isValidSGTIN(String? gtin, String? serialNumber) =>
      CheckDigitUtils.isValidSgtin(gtin, serialNumber);

  static bool isValidEpcUri(String value) {
    return epc_validators.isValidEpcUri(value);
  }

  static bool isValidDigitalLink(String value) {
    return sgtin_validators.validateGs1DigitalLinkUri(value) == null;
  }
}
