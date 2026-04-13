import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/features/dashboard/cubit/dashboard_state.dart';


import '../../../data/services/dashboard_service.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final DashboardService _dashboardService;

  DashboardCubit(this._dashboardService) : super(DashboardInitial());

  Future<void> loadDashboard(String? userEmail) async {
    final currentState = state;
    
    // Check if we already have valid data for the current user
    if (currentState is DashboardLoaded && currentState.ownerEmail == userEmail) {
      // Data is already loaded for this user, no need to show loading unless refreshing
      return;
    }

    emit(DashboardLoading());

    try {
      final results = await Future.wait([
        _dashboardService.getDashboardStats(),
        _dashboardService.getRecentEvents(limit: 5),
        _dashboardService.getSystemHealth(),
      ]);

      emit(DashboardLoaded(
        stats: results[0] as DashboardStats,
        recentEvents: results[1] as List<RecentEvent>,
        healthStatus: results[2] as SystemHealthStatus,
        ownerEmail: userEmail,
      ));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }

  Future<void> refreshDashboard(String? userEmail) async {
    // Similar to loadDashboard but always emits loading first if desired, 
    // or just updates the state after fetch
    try {
      final results = await Future.wait([
        _dashboardService.getDashboardStats(),
        _dashboardService.getRecentEvents(limit: 5),
        _dashboardService.getSystemHealth(),
      ]);

      emit(DashboardLoaded(
        stats: results[0] as DashboardStats,
        recentEvents: results[1] as List<RecentEvent>,
        healthStatus: results[2] as SystemHealthStatus,
        ownerEmail: userEmail,
      ));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }

  void clearDashboard() {
    emit(DashboardInitial());
  }
}
