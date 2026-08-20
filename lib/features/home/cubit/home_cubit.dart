import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/data/models/home/throughput_window.dart';
import 'package:traqtrace_app/data/services/home/dashboard_service.dart';
import 'package:traqtrace_app/data/services/websocket_service.dart';
import 'package:traqtrace_app/data/session/home_overview_session_store.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';
import 'package:traqtrace_app/features/home/cubit/home_state.dart';
import 'package:traqtrace_app/features/home/cubit/home_health_loader.dart';
import 'package:traqtrace_app/features/home/cubit/home_throughput_cache.dart';
class HomeCubit extends Cubit<HomeState> {
  HomeCubit(
    this._dashboardService,
    this._sessionStore, {
    AuthCubit? authCubit,
    WebSocketService? webSocketService,
    this.pollInterval = const Duration(seconds: 60),
  }) : _authCubit = authCubit ?? getIt<AuthCubit>(),
       _webSocketService = webSocketService ?? getIt<WebSocketService>(),
       _currentPollInterval = pollInterval,
       super(const HomeState(status: HomeLoadStatus.loading)) {
    _healthLoader = HomeHealthLoader(_dashboardService, _sessionStore);
    _initializeWebSocketListeners();
    if (_webSocketService.isConnected) {
      emit(state.copyWith(liveUpdatesConnected: true));
    }
  }

  final DashboardService _dashboardService;
  final HomeOverviewSessionStore _sessionStore;
  final AuthCubit _authCubit;
  final WebSocketService _webSocketService;
  late final HomeHealthLoader _healthLoader;

  final Duration pollInterval;

  static const Duration _maxPollBackoff = Duration(minutes: 5);

  static const int _broadcastThroughputHours = 24;

  static const List<int> _prefetchThroughputHours = [1, 168];

  StreamSubscription? _dashboardSubscription;
  StreamSubscription? _connectionSubscription;

  int _throughputPrefetchGeneration = 0;
  Timer? _pollTimer;
  Duration _currentPollInterval;
  String? _pollAccountEmail;
  bool _isRevalidating = false;
  bool _isPolling = false;

  bool get _canReadDashboard => _authCubit.state.canReadDashboard;

  bool get _canReadHealth => _authCubit.state.canReadSystemHealth;

  bool get _canReadThroughput => _authCubit.state.canReadThroughput;

  bool get isWebSocketConnected => _webSocketService.isConnected;

  Future<void> load({String? accountEmail, bool forceRefresh = false}) async {
    if (!_canReadDashboard) {
      emit(const HomeState(status: HomeLoadStatus.success));
      return;
    }
    _pollAccountEmail = accountEmail ?? _pollAccountEmail;

    if (!forceRefresh) {
      final cached = await _sessionStore.readFor(accountEmail);
      if (cached != null) {
        emit(
          HomeState(
            status: HomeLoadStatus.success,
            stats: cached.stats,
            recentEvents: cached.recentEvents,
            healthStatus: cached.healthStatus,
            lastDataRefreshAt: cached.lastDataRefreshAt,
            healthLoading: _canReadHealth,
            liveUpdatesConnected: state.liveUpdatesConnected,
            throughputHours: state.throughputHours,
            throughputByHours: state.throughputByHours,
          ),
        );

        unawaited(
          _revalidate(
            accountEmail: accountEmail,
            keepExistingOnError: true,
          ).then((_) {
            if (!isClosed) {
              _startHealthLoad(accountEmail: accountEmail);
            }
          }),
        );
        return;
      }
    } else if (state.throughputByHours.isNotEmpty) {
      // Force refresh: keep the live 24h window if present, refetch 1H/7D once.
      final kept = <int, ThroughputWindow>{
        if (state.throughputByHours.containsKey(_broadcastThroughputHours))
          _broadcastThroughputHours:
              state.throughputByHours[_broadcastThroughputHours]!,
      };
      emit(state.copyWith(throughputByHours: kept));
    }

    emit(state.copyWith(status: HomeLoadStatus.loading, clearError: true));

    await _revalidate(
      accountEmail: accountEmail,
      keepExistingOnError: forceRefresh && state.hasPayload,
    );
    if (!isClosed) {
      _startHealthLoad(accountEmail: accountEmail);
    }
  }

  /// [refreshHealth] controls whether this call re-runs the actuator health/info
  /// check. Health status doesn't ride the WebSocket heartbeat, so the
  /// reconnect-triggered resync in [_onConnectionChanged] passes `false` — it
  /// only needs to re-sync dashboard stats/recent events, and skipping the
  /// health re-check there avoids firing a redundant duplicate actuator
  /// request when the socket's first "connected" event races with the health
  /// check already kicked off by the initial [load].
  Future<void> refresh({
    String? accountEmail,
    bool refreshHealth = true,
  }) async {
    if (!_canReadDashboard) {
      emit(const HomeState(status: HomeLoadStatus.success));
      return;
    }
    _pollAccountEmail = accountEmail ?? _pollAccountEmail;

    final cached = await _sessionStore.readFor(accountEmail);
    if (cached != null || state.hasPayload) {
      if (cached != null) {
        emit(
          HomeState(
            status: HomeLoadStatus.success,
            stats: cached.stats,
            recentEvents: cached.recentEvents,
            healthStatus: cached.healthStatus ?? state.healthStatus,
            lastDataRefreshAt: cached.lastDataRefreshAt,
            healthLoading: refreshHealth && _canReadHealth,
            liveUpdatesConnected: state.liveUpdatesConnected,
          ),
        );
      } else if (refreshHealth) {
        emit(state.copyWith(healthLoading: _canReadHealth, clearError: true));
      } else {
        emit(state.copyWith(clearError: true));
      }
      await _revalidate(accountEmail: accountEmail, keepExistingOnError: true);
      if (!isClosed && refreshHealth) {
        _startHealthLoad(accountEmail: accountEmail);
      }
      return;
    }

    await load(accountEmail: accountEmail, forceRefresh: true);
  }

  /// REST fallback poll — active only while the WebSocket heartbeat is disconnected.
  void startPolling({String? accountEmail}) {
    if (isClosed || !_canReadDashboard) return;
    _pollAccountEmail = accountEmail ?? _pollAccountEmail;
    _pollTimer?.cancel();
    _isPolling = true;
    _pollTimer = Timer.periodic(_currentPollInterval, (_) => _onPollTick());
  }

  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
    _isPolling = false;
  }

  Future<void> onAppResumed({String? accountEmail}) async {
    if (isClosed || !_canReadDashboard) return;
    final email = accountEmail ?? _pollAccountEmail;
    _pollAccountEmail = email;
    _currentPollInterval = pollInterval;
    await _revalidate(accountEmail: email, keepExistingOnError: true);
    if (!isClosed && !isWebSocketConnected) {
      startPolling(accountEmail: email);
    }
  }

  // ---- WebSocket heartbeat push --------------------------------------------

  void _initializeWebSocketListeners() {
    _dashboardSubscription = _webSocketService.dashboardSummaryStream.listen(
      _onSummaryPushed,
    );
    _connectionSubscription = _webSocketService.connectionStream.listen(
      _onConnectionChanged,
    );
  }

  void connectWebSocket() {
    if (!_canReadDashboard) return;
    _webSocketService.connect();
  }

  void disconnectWebSocket() {
    // Shared socket is owned by the authenticated session (AuthCubit). Feature
    // code must only stop local fallbacks — never tear down the singleton.
    stopPolling();
  }

  void _onConnectionChanged(bool connected) {
    if (isClosed || !_canReadDashboard) return;
    emit(state.copyWith(liveUpdatesConnected: connected));
    if (connected) {
      stopPolling();
      // Immediate REST re-sync so the UI is current without waiting for the first heartbeat.
      // refreshHealth: false — the actuator health/info check isn't tied to the WebSocket
      // heartbeat, so re-running it here on every (re)connect only produces a redundant
      // duplicate call racing with the one the initial `load()` already kicked off.
      unawaited(refresh(accountEmail: _pollAccountEmail, refreshHealth: false));
    } else {
      // Enable the REST fallback poll immediately (don't wait for the first periodic tick).
      startPolling(accountEmail: _pollAccountEmail);
      _onPollTick();
    }
  }

  void _onSummaryPushed(Map<String, dynamic> payload) {
    if (isClosed || !_canReadDashboard) return;
    try {
      final parsed = DashboardService.parseSummaryPayload(payload);
      final refreshedAt = DateTime.now();
      final cache = cacheHomeBroadcastWindow(
        state.throughputByHours,
        parsed.stats,
        broadcastHours: _broadcastThroughputHours,
      );
      final stats = homeStatsForSelectedWindow(
        parsed.stats,
        cache,
        selectedHours: state.throughputHours,
        broadcastHours: _broadcastThroughputHours,
      );

      emit(
        state.copyWith(
          status: HomeLoadStatus.success,
          stats: stats,
          recentEvents: parsed.recentEvents,
          lastDataRefreshAt: refreshedAt,
          throughputByHours: cache,
          clearError: true,
          refreshFailed: false,
        ),
      );

      unawaited(
        _sessionStore.save(
          HomeOverviewBundle(
            stats: stats,
            recentEvents: parsed.recentEvents,
            healthStatus: state.healthStatus,
            lastDataRefreshAt: refreshedAt,
            accountEmail: _pollAccountEmail,
          ),
        ),
      );
    } catch (_) {
      // A malformed push must never clobber existing state; the next heartbeat or the REST
      // fallback (if disconnected) will recover.
    }
  }

  void _onPollTick() {
    if (isClosed || !_isPolling || _isRevalidating || !_canReadDashboard) {
      return;
    }

    _isRevalidating = true;
    unawaited(
      _revalidate(
        accountEmail: _pollAccountEmail,
        keepExistingOnError: true,
        adjustPollBackoff: true,
        lockAlreadyHeld: true,
      ),
    );
  }

  Future<void> _revalidate({
    required String? accountEmail,
    required bool keepExistingOnError,
    bool adjustPollBackoff = false,
    bool lockAlreadyHeld = false,
  }) async {
    if (!_canReadDashboard) return;
    if (!lockAlreadyHeld) {
      if (_isRevalidating) return;
      _isRevalidating = true;
    }
    try {
      // Summary / heartbeat always uses the broadcast window. Other ranges are
      // prefetched once and switched locally via [selectThroughputHours].
      final overview = await _dashboardService.getSummary(
        recentLimit: 5,
        throughputHours: _broadcastThroughputHours,
      );
      final refreshedAt = DateTime.now();

      if (isClosed) return;

      final cache = cacheHomeBroadcastWindow(
        state.throughputByHours,
        overview.stats,
        broadcastHours: _broadcastThroughputHours,
      );
      final stats = homeStatsForSelectedWindow(
        overview.stats,
        cache,
        selectedHours: state.throughputHours,
        broadcastHours: _broadcastThroughputHours,
      );

      emit(
        state.copyWith(
          status: HomeLoadStatus.success,
          stats: stats,
          recentEvents: overview.recentEvents,
          lastDataRefreshAt: refreshedAt,
          throughputByHours: cache,
          clearError: true,
          refreshFailed: false,
        ),
      );

      await _sessionStore.save(
        HomeOverviewBundle(
          stats: stats,
          recentEvents: overview.recentEvents,
          healthStatus: state.healthStatus,
          lastDataRefreshAt: refreshedAt,
          accountEmail: accountEmail,
        ),
      );

      if (adjustPollBackoff) {
        _restorePollInterval();
      }

      unawaited(_prefetchThroughputRanges());
    } catch (e) {
      if (isClosed) return;
      if (adjustPollBackoff) {
        _increasePollBackoff();
      }
      if (keepExistingOnError && state.hasPayload) {
        emit(state.copyWith(refreshFailed: true));
        return;
      }
      emit(
        HomeState(
          status: HomeLoadStatus.failure,
          errorMessage: e.toString(),
          liveUpdatesConnected: state.liveUpdatesConnected,
          throughputHours: state.throughputHours,
          throughputByHours: state.throughputByHours,
        ),
      );
    } finally {
      _isRevalidating = false;
    }
  }

  /// Prefetch 1H / 7D once after startup (24H comes from summary). Range toggles
  /// only read [HomeState.throughputByHours] — they do not hit the network.
  Future<void> _prefetchThroughputRanges() async {
    if (isClosed || !_canReadThroughput || state.stats == null) return;

    final missing = _prefetchThroughputHours
        .where((hours) => !state.throughputByHours.containsKey(hours))
        .toList(growable: false);
    if (missing.isEmpty) return;

    final generation = ++_throughputPrefetchGeneration;
    final fetched = <int, ThroughputWindow>{};
    await Future.wait(
      missing.map((hours) async {
        try {
          final result = await _dashboardService.fetchThroughput(hours);
          fetched[hours] = ThroughputWindow(
            buckets: result.buckets,
            total: result.total,
          );
        } catch (_) {
          // Leave the window absent; a later force refresh can retry.
        }
      }),
    );

    if (isClosed || generation != _throughputPrefetchGeneration) return;
    if (fetched.isEmpty) return;

    final cache = Map<int, ThroughputWindow>.from(state.throughputByHours)
      ..addAll(fetched);
    if (state.stats != null) {
      cache[_broadcastThroughputHours] = ThroughputWindow(
        buckets: Map<int, int>.from(
          cache[_broadcastThroughputHours]?.buckets ??
              state.stats!.throughputBuckets,
        ),
        total:
            cache[_broadcastThroughputHours]?.total ??
            state.stats!.throughputTotal,
      );
    }

    final selected = state.throughputHours;
    final selectedWindow = cache[selected];
    emit(
      state.copyWith(
        throughputByHours: cache,
        stats: selectedWindow == null || state.stats == null
            ? state.stats
            : state.stats!.copyWithThroughput(
                buckets: selectedWindow.buckets,
                total: selectedWindow.total,
              ),
        throughputLoading: false,
      ),
    );
  }

  void _restorePollInterval() {
    if (_currentPollInterval == pollInterval) return;
    _currentPollInterval = pollInterval;
    if (_isPolling && !isClosed) {
      startPolling(accountEmail: _pollAccountEmail);
    }
  }

  void _increasePollBackoff() {
    final doubled = _currentPollInterval * 2;
    _currentPollInterval = doubled > _maxPollBackoff
        ? _maxPollBackoff
        : doubled;
    if (_isPolling && !isClosed) {
      startPolling(accountEmail: _pollAccountEmail);
    }
  }

  void _startHealthLoad({String? accountEmail}) {
    _healthLoader.load(
      accountEmail: accountEmail,
      canReadHealth: _canReadHealth,
      isClosed: () => isClosed,
      currentState: () => state,
      emitState: emit,
    );
  }

  /// Switch the visible throughput range using startup-prefetched windows only.
  void selectThroughputHours(int hours) {
    if (!_canReadThroughput || state.stats == null) return;
    if (hours == state.throughputHours) return;

    final cached = state.throughputByHours[hours];
    if (cached == null) {
      emit(state.copyWith(throughputHours: hours));
      return;
    }

    emit(
      state.copyWith(
        throughputHours: hours,
        stats: state.stats!.copyWithThroughput(
          buckets: cached.buckets,
          total: cached.total,
        ),
        throughputLoading: false,
      ),
    );
  }

  @override
  Future<void> close() {
    stopPolling();
    _dashboardSubscription?.cancel();
    _dashboardSubscription = null;
    _connectionSubscription?.cancel();
    _connectionSubscription = null;
    // Never disconnect the shared WebSocketService singleton here — other features may still
    // be using it.
    return super.close();
  }
}
