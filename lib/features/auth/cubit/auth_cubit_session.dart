part of 'auth_cubit.dart';

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
  Future<bool> _rejectIfFrontendBlockedRole(User user) async {
    final role = user.role.trim().toUpperCase();
    if (!_frontendBlockedRoles.contains(role)) return false;

    _cancelTokenExpiration();
    _disconnectSharedWebSocket();
    _clearSessionCaches();
    try {
      await _authService.logout();
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

  void _cancelTokenExpiration() {
    _tokenExpiryTimer?.cancel();
    _tokenExpiryTimer = null;
    _scheduledExpiryToken = null;
  }

  /// Closes any dialog/bottom-sheet routes still on screen (e.g. the
  /// New/Edit Subscription dialog). Must run synchronously and *before*
  /// [AuthCubit._forceUnauthenticated] emits the unauthenticated state:
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
  void _closeAnyOpenDialogs() {
    final navigator = rootNavigatorKey.currentState;
    if (navigator == null) return;
    navigator.popUntil((route) => route is! PopupRoute);
  }

  /// Schedules a single one-shot logout at JWT `exp` (minus safety margin).
  void _scheduleTokenExpiration(String token) {
    _cancelTokenExpiration();

    final remaining = _tokenManager.remainingLifetime(token);
    if (remaining == null) {
      // Undecodable token: no client timer; Dio/WS remain authoritative.
      return;
    }
    if (remaining <= Duration.zero) {
      unawaited(sessionExpired());
      return;
    }

    _scheduledExpiryToken = token;
    _tokenExpiryTimer = Timer(remaining, () {
      if (_scheduledExpiryToken != token) return;
      if (state.status != AuthStatus.authenticated) return;
      unawaited(sessionExpired());
    });
  }

  void _onAuthenticatedSessionStarted() {
    _preloadGlnPickerCatalog();
    _startCbvVocabulary();
    _ensureSharedWebSocketConnected();
  }

  void _backfillOperationalGln(User user) {
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

  void _disconnectSharedWebSocket() {
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

  void _clearSessionCaches() {
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
