import 'package:traqtrace_app/data/services/dashboard_service.dart';

/// In-memory dashboard payload for [HomeDashboardCubit] / [HomeScreen] (cleared on logout).
class HomeDashboardCache {
  static DashboardStats? stats;
  static List<RecentEvent>? recentEvents;
  static SystemHealthStatus? healthStatus;
  static String? ownerEmail;
  /// When [setData] last ran after a successful dashboard fetch.
  static DateTime? dashboardDataRefreshedAt;

  static bool get hasData =>
      stats != null && recentEvents != null && healthStatus != null;

  static void clear() {
    stats = null;
    recentEvents = null;
    healthStatus = null;
    ownerEmail = null;
    dashboardDataRefreshedAt = null;
  }

  static void setData({
    required DashboardStats stats,
    required List<RecentEvent> recentEvents,
    required SystemHealthStatus healthStatus,
    required String? ownerEmail,
    required DateTime dashboardDataRefreshedAt,
  }) {
    HomeDashboardCache.stats = stats;
    HomeDashboardCache.recentEvents = recentEvents;
    HomeDashboardCache.healthStatus = healthStatus;
    HomeDashboardCache.ownerEmail = ownerEmail;
    HomeDashboardCache.dashboardDataRefreshedAt = dashboardDataRefreshedAt;
  }
}
