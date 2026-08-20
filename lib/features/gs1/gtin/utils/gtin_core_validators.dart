import 'package:traqtrace_app/features/gs1/gtin/utils/gtin_validation_types.dart';

import 'gtin_format.dart';
import 'package:traqtrace_app/core/utils/gs1/check_digit_utils.dart';

abstract final class GtinCoreValidators {
  static String? validateGtinCode(String? value) {
    final s = GtinFormat.stripGtinInput(value);
    if (s.isEmpty) {
      return 'GTIN Code is required';
    }
    final err = CheckDigitUtils.validateGS1CheckDigit(
      s,
      allowedLengths: CheckDigitUtils.gtinLengths,
      label: 'GTIN',
    );
    if (err == null) return null;
    if (err.contains('only digits')) {
      return 'GTIN must contain only digits (spaces and hyphens are ignored)';
    }
    if (err.contains('invalid length')) {
      return 'Invalid length. Use 8, 12, 13, or 14 digits (GS1).';
    }
    return 'Invalid check digit. Verify the GTIN or use a GS1 check-digit calculator.';
  }

  static String? validateGtinCodeOptional(String? value) {
    final s = GtinFormat.stripGtinInput(value);
    if (s.isEmpty) return null;
    return validateGtinCode(s);
  }

  static bool isGtinCodeValid(String? value) => validateGtinCode(value) == null;

  static String canonicalGtin14FromInput(String? value) {
    final s = GtinFormat.stripGtinInput(value);
    if (!GtinFormat.isValidGtin(s)) {
      throw StateError('canonicalGtin14FromInput: invalid or empty GTIN');
    }
    return GtinFormat.normalizeGtinTo14(s);
  }

  static GtinCodeChipsData? validGtinChipsData(String? raw) {
    if (!isGtinCodeValid(raw)) return null;
    final s = GtinFormat.stripGtinInput(raw);
    final canon = GtinFormat.normalizeGtinTo14(s);
    final label = GtinFormat.structureLabelForStrippedInput(s);
    final ind = GtinFormat.indicatorFromCanonical14(canon);
    if (label == null || ind == null) return null;
    final check = s.isNotEmpty ? s[s.length - 1] : '';
    return (
      structureLabel: label,
      indicatorDigit: ind,
      canonical14: canon,
      checkDigit: check,
    );
  }

  static String? validateProductName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Product Name is required';
    }
    final v = value.trim();
    if (v.length > 70) {
      return 'Product Name must be at most 70 characters';
    }

    if (RegExp(r'[\x00-\x1F\x7F]').hasMatch(v)) {
      return 'Product Name contains invalid control characters';
    }
    return null;
  }

  static String? validateManufacturer(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Manufacturer is required';
    }

    final v = value.trim();
    if (v.length > 200) {
      return 'Manufacturer must be at most 200 characters';
    }
    if (RegExp(r'[\x00-\x1F\x7F]').hasMatch(v)) {
      return 'Manufacturer contains invalid control characters';
    }
    return null;
  }

  static String? validatePackSizeOptionalInt(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final v = value.trim();
    final n = int.tryParse(v);
    if (n == null) {
      return 'Pack Size must be numeric';
    }

    if (n <= 0) {
      return 'Pack Size must be greater than 0';
    }
    return null;
  }

  static String? productNameRequired(String? value) =>
      validateProductName(value);

  static String? manufacturerRequired(String? value) =>
      validateManufacturer(value);

  static String? packSizeOptionalInt(String? value) =>
      validatePackSizeOptionalInt(value);
}
