import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/data/services/dashboard_service.dart';
import 'package:traqtrace_app/features/home/home_dashboard_cache.dart';
import 'package:traqtrace_app/features/home/presentation/cubit/home_dashboard_state.dart';

class HomeDashboardCubit extends Cubit<HomeDashboardState> {
  HomeDashboardCubit(this._dashboardService)
      : super(HomeDashboardState.initialFromCache());

  final DashboardService _dashboardService;

  /// Loads from cache when valid, otherwise fetches dashboard APIs.
  Future<void> load({String? ownerEmail}) async {
    if (ownerEmail != null &&
        HomeDashboardCache.ownerEmail != null &&
        HomeDashboardCache.ownerEmail != ownerEmail) {
      HomeDashboardCache.clear();
    }

    if (HomeDashboardCache.hasData) {
      emit(
        HomeDashboardState(
          status: HomeDashboardLoadStatus.success,
          stats: HomeDashboardCache.stats,
          recentEvents: HomeDashboardCache.recentEvents,
          healthStatus: HomeDashboardCache.healthStatus,
          dashboardDataRefreshedAt: HomeDashboardCache.dashboardDataRefreshedAt,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: HomeDashboardLoadStatus.loading,
        clearError: true,
      ),
    );

    try {
      final results = await Future.wait([
        _dashboardService.getDashboardStats(),
        _dashboardService.getRecentEvents(limit: 5),
        _dashboardService.getSystemHealth(),
      ]);

      final stats = results[0] as DashboardStats;
      final recentEvents = results[1] as List<RecentEvent>;
      final healthStatus = results[2] as SystemHealthStatus;
      final refreshedAt = DateTime.now();

      HomeDashboardCache.setData(
        stats: stats,
        recentEvents: recentEvents,
        healthStatus: healthStatus,
        ownerEmail: ownerEmail,
        dashboardDataRefreshedAt: refreshedAt,
      );

      emit(
        HomeDashboardState(
          status: HomeDashboardLoadStatus.success,
          stats: stats,
          recentEvents: recentEvents,
          healthStatus: healthStatus,
          dashboardDataRefreshedAt: refreshedAt,
        ),
      );
    } catch (e) {
      emit(
        HomeDashboardState(
          status: HomeDashboardLoadStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> refresh({String? ownerEmail}) async {
    HomeDashboardCache.clear();
    await load(ownerEmail: ownerEmail);
  }
}
