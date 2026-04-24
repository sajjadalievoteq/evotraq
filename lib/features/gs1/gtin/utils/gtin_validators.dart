/// GTIN-only validators (reusable across screens/widgets).
///
/// Note: these validators only check basic formatting (digits + length).
/// Check-digit validation is handled by the backend `/validate` endpoint.
abstract final class GtinValidators {
  /// Matches GTIN-8 or GTIN-12/13/14 (digits only).
  static final RegExp _basicFormat = RegExp(r'^\d{8}$|^\d{12,14}$');

  /// Returns an error message if invalid, otherwise null.
  static String? requiredBasicFormat(String? value) {
    if (value == null || value.isEmpty) {
      return 'GTIN Code is required';
    }
    if (!_basicFormat.hasMatch(value)) {
      return 'Invalid GTIN format. Must be 8, 12, 13, or 14 digits.';
    }
    return null;
  }

  /// Same as [requiredBasicFormat], but allows empty values (useful for filters).
  static String? optionalBasicFormat(String? value) {
    if (value == null || value.isEmpty) return null;
    if (!_basicFormat.hasMatch(value)) {
      return 'Invalid GTIN format. Must be 8, 12, 13, or 14 digits.';
    }
    return null;
  }
}

