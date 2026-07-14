class DashboardStats {
  final int gtinCount;
  final int glnCount;
  final int sgtinCount;
  final int ssccCount;
  final int totalEvents;
  final Map<String, int> eventsByType;

  final Map<int, int> throughputBuckets;

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

  factory DashboardStats.fromSummaryJson(Map<String, dynamic> json) {
    final counts = json['counts'] as Map<String, dynamic>? ?? const {};
    final eventCounts = json['eventCounts'] as Map<String, dynamic>? ?? const {};
    final throughput = json['throughput'] as Map<String, dynamic>? ?? const {};

    final eventsByType = <String, int>{
      'Object': _asInt(eventCounts['Object']),
      'Aggregation': _asInt(eventCounts['Aggregation']),
      'Transaction': _asInt(eventCounts['Transaction']),
      'Transformation': _asInt(eventCounts['Transformation']),
    };

    final rawBuckets = throughput['buckets'] as List<dynamic>? ?? const [];
    final buckets = <int, int>{};
    for (final b in rawBuckets) {
      if (b is! Map) continue;
      final idx = (b['hourIndex'] as num?)?.toInt();
      final count = (b['count'] as num?)?.toInt();
      if (idx == null || count == null) continue;
      buckets[idx] = count;
    }

    return DashboardStats(
      gtinCount: _asInt(counts['gtin']),
      glnCount: _asInt(counts['gln']),
      sgtinCount: _asInt(counts['sgtin']),
      ssccCount: _asInt(counts['sscc']),
      totalEvents: _asInt(eventCounts['totalEvents']),
      eventsByType: eventsByType,
      throughputBuckets: buckets,
      throughputTotal: _asInt(throughput['totalCount']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gtinCount': gtinCount,
      'glnCount': glnCount,
      'sgtinCount': sgtinCount,
      'ssccCount': ssccCount,
      'totalEvents': totalEvents,
      'eventsByType': eventsByType,
      'throughputBuckets': {
        for (final e in throughputBuckets.entries) e.key.toString(): e.value,
      },
      'throughputTotal': throughputTotal,
    };
  }

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    final rawBuckets = json['throughputBuckets'] as Map<String, dynamic>? ?? {};
    final buckets = <int, int>{};
    rawBuckets.forEach((key, value) {
      final idx = int.tryParse(key);
      if (idx == null) return;
      buckets[idx] = _asInt(value);
    });

    final rawTypes = json['eventsByType'] as Map<String, dynamic>? ?? {};
    final eventsByType = <String, int>{
      for (final e in rawTypes.entries) e.key: _asInt(e.value),
    };

    return DashboardStats(
      gtinCount: _asInt(json['gtinCount']),
      glnCount: _asInt(json['glnCount']),
      sgtinCount: _asInt(json['sgtinCount']),
      ssccCount: _asInt(json['ssccCount']),
      totalEvents: _asInt(json['totalEvents']),
      eventsByType: eventsByType,
      throughputBuckets: buckets,
      throughputTotal: _asInt(json['throughputTotal']),
    );
  }

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

  static int _asInt(Object? value) {
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
