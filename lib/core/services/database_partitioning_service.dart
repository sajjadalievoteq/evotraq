import 'package:dio/dio.dart';
import '../../shared/models/partition_models.dart';
import '../config/app_config.dart';
import '../network/token_manager.dart';

/// Service class for Database Partitioning API calls according to Phase 3.1 requirements
class DatabasePartitioningService {
  final Dio _dio;
  final AppConfig _config;
  final TokenManager _tokenManager;

  DatabasePartitioningService(this._dio, this._config, this._tokenManager);

  /// Helper method to get headers with authentication
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw Exception('Authentication token not found');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// Time-Based Partitioning Services
  
  Future<Map<String, dynamic>> createMonthlyPartition({
    required String tableName,
    required int year,
    required int month,
  }) async {
    try {
      final response = await _dio.post(
        '${_config.apiBaseUrl}/partitioning/time-based/create',
        queryParameters: {
          'tableName': tableName,
          'year': year,
          'month': month,
        },
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> createFuturePartitions({
    required String tableName,
    required int monthsAhead,
  }) async {
    try {
      final response = await _dio.post(
        '${_config.apiBaseUrl}/partitioning/time-based/create-future',
        queryParameters: {
          'tableName': tableName,
          'monthsAhead': monthsAhead,
        },
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getPartitionRoutingInfo({
    required String tableName,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await _dio.post(
        '${_config.apiBaseUrl}/partitioning/time-based/routing',
        queryParameters: {
          'tableName': tableName,
          'startDate': startDate.toIso8601String().split('T')[0],
          'endDate': endDate.toIso8601String().split('T')[0],
        },
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> updatePartitionStatistics({String? tableName}) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await _dio.post(
        '${_config.apiBaseUrl}/partitioning/time-based/update-statistics',
        queryParameters: tableName != null ? {'tableName': tableName} : null,
        options: Options(headers: headers),
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Event Type Partitioning Services

  Future<Map<String, dynamic>> createEventTypePartition({
    required String tableName,
    required String eventType,
  }) async {
    try {
      final response = await _dio.post(
        '${_config.apiBaseUrl}/partitioning/event-type/create',
        queryParameters: {
          'tableName': tableName,
          'eventType': eventType,
        },
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> optimizeCrossPartitionQuery({
    required String tableName,
    required Map<String, dynamic> queryParams,
  }) async {
    try {
      final response = await _dio.post(
        '${_config.apiBaseUrl}/partitioning/event-type/optimize-query',
        queryParameters: {'tableName': tableName},
        data: queryParams,
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, String>> getPartitionAssignmentRules({
    required String tableName,
  }) async {
    try {
      final response = await _dio.post(
        '${_config.apiBaseUrl}/partitioning/event-type/assignment-rules',
        queryParameters: {'tableName': tableName},
      );
      return Map<String, String>.from(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> balancePartitions({
    required String tableName,
  }) async {
    try {
      final response = await _dio.post(
        '${_config.apiBaseUrl}/partitioning/event-type/balance',
        queryParameters: {'tableName': tableName},
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Archive Strategy Services

  Future<Map<String, dynamic>> archiveOldPartitions({
    required DateTime cutoffDate,
    String archiveLocation = 'cold_storage',
  }) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await _dio.post(
        '${_config.apiBaseUrl}/partitioning/archive/archive-old',
        queryParameters: {
          'cutoffDate': cutoffDate.toIso8601String(),
          'archiveLocation': archiveLocation,
        },
        options: Options(headers: headers),
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<ArchiveMetadata>> retrieveArchivedData({
    required String tableName,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await _dio.post(
        '${_config.apiBaseUrl}/partitioning/archive/retrieve',
        queryParameters: {
          'tableName': tableName,
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
        },
      );
      return (response.data as List)
          .map((json) => ArchiveMetadata.fromJson(json))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> optimizeArchiveStorage({
    required int archiveId,
  }) async {
    try {
      final response = await _dio.post(
        '${_config.apiBaseUrl}/partitioning/archive/optimize/$archiveId',
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> queryArchivedData({
    required String tableName,
    required Map<String, dynamic> queryParams,
  }) async {
    try {
      final response = await _dio.post(
        '${_config.apiBaseUrl}/partitioning/archive/query',
        queryParameters: {'tableName': tableName},
        data: queryParams,
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Partition Management Services

  Future<Map<String, dynamic>> automatePartitionCreation() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await _dio.post(
        '${_config.apiBaseUrl}/partitioning/management/automate-creation',
        options: Options(headers: headers),
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> implementPartitionPruning({
    required String tableName,
    required Map<String, dynamic> queryConditions,
  }) async {
    try {
      final response = await _dio.post(
        '${_config.apiBaseUrl}/partitioning/management/implement-pruning',
        queryParameters: {'tableName': tableName},
        data: queryConditions,
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<PartitionMetadata>> getPartitionMetadata({String? tableName}) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await _dio.get(
        '${_config.apiBaseUrl}/partitioning/management/metadata',
        queryParameters: tableName != null ? {'tableName': tableName} : null,
        options: Options(headers: headers),
      );
      return (response.data as List)
          .map((json) => PartitionMetadata.fromJson(json))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<PartitionStatistics> getPartitionMonitoringReport() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await _dio.get(
        '${_config.apiBaseUrl}/partitioning/management/monitoring',
        options: Options(headers: headers),
      );
      return PartitionStatistics.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<PartitionMaintenance> performPartitionMaintenance({
    required String maintenanceType,
    String? tableName,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await _dio.post(
        '${_config.apiBaseUrl}/partitioning/management/maintenance',
        queryParameters: {
          'maintenanceType': maintenanceType,
          if (tableName != null) 'tableName': tableName,
        },
        options: Options(headers: headers),
      );
      return PartitionMaintenance.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getPartitionHealthStatus() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await _dio.get(
        '${_config.apiBaseUrl}/partitioning/management/health',
        options: Options(headers: headers),
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> configurePartitionPolicies({
    required String tableName,
    required Map<String, dynamic> policies,
  }) async {
    try {
      final response = await _dio.post(
        '${_config.apiBaseUrl}/partitioning/management/configure-policies',
        queryParameters: {'tableName': tableName},
        data: policies,
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Dashboard Services

  Future<Map<String, dynamic>> getDashboardOverview() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await _dio.get(
        '${_config.apiBaseUrl}/partitioning/dashboard/overview',
        options: Options(headers: headers),
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getTablePartitioningInfo({
    required String tableName,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await _dio.get(
        '${_config.apiBaseUrl}/partitioning/dashboard/table/$tableName',
        options: Options(headers: headers),
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Data Migration Services

  Future<Map<String, dynamic>> migrateDataToPartitions() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await _dio.post(
        '${_config.apiBaseUrl}/api/partitioning/migrate-data',
        options: Options(headers: headers),
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getMainTableDataInfo() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await _dio.get(
        '${_config.apiBaseUrl}/api/partitioning/main-table-data',
        options: Options(headers: headers),
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getDebugTableInfo() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await _dio.get(
        '${_config.apiBaseUrl}/api/partitioning/debug-table-info',
        options: Options(headers: headers),
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getDebugConnectionInfo() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await _dio.get(
        '${_config.apiBaseUrl}/api/partitioning/debug-connection',
        options: Options(headers: headers),
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(dynamic error) {
    if (error is DioException) {
      if (error.response?.data != null && error.response?.data['message'] != null) {
        return error.response!.data['message'].toString();
      }
      return error.message ?? 'Network error occurred';
    }
    return error.toString();
  }
}
