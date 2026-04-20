import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:traqtrace_app/shared/models/partition_models.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';

/// Service class for Database Partitioning API calls according to Phase 3.1 requirements
class DatabasePartitioningService {
  final DioService _dioService;
  late final String _baseUrl;

  DatabasePartitioningService({required DioService dioService})
    : _dioService = dioService {
    _baseUrl = _dioService.baseUrl;
  }

  /// Helper method to get headers with authentication
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _dioService.getAuthToken();
    if (token == null) {
      throw Exception('Authentication token not found');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  dynamic _decodeJson(dynamic data) {
    if (data is String) return jsonDecode(data);
    return data;
  }

  /// Time-Based Partitioning Services
  
  Future<Map<String, dynamic>> createMonthlyPartition({
    required String tableName,
    required int year,
    required int month,
  }) async {
    try {
      final response = await _dioService.post(
        '$_baseUrl/partitioning/time-based/create',
        queryParameters: {
          'tableName': tableName,
          'year': year,
          'month': month,
        },
        headers: await _getAuthHeaders(),
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );
      return (_decodeJson(response.data) as Map).cast<String, dynamic>();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> createFuturePartitions({
    required String tableName,
    required int monthsAhead,
  }) async {
    try {
      final response = await _dioService.post(
        '$_baseUrl/partitioning/time-based/create-future',
        queryParameters: {
          'tableName': tableName,
          'monthsAhead': monthsAhead,
        },
        headers: await _getAuthHeaders(),
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );
      return (_decodeJson(response.data) as Map).cast<String, dynamic>();
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
      final response = await _dioService.post(
        '$_baseUrl/partitioning/time-based/routing',
        queryParameters: {
          'tableName': tableName,
          'startDate': startDate.toIso8601String().split('T')[0],
          'endDate': endDate.toIso8601String().split('T')[0],
        },
        headers: await _getAuthHeaders(),
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );
      return (_decodeJson(response.data) as Map).cast<String, dynamic>();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> updatePartitionStatistics({String? tableName}) async {
    try {
      final response = await _dioService.post(
        '$_baseUrl/partitioning/time-based/update-statistics',
        queryParameters: tableName != null ? {'tableName': tableName} : null,
        headers: await _getAuthHeaders(),
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );
      return (_decodeJson(response.data) as Map).cast<String, dynamic>();
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
      final response = await _dioService.post(
        '$_baseUrl/partitioning/event-type/create',
        queryParameters: {
          'tableName': tableName,
          'eventType': eventType,
        },
        headers: await _getAuthHeaders(),
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );
      return (_decodeJson(response.data) as Map).cast<String, dynamic>();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> optimizeCrossPartitionQuery({
    required String tableName,
    required Map<String, dynamic> queryParams,
  }) async {
    try {
      final response = await _dioService.post(
        '$_baseUrl/partitioning/event-type/optimize-query',
        queryParameters: {'tableName': tableName},
        data: jsonEncode(queryParams),
        headers: await _getAuthHeaders(),
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );
      return (_decodeJson(response.data) as Map).cast<String, dynamic>();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, String>> getPartitionAssignmentRules({
    required String tableName,
  }) async {
    try {
      final response = await _dioService.post(
        '$_baseUrl/partitioning/event-type/assignment-rules',
        queryParameters: {'tableName': tableName},
        headers: await _getAuthHeaders(),
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );
      return Map<String, String>.from(_decodeJson(response.data) as Map);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> balancePartitions({
    required String tableName,
  }) async {
    try {
      final response = await _dioService.post(
        '$_baseUrl/partitioning/event-type/balance',
        queryParameters: {'tableName': tableName},
        headers: await _getAuthHeaders(),
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );
      return (_decodeJson(response.data) as Map).cast<String, dynamic>();
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
      final response = await _dioService.post(
        '$_baseUrl/partitioning/archive/archive-old',
        queryParameters: {
          'cutoffDate': cutoffDate.toIso8601String(),
          'archiveLocation': archiveLocation,
        },
        headers: await _getAuthHeaders(),
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );
      return (_decodeJson(response.data) as Map).cast<String, dynamic>();
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
      final response = await _dioService.post(
        '$_baseUrl/partitioning/archive/retrieve',
        queryParameters: {
          'tableName': tableName,
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
        },
        headers: await _getAuthHeaders(),
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );
      final data = (_decodeJson(response.data) as List).cast<dynamic>();
      return data
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
      final response = await _dioService.post(
        '$_baseUrl/partitioning/archive/optimize/$archiveId',
        headers: await _getAuthHeaders(),
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );
      return (_decodeJson(response.data) as Map).cast<String, dynamic>();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> queryArchivedData({
    required String tableName,
    required Map<String, dynamic> queryParams,
  }) async {
    try {
      final response = await _dioService.post(
        '$_baseUrl/partitioning/archive/query',
        queryParameters: {'tableName': tableName},
        data: jsonEncode(queryParams),
        headers: await _getAuthHeaders(),
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );
      return (_decodeJson(response.data) as Map).cast<String, dynamic>();
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Partition Management Services

  Future<Map<String, dynamic>> automatePartitionCreation() async {
    try {
      final response = await _dioService.post(
        '$_baseUrl/partitioning/management/automate-creation',
        headers: await _getAuthHeaders(),
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );
      return (_decodeJson(response.data) as Map).cast<String, dynamic>();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> implementPartitionPruning({
    required String tableName,
    required Map<String, dynamic> queryConditions,
  }) async {
    try {
      final response = await _dioService.post(
        '$_baseUrl/partitioning/management/implement-pruning',
        queryParameters: {'tableName': tableName},
        data: jsonEncode(queryConditions),
        headers: await _getAuthHeaders(),
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );
      return (_decodeJson(response.data) as Map).cast<String, dynamic>();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<PartitionMetadata>> getPartitionMetadata({String? tableName}) async {
    try {
      final response = await _dioService.get(
        '$_baseUrl/partitioning/management/metadata',
        queryParameters: tableName != null ? {'tableName': tableName} : null,
        headers: await _getAuthHeaders(),
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );
      final data = (_decodeJson(response.data) as List).cast<dynamic>();
      return data
          .map((json) => PartitionMetadata.fromJson(json))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<PartitionStatistics> getPartitionMonitoringReport() async {
    try {
      final response = await _dioService.get(
        '$_baseUrl/partitioning/management/monitoring',
        headers: await _getAuthHeaders(),
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );
      return PartitionStatistics.fromJson(_decodeJson(response.data));
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<PartitionMaintenance> performPartitionMaintenance({
    required String maintenanceType,
    String? tableName,
  }) async {
    try {
      final response = await _dioService.post(
        '$_baseUrl/partitioning/management/maintenance',
        queryParameters: {
          'maintenanceType': maintenanceType,
          if (tableName != null) 'tableName': tableName,
        },
        headers: await _getAuthHeaders(),
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );
      return PartitionMaintenance.fromJson(_decodeJson(response.data));
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getPartitionHealthStatus() async {
    try {
      final response = await _dioService.get(
        '$_baseUrl/partitioning/management/health',
        headers: await _getAuthHeaders(),
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );
      return (_decodeJson(response.data) as Map).cast<String, dynamic>();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> configurePartitionPolicies({
    required String tableName,
    required Map<String, dynamic> policies,
  }) async {
    try {
      final response = await _dioService.post(
        '$_baseUrl/partitioning/management/configure-policies',
        queryParameters: {'tableName': tableName},
        data: jsonEncode(policies),
        headers: await _getAuthHeaders(),
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );
      return (_decodeJson(response.data) as Map).cast<String, dynamic>();
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Dashboard Services

  Future<Map<String, dynamic>> getDashboardOverview() async {
    try {
      final response = await _dioService.get(
        '$_baseUrl/partitioning/dashboard/overview',
        headers: await _getAuthHeaders(),
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );
      return (_decodeJson(response.data) as Map).cast<String, dynamic>();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getTablePartitioningInfo({
    required String tableName,
  }) async {
    try {
      final response = await _dioService.get(
        '$_baseUrl/partitioning/dashboard/table/$tableName',
        headers: await _getAuthHeaders(),
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );
      return (_decodeJson(response.data) as Map).cast<String, dynamic>();
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Data Migration Services

  Future<Map<String, dynamic>> migrateDataToPartitions() async {
    try {
      final response = await _dioService.post(
        '$_baseUrl/api/partitioning/migrate-data',
        headers: await _getAuthHeaders(),
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );
      return (_decodeJson(response.data) as Map).cast<String, dynamic>();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getMainTableDataInfo() async {
    try {
      final response = await _dioService.get(
        '$_baseUrl/api/partitioning/main-table-data',
        headers: await _getAuthHeaders(),
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );
      return (_decodeJson(response.data) as Map).cast<String, dynamic>();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getDebugTableInfo() async {
    try {
      final response = await _dioService.get(
        '$_baseUrl/api/partitioning/debug-table-info',
        headers: await _getAuthHeaders(),
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );
      return (_decodeJson(response.data) as Map).cast<String, dynamic>();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getDebugConnectionInfo() async {
    try {
      final response = await _dioService.get(
        '$_baseUrl/api/partitioning/debug-connection',
        headers: await _getAuthHeaders(),
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );
      return (_decodeJson(response.data) as Map).cast<String, dynamic>();
    } catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(dynamic error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data != null) {
        try {
          final decoded = _decodeJson(data);
          if (decoded is Map && decoded['message'] != null) {
            return decoded['message'].toString();
          }
        } catch (_) {}
      }
      return error.message ?? 'Network error occurred';
    }
    return error.toString();
  }
}
