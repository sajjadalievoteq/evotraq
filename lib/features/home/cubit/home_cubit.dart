import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/data/services/home/dashboard_service.dart';
import 'package:traqtrace_app/data/session/home_overview_session_store.dart';
import 'package:traqtrace_app/features/home/cubit/home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(
    this._dashboardService,
    this._sessionStore, {
    this.pollInterval = const Duration(seconds: 60),
  })  : _currentPollInterval = pollInterval,
        super(const HomeState(status: HomeLoadStatus.loading));

  final DashboardService _dashboardService;
  final HomeOverviewSessionStore _sessionStore;

  
  final Duration pollInterval;

  static const Duration _maxPollBackoff = Duration(minutes: 5);

  int _healthLoadGeneration = 0;
  Timer? _pollTimer;
  Duration _currentPollInterval;
  String? _pollAccountEmail;
  bool _isRevalidating = false;
  bool _isPolling = false;

  Future<void> load({
    String? accountEmail,
    bool forceRefresh = false,
  }) async {
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
            healthLoading: true,
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

    emit(
      state.copyWith(
        status: HomeLoadStatus.loading,
        clearError: true,
      ),
    );

    await _revalidate(
      accountEmail: accountEmail,
      keepExistingOnError: forceRefresh && state.hasPayload,
    );
    if (!isClosed) {
      _startHealthLoad(accountEmail: accountEmail);
    }
  }

  Future<void> refresh({String? accountEmail}) async {
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
            healthLoading: true,
          ),
        );
      } else {
        emit(state.copyWith(healthLoading: true, clearError: true));
      }
      await _revalidate(
        accountEmail: accountEmail,
        keepExistingOnError: true,
      );
      if (!isClosed) {
        _startHealthLoad(accountEmail: accountEmail);
      }
      return;
    }

    await load(accountEmail: accountEmail, forceRefresh: true);
  }

  
  void startPolling({String? accountEmail}) {
    if (isClosed) return;
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
    if (isClosed) return;
    final email = accountEmail ?? _pollAccountEmail;
    _currentPollInterval = pollInterval;
    await _revalidate(
      accountEmail: email,
      keepExistingOnError: true,
    );
    if (!isClosed) {
      startPolling(accountEmail: email);
    }
  }

  void _onPollTick() {
    if (isClosed || !_isPolling || _isRevalidating) return;
    
    
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
    _currentPollInterval =
        doubled > _maxPollBackoff ? _maxPollBackoff : doubled;
    if (_isPolling && !isClosed) {
      startPolling(accountEmail: _pollAccountEmail);
    }
  }

  void _startHealthLoad({String? accountEmail}) {
    final generation = ++_healthLoadGeneration;
    _loadHealthInBackground(
      accountEmail: accountEmail,
      generation: generation,
    );
  }

  Future<void> _loadHealthInBackground({
    required String? accountEmail,
    required int generation,
  }) async {
    if (isClosed) return;
    emit(state.copyWith(healthLoading: true));
    try {
      final healthStatus = await _dashboardService.getSystemHealth();
      if (isClosed || generation != _healthLoadGeneration) return;

      emit(
        state.copyWith(
          healthStatus: healthStatus,
          healthLoading: false,
        ),
      );

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
    emit(state.copyWith(throughputHours: hours, throughputLoading: true));
    try {
      final result = await _dashboardService.fetchThroughput(hours);
      if (state.stats == null) {
        emit(state.copyWith(throughputLoading: false));
        return;
      }
      emit(state.copyWith(
        stats: state.stats!.copyWithThroughput(
          buckets: result.buckets,
          total: result.total,
        ),
        throughputLoading: false,
      ));
    } catch (_) {
      emit(state.copyWith(throughputLoading: false));
    }
  }

  @override
  Future<void> close() {
    stopPolling();
    return super.close();
  }
}
