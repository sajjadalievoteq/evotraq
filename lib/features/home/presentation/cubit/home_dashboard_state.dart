import 'package:equatable/equatable.dart';
import 'package:traqtrace_app/data/services/dashboard_service.dart';
import 'package:traqtrace_app/features/home/home_dashboard_cache.dart';

enum HomeDashboardLoadStatus { initial, loading, success, failure }

class HomeDashboardState extends Equatable {
  const HomeDashboardState({
    this.status = HomeDashboardLoadStatus.initial,
    this.stats,
    this.recentEvents,
    this.healthStatus,
    this.dashboardDataRefreshedAt,
    this.errorMessage,
  });

  factory HomeDashboardState.initialFromCache() {
    if (HomeDashboardCache.hasData) {
      return HomeDashboardState(
        status: HomeDashboardLoadStatus.success,
        stats: HomeDashboardCache.stats,
        recentEvents: HomeDashboardCache.recentEvents,
        healthStatus: HomeDashboardCache.healthStatus,
        dashboardDataRefreshedAt: HomeDashboardCache.dashboardDataRefreshedAt,
      );
    }
    return const HomeDashboardState(
      status: HomeDashboardLoadStatus.loading,
    );
  }

  final HomeDashboardLoadStatus status;
  final DashboardStats? stats;
  final List<RecentEvent>? recentEvents;
  final SystemHealthStatus? healthStatus;
  /// Clock time when stats / events / health were last loaded successfully.
  final DateTime? dashboardDataRefreshedAt;
  final String? errorMessage;

  bool get isLoading => status == HomeDashboardLoadStatus.loading;
  bool get hasError => status == HomeDashboardLoadStatus.failure;
  bool get hasPayload =>
      stats != null && recentEvents != null && healthStatus != null;

  HomeDashboardState copyWith({
    HomeDashboardLoadStatus? status,
    DashboardStats? stats,
    List<RecentEvent>? recentEvents,
    SystemHealthStatus? healthStatus,
    DateTime? dashboardDataRefreshedAt,
    String? errorMessage,
    bool clearError = false,
  }) {
    return HomeDashboardState(
      status: status ?? this.status,
      stats: stats ?? this.stats,
      recentEvents: recentEvents ?? this.recentEvents,
      healthStatus: healthStatus ?? this.healthStatus,
      dashboardDataRefreshedAt:
          dashboardDataRefreshedAt ?? this.dashboardDataRefreshedAt,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        stats,
        recentEvents,
        healthStatus,
        dashboardDataRefreshedAt,
        errorMessage,
      ];
}
