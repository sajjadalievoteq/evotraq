import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/data/models/home/dashboard_stats.dart';
import 'package:traqtrace_app/data/models/home/recent_event.dart';
import 'package:traqtrace_app/data/models/home/system_health_status.dart';
import 'package:traqtrace_app/data/services/home/dashboard_service.dart';
import 'package:traqtrace_app/data/session/home_overview_session_store.dart';
import 'package:traqtrace_app/features/home/cubit/home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._dashboardService, this._sessionStore)
      : super(const HomeState(status: HomeLoadStatus.loading));

  final DashboardService _dashboardService;
  final HomeOverviewSessionStore _sessionStore;

  Future<void> load({
    String? accountEmail,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      final cached = _sessionStore.readIfValidFor(accountEmail);
      if (cached != null) {
        emit(
          HomeState(
            status: HomeLoadStatus.success,
            stats: cached.stats,
            recentEvents: cached.recentEvents,
            healthStatus: cached.healthStatus,
            lastDataRefreshAt: cached.lastDataRefreshAt,
          ),
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

    try {
      final results = await Future.wait([
        _dashboardService.getStatsAndRecentEvents(recentLimit: 10),
        _dashboardService.getSystemHealth(),
      ]);

      final overview =
          results[0] as ({DashboardStats stats, List<RecentEvent> recentEvents});
      final healthStatus = results[1] as SystemHealthStatus;
      final refreshedAt = DateTime.now();
      _sessionStore.save(
        HomeOverviewBundle(
          stats: overview.stats,
          recentEvents: overview.recentEvents,
          healthStatus: healthStatus,
          lastDataRefreshAt: refreshedAt,
          accountEmail: accountEmail,
        ),
      );

      emit(
        HomeState(
          status: HomeLoadStatus.success,
          stats: overview.stats,
          recentEvents: overview.recentEvents,
          healthStatus: healthStatus,
          lastDataRefreshAt: refreshedAt,
        ),
      );
    } catch (e) {
      emit(
        HomeState(
          status: HomeLoadStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> refresh({String? accountEmail}) =>
      load(accountEmail: accountEmail, forceRefresh: true);

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
