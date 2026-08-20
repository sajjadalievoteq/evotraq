import 'package:traqtrace_app/data/services/home/dashboard_service.dart';
import 'package:traqtrace_app/data/session/home_overview_session_store.dart';
import 'package:traqtrace_app/features/home/cubit/home_state.dart';

class HomeHealthLoader {
  HomeHealthLoader(this._dashboardService, this._sessionStore);

  final DashboardService _dashboardService;
  final HomeOverviewSessionStore _sessionStore;
  int _generation = 0;

  Future<void> load({
    required String? accountEmail,
    required bool canReadHealth,
    required bool Function() isClosed,
    required HomeState Function() currentState,
    required void Function(HomeState state) emitState,
  }) async {
    if (!canReadHealth) {
      if (!isClosed() && currentState().healthLoading) {
        emitState(currentState().copyWith(healthLoading: false));
      }
      return;
    }
    final generation = ++_generation;
    if (isClosed()) return;
    emitState(currentState().copyWith(healthLoading: true));
    try {
      final healthStatus = await _dashboardService.getSystemHealth();
      if (isClosed() || generation != _generation) return;
      emitState(
        currentState().copyWith(
          healthStatus: healthStatus,
          healthLoading: false,
        ),
      );
      final state = currentState();
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
      if (isClosed() || generation != _generation) return;
      emitState(currentState().copyWith(healthLoading: false));
    }
  }
}
