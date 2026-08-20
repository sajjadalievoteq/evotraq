import 'package:traqtrace_app/data/models/home/dashboard_stats.dart';
import 'package:traqtrace_app/data/models/home/throughput_window.dart';

Map<int, ThroughputWindow> cacheHomeBroadcastWindow(
  Map<int, ThroughputWindow> existing,
  DashboardStats broadcastStats, {
  required int broadcastHours,
}) {
  return Map<int, ThroughputWindow>.from(existing)
    ..[broadcastHours] = ThroughputWindow(
      buckets: Map<int, int>.from(broadcastStats.throughputBuckets),
      total: broadcastStats.throughputTotal,
    );
}

DashboardStats homeStatsForSelectedWindow(
  DashboardStats broadcastStats,
  Map<int, ThroughputWindow> cache, {
  required int selectedHours,
  required int broadcastHours,
}) {
  if (selectedHours == broadcastHours) return broadcastStats;
  final selected = cache[selectedHours];
  if (selected == null) return broadcastStats;
  return broadcastStats.copyWithThroughput(
    buckets: selected.buckets,
    total: selected.total,
  );
}
