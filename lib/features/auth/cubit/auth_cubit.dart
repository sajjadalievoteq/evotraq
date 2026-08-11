import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/core/network/token_manager.dart';
import 'package:traqtrace_app/core/storage/operational_gln_store.dart';
import 'package:traqtrace_app/data/models/auth/user.dart';
import 'package:traqtrace_app/data/session/home_overview_session_store.dart';
import 'package:traqtrace_app/data/services/epcis/cbv_vocabulary_service.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_state.dart';
import 'package:traqtrace_app/data/services/auth/auth_service.dart';
import 'package:traqtrace_app/data/models/auth/login_request.dart';
import 'package:traqtrace_app/data/models/auth/register_request.dart';
import 'package:traqtrace_app/data/services/gs1/gln/gln_picker_catalog.dart';
import 'package:traqtrace_app/data/services/websocket_service.dart';

part 'auth_cubit_session.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService;
  final TokenManager _tokenManager;
  final Duration _authCheckTimeout;
  final Duration _loginTimeout;
  final Duration _verifyEmailTimeout;
  AuthService get authService => _authService;

  /// Serializes concurrent session-expiry notifications (many parallel 401s).
  bool _sessionExpiryInFlight = false;

  /// One-shot JWT `exp` timer for the current authenticated session.
  Timer? _tokenExpiryTimer;

  /// Token identity associated with [_tokenExpiryTimer] (stale-timer guard).
  String? _scheduledExpiryToken;

  static const Duration authCheckTimeout = Duration(seconds: 10);

  static const Duration loginTimeout = Duration(seconds: 15);

  static const Duration verifyEmailTimeout = Duration(seconds: 15);

  AuthCubit({
    required AuthService authService,
    TokenManager? tokenManager,
    Duration? authCheckTimeout,
    Duration? loginTimeout,
    Duration? verifyEmailTimeout,
  }) : _authService = authService,
       _tokenManager = tokenManager ?? TokenManager(),
       _authCheckTimeout = authCheckTimeout ?? AuthCubit.authCheckTimeout,
       _loginTimeout = loginTimeout ?? AuthCubit.loginTimeout,
       _verifyEmailTimeout = verifyEmailTimeout ?? AuthCubit.verifyEmailTimeout,
       super(const AuthState(status: AuthStatus.initial));

  @visibleForTesting
  bool get hasTokenExpiryTimerForTest => _tokenExpiryTimer != null;

  @visibleForTesting
  String? get scheduledExpiryTokenForTest => _scheduledExpiryToken;

  Future<void> checkAuth({Duration minSplashDelay = Duration.zero}) async {
    emit(
      state.copyWith(status: AuthStatus.loading, error: null, message: null),
    );
    final startedAt = DateTime.now();
    try {
      final token = await _authService.getAuthToken();
      if (token == null || token.isEmpty) {
        await _awaitMinSplash(startedAt, minSplashDelay);
        await _forceUnauthenticated();
        return;
      }

      if (_tokenManager.isExpired(token)) {
        await _awaitMinSplash(startedAt, minSplashDelay);
        await sessionExpired();
        return;
      }

      final user = await _authService.getCurrentUser().timeout(
        _authCheckTimeout,
      );
      await _awaitMinSplash(startedAt, minSplashDelay);
      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          token: token,
          error: null,
          message: null,
          registeredEmail: null,
          bootstrapCompleted: true,
        ),
      );
      _scheduleTokenExpiration(token);
      _onAuthenticatedSessionStarted();
      _backfillOperationalGln(user);
    } on TimeoutException {
      await _awaitMinSplash(startedAt, minSplashDelay);
      await _forceUnauthenticated();
    } catch (e) {
      await _awaitMinSplash(startedAt, minSplashDelay);
      await _forceUnauthenticated();
    }
  }

  Future<void> _awaitMinSplash(DateTime startedAt, Duration minDelay) async {
    if (minDelay <= Duration.zero) return;
    final remaining = minDelay - DateTime.now().difference(startedAt);
    if (remaining > Duration.zero) {
      await Future.delayed(remaining);
    }
  }

  Future<void> login(LoginRequest request) async {
    emit(
      state.copyWith(status: AuthStatus.loading, error: null, message: null),
    );
    try {
      final response = await _authService.login(request).timeout(_loginTimeout);
      final user = await _authService.getCurrentUser().timeout(_loginTimeout);
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
      _scheduleTokenExpiration(response.token);
      _onAuthenticatedSessionStarted();
      _backfillOperationalGln(user);
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
    _cancelTokenExpiration();
    _disconnectSharedWebSocket();
    try {
      await _authService.logout();
    } catch (_) {}
    await _forceUnauthenticated();
  }

  /// Centralized path for JWT timer expiry, HTTP 401, and STOMP auth failures.
  ///
  /// Emits unauthenticated immediately so GoRouter redirects to Login without a
  /// browser refresh. Remote logout is best-effort and must not block navigation
  /// (awaiting a hung logout POST previously left the UI on a protected screen).
  Future<void> sessionExpired() async {
    if (state.status == AuthStatus.unauthenticated) return;
    if (_sessionExpiryInFlight) return;
    _sessionExpiryInFlight = true;
    try {
      _cancelTokenExpiration();
      _disconnectSharedWebSocket();
      await _forceUnauthenticated();
      unawaited(_authService.logout().catchError((_) {}));
    } finally {
      _sessionExpiryInFlight = false;
    }
  }

  Future<void> _forceUnauthenticated() async {
    _cancelTokenExpiration();
    _disconnectSharedWebSocket();
    _clearSessionCaches();
    emit(
      const AuthState(
        status: AuthStatus.unauthenticated,
        bootstrapCompleted: true,
      ),
    );
  }

  Future<void> getCurrentUser() async {
    try {
      final token = await _authService.getAuthToken();
      final user = await _authService.getCurrentUser();
      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          token: token,
          error: null,
          message: null,
        ),
      );
      if (token != null && token.isNotEmpty) {
        _scheduleTokenExpiration(token);
      }
      _onAuthenticatedSessionStarted();
      _backfillOperationalGln(user);
    } catch (e) {
      await _forceUnauthenticated();
    }
  }

  @override
  Future<void> close() {
    _cancelTokenExpiration();
    return super.close();
  }

  /// Replaces the cached authenticated user without changing auth status.
  void applyCachedUser(User user) {
    if (state.status != AuthStatus.authenticated) return;
    emit(state.copyWith(user: user));
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
}
