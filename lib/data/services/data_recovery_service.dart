import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';

class DataRecoveryService {
  final DioService _dioService;

  DataRecoveryService({required DioService dioService}) : _dioService = dioService;

  String get _baseUrl => '${_dioService.baseUrl}/v1/data-recovery';

  Future<Map<String, String>> _getHeaders() async {
    final token = await _dioService.getAuthToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Initiate a data recovery operation
  Future<Map<String, dynamic>> initiateDataRecovery({
    required String recoveryType,
    required Map<String, dynamic> recoveryParameters,
    required String initiatedBy,
  }) async {
    final headers = await _getHeaders();

    final queryParams = <String, dynamic>{
      'recoveryType': recoveryType,
      'initiatedBy': initiatedBy,
    };

    final response = await _dioService.post(
      '$_baseUrl/initiate',
      headers: headers,
      queryParameters: queryParams,
      data: jsonEncode(recoveryParameters),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.data);
    } else {
      throw Exception(
        'Failed to initiate data recovery: ${response.statusCode} - ${response.data}',
      );
    }
  }

  /// Perform data backup
  Future<Map<String, dynamic>> performDataBackup({
    required List<String> eventIds,
    Map<String, dynamic>? backupOptions,
  }) async {
    final headers = await _getHeaders();

    final body = {
      'eventIds': eventIds,
      'backupOptions': backupOptions ?? {
        'backup_type': 'FULL',
        'include_metadata': true,
        'compression': 'GZIP',
        'storage_location': 'LOCAL',
      },
    };

    final response = await _dioService.post(
      '$_baseUrl/backup',
      headers: headers,
      data: jsonEncode(body),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.data);
    } else {
      throw Exception(
        'Failed to perform data backup: ${response.statusCode} - ${response.data}',
      );
    }
  }

  /// Restore data from backup
  Future<Map<String, dynamic>> restoreDataFromBackup({
    required String backupId,
    Map<String, dynamic>? restoreOptions,
  }) async {
    final headers = await _getHeaders();

    final queryParams = <String, dynamic>{'backupId': backupId};

    final body = restoreOptions ?? {
      'validate_before_restore': true,
      'create_backup_before_restore': true,
      'restore_mode': 'REPLACE',
    };

    final response = await _dioService.post(
      '$_baseUrl/restore',
      headers: headers,
      queryParameters: queryParams,
      data: jsonEncode(body),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.data);
    } else if (response.statusCode == 404) {
      throw Exception('Backup not found: $backupId');
    } else {
      throw Exception(
        'Failed to restore data from backup: ${response.statusCode} - ${response.data}',
      );
    }
  }

  /// Get recovery operation status
  Future<Map<String, dynamic>> getRecoveryOperationStatus(String operationId) async {
    final headers = await _getHeaders();

    final response = await _dioService.get(
      '$_baseUrl/operations/$operationId/status',
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.data);
    } else if (response.statusCode == 404) {
      throw Exception('Recovery operation not found: $operationId');
    } else {
      throw Exception(
        'Failed to get recovery operation status: ${response.statusCode} - ${response.data}',
      );
    }
  }

  /// List available backups
  Future<List<dynamic>> listAvailableBackups({
    Map<String, dynamic>? searchCriteria,
  }) async {
    final headers = await _getHeaders();

    final queryParams = <String, dynamic>{};
    if (searchCriteria != null) {
      searchCriteria.forEach((key, value) {
        if (value != null) {
          if (value is DateTime) {
            queryParams[key] = value.toIso8601String();
          } else {
            queryParams[key] = value.toString();
          }
        }
      });
    }

    final response = await _dioService.get(
      '$_baseUrl/backups',
      headers: headers,
      queryParameters: queryParams,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.data);
    } else {
      throw Exception(
        'Failed to list available backups: ${response.statusCode} - ${response.data}',
      );
    }
  }

  /// Validate backup integrity
  Future<Map<String, dynamic>> validateBackup({
    required String backupId,
    Map<String, dynamic>? validationOptions,
  }) async {
    final headers = await _getHeaders();

    final body = validationOptions ?? {
      'check_checksums': true,
      'verify_structure': true,
      'validate_events': true,
    };

    final response = await _dioService.post(
      '$_baseUrl/validate-backup/$backupId',
      headers: headers,
      data: jsonEncode(body),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.data);
    } else if (response.statusCode == 404) {
      throw Exception('Backup not found: $backupId');
    } else {
      throw Exception(
        'Failed to validate backup: ${response.statusCode} - ${response.data}',
      );
    }
  }

  /// Schedule automatic backup
  Future<Map<String, dynamic>> scheduleAutomaticBackup({
    required Map<String, dynamic> scheduleConfig,
  }) async {
    final headers = await _getHeaders();

    final response = await _dioService.post(
      '$_baseUrl/schedule-backup',
      headers: headers,
      data: jsonEncode(scheduleConfig),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.data);
    } else {
      throw Exception(
        'Failed to schedule automatic backup: ${response.statusCode} - ${response.data}',
      );
    }
  }

  /// Cancel recovery operation
  Future<Map<String, dynamic>> cancelRecoveryOperation({
    required String operationId,
    String? reason,
  }) async {
    final headers = await _getHeaders();

    final queryParams = <String, dynamic>{};
    if (reason != null) {
      queryParams['reason'] = reason;
    }

    final response = await _dioService.delete(
      '$_baseUrl/operations/$operationId',
      headers: headers,
      queryParameters: queryParams,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.data);
    } else if (response.statusCode == 404) {
      throw Exception('Recovery operation not found: $operationId');
    } else if (response.statusCode == 400) {
      throw Exception('Cannot cancel recovery operation: ${response.data}');
    } else {
      throw Exception(
        'Failed to cancel recovery operation: ${response.statusCode} - ${response.data}',
      );
    }
  }

  /// Get recovery statistics
  Future<Map<String, dynamic>> getRecoveryStatistics({
    int days = 30,
  }) async {
    final headers = await _getHeaders();

    final queryParams = <String, dynamic>{'days': days.toString()};
    final response = await _dioService.get(
      '$_baseUrl/statistics',
      headers: headers,
      queryParameters: queryParams,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.data);
    } else {
      throw Exception(
        'Failed to get recovery statistics: ${response.statusCode} - ${response.data}',
      );
    }
  }

  /// Export backup data
  Future<Map<String, dynamic>> exportBackupData({
    required String backupId,
    String format = 'JSON',
    Map<String, dynamic>? exportOptions,
  }) async {
    final headers = await _getHeaders();

    final queryParams = <String, dynamic>{
      'format': format,
    };

    final body = exportOptions ?? {
      'include_metadata': true,
      'compress_output': false,
    };

    final response = await _dioService.post(
      '$_baseUrl/backups/$backupId/export',
      headers: headers,
      queryParameters: queryParams,
      data: jsonEncode(body),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.data);
    } else if (response.statusCode == 404) {
      throw Exception('Backup not found: $backupId');
    } else {
      throw Exception(
        'Failed to export backup data: ${response.statusCode} - ${response.data}',
      );
    }
  }

  /// Get backup details
  Future<Map<String, dynamic>> getBackupDetails(String backupId) async {
    final headers = await _getHeaders();

    final response = await _dioService.get(
      '$_baseUrl/backups/$backupId',
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.data);
    } else if (response.statusCode == 404) {
      throw Exception('Backup not found: $backupId');
    } else {
      throw Exception(
        'Failed to get backup details: ${response.statusCode} - ${response.data}',
      );
    }
  }

  /// Delete backup
  Future<Map<String, dynamic>> deleteBackup({
    required String backupId,
    String? reason,
  }) async {
    final headers = await _getHeaders();

    final queryParams = <String, dynamic>{};
    if (reason != null) {
      queryParams['reason'] = reason;
    }

    final response = await _dioService.delete(
      '$_baseUrl/backups/$backupId',
      headers: headers,
      queryParameters: queryParams,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.data);
    } else if (response.statusCode == 404) {
      throw Exception('Backup not found: $backupId');
    } else {
      throw Exception(
        'Failed to delete backup: ${response.statusCode} - ${response.data}',
      );
    }
  }

  /// Test backup restore (dry run)
  Future<Map<String, dynamic>> testBackupRestore({
    required String backupId,
    Map<String, dynamic>? testOptions,
  }) async {
    final headers = await _getHeaders();

    final body = testOptions ?? {
      'dry_run': true,
      'validate_events': true,
      'check_dependencies': true,
    };

    final response = await _dioService.post(
      '$_baseUrl/backups/$backupId/test-restore',
      headers: headers,
      data: jsonEncode(body),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.data);
    } else if (response.statusCode == 404) {
      throw Exception('Backup not found: $backupId');
    } else {
      throw Exception(
        'Failed to test backup restore: ${response.statusCode} - ${response.data}',
      );
    }
  }

  /// Get recovery operation logs
  Future<List<dynamic>> getRecoveryOperationLogs({
    required String operationId,
    int? limit,
    String? level,
  }) async {
    final headers = await _getHeaders();

    final queryParams = <String, dynamic>{};
    if (limit != null) {
      queryParams['limit'] = limit.toString();
    }
    if (level != null) {
      queryParams['level'] = level;
    }

    final response = await _dioService.get(
      '$_baseUrl/operations/$operationId/logs',
      headers: headers,
      queryParameters: queryParams,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.data);
    } else if (response.statusCode == 404) {
      throw Exception('Recovery operation not found: $operationId');
    } else {
      throw Exception(
        'Failed to get recovery operation logs: ${response.statusCode} - ${response.data}',
      );
    }
  }

  /// Monitor recovery operation progress (polling)
  Stream<Map<String, dynamic>> monitorRecoveryOperationProgress(String operationId) async* {
    while (true) {
      try {
        final status = await getRecoveryOperationStatus(operationId);
        yield status;

        final operationStatus = status['status'] as String?;
        if (operationStatus == 'COMPLETED' || operationStatus == 'FAILED' || operationStatus == 'CANCELLED') {
          break;
        }

        await Future.delayed(const Duration(seconds: 5)); // Poll every 5 seconds
      } catch (e) {
        yield {'error': e.toString()};
        break;
      }
    }
  }

  /// Estimate recovery time
  Future<Map<String, dynamic>> estimateRecoveryTime({
    required String recoveryType,
    required Map<String, dynamic> recoveryParameters,
  }) async {
    final headers = await _getHeaders();

    final body = {
      'recovery_type': recoveryType,
      'recovery_parameters': recoveryParameters,
    };

    final response = await _dioService.post(
      '$_baseUrl/estimate-recovery-time',
      headers: headers,
      data: jsonEncode(body),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.data);
    } else {
      throw Exception(
        'Failed to estimate recovery time: ${response.statusCode} - ${response.data}',
      );
    }
  }
}
