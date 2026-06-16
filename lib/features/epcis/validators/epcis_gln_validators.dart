import 'package:traqtrace_app/core/utils/gs1_utils.dart';
import 'package:traqtrace_app/features/gs1/gln/utils/gln_field_validators.dart';

/// Shared GLN parsing/validation for EPCIS event forms.
abstract final class EpcisGlnValidators {
  static String parseGlnToCode(String input) {
    final clean = input.trim();
    final extracted = GS1Utils.extractGLNCode(clean);
    if (extracted != null && RegExp(r'^\d{13}$').hasMatch(extracted)) {
      return extracted;
    }
    if (RegExp(r'^\d{13}$').hasMatch(clean)) {
      return clean;
    }
    if (clean.contains('.') && !clean.startsWith('urn:')) {
      final parts = clean.split('.');
      if (parts.length >= 2) {
        final companyPrefix = parts[0];
        final locationRef = parts[1].padLeft(5, '0');
        if (companyPrefix.length >= 7 && companyPrefix.length <= 10) {
          final withoutCheck = companyPrefix + locationRef;
          return withoutCheck + GS1Utils.calculateGS1CheckDigit(withoutCheck);
        }
      }
    }
    return clean;
  }

  static String? validateLocationGln(String? value, {bool required = true}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'Please enter the location GLN' : null;
    }
    final code = parseGlnToCode(value);
    return GlnFieldValidators.validateGlnCode(code);
  }
}
