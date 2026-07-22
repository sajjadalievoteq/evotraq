import 'dart:async';

import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';
import 'package:traqtrace_app/core/storage/cbv_vocabulary_cache_store.dart';
import 'package:traqtrace_app/data/models/epcis/cbv_vocabulary_session.dart';
import 'package:traqtrace_app/data/services/epcis/cbv_master_data_service.dart';



class CbvVocabularyFetchEvent {
  final bool isLoading;
  final CbvVocabularySession? session;
  final Object? error;

  const CbvVocabularyFetchEvent({required this.isLoading, this.session, this.error});
}







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

  
  CbvVocabularySession? get currentSession => _session;

  
  Stream<CbvVocabularyFetchEvent> get events => _eventsController.stream;

  
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

  
  
  
  Future<void> start() async {
    await hydrateFromCache();

    if (_networkStarted) return;
    if (!await _hasAuthToken()) return;

    _networkStarted = true;
    _fireAndForget(_fetch(forceRefresh: false));
  }

  
  
  void reset() {
    _retryTimer?.cancel();
    _ttlTimer?.cancel();
    _retryTimer = null;
    _ttlTimer = null;
    _inFlight = null;
    _attempt = 0;
    _networkStarted = false;
  }

  
  
  
  
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

  
  
  
  void _fireAndForget(Future<CbvVocabularySession> future) {
    unawaited(future.then((_) {}, onError: (_) {}));
  }

  void dispose() {
    _retryTimer?.cancel();
    _ttlTimer?.cancel();
    _eventsController.close();
  }
}
