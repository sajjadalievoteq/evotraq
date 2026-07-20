import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/data/session/home_overview_session_store.dart';
import 'package:traqtrace_app/data/services/epcis/cbv_vocabulary_service.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_state.dart';
import 'package:traqtrace_app/data/services/auth_service/auth_service.dart';
import 'package:traqtrace_app/data/models/auth/auth_models.dart';
import 'package:traqtrace_app/features/gs1/gln/services/gln_picker_catalog.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService;
  final Duration _authCheckTimeout;
  final Duration _loginTimeout;
  final Duration _verifyEmailTimeout;
  AuthService get authService => _authService;

  /// Startup profile check must finish within this window or become unauthenticated.
  static const Duration authCheckTimeout = Duration(seconds: 10);

  /// Login must fail fast so the button never spins forever.
  static const Duration loginTimeout = Duration(seconds: 15);

  /// Email verification must fail fast so the screen never spins forever.
  static const Duration verifyEmailTimeout = Duration(seconds: 15);

  AuthCubit({
    required AuthService authService,
    Duration? authCheckTimeout,
    Duration? loginTimeout,
    Duration? verifyEmailTimeout,
  })  : _authService = authService,
        _authCheckTimeout = authCheckTimeout ?? AuthCubit.authCheckTimeout,
        _loginTimeout = loginTimeout ?? AuthCubit.loginTimeout,
        _verifyEmailTimeout =
            verifyEmailTimeout ?? AuthCubit.verifyEmailTimeout,
        super(const AuthState(status: AuthStatus.initial));

  bool _requiresEmailVerification(String? message) {
    final normalized = message?.trim().toLowerCase();
    if (normalized == null || normalized.isEmpty) {
      return false;
    }
    return normalized.contains('verify your email');
  }

  String? _extractEmailFromError(dynamic error) {
    if (error is! ApiException || error.responseBody == null) {
      return null;
    }

    final body = _authService.parseResponseMap(error.responseBody);
    final email = body?['email'];
    if (email is String && email.trim().isNotEmpty) {
      return email.trim();
    }
    return null;
  }

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
      final user = await _authService
          .getCurrentUser()
          .timeout(_authCheckTimeout);
      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          error: null,
          message: null,
          registeredEmail: null,
        ),
      );
      _preloadGlnPickerCatalog();
      _startCbvVocabulary();
    } on TimeoutException {
      await _forceUnauthenticated();
    } catch (e) {
      await _forceUnauthenticated();
    }
  }

  Future<void> login(LoginRequest request) async {
    emit(
      state.copyWith(status: AuthStatus.loading, error: null, message: null),
    );
    try {
      final response =
          await _authService.login(request).timeout(_loginTimeout);
      final user =
          await _authService.getCurrentUser().timeout(_loginTimeout);
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
      _preloadGlnPickerCatalog();
      _startCbvVocabulary();
    } on TimeoutException {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          error: 'Login timed out. Please check your connection and try again.',
          message: null,
        ),
      );
    } catch (e) {
      final errorMessage = _resolveErrorMessage(e, 'Authentication failed');
      final fallbackEmail = request.username.contains('@')
          ? request.username.trim()
          : null;
      emit(
        state.copyWith(
          status: AuthStatus.error,
          error: errorMessage,
          message: null,
          registeredEmail: _requiresEmailVerification(errorMessage)
              ? (_extractEmailFromError(e) ?? fallbackEmail)
              : null,
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
    try {
      await _authService.logout();
    } catch (_) {
      // Local session clear must proceed even if token delete fails.
    }
    await _forceUnauthenticated();
  }

  /// Clears the session after 401 / expiry. Idempotent if already unauthenticated.
  Future<void> sessionExpired() async {
    if (state.status == AuthStatus.unauthenticated) return;
    try {
      await _authService.logout();
    } catch (_) {}
    await _forceUnauthenticated();
  }

  Future<void> _forceUnauthenticated() async {
    _clearSessionCaches();
    emit(const AuthState(status: AuthStatus.unauthenticated));
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
      _preloadGlnPickerCatalog();
      _startCbvVocabulary();
    } catch (e) {
      await _forceUnauthenticated();
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

  Future<void> verifyEmail(String token) async {
    emit(
      state.copyWith(status: AuthStatus.loading, error: null, message: null),
    );
    try {
      final message = await _authService
          .verifyEmail(token)
          .timeout(_verifyEmailTimeout);
      emit(
        state.copyWith(
          status: AuthStatus.emailVerified,
          error: null,
          message: message,
        ),
      );
    } on TimeoutException {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          error:
              'Email verification timed out. Please check your connection and try again.',
          message: null,
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

  Future<void> resendVerificationEmail(String email) async {
    final normalizedEmail = email.trim();
    emit(
      state.copyWith(
        status: AuthStatus.loading,
        error: null,
        message: null,
        registeredEmail: normalizedEmail,
      ),
    );
    try {
      final message = await _authService.resendVerificationEmail(
        normalizedEmail,
      );
      emit(
        state.copyWith(
          status: AuthStatus.verificationEmailResent,
          error: null,
          message: message,
          registeredEmail: normalizedEmail,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          error: _resolveErrorMessage(e, 'Failed to resend verification email'),
          message: null,
          registeredEmail: normalizedEmail,
        ),
      );
    }
  }

  void _clearHomeOverviewSession() {
    if (getIt.isRegistered<HomeOverviewSessionStore>()) {
      getIt<HomeOverviewSessionStore>().clear();
    }
  }

  void _clearGlnPickerCatalog() {
    if (getIt.isRegistered<GlnPickerCatalog>()) {
      getIt<GlnPickerCatalog>().clear();
    }
  }

  void _clearSessionCaches() {
    _clearHomeOverviewSession();
    _clearGlnPickerCatalog();
    _resetCbvVocabulary();
  }

  void _preloadGlnPickerCatalog() {
    if (!getIt.isRegistered<GlnPickerCatalog>()) return;
    // Fire-and-forget: pickers read from cache once this completes.
    getIt<GlnPickerCatalog>().preload();
  }

  void _startCbvVocabulary() {
    if (!getIt.isRegistered<CbvVocabularyService>()) return;
    unawaited(getIt<CbvVocabularyService>().start());
  }

  void _resetCbvVocabulary() {
    if (!getIt.isRegistered<CbvVocabularyService>()) return;
    getIt<CbvVocabularyService>().reset();
  }
}
