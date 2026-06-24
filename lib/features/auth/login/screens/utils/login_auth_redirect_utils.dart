import 'package:traqtrace_app/features/auth/cubit/auth_state.dart';

abstract final class LoginAuthRedirectUtils {
  static bool shouldRedirectToCheckEmail(AuthState state) {
    final error = state.error?.trim().toLowerCase() ?? '';
    return state.status == AuthStatus.error &&
        error.contains('verify your email');
  }
}
