import 'package:traqtrace_app/features/gs1/gln/utils/gln_format.dart';
import 'package:traqtrace_app/features/gs1/gtin/utils/gtin_format.dart';
import 'package:traqtrace_app/features/gs1/sgtin/utils/sgtin_validators.dart'
    as sgtin_validators;
import 'package:traqtrace_app/features/gs1/sscc/utils/sscc_format.dart';

/// Legacy GS1 validation facade.
///
/// Prefer [GtinFormat], [GlnFormat], [SsccFormat], and [sgtin_validators]
/// for new code.
@Deprecated(
  'Use GtinFormat, GlnFormat, SsccFormat, and sgtin_validators instead.',
)
class GS1Validator {
  static bool isValidGTIN(String? gtinCode) {
    if (gtinCode == null || gtinCode.isEmpty) return false;
    return GtinFormat.isValidGtin(GtinFormat.stripGtinInput(gtinCode));
  }

  static bool isValidGLN(String? glnCode) {
    if (glnCode == null || glnCode.isEmpty) return false;
    return GlnFormat.isValidGln(GlnFormat.stripGlnInput(glnCode));
  }

  static bool isValidSSCC(String? ssccCode) {
    if (ssccCode == null || ssccCode.isEmpty) return false;
    return SsccFormat.isValidSscc(SsccFormat.stripSsccInput(ssccCode));
  }

  static bool isValidSGTIN(String? gtin, String? serialNumber) {
    if (!isValidGTIN(gtin)) return false;
    return sgtin_validators.validateSerialNumber(serialNumber) == null;
  }

  static bool isValidEPCURI(String? epcUri) {
    if (epcUri == null || epcUri.isEmpty) return false;
    final pattern = RegExp(
      r'^urn:epc:(id|class|idpat):(sgtin|sscc|sgln|grai|giai|gsrn|gdti|cpi):.+$',
    );
    return pattern.hasMatch(epcUri);
  }

  static String? validateBarcodeData(String? barcodeData) {
    if (barcodeData == null || barcodeData.isEmpty) {
      return 'Barcode data cannot be empty';
    }
    final aiPattern = RegExp(r'\(\d{2,4}\)');
    if (!aiPattern.hasMatch(barcodeData)) {
      return 'Invalid barcode format: missing Application Identifiers';
    }
    return null;
  }
}
