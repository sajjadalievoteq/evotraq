import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_state.dart';
import 'package:traqtrace_app/data/services/auth_service.dart';
import 'package:traqtrace_app/features/auth/models/auth_models.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService;

  AuthService get authService => _authService; // Expose AuthService

  AuthCubit({required AuthService authService})
      : _authService = authService,
        super(const AuthState(status: AuthStatus.initial));

  Future<void> checkAuth() async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final user = await _authService.getCurrentUser();
      emit(state.copyWith(status: AuthStatus.authenticated, user: user));
    } catch (e) {
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    }
  }

  Future<void> login(LoginRequest request) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final response = await _authService.login(request);
      final user = await _authService.getCurrentUser();
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        token: response.token,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        error: e.toString(),
      ));
    }
  }

  Future<void> register(RegisterRequest request) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      await _authService.register(request);
      emit(state.copyWith(status: AuthStatus.registered));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        error: e.toString(),
      ));
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    emit(state.copyWith(
      status: AuthStatus.unauthenticated,
      user: null,
      token: null,
    ));
  }

  Future<void> getCurrentUser() async {
    try {
      final user = await _authService.getCurrentUser();
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
      ));
    }
  }

  // Password reset handlers
  Future<void> requestPasswordReset(String email) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      await _authService.requestPasswordReset(email);
      emit(state.copyWith(status: AuthStatus.passwordResetRequested));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        error: e.toString(),
      ));
    }
  }

  Future<void> validatePasswordResetToken(String token) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final isValid = await _authService.validatePasswordResetToken(token);
      if (isValid) {
        emit(state.copyWith(status: AuthStatus.passwordResetTokenValid));
      } else {
        emit(state.copyWith(status: AuthStatus.passwordResetTokenInvalid));
      }
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        error: e.toString(),
      ));
    }
  }

  Future<void> completePasswordReset(String token, String newPassword, String confirmPassword) async {
    emit(state.copyWith(status: AuthStatus.loading));
    
    if (newPassword != confirmPassword) {
      emit(state.copyWith(
        status: AuthStatus.error,
        error: 'Passwords do not match',
      ));
      return;
    }
    
    try {
      final success = await _authService.resetPassword(
        token,
        newPassword,
        confirmPassword,
      );
      
      if (success) {
        emit(state.copyWith(status: AuthStatus.passwordReset));
      } else {
        emit(state.copyWith(
          status: AuthStatus.error,
          error: 'Password reset failed. Please try again.',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        error: e.toString(),
      ));
    }
  }

  // Email verification handler
  Future<void> verifyEmail(String token) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final success = await _authService.verifyEmail(token);
      
      if (success) {
        emit(state.copyWith(status: AuthStatus.emailVerified));
      } else {
        emit(state.copyWith(
          status: AuthStatus.error,
          error: 'Email verification failed. The token may be invalid or expired.',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        error: e.toString(),
      ));
    }
  }
}
