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
    this.throughputHours = 24,
    this.throughputLoading = false,
    this.healthLoading = false,
    this.refreshFailed = false,
  });

  final HomeLoadStatus status;
  final DashboardStats? stats;
  final List<RecentEvent>? recentEvents;
  final SystemHealthStatus? healthStatus;
  final DateTime? lastDataRefreshAt;
  final String? errorMessage;
  final int throughputHours;
  final bool throughputLoading;
  final bool healthLoading;

  /// True when a background revalidation failed and the data currently shown is
  /// a retained (possibly stale) cached snapshot. Lets the UI surface a
  /// "couldn't refresh" hint instead of presenting stale numbers as live.
  final bool refreshFailed;

  bool get isLoading => status == HomeLoadStatus.loading;
  bool get hasError => status == HomeLoadStatus.failure;
  bool get hasPayload => stats != null && recentEvents != null;

  HomeState copyWith({
    HomeLoadStatus? status,
    DashboardStats? stats,
    List<RecentEvent>? recentEvents,
    SystemHealthStatus? healthStatus,
    DateTime? lastDataRefreshAt,
    String? errorMessage,
    bool clearError = false,
    int? throughputHours,
    bool? throughputLoading,
    bool? healthLoading,
    bool? refreshFailed,
  }) {
    return HomeState(
      status: status ?? this.status,
      stats: stats ?? this.stats,
      recentEvents: recentEvents ?? this.recentEvents,
      healthStatus: healthStatus ?? this.healthStatus,
      lastDataRefreshAt: lastDataRefreshAt ?? this.lastDataRefreshAt,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      throughputHours: throughputHours ?? this.throughputHours,
      throughputLoading: throughputLoading ?? this.throughputLoading,
      healthLoading: healthLoading ?? this.healthLoading,
      refreshFailed: refreshFailed ?? this.refreshFailed,
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
        throughputHours,
        throughputLoading,
        healthLoading,
        refreshFailed,
      ];
}
