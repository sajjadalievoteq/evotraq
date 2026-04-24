import 'gtin_format.dart';

/// All GTIN **input** validation for forms and related UI. Use [validateGtinCode] on the GTIN field.
///
/// Pure functions only: no `BuildContext`, cubits, or side effects.
abstract final class GtinFieldValidators {
  // --- GTIN code (single source of truth for rules) ---

  /// Required GTIN: strip, length 8/12/13/14, GS1 Mod-10. Use as [FormField.validator].
  static String? validateGtinCode(String? value) {
    final s = GtinFormat.stripGtinInput(value);
    if (s.isEmpty) {
      return 'GTIN Code is required';
    }
    if (!GtinFormat.isValidGtin(s)) {
      if (!RegExp(r'^\d+$').hasMatch(s)) {
        return 'GTIN must contain only digits (spaces and hyphens are ignored)';
      }
      if (!RegExp(r'^(?:\d{8}|\d{12}|\d{13}|\d{14})$').hasMatch(s)) {
        return 'Invalid length. Use 8, 12, 13, or 14 digits (GS1).';
      }
      return 'Invalid check digit. Verify the GTIN or use a GS1 check-digit calculator.';
    }
    return null;
  }

  /// Optional GTIN (e.g. search filters). Empty is valid.
  static String? validateGtinCodeOptional(String? value) {
    final s = GtinFormat.stripGtinInput(value);
    if (s.isEmpty) return null;
    return validateGtinCode(s);
  }

  /// `true` when [validateGtinCode] passes and the stripped value is non-empty.
  static bool isGtinCodeValid(String? value) => validateGtinCode(value) == null;

  /// 14-digit canonical form. Call only when [validateGtinCode] is already `null`.
  static String canonicalGtin14FromInput(String? value) {
    final s = GtinFormat.stripGtinInput(value);
    if (!GtinFormat.isValidGtin(s)) {
      throw StateError('canonicalGtin14FromInput: invalid or empty GTIN');
    }
    return GtinFormat.normalizeGtinTo14(s);
  }

  /// Data for the “valid GTIN” chip row. `null` if invalid or empty.
  static GtinCodeChipsData? validGtinChipsData(String? raw) {
    if (!isGtinCodeValid(raw)) return null;
    final s = GtinFormat.stripGtinInput(raw);
    final canon = GtinFormat.normalizeGtinTo14(s);
    final label = GtinFormat.structureLabelForStrippedInput(s);
    final ind = GtinFormat.indicatorFromCanonical14(canon);
    if (label == null || ind == null) return null;
    return (structureLabel: label, indicatorDigit: ind, canonical14: canon);
  }

  // --- Other GTIN form fields ---

  static String? productNameRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Product Name is required';
    }
    return null;
  }

  static String? manufacturerRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Manufacturer is required';
    }
    return null;
  }

  static String? packSizeOptionalInt(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    if (int.tryParse(value.trim()) == null) {
      return 'Pack Size must be a valid number';
    }
    return null;
  }
}

/// Return type for [GtinFieldValidators.validGtinChipsData].
typedef GtinCodeChipsData = ({
  String structureLabel,
  String indicatorDigit,
  String canonical14,
});
