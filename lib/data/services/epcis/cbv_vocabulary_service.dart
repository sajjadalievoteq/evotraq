import 'dart:async';

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
/// This exists so the splash screen no longer has to block navigation on
/// loading the vocabulary — [start] is called once, non-blocking, at app
/// boot, and the vocabulary becomes available (from cache, then from the
/// network) independently of routing. [CbvVocabularyCubit] wraps this
/// service to keep its existing public API/consumers unchanged.
class CbvVocabularyService {
  final CbvMasterDataService _masterDataService;

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
  bool _started = false;

  final _eventsController = StreamController<CbvVocabularyFetchEvent>.broadcast();

  CbvVocabularyService({required CbvMasterDataService masterDataService})
      : _masterDataService = masterDataService;

  /// The most recently loaded session, if any (from cache or network).
  CbvVocabularySession? get currentSession => _session;

  /// Lifecycle events: emitted on load start, success, and failure.
  Stream<CbvVocabularyFetchEvent> get events => _eventsController.stream;

  /// Call once at app boot. Hydrates from the persistent cache (fast) and
  /// kicks off a background network fetch (not awaited) to refresh/populate
  /// the vocabulary. Safe to call more than once — subsequent calls are a
  /// no-op if already started.
  Future<void> start() async {
    if (_started) return;
    _started = true;

    final cached = await CbvVocabularyCacheStore.read();
    if (cached != null) {
      _session = cached.session;
      _eventsController.add(CbvVocabularyFetchEvent(isLoading: false, session: cached.session));
    }

    _fireAndForget(_fetch(forceRefresh: false));
  }

  /// Returns the current session immediately if one is already loaded
  /// (from cache or a prior fetch). Otherwise triggers/joins a fetch and
  /// waits up to [timeout]. A timeout never cancels the underlying fetch or
  /// the retry loop — it only stops this particular caller from waiting.
  Future<CbvVocabularySession> ensureLoaded({
    Duration timeout = const Duration(seconds: 8),
  }) async {
    if (_session != null) return _session!;

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
    _attempt = 0;
    _retryTimer?.cancel();
    await _fetch(forceRefresh: true);
  }

  Future<CbvVocabularySession> _fetch({required bool forceRefresh}) {
    final existing = _inFlight;
    if (existing != null) return existing;

    _eventsController.add(const CbvVocabularyFetchEvent(isLoading: true));

    final future = _masterDataService
        .loadVocabularySession(forceRefresh: forceRefresh)
        .then((session) {
      _retryTimer?.cancel();
      _attempt = 0;
      _session = session;
      unawaited(CbvVocabularyCacheStore.write(session));
      _eventsController.add(CbvVocabularyFetchEvent(isLoading: false, session: session));
      _scheduleTtlRevalidation();
      return session;
    }, onError: (Object e) {
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
