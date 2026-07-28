import 'package:traqtrace_app/core/utils/gs1/check_digit_utils.dart';
import 'package:traqtrace_app/features/barcode/services/gs1_barcode_parser.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_slice.dart';

/// Shared GTIN/GLN/SSCC/SGTIN identifier validation used by GS1 Tools Validator
/// and the Validation Workbench Identifier section.
abstract final class Gs1IdentifierValidation {
  static WorkbenchSlice validate({
    String? gtin,
    String? gln,
    String? sscc,
    String? sgtin,
  }) {
    final fields = <String, String>{};
    var any = false;

    void add(String label, String? value, String? Function() validate) {
      final v = (value ?? '').trim();
      if (v.isEmpty) return;
      any = true;
      final err = validate();
      fields[label] = err == null ? 'PASS' : 'FAIL — $err';
    }

    add(
      'GTIN',
      gtin,
      () => CheckDigitUtils.validateGtin(gtin),
    );
    add(
      'GLN',
      gln,
      () => CheckDigitUtils.validateGln(gln),
    );
    add(
      'SSCC',
      sscc,
      () => CheckDigitUtils.validateSscc(sscc),
    );
    add('SGTIN', sgtin, () {
      final parsed = GS1BarcodeParser.parseGS1Barcode(sgtin ?? '');
      final gtinVal = parsed['GTIN']?.toString();
      final serial = parsed['SERIAL']?.toString();
      if (gtinVal != null && serial != null && serial.isNotEmpty) {
        return CheckDigitUtils.validateSgtin(gtinVal, serial);
      }
      // Allow "gtin+serial" or "gtin,serial" paste forms.
      final plus = (sgtin ?? '').split('+');
      if (plus.length == 2) {
        return CheckDigitUtils.validateSgtin(plus[0].trim(), plus[1].trim());
      }
      return 'Expected (01)GTIN(21)SERIAL, Digital Link SGTIN, or gtin+serial';
    });

    if (!any) {
      return const WorkbenchSlice(
        status: WorkbenchActionStatus.error,
        error: 'Enter at least one identifier',
      );
    }

    return WorkbenchSlice(
      status: WorkbenchActionStatus.success,
      resultText:
          fields.entries.map((e) => '${e.key}: ${e.value}').join('\n'),
      resultFields: fields,
    );
  }
}
