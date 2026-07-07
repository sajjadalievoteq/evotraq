import 'package:traqtrace_app/core/utils/epc_uri_validators.dart' as epc_validators;
import 'package:traqtrace_app/features/gs1/gln/utils/gln_format.dart';
import 'package:traqtrace_app/features/gs1/gtin/utils/gtin_format.dart';
import 'package:traqtrace_app/features/gs1/sgtin/utils/sgtin_validators.dart'
    as sgtin_validators;
import 'package:traqtrace_app/features/gs1/sscc/utils/sscc_format.dart';

/// Unified GS1 validation facade.
///
/// Delegates to existing validators to keep behavior unchanged.
abstract final class Gs1Validator {
  static bool isValidGTIN(String? value) {
    if (value == null || value.isEmpty) return false;
    return GtinFormat.isValidGtin(GtinFormat.stripGtinInput(value));
  }

  static bool isValidGLN(String? value) {
    if (value == null || value.isEmpty) return false;
    return GlnFormat.isValidGln(GlnFormat.stripGlnInput(value));
  }

  static bool isValidSSCC(String? value) {
    if (value == null || value.isEmpty) return false;
    return SsccFormat.isValidSscc(SsccFormat.stripSsccInput(value));
  }

  static bool isValidSGTIN(String? gtin, String? serialNumber) {
    if (!isValidGTIN(gtin)) return false;
    return sgtin_validators.validateSerialNumber(serialNumber) == null;
  }

  /// Validates with the modern full EPC URI validator.
  static bool isValidEpcUri(String value) {
    return epc_validators.isValidEpcUri(value);
  }

  /// Validates only GS1 Digital Link that maps to an SGTIN URI.
  static bool isValidDigitalLink(String value) {
    return sgtin_validators.validateGs1DigitalLinkUri(value) == null;
  }
}
