import 'package:traqtrace_app/data/models/home/dashboard_stats.dart';
import 'package:traqtrace_app/data/models/home/recent_event.dart';
import 'package:traqtrace_app/data/models/home/system_health_status.dart';

class HomeOverviewSessionStore {
  HomeOverviewSessionStore({
    this.maxReuseAge = const Duration(minutes: 2),
  });

  final Duration maxReuseAge;

  HomeOverviewBundle? _bundle;

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
