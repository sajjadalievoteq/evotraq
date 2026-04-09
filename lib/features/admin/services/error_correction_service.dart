import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../core/network/token_manager.dart';
import '../../../core/config/app_config.dart';

class ErrorCorrectionService {
  final http.Client _client;
  final TokenManager _tokenManager;
  final AppConfig _appConfig;

  ErrorCorrectionService({
    required http.Client client,
    required TokenManager tokenManager,
    required AppConfig appConfig,
  }) : _client = client,
       _tokenManager = tokenManager,
       _appConfig = appConfig;

  /// Identify correctable errors in specified time range
  Future<List<dynamic>> identifyCorrectableErrors(
    DateTime startTime,
    DateTime endTime,
    List<String> errorTypes,
  ) async {
    final token = await _tokenManager.getToken();
    final response = await _client.get(
      Uri.parse('${_appConfig.apiBaseUrl}/data/correction/errors/identify')
          .replace(queryParameters: {
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
        'errorTypes': errorTypes,
      }),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List;
    } else {
      throw Exception('Failed to identify correctable errors: ${response.statusCode}');
    }
  }

  /// Initiate error correction workflow
  Future<Map<String, dynamic>> initiateErrorCorrectionWorkflow(
    String errorId,
    String correctionType,
    Map<String, dynamic> proposedCorrection,
    String userId,
  ) async {
    final token = await _tokenManager.getToken();
    final response = await _client.post(
      Uri.parse('${_appConfig.apiBaseUrl}/data/correction/workflows/initiate')
          .replace(queryParameters: {
        'errorId': errorId,
        'correctionType': correctionType,
        'userId': userId,
      }),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(proposedCorrection),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to initiate correction workflow: ${response.statusCode}');
    }
  }

  /// Apply automatic error correction
  Future<Map<String, dynamic>> applyAutomaticErrorCorrection(
    String errorId,
    Map<String, dynamic> correctionRules,
  ) async {
    final token = await _tokenManager.getToken();
    final response = await _client.post(
      Uri.parse('${_appConfig.apiBaseUrl}/data/correction/automatic/$errorId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(correctionRules),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to apply automatic correction: ${response.statusCode}');
    }
  }

  /// Submit correction for approval
  Future<Map<String, dynamic>> submitCorrectionForApproval(
    String workflowId,
    Map<String, dynamic> correctionData,
    String justification,
    String submitterId,
  ) async {
    final token = await _tokenManager.getToken();
    final response = await _client.post(
      Uri.parse('${_appConfig.apiBaseUrl}/data/correction/workflows/$workflowId/submit-for-approval'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'correction_data': correctionData,
        'justification': justification,
        'submitter_id': submitterId,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to submit for approval: ${response.statusCode}');
    }
  }

  /// Review and approve/reject error correction
  Future<Map<String, dynamic>> reviewErrorCorrection(
    String approvalRequestId,
    bool approved,
    String reviewComments,
    String reviewerId,
  ) async {
    final token = await _tokenManager.getToken();
    final response = await _client.post(
      Uri.parse('${_appConfig.apiBaseUrl}/data/correction/approvals/$approvalRequestId/review')
          .replace(queryParameters: {
        'approved': approved.toString(),
        'reviewComments': reviewComments,
        'reviewerId': reviewerId,
      }),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to review correction: ${response.statusCode}');
    }
  }

  /// Execute approved error correction
  Future<Map<String, dynamic>> executeApprovedCorrection(String approvalRequestId) async {
    final token = await _tokenManager.getToken();
    final response = await _client.post(
      Uri.parse('${_appConfig.apiBaseUrl}/data/correction/approvals/$approvalRequestId/execute'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to execute correction: ${response.statusCode}');
    }
  }

  /// Get correction workflow status
  Future<Map<String, dynamic>> getCorrectionWorkflowStatus(String workflowId) async {
    final token = await _tokenManager.getToken();
    final response = await _client.get(
      Uri.parse('${_appConfig.apiBaseUrl}/data/correction/workflows/$workflowId/status'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get workflow status: ${response.statusCode}');
    }
  }

  /// Get correction audit trail for an event
  Future<List<dynamic>> getCorrectionAuditTrail(String eventId) async {
    final token = await _tokenManager.getToken();
    final response = await _client.get(
      Uri.parse('${_appConfig.apiBaseUrl}/data/correction/audit-trail/$eventId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List;
    } else {
      throw Exception('Failed to get audit trail: ${response.statusCode}');
    }
  }

  /// Send correction notifications
  Future<Map<String, dynamic>> sendCorrectionNotification(
    String correctionId,
    String notificationType,
    List<String> recipients,
  ) async {
    final token = await _tokenManager.getToken();
    final response = await _client.post(
      Uri.parse('${_appConfig.apiBaseUrl}/data/correction/notifications/send')
          .replace(queryParameters: {
        'correctionId': correctionId,
        'notificationType': notificationType,
      }),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(recipients),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to send notification: ${response.statusCode}');
    }
  }

  /// Rollback error correction
  Future<Map<String, dynamic>> rollbackErrorCorrection(
    String correctionId,
    String rollbackReason,
    String userId,
  ) async {
    final token = await _tokenManager.getToken();
    final response = await _client.post(
      Uri.parse('${_appConfig.apiBaseUrl}/data/correction/rollback/$correctionId')
          .replace(queryParameters: {
        'rollbackReason': rollbackReason,
        'userId': userId,
      }),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to rollback correction: ${response.statusCode}');
    }
  }

  /// Get error correction statistics
  Future<Map<String, dynamic>> getErrorCorrectionStatistics(
    DateTime startTime,
    DateTime endTime,
  ) async {
    final token = await _tokenManager.getToken();
    final response = await _client.get(
      Uri.parse('${_appConfig.apiBaseUrl}/data/correction/statistics')
          .replace(queryParameters: {
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
      }),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get statistics: ${response.statusCode}');
    }
  }

  /// Create correction audit trail entry
  Future<Map<String, dynamic>> createCorrectionAuditTrail(
    String eventId,
    String correctionType,
    Map<String, dynamic> originalData,
    Map<String, dynamic> correctedData,
    String userId,
    String justification,
  ) async {
    final token = await _tokenManager.getToken();
    final response = await _client.post(
      Uri.parse('${_appConfig.apiBaseUrl}/data/correction/audit-trail/create'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'event_id': eventId,
        'correction_type': correctionType,
        'original_data': originalData,
        'corrected_data': correctedData,
        'user_id': userId,
        'justification': justification,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create audit trail: ${response.statusCode}');
    }
  }

  /// Register integrity violations as correctable error
  Future<Map<String, dynamic>> registerIntegrityViolations(
    String jobId,
    List<Map<String, Object>> violations,
    double integrityScore,
  ) async {
    final token = await _tokenManager.getToken();
    final response = await _client.post(
      Uri.parse('${_appConfig.apiBaseUrl}/data/correction/integrity-violations/register'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'job_id': jobId,
        'violations': violations,
        'integrity_score': integrityScore,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to register integrity violations: ${response.statusCode}');
    }
  }

  /// Get all correction workflows
  Future<List<Map<String, dynamic>>> getAllCorrectionWorkflows() async {
    final token = await _tokenManager.getToken();
    final response = await _client.get(
      Uri.parse('${_appConfig.apiBaseUrl}/data/correction/workflows'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to get correction workflows: ${response.statusCode}');
    }
  }

  /// Register a real error detected by the system
  Future<String> registerRealError(
    String errorType,
    String description,
    List<String> affectedEvents,
    String severity,
    Map<String, dynamic> proposedCorrection,
  ) async {
    final token = await _tokenManager.getToken();
    final response = await _client.post(
      Uri.parse('${_appConfig.apiBaseUrl}/data/correction/real-error/register'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'error_type': errorType,
        'description': description,
        'affected_events': affectedEvents,
        'severity': severity,
        'proposed_correction': proposedCorrection,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['error_id'];
    } else {
      throw Exception('Failed to register real error: ${response.statusCode}');
    }
  }
}
