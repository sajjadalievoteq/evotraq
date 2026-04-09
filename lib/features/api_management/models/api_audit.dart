/// API audit log entry for partner access tracking
class ApiAuditLog {
  final String id;
  final String requestId;
  final String method;
  final String path;
  final String? query;
  final int status;
  final int processingTimeMs;
  final String? clientIp;
  final DateTime timestamp;
  final String? error;

  ApiAuditLog({
    required this.id,
    required this.requestId,
    required this.method,
    required this.path,
    this.query,
    required this.status,
    required this.processingTimeMs,
    this.clientIp,
    required this.timestamp,
    this.error,
  });

  factory ApiAuditLog.fromJson(Map<String, dynamic> json) {
    return ApiAuditLog(
      id: json['id'] ?? '',
      requestId: json['requestId'] ?? '',
      method: json['method'] ?? 'GET',
      path: json['path'] ?? '',
      query: json['query'],
      status: json['status'] ?? 0,
      processingTimeMs: json['processingTimeMs'] ?? 0,
      clientIp: json['clientIp'],
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp']) 
          : DateTime.now(),
      error: json['error'],
    );
  }

  bool get isSuccess => status >= 200 && status < 300;
  bool get isClientError => status >= 400 && status < 500;
  bool get isServerError => status >= 500;
  
  // Alias getters for compatibility with screens
  String get httpMethod => method;
  String get endpoint => path;
  int get httpStatus => status;
  int get responseTimeMs => processingTimeMs;
  String? get userAgent => null; // Not currently tracked
  String? get errorMessage => error;
}

/// API usage statistics for a partner
class ApiUsageStats {
  final String partnerId;
  final DateTime fromDate;
  final DateTime toDate;
  final int totalRequests;
  final int successfulRequests;
  final int failedRequests;
  final double successRate;
  final double avgProcessingTimeMs;
  final List<DailyApiUsage> dailyUsage;
  final Map<String, int> topEndpoints;
  final double minResponseTime;
  final double maxResponseTime;
  final double p50ResponseTime;
  final double p95ResponseTime;
  final double p99ResponseTime;

  ApiUsageStats({
    required this.partnerId,
    required this.fromDate,
    required this.toDate,
    required this.totalRequests,
    required this.successfulRequests,
    required this.failedRequests,
    required this.successRate,
    required this.avgProcessingTimeMs,
    this.dailyUsage = const [],
    this.topEndpoints = const {},
    this.minResponseTime = 0.0,
    this.maxResponseTime = 0.0,
    this.p50ResponseTime = 0.0,
    this.p95ResponseTime = 0.0,
    this.p99ResponseTime = 0.0,
  });
  
  // Alias getter for compatibility
  double get avgResponseTime => avgProcessingTimeMs;

  factory ApiUsageStats.fromJson(Map<String, dynamic> json) {
    return ApiUsageStats(
      partnerId: json['partnerId'] ?? '',
      fromDate: json['fromDate'] != null 
          ? DateTime.parse(json['fromDate']) 
          : DateTime.now().subtract(const Duration(days: 7)),
      toDate: json['toDate'] != null 
          ? DateTime.parse(json['toDate']) 
          : DateTime.now(),
      totalRequests: json['totalRequests'] ?? 0,
      successfulRequests: json['successfulRequests'] ?? 0,
      failedRequests: json['failedRequests'] ?? 0,
      successRate: (json['successRate'] ?? 0.0).toDouble(),
      avgProcessingTimeMs: (json['avgProcessingTimeMs'] ?? 0.0).toDouble(),
      dailyUsage: json['dailyUsage'] != null 
          ? (json['dailyUsage'] as List).map((d) => DailyApiUsage.fromJson(d)).toList()
          : [],
      topEndpoints: json['topEndpoints'] != null 
          ? Map<String, int>.from(json['topEndpoints'])
          : {},
      minResponseTime: (json['minResponseTime'] ?? 0.0).toDouble(),
      maxResponseTime: (json['maxResponseTime'] ?? 0.0).toDouble(),
      p50ResponseTime: (json['p50ResponseTime'] ?? 0.0).toDouble(),
      p95ResponseTime: (json['p95ResponseTime'] ?? 0.0).toDouble(),
      p99ResponseTime: (json['p99ResponseTime'] ?? 0.0).toDouble(),
    );
  }
}

/// Daily API usage for charts
class DailyApiUsage {
  final DateTime date;
  final int requestCount;
  final int successCount;
  final int errorCount;
  final double avgResponseTime;

  DailyApiUsage({
    required this.date,
    required this.requestCount,
    required this.successCount,
    required this.errorCount,
    required this.avgResponseTime,
  });

  factory DailyApiUsage.fromJson(Map<String, dynamic> json) {
    return DailyApiUsage(
      date: DateTime.parse(json['date']),
      requestCount: json['requestCount'] ?? 0,
      successCount: json['successCount'] ?? 0,
      errorCount: json['errorCount'] ?? 0,
      avgResponseTime: (json['avgResponseTime'] ?? 0.0).toDouble(),
    );
  }
}
