import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../core/network/token_manager.dart';
import '../../../core/config/app_config.dart';

class DataQualityMetricsService {
  final http.Client client;
  final TokenManager tokenManager;
  final AppConfig appConfig;

  DataQualityMetricsService({
    required this.client,
    required this.tokenManager,
    required this.appConfig,
  });

  String get _baseUrl => '${appConfig.apiBaseUrl}/api/v1/quality-metrics';

  Future<Map<String, String>> _getHeaders() async {
    final token = await tokenManager.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// Calculate comprehensive data quality metrics
  Future<Map<String, dynamic>> calculateDataQualityMetrics({
    required DateTime startTime,
    required DateTime endTime,
    List<String>? eventTypes,
  }) async {
    final headers = await _getHeaders();

    final queryParams = {
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
    };

    if (eventTypes != null && eventTypes.isNotEmpty) {
      for (int i = 0; i < eventTypes.length; i++) {
        queryParams['eventTypes[$i]'] = eventTypes[i];
      }
    }

    final uri = Uri.parse('$_baseUrl/calculate').replace(queryParameters: queryParams);

    final response = await client.post(uri, headers: headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to calculate quality metrics: ${response.statusCode} - ${response.body}');
    }
  }

  /// Generate comprehensive data quality report
  Future<Map<String, dynamic>> generateDataQualityReport({
    required DateTime startTime,
    required DateTime endTime,
    Map<String, dynamic>? reportOptions,
  }) async {
    final headers = await _getHeaders();

    final queryParams = {
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
    };

    final uri = Uri.parse('$_baseUrl/report').replace(queryParameters: queryParams);

    final body = reportOptions ?? {
      'format': 'detailed',
      'include_charts': false,
      'event_types': ['ObjectEvent', 'AggregationEvent', 'TransactionEvent', 'TransformationEvent'],
    };

    final response = await client.post(
      uri,
      headers: headers,
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to generate quality report: ${response.statusCode} - ${response.body}');
    }
  }

  /// Identify data quality issues
  Future<List<dynamic>> identifyDataQualityIssues({
    required DateTime startTime,
    required DateTime endTime,
    Map<String, dynamic>? issueFilters,
  }) async {
    final headers = await _getHeaders();

    final queryParams = {
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
    };

    final uri = Uri.parse('$_baseUrl/issues').replace(queryParameters: queryParams);

    final body = issueFilters ?? {
      'severity_levels': ['HIGH', 'MEDIUM', 'LOW'],
      'issue_types': ['COMPLETENESS', 'ACCURACY', 'CONSISTENCY', 'TIMELINESS'],
      'include_recommendations': true,
    };

    final response = await client.post(
      uri,
      headers: headers,
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to identify quality issues: ${response.statusCode} - ${response.body}');
    }
  }

  /// Get quality metrics by ID
  Future<Map<String, dynamic>> getQualityMetricsById(String metricsId) async {
    final headers = await _getHeaders();
    final uri = Uri.parse('$_baseUrl/metrics/$metricsId');

    final response = await client.get(uri, headers: headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 404) {
      throw Exception('Quality metrics not found: $metricsId');
    } else {
      throw Exception('Failed to get quality metrics: ${response.statusCode} - ${response.body}');
    }
  }

  /// Benchmark data quality against historical data
  Future<Map<String, dynamic>> benchmarkDataQuality({
    required DateTime currentPeriodStart,
    required DateTime currentPeriodEnd,
    Map<String, dynamic>? benchmarkOptions,
  }) async {
    final headers = await _getHeaders();

    final queryParams = {
      'currentPeriodStart': currentPeriodStart.toIso8601String(),
      'currentPeriodEnd': currentPeriodEnd.toIso8601String(),
    };

    final uri = Uri.parse('$_baseUrl/benchmark').replace(queryParameters: queryParams);

    final body = benchmarkOptions ?? {
      'comparison_period_days': 30,
      'benchmark_type': 'HISTORICAL',
      'include_trend_analysis': true,
    };

    final response = await client.post(
      uri,
      headers: headers,
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to benchmark quality: ${response.statusCode} - ${response.body}');
    }
  }

  /// Set quality thresholds for alerting
  Future<Map<String, dynamic>> setQualityThresholds(Map<String, dynamic> thresholds) async {
    final headers = await _getHeaders();
    final uri = Uri.parse('$_baseUrl/thresholds');

    final response = await client.post(
      uri,
      headers: headers,
      body: json.encode(thresholds),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to set quality thresholds: ${response.statusCode} - ${response.body}');
    }
  }

  /// Get current quality thresholds
  Future<Map<String, dynamic>> getQualityThresholds() async {
    final headers = await _getHeaders();
    final uri = Uri.parse('$_baseUrl/thresholds');

    final response = await client.get(uri, headers: headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get quality thresholds: ${response.statusCode} - ${response.body}');
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

    final queryParams = {
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'granularity': granularity,
    };

    if (eventTypes != null && eventTypes.isNotEmpty) {
      for (int i = 0; i < eventTypes.length; i++) {
        queryParams['eventTypes[$i]'] = eventTypes[i];
      }
    }

    final uri = Uri.parse('$_baseUrl/history').replace(queryParameters: queryParams);

    final response = await client.get(uri, headers: headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get quality metrics history: ${response.statusCode} - ${response.body}');
    }
  }

  /// Generate quality improvement recommendations
  Future<Map<String, dynamic>> generateImprovementRecommendations({
    required DateTime startTime,
    required DateTime endTime,
    Map<String, dynamic>? analysisOptions,
  }) async {
    final headers = await _getHeaders();

    final queryParams = {
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
    };

    final uri = Uri.parse('$_baseUrl/recommendations').replace(queryParameters: queryParams);

    final body = analysisOptions ?? {
      'include_root_cause_analysis': true,
      'prioritize_by_impact': true,
      'include_cost_benefit': false,
    };

    final response = await client.post(
      uri,
      headers: headers,
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to generate improvement recommendations: ${response.statusCode} - ${response.body}');
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

    final queryParams = {
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'format': format,
    };

    final uri = Uri.parse('$_baseUrl/export').replace(queryParameters: queryParams);

    final body = exportOptions ?? {
      'include_charts': true,
      'include_recommendations': true,
      'compress_output': false,
    };

    final response = await client.post(
      uri,
      headers: headers,
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to export quality metrics: ${response.statusCode} - ${response.body}');
    }
  }

  /// Get real-time quality statistics
  Future<Map<String, dynamic>> getRealtimeQualityStatistics() async {
    final headers = await _getHeaders();
    final uri = Uri.parse('$_baseUrl/realtime/statistics');

    final response = await client.get(uri, headers: headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get realtime quality statistics: ${response.statusCode} - ${response.body}');
    }
  }

  /// Subscribe to quality alerts
  Future<Map<String, dynamic>> subscribeToQualityAlerts({
    required List<String> alertTypes,
    required Map<String, dynamic> subscriptionConfig,
  }) async {
    final headers = await _getHeaders();
    final uri = Uri.parse('$_baseUrl/alerts/subscribe');

    final body = {
      'alert_types': alertTypes,
      'subscription_config': subscriptionConfig,
    };

    final response = await client.post(
      uri,
      headers: headers,
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to subscribe to quality alerts: ${response.statusCode} - ${response.body}');
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

    final queryParams = {
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

    final uri = Uri.parse('$_baseUrl/alerts/history').replace(queryParameters: queryParams);

    final response = await client.get(uri, headers: headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get quality alert history: ${response.statusCode} - ${response.body}');
    }
  }
}
