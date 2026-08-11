part of 'auth_cubit.dart';

extension AuthCubitSession on AuthCubit {
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
