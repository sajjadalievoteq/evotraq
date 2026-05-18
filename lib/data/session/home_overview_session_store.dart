import 'package:traqtrace_app/data/models/home/dashboard_stats.dart';
import 'package:traqtrace_app/data/models/home/recent_event.dart';
import 'package:traqtrace_app/data/models/home/system_health_status.dart';

/// Last successful home overview for the current app session.
///
/// Scoped to [accountEmail] so a different signed-in user never sees stale
/// data. Cleared on logout via [clear].
class HomeOverviewSessionStore {
  HomeOverviewSessionStore({
    this.maxReuseAge = const Duration(minutes: 2),
  });

  /// In-memory reuse only while younger than this (pull-to-refresh ignores it).
  final Duration maxReuseAge;

  HomeOverviewBundle? _bundle;

  /// Returns the last bundle only when [accountEmail] matches the stored
  /// identity (both must be non-null and equal) and data is not older than
  /// [maxReuseAge].
  HomeOverviewBundle? readIfValidFor(String? accountEmail) {
    final b = _bundle;
    if (b == null) return null;
    if (accountEmail == null || b.accountEmail == null) return null;
    if (accountEmail != b.accountEmail) return null;
    if (DateTime.now().difference(b.lastDataRefreshAt) > maxReuseAge) {
      return null;
    }
    return b;
  }

  void save(HomeOverviewBundle bundle) {
    _bundle = bundle;
  }

  void clear() {
    _bundle = null;
  }
}

class HomeOverviewBundle {
  const HomeOverviewBundle({
    required this.stats,
    required this.recentEvents,
    required this.healthStatus,
    required this.lastDataRefreshAt,
    required this.accountEmail,
  });

  final DashboardStats stats;
  final List<RecentEvent> recentEvents;
  final SystemHealthStatus healthStatus;
  final DateTime lastDataRefreshAt;
  final String? accountEmail;
}
