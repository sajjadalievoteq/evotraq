import 'package:equatable/equatable.dart';
import 'package:traqtrace_app/data/models/home/dashboard_stats.dart';
import 'package:traqtrace_app/data/models/home/recent_event.dart';
import 'package:traqtrace_app/data/models/home/system_health_status.dart';

enum HomeLoadStatus { initial, loading, success, failure }

class HomeState extends Equatable {
  const HomeState({
    this.status = HomeLoadStatus.initial,
    this.stats,
    this.recentEvents,
    this.healthStatus,
    this.lastDataRefreshAt,
    this.errorMessage,
  });

  final HomeLoadStatus status;
  final DashboardStats? stats;
  final List<RecentEvent>? recentEvents;
  final SystemHealthStatus? healthStatus;
  /// When stats / events / health were last loaded successfully.
  final DateTime? lastDataRefreshAt;
  final String? errorMessage;

  bool get isLoading => status == HomeLoadStatus.loading;
  bool get hasError => status == HomeLoadStatus.failure;
  bool get hasPayload =>
      stats != null && recentEvents != null && healthStatus != null;

  HomeState copyWith({
    HomeLoadStatus? status,
    DashboardStats? stats,
    List<RecentEvent>? recentEvents,
    SystemHealthStatus? healthStatus,
    DateTime? lastDataRefreshAt,
    String? errorMessage,
    bool clearError = false,
  }) {
    return HomeState(
      status: status ?? this.status,
      stats: stats ?? this.stats,
      recentEvents: recentEvents ?? this.recentEvents,
      healthStatus: healthStatus ?? this.healthStatus,
      lastDataRefreshAt: lastDataRefreshAt ?? this.lastDataRefreshAt,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        stats,
        recentEvents,
        healthStatus,
        lastDataRefreshAt,
        errorMessage,
      ];
}
