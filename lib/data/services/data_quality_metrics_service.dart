import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';

class DataQualityMetricsService {
  final DioService _dioService;

  DataQualityMetricsService({required DioService dioService})
    : _dioService = dioService;

  String get _baseUrl => '${_dioService.baseUrl}/v1/quality-metrics';

  Future<Map<String, String>> _getHeaders() async {
    final token = await _dioService.getAuthToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Calculate comprehensive data quality metrics
  Future<Map<String, dynamic>> calculateDataQualityMetrics({
    required DateTime startTime,
    required DateTime endTime,
    List<String>? eventTypes,
  }) async {
    final headers = await _getHeaders();

    final queryParams = <String, dynamic>{
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
    };

    if (eventTypes != null && eventTypes.isNotEmpty) {
      for (int i = 0; i < eventTypes.length; i++) {
        queryParams['eventTypes[$i]'] = eventTypes[i];
      }
    }

    final response = await _dioService.post(
      '$_baseUrl/calculate',
      headers: headers,
      queryParameters: queryParams,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.data);
    } else {
      throw Exception(
        'Failed to calculate quality metrics: ${response.statusCode} - ${response.data}',
      );
    }
  }

  /// Generate comprehensive data quality report
  Future<Map<String, dynamic>> generateDataQualityReport({
    required DateTime startTime,
    required DateTime endTime,
    Map<String, dynamic>? reportOptions,
  }) async {
    final headers = await _getHeaders();

    final queryParams = <String, dynamic>{
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
    };

    final body =
        reportOptions ??
        {
          'format': 'detailed',
          'include_charts': false,
          'event_types': [
            'ObjectEvent',
            'AggregationEvent',
            'TransactionEvent',
            'TransformationEvent',
          ],
        };

    final response = await _dioService.post(
      '$_baseUrl/report',
      headers: headers,
      queryParameters: queryParams,
      data: jsonEncode(body),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.data);
    } else {
      throw Exception(
        'Failed to generate quality report: ${response.statusCode} - ${response.data}',
      );
    }
  }

  /// Identify data quality issues
  Future<List<dynamic>> identifyDataQualityIssues({
    required DateTime startTime,
    required DateTime endTime,
    Map<String, dynamic>? issueFilters,
  }) async {
    final headers = await _getHeaders();

    final queryParams = <String, dynamic>{
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
    };

    final body =
        issueFilters ??
        {
          'severity_levels': ['HIGH', 'MEDIUM', 'LOW'],
          'issue_types': [
            'COMPLETENESS',
            'ACCURACY',
            'CONSISTENCY',
            'TIMELINESS',
          ],
          'include_recommendations': true,
        };

    final response = await _dioService.post(
      '$_baseUrl/issues',
      headers: headers,
      queryParameters: queryParams,
      data: jsonEncode(body),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.data);
    } else {
      throw Exception(
        'Failed to identify quality issues: ${response.statusCode} - ${response.data}',
      );
    }
  }

  /// Get quality metrics by ID
  Future<Map<String, dynamic>> getQualityMetricsById(String metricsId) async {
    final headers = await _getHeaders();

    final response = await _dioService.get(
      '$_baseUrl/metrics/$metricsId',
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.data);
    } else if (response.statusCode == 404) {
      throw Exception('Quality metrics not found: $metricsId');
    } else {
      throw Exception(
        'Failed to get quality metrics: ${response.statusCode} - ${response.data}',
      );
    }
  }

  /// Benchmark data quality against historical data
  Future<Map<String, dynamic>> benchmarkDataQuality({
    required DateTime currentPeriodStart,
    required DateTime currentPeriodEnd,
    Map<String, dynamic>? benchmarkOptions,
  }) async {
    final headers = await _getHeaders();

    final queryParams = <String, dynamic>{
      'currentPeriodStart': currentPeriodStart.toIso8601String(),
      'currentPeriodEnd': currentPeriodEnd.toIso8601String(),
    };

    final body =
        benchmarkOptions ??
        {
          'comparison_period_days': 30,
          'benchmark_type': 'HISTORICAL',
          'include_trend_analysis': true,
        };

    final response = await _dioService.post(
      '$_baseUrl/benchmark',
      headers: headers,
      queryParameters: queryParams,
      data: jsonEncode(body),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.data);
    } else {
      throw Exception(
        'Failed to benchmark quality: ${response.statusCode} - ${response.data}',
      );
    }
  }

  /// Set quality thresholds for alerting
  Future<Map<String, dynamic>> setQualityThresholds(
    Map<String, dynamic> thresholds,
  ) async {
    final headers = await _getHeaders();

    final response = await _dioService.post(
      '$_baseUrl/thresholds',
      headers: headers,
      data: jsonEncode(thresholds),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.data);
    } else {
      throw Exception(
        'Failed to set quality thresholds: ${response.statusCode} - ${response.data}',
      );
    }
  }

  /// Get current quality thresholds
  Future<Map<String, dynamic>> getQualityThresholds() async {
    final headers = await _getHeaders();

    final response = await _dioService.get(
      '$_baseUrl/thresholds',
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.data);
    } else {
      throw Exception(
        'Failed to get quality thresholds: ${response.statusCode} - ${response.data}',
      );
    }
  }

  /// Get quality metrics history
  Future<List<dynamic>> getQualityMetricsHistory({
    required DateTime startTime,
    required DateTime endTime,
    String granularity = 'DAILY',
    List<String>? eventTypes,
  }) async {
    final headers = await _getHeaders();

    final queryParams = <String, dynamic>{
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'granularity': granularity,
    };

    if (eventTypes != null && eventTypes.isNotEmpty) {
      for (int i = 0; i < eventTypes.length; i++) {
        queryParams['eventTypes[$i]'] = eventTypes[i];
      }
    }

    final response = await _dioService.get(
      '$_baseUrl/history',
      headers: headers,
      queryParameters: queryParams,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.data);
    } else {
      throw Exception(
        'Failed to get quality metrics history: ${response.statusCode} - ${response.data}',
      );
    }
  }

  /// Generate quality improvement recommendations
  Future<Map<String, dynamic>> generateImprovementRecommendations({
    required DateTime startTime,
    required DateTime endTime,
    Map<String, dynamic>? analysisOptions,
  }) async {
    final headers = await _getHeaders();

    final queryParams = <String, dynamic>{
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
    };

    final body =
        analysisOptions ??
        {
          'include_root_cause_analysis': true,
          'prioritize_by_impact': true,
          'include_cost_benefit': false,
        };

    final response = await _dioService.post(
      '$_baseUrl/recommendations',
      headers: headers,
      queryParameters: queryParams,
      data: jsonEncode(body),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.data);
    } else {
      throw Exception(
        'Failed to generate improvement recommendations: ${response.statusCode} - ${response.data}',
      );
    }
  }

  /// Export quality metrics data
  Future<Map<String, dynamic>> exportQualityMetrics({
    required DateTime startTime,
    required DateTime endTime,
    String format = 'JSON',
    Map<String, dynamic>? exportOptions,
  }) async {
    final headers = await _getHeaders();

    final queryParams = <String, dynamic>{
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'format': format,
    };

    final body =
        exportOptions ??
        {
          'include_charts': true,
          'include_recommendations': true,
          'compress_output': false,
        };

    final response = await _dioService.post(
      '$_baseUrl/export',
      headers: headers,
      queryParameters: queryParams,
      data: jsonEncode(body),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.data);
    } else {
      throw Exception(
        'Failed to export quality metrics: ${response.statusCode} - ${response.data}',
      );
    }
  }

  /// Get real-time quality statistics
  Future<Map<String, dynamic>> getRealtimeQualityStatistics() async {
    final headers = await _getHeaders();

    final response = await _dioService.get(
      '$_baseUrl/realtime/statistics',
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.data);
    } else {
      throw Exception(
        'Failed to get realtime quality statistics: ${response.statusCode} - ${response.data}',
      );
    }
  }

  /// Subscribe to quality alerts
  Future<Map<String, dynamic>> subscribeToQualityAlerts({
    required List<String> alertTypes,
    required Map<String, dynamic> subscriptionConfig,
  }) async {
    final headers = await _getHeaders();

    final body = {
      'alert_types': alertTypes,
      'subscription_config': subscriptionConfig,
    };

    final response = await _dioService.post(
      '$_baseUrl/alerts/subscribe',
      headers: headers,
      data: jsonEncode(body),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.data);
    } else {
      throw Exception(
        'Failed to subscribe to quality alerts: ${response.statusCode} - ${response.data}',
      );
    }
  }

  /// Get quality alert history
  Future<List<dynamic>> getQualityAlertHistory({
    required DateTime startTime,
    required DateTime endTime,
    List<String>? alertTypes,
    List<String>? severityLevels,
  }) async {
    final headers = await _getHeaders();

    final queryParams = <String, dynamic>{
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
    };

    if (alertTypes != null && alertTypes.isNotEmpty) {
      for (int i = 0; i < alertTypes.length; i++) {
        queryParams['alertTypes[$i]'] = alertTypes[i];
      }
    }

    if (severityLevels != null && severityLevels.isNotEmpty) {
      for (int i = 0; i < severityLevels.length; i++) {
        queryParams['severityLevels[$i]'] = severityLevels[i];
      }
    }

    final response = await _dioService.get(
      '$_baseUrl/alerts/history',
      headers: headers,
      queryParameters: queryParams,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.data);
    } else {
      throw Exception(
        'Failed to get quality alert history: ${response.statusCode} - ${response.data}',
      );
    }
  }
}
