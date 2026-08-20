import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:traqtrace_app/core/config/app_navigation.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/core/storage/operational_gln_store.dart';
import 'package:traqtrace_app/data/models/auth/user.dart';
import 'package:traqtrace_app/data/services/epcis/cbv_vocabulary_service.dart';
import 'package:traqtrace_app/data/services/gs1/gln/gln_picker_catalog.dart';
import 'package:traqtrace_app/data/services/websocket_service.dart';
import 'package:traqtrace_app/data/session/home_overview_session_store.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_state.dart';

extension AuthCubitSession on AuthCubit {
  /// Roles that must never reach [AuthStatus.authenticated] through the
  /// Flutter web frontend. B2B_SERVICE is an integration-testing role meant
  /// for partners calling the documented APIs directly (see the Inbound API
  /// catalog in Automation Center) - it must keep working against the auth
  /// API itself, so this check runs only after login/session-restore fetch
  /// the user, and it is enforced here (client-side) rather than by
  /// rejecting the credentials at the API layer.
  static const Set<String> _frontendBlockedRoles = {'B2B_SERVICE'};

  /// If [user]'s role is not permitted to use the web frontend, tears down
  /// any partial session state and emits an explanatory error instead of
  /// ever emitting [AuthStatus.authenticated]. Returns true when the caller
  /// (login/checkAuth) should stop and return immediately.
  Future<bool> rejectIfFrontendBlockedRole(User user) async {
    final role = user.role.trim().toUpperCase();
    if (!_frontendBlockedRoles.contains(role)) return false;

    cancelTokenExpiration();
    disconnectSharedWebSocket();
    clearSessionCaches();
    try {
      await authService.logout();
    } catch (_) {}

    emit(
      const AuthState(
        status: AuthStatus.error,
        bootstrapCompleted: true,
        error:
            'B2B Service accounts cannot sign in through the web application. '
            'Use these credentials to call the API directly - see the '
            '"How to authenticate" instructions in Automation Center > Inbound.',
      ),
    );
    return true;
  }

  bool requiresEmailVerification(String? message) {
    final normalized = message?.trim().toLowerCase();
    if (normalized == null || normalized.isEmpty) {
      return false;
    }
    return normalized.contains('verify your email');
  }

  String? extractEmailFromError(dynamic error) {
    if (error is! ApiException || error.responseBody == null) {
      return null;
    }

    final body = authService.parseResponseMap(error.responseBody);
    final email = body?['email'];
    if (email is String && email.trim().isNotEmpty) {
      return email.trim();
    }
    return null;
  }

  String resolveErrorMessage(dynamic error, String fallback) {
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

  void cancelTokenExpiration() {
    tokenExpiryTimer?.cancel();
    tokenExpiryTimer = null;
    scheduledExpiryToken = null;
    idleTimer?.cancel();
    idleTimer = null;
  }

  void onAuthenticatedSessionStarted(String token) {
    lastUserActivityAt = DateTime.now();
    lastActivityPingAt = null;
    _scheduleTokenRefresh(token);
    _scheduleIdleLogout();
    _preloadGlnPickerCatalog();
    _startCbvVocabulary();
    _ensureSharedWebSocketConnected();
  }

  /// Pointer / keyboard / scroll from the live UI. WebSocket traffic is ignored.
  void noteUserActivity() {
    if (state.status != AuthStatus.authenticated) return;
    lastUserActivityAt = DateTime.now();
    _scheduleIdleLogout();
    _pingActivityIfDue();
  }

  void _scheduleIdleLogout() {
    idleTimer?.cancel();
    idleTimer = Timer(sessionIdleTimeout, () {
      if (state.status != AuthStatus.authenticated) return;
      unawaited(sessionExpired());
    });
  }

  void _pingActivityIfDue() {
    final now = DateTime.now();
    final lastPing = lastActivityPingAt;
    if (lastPing != null &&
        now.difference(lastPing) < sessionActivityPingThrottle) {
      return;
    }
    lastActivityPingAt = now;
    unawaited(authService.pingActivity());
  }

  /// Refresh the JWT shortly before `exp` when the user is still active.
  /// Idle users are logged out instead of silently extending the session.
  void _scheduleTokenRefresh(String token) {
    tokenExpiryTimer?.cancel();
    tokenExpiryTimer = null;
    scheduledExpiryToken = null;

    final remaining = tokenManager.remainingLifetime(token);
    if (remaining == null) {
      return;
    }
    if (remaining <= Duration.zero) {
      unawaited(_refreshOrExpire(token));
      return;
    }

    scheduledExpiryToken = token;
    tokenExpiryTimer = Timer(remaining, () {
      if (scheduledExpiryToken != token) return;
      if (state.status != AuthStatus.authenticated) return;
      unawaited(_refreshOrExpire(token));
    });
  }

  bool _isUserIdle() {
    final last = lastUserActivityAt;
    if (last == null) return true;
    return DateTime.now().difference(last) >= sessionIdleTimeout;
  }

  Future<void> _refreshOrExpire(String token) async {
    if (_isUserIdle()) {
      await sessionExpired();
      return;
    }
    if (tokenRefreshInFlight) return;
    tokenRefreshInFlight = true;
    try {
      final refreshed = await authService.refreshToken();
      if (state.status != AuthStatus.authenticated) return;
      emit(state.copyWith(token: refreshed.token, error: null, message: null));
      _scheduleTokenRefresh(refreshed.token);
    } catch (_) {
      await sessionExpired();
    } finally {
      tokenRefreshInFlight = false;
    }
  }

  /// Closes any dialog/bottom-sheet routes still on screen (e.g. the
  /// New/Edit Subscription dialog). Must run synchronously and *before*
  /// [AuthCubit.forceUnauthenticated] emits the unauthenticated state:
  /// GoRouter's redirect is deferred to the next frame (see
  /// GoRouterRefreshStream), so without this a dialog left open at the
  /// moment of logout survives as an orphaned overlay when the underlying
  /// page is swapped out, and its BlocProvider.value/FormBuilder
  /// InheritedElement can unmount while it still has live dependents -
  /// tripping framework.dart's `_dependents.isEmpty` assertion. Popping it
  /// here first lets Flutter tear it down through the normal deactivate/
  /// unmount path instead.
  ///
  /// `popUntil` only removes routes for which the predicate is false, so
  /// this stops as soon as it reaches the underlying page route - it never
  /// touches page-level navigation.
  void closeAnyOpenDialogs() {
    final navigator = rootNavigatorKey.currentState;
    if (navigator == null) return;
    navigator.popUntil((route) => route is! PopupRoute);
  }

  void backfillOperationalGln(User user) {
    unawaited(
      OperationalGlnStore.backfillIfNeeded(user).catchError((_) {
        // Best-effort migration: storage failure must not destabilize auth.
      }),
    );
  }

  void _ensureSharedWebSocketConnected() {
    if (!getIt.isRegistered<WebSocketService>()) return;
    getIt<WebSocketService>().connect();
  }

  void disconnectSharedWebSocket() {
    if (!getIt.isRegistered<WebSocketService>()) return;
    getIt<WebSocketService>().disconnect();
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

  void clearSessionCaches() {
    _clearHomeOverviewSession();
    _clearGlnPickerCatalog();
    _resetCbvVocabulary();
  }

  void _preloadGlnPickerCatalog() {
    if (!getIt.isRegistered<GlnPickerCatalog>()) return;

    getIt<GlnPickerCatalog>().preload();
  }

  void _startCbvVocabulary() {
    if (!getIt.isRegistered<CbvVocabularyService>()) return;
    unawaited(getIt<CbvVocabularyService>().start());
  }

  void _resetCbvVocabulary() {
    if (!getIt.isRegistered<CbvVocabularyService>()) return;
    unawaited(getIt<CbvVocabularyService>().reset());
  }
}
