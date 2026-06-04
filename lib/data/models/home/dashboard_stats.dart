/// Dashboard statistics for home / operations overview.
class DashboardStats {
  final int gtinCount;
  final int glnCount;
  final int sgtinCount;
  final int ssccCount;
  final int totalEvents;
  final Map<String, int> eventsByType;

  /// Per-hour commissioning throughput for the last 24 h.
  /// Key = hourIndex (0 = oldest, 23 = current hour), value = items commissioned.
  final Map<int, int> throughputBuckets;

  /// Total items commissioned in the last 24 h.
  final int throughputTotal;

  DashboardStats({
    required this.gtinCount,
    required this.glnCount,
    required this.sgtinCount,
    required this.ssccCount,
    required this.totalEvents,
    required this.eventsByType,
    this.throughputBuckets = const {},
    this.throughputTotal = 0,
  });

  DashboardStats copyWithThroughput({
    required Map<int, int> buckets,
    required int total,
  }) {
    return DashboardStats(
      gtinCount: gtinCount,
      glnCount: glnCount,
      sgtinCount: sgtinCount,
      ssccCount: ssccCount,
      totalEvents: totalEvents,
      eventsByType: eventsByType,
      throughputBuckets: buckets,
      throughputTotal: total,
    );
  }
}
