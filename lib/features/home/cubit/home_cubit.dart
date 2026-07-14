import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/data/services/home/dashboard_service.dart';
import 'package:traqtrace_app/data/session/home_overview_session_store.dart';
import 'package:traqtrace_app/features/home/cubit/home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._dashboardService, this._sessionStore)
      : super(const HomeState(status: HomeLoadStatus.loading));

  final DashboardService _dashboardService;
  final HomeOverviewSessionStore _sessionStore;
  int _healthLoadGeneration = 0;

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
        // Revalidate in background — do not block the return of load().
        _revalidate(
          accountEmail: accountEmail,
          keepExistingOnError: true,
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
      return;
    }

    await load(accountEmail: accountEmail, forceRefresh: true);
  }

  Future<void> _revalidate({
    required String? accountEmail,
    required bool keepExistingOnError,
  }) async {
    try {
      final overview = await _dashboardService.getSummary(
        recentLimit: 10,
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
          healthLoading: true,
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

      _startHealthLoad(accountEmail: accountEmail);
    } catch (e) {
      if (isClosed) return;
      if (keepExistingOnError && state.hasPayload) {
        // Revalidation failed but we have a cached snapshot to keep showing.
        // Flag it so the UI can indicate the numbers may be stale instead of
        // presenting a retained (possibly zero) snapshot as live data.
        emit(state.copyWith(healthLoading: false, refreshFailed: true));
        _startHealthLoad(accountEmail: accountEmail);
        return;
      }
      emit(
        HomeState(
          status: HomeLoadStatus.failure,
          errorMessage: e.toString(),
        ),
      );
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
}
