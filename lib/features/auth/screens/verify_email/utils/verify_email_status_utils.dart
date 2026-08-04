abstract final class VerifyEmailStatusUtils {
  static String statusKey({
    required bool isVerifying,
    required String? successMessage,
  }) {
    if (isVerifying) return 'verifying';
    if (successMessage != null) return 'success';
    return 'error';
  }
}
