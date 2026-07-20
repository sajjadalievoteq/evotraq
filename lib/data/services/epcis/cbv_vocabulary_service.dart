import 'dart:async';

import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';
import 'package:traqtrace_app/core/storage/cbv_vocabulary_cache_store.dart';
import 'package:traqtrace_app/data/models/epcis/cbv_vocabulary_session.dart';
import 'package:traqtrace_app/data/services/epcis/cbv_master_data_service.dart';

/// One fetch-lifecycle event emitted by [CbvVocabularyService]. `session`
/// is set on a successful (re)load; `error` is set on a failed attempt.
class CbvVocabularyFetchEvent {
  final bool isLoading;
  final CbvVocabularySession? session;
  final Object? error;

  const CbvVocabularyFetchEvent({required this.isLoading, this.session, this.error});
}

/// Owns the complete lifecycle of the CBV vocabulary: persistent caching,
/// single-flight fetching, and automatic retry-with-backoff until success.
///
/// [hydrateFromCache] may run at app boot (offline, pre-login). The network
/// fetch via [start] must only run after authentication — AuthCubit triggers
/// it on login / session restore and [reset] on logout.
class CbvVocabularyService {
  final CbvMasterDataService _masterDataService;
  final DioService _dioService;

  static const _retryDelays = [
    Duration(seconds: 5),
    Duration(seconds: 15),
    Duration(seconds: 30),
  ];
  static const _retryFloor = Duration(seconds: 60);
  static const _cacheTtl = Duration(hours: 12);

  CbvVocabularySession? _session;
  Future<CbvVocabularySession>? _inFlight;
  Timer? _retryTimer;
  Timer? _ttlTimer;
  int _attempt = 0;
  bool _networkStarted = false;
  bool _cacheHydrated = false;

  final _eventsController = StreamController<CbvVocabularyFetchEvent>.broadcast();

  CbvVocabularyService({
    required CbvMasterDataService masterDataService,
    required DioService dioService,
  })  : _masterDataService = masterDataService,
        _dioService = dioService;

  /// The most recently loaded session, if any (from cache or network).
  CbvVocabularySession? get currentSession => _session;

  /// Lifecycle events: emitted on load start, success, and failure.
  Stream<CbvVocabularyFetchEvent> get events => _eventsController.stream;

  /// Disk hydrate only — safe pre-login. Does not call the network.
  Future<void> hydrateFromCache() async {
    if (_cacheHydrated && _session != null) return;
    _cacheHydrated = true;

    final cached = await CbvVocabularyCacheStore.read();
    if (cached != null) {
      _session = cached.session;
      _eventsController.add(
        CbvVocabularyFetchEvent(isLoading: false, session: cached.session),
      );
    }
  }

  /// Starts the background network fetch (and hydrates cache if needed).
  /// No-ops if already started. Skips the network call when no auth token
  /// is present so pre-login callers never hit a secured endpoint.
  Future<void> start() async {
    await hydrateFromCache();

    if (_networkStarted) return;
    if (!await _hasAuthToken()) return;

    _networkStarted = true;
    _fireAndForget(_fetch(forceRefresh: false));
  }

  /// Cancels retries/TTL and allows [start] to run again after the next login.
  /// Keeps any in-memory/cache session for instant UI; does not clear disk.
  void reset() {
    _retryTimer?.cancel();
    _ttlTimer?.cancel();
    _retryTimer = null;
    _ttlTimer = null;
    _inFlight = null;
    _attempt = 0;
    _networkStarted = false;
  }

  /// Returns the current session immediately if one is already loaded
  /// (from cache or a prior fetch). Otherwise triggers/joins a fetch and
  /// waits up to [timeout]. A timeout never cancels the underlying fetch or
  /// the retry loop — it only stops this particular caller from waiting.
  Future<CbvVocabularySession> ensureLoaded({
    Duration timeout = const Duration(seconds: 8),
  }) async {
    if (_session != null) return _session!;

    await hydrateFromCache();
    if (_session != null) return _session!;

    if (!await _hasAuthToken()) {
      throw TimeoutException('CBV vocabulary deferred until authenticated');
    }

    try {
      return await _fetch(forceRefresh: false).timeout(timeout);
    } on TimeoutException {
      if (_session != null) return _session!;
      rethrow;
    }
  }

  /// Forces a network refresh, bypassing the cache/TTL, and resets the
  /// retry backoff. Used by admin mutations and the manual "Retry" action.
  Future<void> refresh() async {
    if (!await _hasAuthToken()) return;
    _attempt = 0;
    _retryTimer?.cancel();
    _networkStarted = true;
    await _fetch(forceRefresh: true);
  }

  Future<CbvVocabularySession> _fetch({required bool forceRefresh}) {
    final existing = _inFlight;
    if (existing != null) return existing;

    _eventsController.add(const CbvVocabularyFetchEvent(isLoading: true));

    final future = () async {
      if (!await _hasAuthToken()) {
        throw ApiException(
          statusCode: 401,
          message: 'Authentication required for CBV vocabulary',
        );
      }
      return _masterDataService.loadVocabularySession(
        forceRefresh: forceRefresh,
      );
    }()
        .then((session) {
      _retryTimer?.cancel();
      _attempt = 0;
      _session = session;
      unawaited(CbvVocabularyCacheStore.write(session));
      _eventsController.add(
        CbvVocabularyFetchEvent(isLoading: false, session: session),
      );
      _scheduleTtlRevalidation();
      return session;
    }, onError: (Object e) {
      if (_isUnauthenticatedError(e)) {
        // Defer until AuthCubit starts us again — do not retry/backoff or
        // surface a hard error for pre-auth / expired-session responses.
        _networkStarted = false;
        _retryTimer?.cancel();
        throw e;
      }
      _eventsController.add(CbvVocabularyFetchEvent(isLoading: false, error: e));
      _scheduleRetry();
      throw e;
    });

    _inFlight = future;
    future.whenComplete(() {
      if (identical(_inFlight, future)) {
        _inFlight = null;
      }
    });
    return future;
  }

  void _scheduleRetry() {
    _retryTimer?.cancel();
    final delay = _attempt < _retryDelays.length ? _retryDelays[_attempt] : _retryFloor;
    _attempt++;
    _retryTimer = Timer(delay, () => _fireAndForget(_fetch(forceRefresh: false)));
  }

  void _scheduleTtlRevalidation() {
    _ttlTimer?.cancel();
    _ttlTimer = Timer(_cacheTtl, () => _fireAndForget(_fetch(forceRefresh: true)));
  }

  Future<bool> _hasAuthToken() async {
    final token = await _dioService.getAuthToken();
    return token != null && token.isNotEmpty;
  }

  bool _isUnauthenticatedError(Object e) {
    if (e is ApiException) {
      return e.statusCode == 401 || e.statusCode == 403;
    }
    return false;
  }

  /// Runs [future] in the background, swallowing any error — failures are
  /// already reflected via [events] and drive the retry loop, so nothing
  /// here needs to surface an unhandled-exception warning.
  void _fireAndForget(Future<CbvVocabularySession> future) {
    unawaited(future.then((_) {}, onError: (_) {}));
  }

  void dispose() {
    _retryTimer?.cancel();
    _ttlTimer?.cancel();
    _eventsController.close();
  }
}
