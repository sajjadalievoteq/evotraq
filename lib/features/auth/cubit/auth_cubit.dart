import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_state.dart';
import 'package:traqtrace_app/data/services/auth_service/auth_service.dart';
import 'package:traqtrace_app/data/models/auth/auth_models.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService;
  AuthService get authService => _authService;
  AuthCubit({required AuthService authService})
    : _authService = authService,
      super(const AuthState(status: AuthStatus.initial));

  String _resolveErrorMessage(dynamic error, String fallback) {
    if (error is ApiException) {
      final message = error.message.trim();
      if (message.isNotEmpty) {
        return message;
      }
      return error.getUserFriendlyMessage();
    }
    final message = error.toString().trim();
    if (message.isEmpty) {
      return fallback;
    }
    return message
        .replaceFirst('Exception: ', '')
        .replaceFirst('ApiException: ', '');
  }

  Future<void> checkAuth() async {
    emit(
      state.copyWith(status: AuthStatus.loading, error: null, message: null),
    );
    try {
      final user = await _authService.getCurrentUser();
      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          error: null,
          message: null,
          registeredEmail: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          error: null,
          message: null,
        ),
      );
    }
  }

  Future<void> login(LoginRequest request) async {
    emit(
      state.copyWith(status: AuthStatus.loading, error: null, message: null),
    );
    try {
      final response = await _authService.login(request);
      final user = await _authService.getCurrentUser();
      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          token: response.token,
          error: null,
          message: null,
          registeredEmail: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          error: _resolveErrorMessage(e, 'Authentication failed'),
          message: null,
        ),
      );
    }
  }

  Future<void> register(RegisterRequest request) async {
    emit(
      state.copyWith(status: AuthStatus.loading, error: null, message: null),
    );
    try {
      await _authService.register(request);
      emit(
        state.copyWith(
          status: AuthStatus.registered,
          error: null,
          message:
              'Registration successful. We sent a verification email to ${request.email}.',
          registeredEmail: request.email,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          error: _resolveErrorMessage(e, 'Registration failed'),
          message: null,
        ),
      );
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    emit(
      state.copyWith(
        status: AuthStatus.unauthenticated,
        user: null,
        token: null,
        error: null,
        message: null,
        registeredEmail: null,
      ),
    );
  }

  Future<void> getCurrentUser() async {
    try {
      final user = await _authService.getCurrentUser();
      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          error: null,
          message: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          error: null,
          message: null,
        ),
      );
    }
  }

  Future<void> requestPasswordReset(String email) async {
    emit(
      state.copyWith(status: AuthStatus.loading, error: null, message: null),
    );
    try {
      await _authService.requestPasswordReset(email);
      emit(
        state.copyWith(
          status: AuthStatus.passwordResetRequested,
          error: null,
          message: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          error: _resolveErrorMessage(e, 'Password reset request failed'),
          message: null,
        ),
      );
    }
  }

  Future<void> validatePasswordResetToken(String token) async {
    emit(
      state.copyWith(status: AuthStatus.loading, error: null, message: null),
    );
    try {
      final isValid = await _authService.validatePasswordResetToken(token);
      if (isValid) {
        emit(
          state.copyWith(
            status: AuthStatus.passwordResetTokenValid,
            error: null,
            message: null,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: AuthStatus.passwordResetTokenInvalid,
            error: null,
            message: null,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          error: _resolveErrorMessage(
            e,
            'Password reset token validation failed',
          ),
          message: null,
        ),
      );
    }
  }

  Future<void> completePasswordReset(
    String token,
    String newPassword,
    String confirmPassword,
  ) async {
    emit(
      state.copyWith(status: AuthStatus.loading, error: null, message: null),
    );

    if (newPassword != confirmPassword) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          error: 'Passwords do not match',
          message: null,
        ),
      );
      return;
    }

    try {
      final success = await _authService.resetPassword(
        token,
        newPassword,
        confirmPassword,
      );

      if (success) {
        emit(
          state.copyWith(
            status: AuthStatus.passwordReset,
            error: null,
            message: null,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: AuthStatus.error,
            error: 'Password reset failed. Please try again.',
            message: null,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          error: _resolveErrorMessage(e, 'Password reset failed'),
          message: null,
        ),
      );
    }
  }

  // Email verification handler
  Future<void> verifyEmail(String token) async {
    emit(
      state.copyWith(status: AuthStatus.loading, error: null, message: null),
    );
    try {
      final message = await _authService.verifyEmail(token);
      emit(
        state.copyWith(
          status: AuthStatus.emailVerified,
          error: null,
          message: message,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          error: _resolveErrorMessage(e, 'Email verification failed'),
          message: null,
        ),
      );
    }
  }
}
