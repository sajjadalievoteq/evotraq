import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';

class DataConsistencyService {
  final DioService _dioService;

  DataConsistencyService({
    required DioService dioService,
  }) : _dioService = dioService;

  Future<Map<String, dynamic>> performConsistencyValidation(List<String> eventIds) async {
    final token = await _dioService.getAuthToken();
    final response = await _dioService.post(
      '${_dioService.baseUrl}/api/data/consistency/validate/events',
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      data: jsonEncode(eventIds),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.data);
    } else {
      throw Exception('Failed to perform consistency validation: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> validateSupplyChainConsistency(
    String epc,
    DateTime startTime,
    DateTime endTime,
  ) async {
    final token = await _dioService.getAuthToken();
    final response = await _dioService.get(
      '${_dioService.baseUrl}/api/data/consistency/validate/supply-chain',
      queryParameters: {
        'epc': epc,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
      },
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
      },
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.data);
    } else {
      throw Exception('Failed to validate supply chain consistency: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> runDataIntegrityVerificationJob(Map<String, dynamic> jobParams) async {
    final token = await _dioService.getAuthToken();
    final response = await _dioService.post(
      '${_dioService.baseUrl}/api/data/consistency/integrity/verify',
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      data: jsonEncode(jobParams),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.data);
    } else {
      throw Exception('Failed to run integrity verification job: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> getIntegrityJobStatus(String jobId) async {
    final token = await _dioService.getAuthToken();
    final response = await _dioService.get(
      '${_dioService.baseUrl}/api/data/consistency/integrity/verify/$jobId',
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
      },
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.data);
    } else {
      throw Exception('Failed to get job status: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> getIntegrityJobResults(String jobId) async {
    final status = await getIntegrityJobStatus(jobId);
    if (status['status'] == 'COMPLETED' && status.containsKey('results')) {
      return status['results'];
    } else {
      throw Exception('Job not completed or results not available');
    }
  }

  Future<List<dynamic>> detectDataAnomalies(
    Map<String, DateTime> timeRange,
    List<String> eventTypes,
  ) async {
    final token = await _dioService.getAuthToken();
    final response = await _dioService.post(
      '${_dioService.baseUrl}/api/data/consistency/anomalies/detect',
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      data: jsonEncode({
        'time_range': {
          'start': timeRange['start']?.toIso8601String(),
          'end': timeRange['end']?.toIso8601String(),
        },
        'event_types': eventTypes,
      }),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.data) as List;
    } else {
      throw Exception('Failed to detect anomalies: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> generateConsistencyReport(
    DateTime startTime,
    DateTime endTime,
    List<String> eventTypes,
  ) async {
    final token = await _dioService.getAuthToken();
    final response = await _dioService.post(
      '${_dioService.baseUrl}/api/data/consistency/reports/generate',
      queryParameters: {
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
        'eventTypes': eventTypes,
      },
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
      },
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.data);
    } else {
      throw Exception('Failed to generate consistency report: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> validateBusinessLogicConsistency(List<Map<String, dynamic>> events) async {
    final token = await _dioService.getAuthToken();
    final response = await _dioService.post(
      '${_dioService.baseUrl}/api/data/consistency/validate/business-logic',
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      data: jsonEncode(events),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.data);
    } else {
      throw Exception('Failed to validate business logic consistency: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> checkMissingEvents(
    String epc,
    List<String> expectedSequence,
  ) async {
    final token = await _dioService.getAuthToken();
    final response = await _dioService.get(
      '${_dioService.baseUrl}/api/data/consistency/validate/missing-events',
      queryParameters: {
        'epc': epc,
        'expectedSequence': expectedSequence,
      },
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
      },
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.data);
    } else {
      throw Exception('Failed to check missing events: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> validateEventTimingConsistency(List<Map<String, dynamic>> events) async {
    final token = await _dioService.getAuthToken();
    final response = await _dioService.post(
      '${_dioService.baseUrl}/api/data/consistency/validate/timing',
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      data: jsonEncode(events),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.data);
    } else {
      throw Exception('Failed to validate timing consistency: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> crossValidateWithExternalSources(
    List<Map<String, dynamic>> events,
    List<String> externalSources,
  ) async {
    final token = await _dioService.getAuthToken();
    final response = await _dioService.post(
      '${_dioService.baseUrl}/api/data/consistency/validate/cross-validation',
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      data: jsonEncode({
        'events': events,
        'external_sources': externalSources,
      }),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.data);
    } else {
      throw Exception('Failed to cross-validate: ${response.statusCode}');
    }
  }
}
