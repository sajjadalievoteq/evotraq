import 'package:traqtrace_app/features/auth/cubit/auth_state.dart';

abstract final class ResetPasswordStatusUtils {
  static String statusKey(AuthState state) {
    if (state.status == AuthStatus.loading) return 'loading';
    if (state.status == AuthStatus.passwordResetTokenInvalid) return 'invalid';
    if (state.status == AuthStatus.passwordReset) return 'success';
    return 'form';
  }
}
