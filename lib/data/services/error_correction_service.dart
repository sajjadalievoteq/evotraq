import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';

class ErrorCorrectionService {
  final DioService _dioService;

  ErrorCorrectionService({
    required DioService dioService,
  }) : _dioService = dioService;

  Future<Map<String, String>> _getHeaders() async {
    final token = await _dioService.getAuthToken();
    return {
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Identify correctable errors in specified time range
  Future<List<dynamic>> identifyCorrectableErrors(
    DateTime startTime,
    DateTime endTime,
    List<String> errorTypes,
  ) async {
    final response = await _dioService.get(
      '${_dioService.baseUrl}/data/correction/errors/identify',
      queryParameters: {
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
        'errorTypes': errorTypes,
      },
      headers: await _getHeaders(),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return (jsonDecode(response.data) as List).cast<dynamic>();
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
    final response = await _dioService.post(
      '${_dioService.baseUrl}/data/correction/workflows/initiate',
      queryParameters: {
        'errorId': errorId,
        'correctionType': correctionType,
        'userId': userId,
      },
      headers: {
        ...await _getHeaders(),
        'Content-Type': 'application/json',
      },
      data: jsonEncode(proposedCorrection),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.data);
    } else {
      throw Exception('Failed to initiate correction workflow: ${response.statusCode}');
    }
  }

  /// Apply automatic error correction
  Future<Map<String, dynamic>> applyAutomaticErrorCorrection(
    String errorId,
    Map<String, dynamic> correctionRules,
  ) async {
    final response = await _dioService.post(
      '${_dioService.baseUrl}/data/correction/automatic/$errorId',
      headers: {
        ...await _getHeaders(),
        'Content-Type': 'application/json',
      },
      data: jsonEncode(correctionRules),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.data);
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
    final response = await _dioService.post(
      '${_dioService.baseUrl}/data/correction/workflows/$workflowId/submit-for-approval',
      headers: {
        ...await _getHeaders(),
        'Content-Type': 'application/json',
      },
      data: jsonEncode({
        'correction_data': correctionData,
        'justification': justification,
        'submitter_id': submitterId,
      }),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.data);
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
    final response = await _dioService.post(
      '${_dioService.baseUrl}/data/correction/approvals/$approvalRequestId/review',
      queryParameters: {
        'approved': approved.toString(),
        'reviewComments': reviewComments,
        'reviewerId': reviewerId,
      },
      headers: await _getHeaders(),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.data);
    } else {
      throw Exception('Failed to review correction: ${response.statusCode}');
    }
  }

  /// Execute approved error correction
  Future<Map<String, dynamic>> executeApprovedCorrection(String approvalRequestId) async {
    final response = await _dioService.post(
      '${_dioService.baseUrl}/data/correction/approvals/$approvalRequestId/execute',
      headers: await _getHeaders(),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.data);
    } else {
      throw Exception('Failed to execute correction: ${response.statusCode}');
    }
  }

  /// Get correction workflow status
  Future<Map<String, dynamic>> getCorrectionWorkflowStatus(String workflowId) async {
    final response = await _dioService.get(
      '${_dioService.baseUrl}/data/correction/workflows/$workflowId/status',
      headers: await _getHeaders(),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.data);
    } else {
      throw Exception('Failed to get workflow status: ${response.statusCode}');
    }
  }

  /// Get correction audit trail for an event
  Future<List<dynamic>> getCorrectionAuditTrail(String eventId) async {
    final response = await _dioService.get(
      '${_dioService.baseUrl}/data/correction/audit-trail/$eventId',
      headers: await _getHeaders(),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return (jsonDecode(response.data) as List).cast<dynamic>();
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
    final response = await _dioService.post(
      '${_dioService.baseUrl}/data/correction/notifications/send',
      queryParameters: {
        'correctionId': correctionId,
        'notificationType': notificationType,
      },
      headers: {
        ...await _getHeaders(),
        'Content-Type': 'application/json',
      },
      data: jsonEncode(recipients),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.data);
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
    final response = await _dioService.post(
      '${_dioService.baseUrl}/data/correction/rollback/$correctionId',
      queryParameters: {
        'rollbackReason': rollbackReason,
        'userId': userId,
      },
      headers: await _getHeaders(),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.data);
    } else {
      throw Exception('Failed to rollback correction: ${response.statusCode}');
    }
  }

  /// Get error correction statistics
  Future<Map<String, dynamic>> getErrorCorrectionStatistics(
    DateTime startTime,
    DateTime endTime,
  ) async {
    final response = await _dioService.get(
      '${_dioService.baseUrl}/data/correction/statistics',
      queryParameters: {
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
      },
      headers: await _getHeaders(),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.data);
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
    final response = await _dioService.post(
      '${_dioService.baseUrl}/data/correction/audit-trail/create',
      headers: {
        ...await _getHeaders(),
        'Content-Type': 'application/json',
      },
      data: jsonEncode({
        'event_id': eventId,
        'correction_type': correctionType,
        'original_data': originalData,
        'corrected_data': correctedData,
        'user_id': userId,
        'justification': justification,
      }),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.data);
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
    final response = await _dioService.post(
      '${_dioService.baseUrl}/data/correction/integrity-violations/register',
      headers: {
        ...await _getHeaders(),
        'Content-Type': 'application/json',
      },
      data: jsonEncode({
        'job_id': jobId,
        'violations': violations,
        'integrity_score': integrityScore,
      }),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.data);
    } else {
      throw Exception('Failed to register integrity violations: ${response.statusCode}');
    }
  }

  /// Get all correction workflows
  Future<List<Map<String, dynamic>>> getAllCorrectionWorkflows() async {
    final response = await _dioService.get(
      '${_dioService.baseUrl}/data/correction/workflows',
      headers: await _getHeaders(),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.data);
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
    final response = await _dioService.post(
      '${_dioService.baseUrl}/data/correction/real-error/register',
      headers: {
        ...await _getHeaders(),
        'Content-Type': 'application/json',
      },
      data: jsonEncode({
        'error_type': errorType,
        'description': description,
        'affected_events': affectedEvents,
        'severity': severity,
        'proposed_correction': proposedCorrection,
      }),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.data);
      return data['error_id'];
    } else {
      throw Exception('Failed to register real error: ${response.statusCode}');
    }
  }
}
