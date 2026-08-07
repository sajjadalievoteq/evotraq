import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/data/services/home/dashboard_service.dart';
import 'package:traqtrace_app/data/services/websocket_service.dart';
import 'package:traqtrace_app/data/session/home_overview_session_store.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';
import 'package:traqtrace_app/features/home/cubit/home_state.dart';

/// Drives the Home dashboard from an initial REST load plus a live WebSocket heartbeat push.
///
/// The backend recomputes the summary on a fixed interval and broadcasts it to every connected
/// client (see `DashboardSummaryBroadcaster`) instead of each client polling REST on its own
/// timer. REST is used only for: the initial load, an immediate re-sync on (re)connect, and a
/// fallback poll while the socket is disconnected — mirroring JobQueueCubit's reconnect model.
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
    _initializeWebSocketListeners();
    if (_webSocketService.isConnected) {
      emit(state.copyWith(liveUpdatesConnected: true));
    }
  }

  final DashboardService _dashboardService;
  final HomeOverviewSessionStore _sessionStore;
  final AuthCubit _authCubit;
  final WebSocketService _webSocketService;

  final Duration pollInterval;

  static const Duration _maxPollBackoff = Duration(minutes: 5);

  // The backend heartbeat always broadcasts this throughput window (DashboardSummaryBroadcaster).
  // If the user has selected a different one, a push must not clobber their selected view.
  static const int _broadcastThroughputHours = 24;

  StreamSubscription? _dashboardSubscription;
  StreamSubscription? _connectionSubscription;

  int _healthLoadGeneration = 0;
  Timer? _pollTimer;
  Duration _currentPollInterval;
  String? _pollAccountEmail;
  bool _isRevalidating = false;
  bool _isPolling = false;

  bool get _canReadDashboard => _authCubit.state.canReadDashboard;

  bool get _canReadHealth => _authCubit.state.canReadSystemHealth;

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

  Future<void> refresh({String? accountEmail}) async {
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
            healthLoading: _canReadHealth,
            liveUpdatesConnected: state.liveUpdatesConnected,
          ),
        );
      } else {
        emit(state.copyWith(healthLoading: _canReadHealth, clearError: true));
      }
      await _revalidate(accountEmail: accountEmail, keepExistingOnError: true);
      if (!isClosed) {
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
      unawaited(refresh(accountEmail: _pollAccountEmail));
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

      // The broadcast always uses the default throughput window; if the user picked a
      // different one, keep their existing throughput data and only refresh the rest.
      final stats =
          (state.throughputHours == _broadcastThroughputHours ||
              state.stats == null)
          ? parsed.stats
          : parsed.stats.copyWithThroughput(
              buckets: state.stats!.throughputBuckets,
              total: state.stats!.throughputTotal,
            );

      emit(
        state.copyWith(
          status: HomeLoadStatus.success,
          stats: stats,
          recentEvents: parsed.recentEvents,
          lastDataRefreshAt: refreshedAt,
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
      final overview = await _dashboardService.getSummary(
        recentLimit: 5,
        throughputHours: state.throughputHours,
      );
      final refreshedAt = DateTime.now();

      if (isClosed) return;

      emit(
        state.copyWith(
          status: HomeLoadStatus.success,
          stats: overview.stats,
          recentEvents: overview.recentEvents,
          lastDataRefreshAt: refreshedAt,
          clearError: true,
          refreshFailed: false,
        ),
      );

      await _sessionStore.save(
        HomeOverviewBundle(
          stats: overview.stats,
          recentEvents: overview.recentEvents,
          healthStatus: state.healthStatus,
          lastDataRefreshAt: refreshedAt,
          accountEmail: accountEmail,
        ),
      );

      if (adjustPollBackoff) {
        _restorePollInterval();
      }
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
        ),
      );
    } finally {
      _isRevalidating = false;
    }
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
    if (!_canReadHealth) {
      if (!isClosed && state.healthLoading) {
        emit(state.copyWith(healthLoading: false));
      }
      return;
    }
    final generation = ++_healthLoadGeneration;
    _loadHealthInBackground(accountEmail: accountEmail, generation: generation);
  }

  Future<void> _loadHealthInBackground({
    required String? accountEmail,
    required int generation,
  }) async {
    if (isClosed || !_canReadHealth) return;
    emit(state.copyWith(healthLoading: true));
    try {
      final healthStatus = await _dashboardService.getSystemHealth();
      if (isClosed || generation != _healthLoadGeneration) return;

      emit(state.copyWith(healthStatus: healthStatus, healthLoading: false));

      if (state.stats != null && state.recentEvents != null) {
        await _sessionStore.save(
          HomeOverviewBundle(
            stats: state.stats!,
            recentEvents: state.recentEvents!,
            healthStatus: healthStatus,
            lastDataRefreshAt: state.lastDataRefreshAt ?? DateTime.now(),
            accountEmail: accountEmail,
          ),
        );
      }
    } catch (_) {
      if (isClosed || generation != _healthLoadGeneration) return;
      emit(state.copyWith(healthLoading: false));
    }
  }

  Future<void> loadThroughput(int hours) async {
    if (!_authCubit.state.canReadThroughput) return;
    emit(state.copyWith(throughputHours: hours, throughputLoading: true));
    try {
      final result = await _dashboardService.fetchThroughput(hours);
      if (state.stats == null) {
        emit(state.copyWith(throughputLoading: false));
        return;
      }
      emit(
        state.copyWith(
          stats: state.stats!.copyWithThroughput(
            buckets: result.buckets,
            total: result.total,
          ),
          throughputLoading: false,
        ),
      );
    } catch (_) {
      emit(state.copyWith(throughputLoading: false));
    }
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
