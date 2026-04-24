import 'gtin_validators.dart';

/// GTIN feature field validators (UI-level).
///
/// Keep these pure and reusable: no `BuildContext`, no cubits, no side-effects.
abstract final class GtinFieldValidators {
  static String? gtinCodeRequired(String? value) =>
      GtinValidators.requiredBasicFormat(value);

  static String? productNameRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Product Name is required';
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

