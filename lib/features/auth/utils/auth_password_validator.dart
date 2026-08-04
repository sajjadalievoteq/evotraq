abstract final class AuthPasswordValidator {
  static const int minLength = 8;

  static String? validate(
    String? value, {
    String emptyMessage = 'Please enter a password',
    String tooShortMessage = 'Password must be at least 8 characters',
  }) {
    if (value == null || value.isEmpty) {
      return emptyMessage;
    }
    if (value.length < minLength) {
      return tooShortMessage;
    }
    return null;
  }

  static String? validateConfirmation(
    String? value,
    String password, {
    String emptyMessage = 'Please confirm your password',
    String mismatchMessage = 'Passwords do not match',
  }) {
    if (value == null || value.isEmpty) {
      return emptyMessage;
    }
    if (value != password) {
      return mismatchMessage;
    }
    return null;
  }
}
