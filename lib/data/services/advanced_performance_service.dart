import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:traqtrace_app/core/config/app_config.dart';
import 'package:traqtrace_app/core/network/http_service.dart';
import 'package:traqtrace_app/core/network/token_manager.dart';

class AdvancedPerformanceService {
  final HttpService _httpService;
  final TokenManager _tokenManager;
  final AppConfig _appConfig;

  AdvancedPerformanceService({
    required HttpService httpService,
    required TokenManager tokenManager,
    required AppConfig appConfig,
  }) : _httpService = httpService,
       _tokenManager = tokenManager,
       _appConfig = appConfig;

  // Query Plan Analysis Service
  Future<Map<String, dynamic>> analyzeQuery(String query) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw Exception('Authentication token not found');
    }

    final response = await _httpService.post(
      '${_appConfig.apiBaseUrl}/api/admin/performance/query-plan/analyze',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      data: json.encode({'query': query}),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return json.decode(response.data);
    } else {
      throw Exception('Failed to analyze query: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> getQueryPlanPatterns() async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw Exception('Authentication token not found');
    }

    final response = await _httpService.get(
      '${_appConfig.apiBaseUrl}/api/admin/performance/query-plan/patterns',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return json.decode(response.data);
    } else {
      throw Exception('Failed to get query patterns: ${response.statusCode}');
    }
  }

  Future<List<dynamic>> getOptimizationRecommendations() async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw Exception('Authentication token not found');
    }

    final response = await _httpService.get(
      '${_appConfig.apiBaseUrl}/api/admin/performance/query-plan/recommendations',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return json.decode(response.data);
    } else {
      throw Exception('Failed to get recommendations: ${response.statusCode}');
    }
  }

  Future<List<dynamic>> getProblematicQueries() async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw Exception('Authentication token not found');
    }

    final response = await _httpService.get(
      '${_appConfig.apiBaseUrl}/api/admin/performance/query-plan/problematic',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return json.decode(response.data);
    } else {
      throw Exception(
        'Failed to get problematic queries: ${response.statusCode}',
      );
    }
  }

  // Connection Pool Monitoring Service
  Future<Map<String, dynamic>> getConnectionPoolStatus() async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw Exception('Authentication token not found');
    }

    final response = await _httpService.get(
      '${_appConfig.apiBaseUrl}/api/admin/performance/connection-pool/status',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return json.decode(response.data);
    } else {
      throw Exception(
        'Failed to get connection pool status: ${response.statusCode}',
      );
    }
  }

  Future<Map<String, dynamic>> detectConnectionLeaks() async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw Exception('Authentication token not found');
    }

    final response = await _httpService.get(
      '${_appConfig.apiBaseUrl}/api/admin/performance/connection-pool/leak-detection',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return json.decode(response.data);
    } else {
      throw Exception(
        'Failed to detect connection leaks: ${response.statusCode}',
      );
    }
  }

  Future<Map<String, dynamic>> checkConnectionPoolHealth() async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw Exception('Authentication token not found');
    }

    final response = await _httpService.get(
      '${_appConfig.apiBaseUrl}/api/admin/performance/connection-pool/health',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return json.decode(response.data);
    } else {
      throw Exception(
        'Failed to check connection pool health: ${response.statusCode}',
      );
    }
  }

  Future<List<dynamic>> getConnectionPoolRecommendations() async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw Exception('Authentication token not found');
    }

    final response = await _httpService.get(
      '${_appConfig.apiBaseUrl}/api/admin/performance/connection-pool/recommendations',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return json.decode(response.data);
    } else {
      throw Exception(
        'Failed to get connection pool recommendations: ${response.statusCode}',
      );
    }
  }

  // Thread Pool Management Service
  Future<Map<String, dynamic>> getThreadPoolMetrics() async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw Exception('Authentication token not found');
    }

    final response = await _httpService.get(
      '${_appConfig.apiBaseUrl}/api/admin/performance/thread-pool/metrics',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return json.decode(response.data);
    } else {
      throw Exception(
        'Failed to get thread pool metrics: ${response.statusCode}',
      );
    }
  }

  Future<Map<String, dynamic>> analyzeContention() async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw Exception('Authentication token not found');
    }

    final response = await _httpService.get(
      '${_appConfig.apiBaseUrl}/api/admin/performance/thread-pool/contention',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return json.decode(response.data);
    } else {
      throw Exception('Failed to analyze contention: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> configureBackpressure(
    String strategy,
    Map<String, dynamic> config,
  ) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw Exception('Authentication token not found');
    }

    final response = await _httpService.post(
      '${_appConfig.apiBaseUrl}/api/admin/performance/thread-pool/backpressure',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      data: json.encode({'strategy': strategy, 'config': config}),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return json.decode(response.data);
    } else {
      throw Exception(
        'Failed to configure backpressure: ${response.statusCode}',
      );
    }
  }

  Future<Map<String, dynamic>> optimizeThreadPools(
    Map<String, dynamic> settings,
  ) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw Exception('Authentication token not found');
    }

    final response = await _httpService.post(
      '${_appConfig.apiBaseUrl}/api/admin/performance/thread-pool/optimize',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      data: json.encode(settings),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return json.decode(response.data);
    } else {
      throw Exception(
        'Failed to optimize thread pools: ${response.statusCode}',
      );
    }
  }

  // Resource Management Service
  Future<Map<String, dynamic>> getSystemResourceMetrics() async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw Exception('Authentication token not found');
    }

    final response = await _httpService.get(
      '${_appConfig.apiBaseUrl}/api/admin/performance/resources/metrics',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return json.decode(response.data);
    } else {
      throw Exception(
        'Failed to get system resource metrics: ${response.statusCode}',
      );
    }
  }

  Future<Map<String, dynamic>> optimizeMemoryUsage() async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw Exception('Authentication token not found');
    }

    final response = await _httpService.post(
      '${_appConfig.apiBaseUrl}/api/admin/performance/resources/memory/optimize',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return json.decode(response.data);
    } else {
      throw Exception(
        'Failed to optimize memory usage: ${response.statusCode}',
      );
    }
  }

  Future<Map<String, dynamic>> optimizeCpuUsage() async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw Exception('Authentication token not found');
    }

    final response = await _httpService.post(
      '${_appConfig.apiBaseUrl}/api/admin/performance/resources/cpu/optimize',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return json.decode(response.data);
    } else {
      throw Exception('Failed to optimize CPU usage: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> optimizeIoPerformance() async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw Exception('Authentication token not found');
    }

    final response = await _httpService.post(
      '${_appConfig.apiBaseUrl}/api/admin/performance/resources/io/optimize',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return json.decode(response.data);
    } else {
      throw Exception(
        'Failed to optimize I/O performance: ${response.statusCode}',
      );
    }
  }

  Future<List<dynamic>> getResourceRecommendations() async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw Exception('Authentication token not found');
    }

    final response = await _httpService.get(
      '${_appConfig.apiBaseUrl}/api/admin/performance/resources/recommendations',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return json.decode(response.data);
    } else {
      throw Exception(
        'Failed to get resource recommendations: ${response.statusCode}',
      );
    }
  }

  // Comprehensive Performance Service
  Future<Map<String, dynamic>> getComprehensiveAnalysis() async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw Exception('Authentication token not found');
    }

    final response = await _httpService.get(
      '${_appConfig.apiBaseUrl}/api/admin/performance/comprehensive/analysis',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return json.decode(response.data);
    } else {
      throw Exception(
        'Failed to get comprehensive analysis: ${response.statusCode}',
      );
    }
  }

  Future<Map<String, dynamic>> performAutomatedOptimization() async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw Exception('Authentication token not found');
    }

    final response = await _httpService.post(
      '${_appConfig.apiBaseUrl}/api/admin/performance/comprehensive/optimize',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return json.decode(response.data);
    } else {
      throw Exception(
        'Failed to perform automated optimization: ${response.statusCode}',
      );
    }
  }
}
