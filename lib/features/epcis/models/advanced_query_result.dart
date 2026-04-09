class AdvancedQueryResult {
  final List<EPCISEvent> events;
  final int totalCount;
  final int returnedCount;
  final int executionTimeMs;
  final QueryExecutionMetadata? executionMetadata;
  final Map<String, dynamic>? aggregations;
  final QueryPerformanceMetrics? performanceMetrics;
  final List<String>? warnings;
  final QueryCacheInfo? cacheInfo;

  AdvancedQueryResult({
    required this.events,
    required this.totalCount,
    required this.returnedCount,
    required this.executionTimeMs,
    this.executionMetadata,
    this.aggregations,
    this.performanceMetrics,
    this.warnings,
    this.cacheInfo,
  });

  factory AdvancedQueryResult.fromJson(Map<String, dynamic> json) {
    return AdvancedQueryResult(
      events: (json['events'] as List<dynamic>?)
          ?.map((e) => EPCISEvent.fromJson(e))
          .toList() ?? [],
      totalCount: json['totalCount'] ?? 0,
      returnedCount: json['returnedCount'] ?? 0,
      executionTimeMs: json['executionTimeMs'] ?? 0,
      executionMetadata: json['executionMetadata'] != null
          ? QueryExecutionMetadata.fromJson(json['executionMetadata'])
          : null,
      aggregations: json['aggregations'],
      performanceMetrics: json['performanceMetrics'] != null
          ? QueryPerformanceMetrics.fromJson(json['performanceMetrics'])
          : null,
      warnings: json['warnings']?.cast<String>(),
      cacheInfo: json['cacheInfo'] != null
          ? QueryCacheInfo.fromJson(json['cacheInfo'])
          : null,
    );
  }
}

class QueryExecutionMetadata {
  final String? queryStartTime;
  final String? queryEndTime;
  final List<String>? tablesAccessed;
  final List<String>? indexesUsed;
  final double? complexityScore;
  final bool? wasOptimized;
  final String? queryPlanSummary;

  QueryExecutionMetadata({
    this.queryStartTime,
    this.queryEndTime,
    this.tablesAccessed,
    this.indexesUsed,
    this.complexityScore,
    this.wasOptimized,
    this.queryPlanSummary,
  });

  factory QueryExecutionMetadata.fromJson(Map<String, dynamic> json) {
    return QueryExecutionMetadata(
      queryStartTime: json['queryStartTime'],
      queryEndTime: json['queryEndTime'],
      tablesAccessed: json['tablesAccessed']?.cast<String>(),
      indexesUsed: json['indexesUsed']?.cast<String>(),
      complexityScore: json['complexityScore']?.toDouble(),
      wasOptimized: json['wasOptimized'],
      queryPlanSummary: json['queryPlanSummary'],
    );
  }
}

class QueryPerformanceMetrics {
  final int? dbQueryTimeMs;
  final int? processingTimeMs;
  final int? serializationTimeMs;
  final int? dbRoundTrips;
  final int? dataTransferredBytes;
  final int? peakMemoryUsageBytes;
  final int? cpuTimeMs;

  QueryPerformanceMetrics({
    this.dbQueryTimeMs,
    this.processingTimeMs,
    this.serializationTimeMs,
    this.dbRoundTrips,
    this.dataTransferredBytes,
    this.peakMemoryUsageBytes,
    this.cpuTimeMs,
  });

  factory QueryPerformanceMetrics.fromJson(Map<String, dynamic> json) {
    return QueryPerformanceMetrics(
      dbQueryTimeMs: json['dbQueryTimeMs'],
      processingTimeMs: json['processingTimeMs'],
      serializationTimeMs: json['serializationTimeMs'],
      dbRoundTrips: json['dbRoundTrips'],
      dataTransferredBytes: json['dataTransferredBytes'],
      peakMemoryUsageBytes: json['peakMemoryUsageBytes'],
      cpuTimeMs: json['cpuTimeMs'],
    );
  }
}

class QueryCacheInfo {
  final bool? fromCache;
  final double? cacheHitRatio;
  final String? cacheKey;
  final String? cacheExpirationTime;
  final String? cacheCreationTime;
  final int? cacheSizeBytes;

  QueryCacheInfo({
    this.fromCache,
    this.cacheHitRatio,
    this.cacheKey,
    this.cacheExpirationTime,
    this.cacheCreationTime,
    this.cacheSizeBytes,
  });

  factory QueryCacheInfo.fromJson(Map<String, dynamic> json) {
    return QueryCacheInfo(
      fromCache: json['fromCache'],
      cacheHitRatio: json['cacheHitRatio']?.toDouble(),
      cacheKey: json['cacheKey'],
      cacheExpirationTime: json['cacheExpirationTime'],
      cacheCreationTime: json['cacheCreationTime'],
      cacheSizeBytes: json['cacheSizeBytes'],
    );
  }
}

class EPCISEvent {
  final String? id;
  final String? eventType;
  final String? eventTime;
  final String? recordTime;
  final String? bizStep;
  final String? disposition;
  final String? readPoint;
  final String? bizLocation;
  final List<String>? epcList;
  final Map<String, dynamic>? additionalData;

  EPCISEvent({
    this.id,
    this.eventType,
    this.eventTime,
    this.recordTime,
    this.bizStep,
    this.disposition,
    this.readPoint,
    this.bizLocation,
    this.epcList,
    this.additionalData,
  });

  factory EPCISEvent.fromJson(Map<String, dynamic> json) {
    return EPCISEvent(
      id: json['id'],
      eventType: json['eventType'],
      eventTime: json['eventTime'],
      recordTime: json['recordTime'],
      bizStep: json['bizStep'],
      disposition: json['disposition'],
      readPoint: json['readPoint'],
      bizLocation: json['bizLocation'],
      epcList: json['epcList']?.cast<String>(),
      additionalData: json['additionalData'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eventType': eventType,
      'eventTime': eventTime,
      'recordTime': recordTime,
      'bizStep': bizStep,
      'disposition': disposition,
      'readPoint': readPoint,
      'bizLocation': bizLocation,
      'epcList': epcList,
      'additionalData': additionalData,
    };
  }
}
