import 'package:traqtrace_app/core/utils/gs1/check_digit_utils.dart';
import 'package:traqtrace_app/core/utils/gs1/gs1_canonical_identifier.dart';
import 'package:traqtrace_app/features/barcode/services/gs1_barcode_parser.dart';
import 'package:traqtrace_app/features/gs1/sgtin/utils/sgtin_validators.dart'
    as sgtin_validators;

/// Thin facade over [CheckDigitUtils] / canonical EPC helpers.
/// Prefer calling [CheckDigitUtils] directly in new code.
@Deprecated(
  'Use CheckDigitUtils (and Gs1CanonicalIdentifier / GS1BarcodeParser) instead.',
)
class GS1Validator {
  static bool isValidGTIN(String? gtinCode) =>
      CheckDigitUtils.isValidGtin(gtinCode);

  static bool isValidGLN(String? glnCode) =>
      CheckDigitUtils.isValidGln(glnCode);

  static bool isValidSSCC(String? ssccCode) =>
      CheckDigitUtils.isValidSscc(ssccCode);

  static bool isValidSGTIN(String? gtin, String? serialNumber) =>
      CheckDigitUtils.isValidSgtin(gtin, serialNumber);

  static bool isValidEPCURI(String? epcUri) {
    if (epcUri == null || epcUri.isEmpty) return false;
    return Gs1CanonicalIdentifier.isValid(epcUri);
  }

  /// Parses GS1 element strings / human-readable AI forms via [GS1BarcodeParser].
  /// Returns `null` when valid; otherwise a reason string.
  static String? validateBarcodeData(String? barcodeData) {
    if (barcodeData == null || barcodeData.trim().isEmpty) {
      return 'Barcode data cannot be empty';
    }
    final parsed = GS1BarcodeParser.parseGS1Barcode(barcodeData.trim());
    if (parsed['valid'] == true) return null;
    final checkErrors = (parsed['checkDigitErrors'] as List?)
        ?.map((e) => '$e')
        .where((e) => e.isNotEmpty)
        .toList();
    if (checkErrors != null && checkErrors.isNotEmpty) {
      return checkErrors.join('; ');
    }
    final ais = parsed['parsedData'];
    if (ais is! Map || ais.isEmpty) {
      return 'Invalid barcode format: missing Application Identifiers';
    }
    return 'Invalid GS1 barcode data';
  }

  static String? validateSerialNumber(String? serial) =>
      sgtin_validators.validateSerialNumber(serial);
}
