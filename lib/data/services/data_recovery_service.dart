import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:traqtrace_app/core/network/token_manager.dart';
import 'package:traqtrace_app/core/config/app_config.dart';

class DataRecoveryService {
  final http.Client client;
  final TokenManager tokenManager;
  final AppConfig appConfig;

  DataRecoveryService({
    required this.client,
    required this.tokenManager,
    required this.appConfig,
  });

  String get _baseUrl => '${appConfig.apiBaseUrl}/api/v1/data-recovery';

  Future<Map<String, String>> _getHeaders() async {
    final token = await tokenManager.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// Initiate a data recovery operation
  Future<Map<String, dynamic>> initiateDataRecovery({
    required String recoveryType,
    required Map<String, dynamic> recoveryParameters,
    required String initiatedBy,
  }) async {
    final headers = await _getHeaders();

    final queryParams = {
      'recoveryType': recoveryType,
      'initiatedBy': initiatedBy,
    };

    final uri = Uri.parse('$_baseUrl/initiate').replace(queryParameters: queryParams);

    final response = await client.post(
      uri,
      headers: headers,
      body: json.encode(recoveryParameters),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to initiate data recovery: ${response.statusCode} - ${response.body}');
    }
  }

  /// Perform data backup
  Future<Map<String, dynamic>> performDataBackup({
    required List<String> eventIds,
    Map<String, dynamic>? backupOptions,
  }) async {
    final headers = await _getHeaders();
    final uri = Uri.parse('$_baseUrl/backup');

    final body = {
      'eventIds': eventIds,
      'backupOptions': backupOptions ?? {
        'backup_type': 'FULL',
        'include_metadata': true,
        'compression': 'GZIP',
        'storage_location': 'LOCAL',
      },
    };

    final response = await client.post(
      uri,
      headers: headers,
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to perform data backup: ${response.statusCode} - ${response.body}');
    }
  }

  /// Restore data from backup
  Future<Map<String, dynamic>> restoreDataFromBackup({
    required String backupId,
    Map<String, dynamic>? restoreOptions,
  }) async {
    final headers = await _getHeaders();

    final queryParams = {'backupId': backupId};
    final uri = Uri.parse('$_baseUrl/restore').replace(queryParameters: queryParams);

    final body = restoreOptions ?? {
      'validate_before_restore': true,
      'create_backup_before_restore': true,
      'restore_mode': 'REPLACE',
    };

    final response = await client.post(
      uri,
      headers: headers,
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 404) {
      throw Exception('Backup not found: $backupId');
    } else {
      throw Exception('Failed to restore data from backup: ${response.statusCode} - ${response.body}');
    }
  }

  /// Get recovery operation status
  Future<Map<String, dynamic>> getRecoveryOperationStatus(String operationId) async {
    final headers = await _getHeaders();
    final uri = Uri.parse('$_baseUrl/operations/$operationId/status');

    final response = await client.get(uri, headers: headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 404) {
      throw Exception('Recovery operation not found: $operationId');
    } else {
      throw Exception('Failed to get recovery operation status: ${response.statusCode} - ${response.body}');
    }
  }

  /// List available backups
  Future<List<dynamic>> listAvailableBackups({
    Map<String, dynamic>? searchCriteria,
  }) async {
    final headers = await _getHeaders();

    final queryParams = <String, String>{};
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

    final uri = Uri.parse('$_baseUrl/backups').replace(queryParameters: queryParams);

    final response = await client.get(uri, headers: headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to list available backups: ${response.statusCode} - ${response.body}');
    }
  }

  /// Validate backup integrity
  Future<Map<String, dynamic>> validateBackup({
    required String backupId,
    Map<String, dynamic>? validationOptions,
  }) async {
    final headers = await _getHeaders();
    final uri = Uri.parse('$_baseUrl/validate-backup/$backupId');

    final body = validationOptions ?? {
      'check_checksums': true,
      'verify_structure': true,
      'validate_events': true,
    };

    final response = await client.post(
      uri,
      headers: headers,
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 404) {
      throw Exception('Backup not found: $backupId');
    } else {
      throw Exception('Failed to validate backup: ${response.statusCode} - ${response.body}');
    }
  }

  /// Schedule automatic backup
  Future<Map<String, dynamic>> scheduleAutomaticBackup({
    required Map<String, dynamic> scheduleConfig,
  }) async {
    final headers = await _getHeaders();
    final uri = Uri.parse('$_baseUrl/schedule-backup');

    final response = await client.post(
      uri,
      headers: headers,
      body: json.encode(scheduleConfig),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to schedule automatic backup: ${response.statusCode} - ${response.body}');
    }
  }

  /// Cancel recovery operation
  Future<Map<String, dynamic>> cancelRecoveryOperation({
    required String operationId,
    String? reason,
  }) async {
    final headers = await _getHeaders();

    final queryParams = <String, String>{};
    if (reason != null) {
      queryParams['reason'] = reason;
    }

    final uri = Uri.parse('$_baseUrl/operations/$operationId').replace(queryParameters: queryParams);

    final response = await client.delete(uri, headers: headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 404) {
      throw Exception('Recovery operation not found: $operationId');
    } else if (response.statusCode == 400) {
      throw Exception('Cannot cancel recovery operation: ${response.body}');
    } else {
      throw Exception('Failed to cancel recovery operation: ${response.statusCode} - ${response.body}');
    }
  }

  /// Get recovery statistics
  Future<Map<String, dynamic>> getRecoveryStatistics({
    int days = 30,
  }) async {
    final headers = await _getHeaders();

    final queryParams = {'days': days.toString()};
    final uri = Uri.parse('$_baseUrl/statistics').replace(queryParameters: queryParams);

    final response = await client.get(uri, headers: headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get recovery statistics: ${response.statusCode} - ${response.body}');
    }
  }

  /// Export backup data
  Future<Map<String, dynamic>> exportBackupData({
    required String backupId,
    String format = 'JSON',
    Map<String, dynamic>? exportOptions,
  }) async {
    final headers = await _getHeaders();

    final queryParams = {
      'format': format,
    };

    final uri = Uri.parse('$_baseUrl/backups/$backupId/export').replace(queryParameters: queryParams);

    final body = exportOptions ?? {
      'include_metadata': true,
      'compress_output': false,
    };

    final response = await client.post(
      uri,
      headers: headers,
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 404) {
      throw Exception('Backup not found: $backupId');
    } else {
      throw Exception('Failed to export backup data: ${response.statusCode} - ${response.body}');
    }
  }

  /// Get backup details
  Future<Map<String, dynamic>> getBackupDetails(String backupId) async {
    final headers = await _getHeaders();
    final uri = Uri.parse('$_baseUrl/backups/$backupId');

    final response = await client.get(uri, headers: headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 404) {
      throw Exception('Backup not found: $backupId');
    } else {
      throw Exception('Failed to get backup details: ${response.statusCode} - ${response.body}');
    }
  }

  /// Delete backup
  Future<Map<String, dynamic>> deleteBackup({
    required String backupId,
    String? reason,
  }) async {
    final headers = await _getHeaders();

    final queryParams = <String, String>{};
    if (reason != null) {
      queryParams['reason'] = reason;
    }

    final uri = Uri.parse('$_baseUrl/backups/$backupId').replace(queryParameters: queryParams);

    final response = await client.delete(uri, headers: headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 404) {
      throw Exception('Backup not found: $backupId');
    } else {
      throw Exception('Failed to delete backup: ${response.statusCode} - ${response.body}');
    }
  }

  /// Test backup restore (dry run)
  Future<Map<String, dynamic>> testBackupRestore({
    required String backupId,
    Map<String, dynamic>? testOptions,
  }) async {
    final headers = await _getHeaders();
    final uri = Uri.parse('$_baseUrl/backups/$backupId/test-restore');

    final body = testOptions ?? {
      'dry_run': true,
      'validate_events': true,
      'check_dependencies': true,
    };

    final response = await client.post(
      uri,
      headers: headers,
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 404) {
      throw Exception('Backup not found: $backupId');
    } else {
      throw Exception('Failed to test backup restore: ${response.statusCode} - ${response.body}');
    }
  }

  /// Get recovery operation logs
  Future<List<dynamic>> getRecoveryOperationLogs({
    required String operationId,
    int? limit,
    String? level,
  }) async {
    final headers = await _getHeaders();

    final queryParams = <String, String>{};
    if (limit != null) {
      queryParams['limit'] = limit.toString();
    }
    if (level != null) {
      queryParams['level'] = level;
    }

    final uri = Uri.parse('$_baseUrl/operations/$operationId/logs').replace(queryParameters: queryParams);

    final response = await client.get(uri, headers: headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 404) {
      throw Exception('Recovery operation not found: $operationId');
    } else {
      throw Exception('Failed to get recovery operation logs: ${response.statusCode} - ${response.body}');
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
    final uri = Uri.parse('$_baseUrl/estimate-recovery-time');

    final body = {
      'recovery_type': recoveryType,
      'recovery_parameters': recoveryParameters,
    };

    final response = await client.post(
      uri,
      headers: headers,
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to estimate recovery time: ${response.statusCode} - ${response.body}');
    }
  }
}
