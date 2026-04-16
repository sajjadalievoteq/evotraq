

import '../../core/network/dio_service.dart';

/// Service for Performance Optimization API calls
class PerformanceOptimizationService {
  final DioService _dioService = DioService();

  // Query Optimization Methods
  Future<Map<String, dynamic>> analyzeQueryExecutionPlan(String query) async {
    try {
      final response = await _dioService.post(
        '/admin/performance/query/analyze',
        data: {'query': query},
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to analyze query execution plan: $e');
    }
  }

  Future<Map<String, dynamic>> getIndexOptimizationRecommendations(String tableName) async {
    try {
      final response = await _dioService.get(
        '/admin/performance/query/index-recommendations/$tableName',
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to get index recommendations: $e');
    }
  }

  Future<Map<String, dynamic>> rewriteQueryForPerformance(String originalQuery) async {
    try {
      final response = await _dioService.post(
        '/admin/performance/query/rewrite',
        data: {'originalQuery': originalQuery},
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to rewrite query for performance: $e');
    }
  }

  Future<Map<String, dynamic>> detectSlowQueries({int thresholdMs = 1000}) async {
    try {
      final response = await _dioService.get(
        '/admin/performance/query/slow-queries?thresholdMs=$thresholdMs',
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to detect slow queries: $e');
    }
  }

  // Connection Pool Management Methods
  Future<Map<String, dynamic>> getOptimizedConnectionPoolConfig() async {
    try {
      final response = await _dioService.get(
        '/admin/performance/connection-pool/optimal-config',
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to get optimized connection pool config: $e');
    }
  }

  Future<Map<String, dynamic>> monitorConnectionPool() async {
    try {
      final response = await _dioService.get(
        '/admin/performance/connection-pool/monitor',
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to monitor connection pool: $e');
    }
  }

  Future<Map<String, dynamic>> adjustConnectionPoolSize(double targetLoad) async {
    try {
      final response = await _dioService.post(
        '/admin/performance/connection-pool/adjust-size?targetLoad=$targetLoad',
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to adjust connection pool size: $e');
    }
  }

  Future<Map<String, dynamic>> detectConnectionLeaks() async {
    try {
      final response = await _dioService.get(
        '/admin/performance/connection-pool/detect-leaks',
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to detect connection leaks: $e');
    }
  }

  // Thread Management Methods
  Future<Map<String, dynamic>> configureOptimalThreadPool({
    required String poolName,
    required int coreSize,
    required int maxSize,
    required int queueCapacity,
  }) async {
    try {
      final response = await _dioService.post(
        '/admin/performance/threads/configure-pool?poolName=$poolName&coreSize=$coreSize&maxSize=$maxSize&queueCapacity=$queueCapacity',
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to configure optimal thread pool: $e');
    }
  }

  Future<Map<String, dynamic>> implementTaskPrioritization({
    required String poolName,
    required Map<String, dynamic> priorityConfig,
  }) async {
    try {
      final response = await _dioService.post(
        '/admin/performance/threads/prioritization?poolName=$poolName',
        data: priorityConfig,
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to implement task prioritization: $e');
    }
  }

  Future<Map<String, dynamic>> buildBackpressureMechanisms({
    required String poolName,
    required Map<String, dynamic> backpressureConfig,
  }) async {
    try {
      final response = await _dioService.post(
        '/admin/performance/threads/backpressure?poolName=$poolName',
        data: backpressureConfig,
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to build backpressure mechanisms: $e');
    }
  }

  Future<Map<String, dynamic>> monitorThreadPools({String? poolName}) async {
    try {
      String url = '/admin/performance/threads/monitor';
      if (poolName != null) {
        url += '?poolName=$poolName';
      }
      final response = await _dioService.get(url);
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to monitor thread pools: $e');
    }
  }

  // Resource Management Methods
  Future<Map<String, dynamic>> optimizeMemoryUsage() async {
    try {
      final response = await _dioService.post(
        '/admin/performance/resources/optimize-memory',
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to optimize memory usage: $e');
    }
  }

  Future<Map<String, dynamic>> balanceCpuUtilization() async {
    try {
      final response = await _dioService.post(
        '/admin/performance/resources/balance-cpu',
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to balance CPU utilization: $e');
    }
  }

  Future<Map<String, dynamic>> optimizeIoOperations() async {
    try {
      final response = await _dioService.post(
        '/admin/performance/resources/optimize-io',
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to optimize I/O operations: $e');
    }
  }

  Future<Map<String, dynamic>> monitorResourceUsage() async {
    try {
      final response = await _dioService.get(
        '/admin/performance/resources/monitor',
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to monitor resource usage: $e');
    }
  }

  // Comprehensive Performance Analytics Methods
  Future<Map<String, dynamic>> getPerformanceReport() async {
    try {
      final response = await _dioService.get(
        '/admin/performance/report',
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to get performance report: $e');
    }
  }

  Future<Map<String, dynamic>> runPerformanceBenchmark(String testType) async {
    try {
      final response = await _dioService.post(
        '/admin/performance/benchmark?testType=$testType',
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to run performance benchmark: $e');
    }
  }

  Future<Map<String, dynamic>> getOptimizationRecommendations() async {
    try {
      final response = await _dioService.get(
        '/admin/performance/recommendations',
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to get optimization recommendations: $e');
    }
  }

  Future<Map<String, dynamic>> applyAutomaticOptimizations(String optimizationType) async {
    try {
      final response = await _dioService.post(
        '/admin/performance/auto-optimize?optimizationType=$optimizationType',
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to apply automatic optimizations: $e');
    }
  }

  Future<Map<String, dynamic>> getHealth() async {
    try {
      final response = await _dioService.get(
        '/admin/performance/health',
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to get performance service health: $e');
    }
  }
}
