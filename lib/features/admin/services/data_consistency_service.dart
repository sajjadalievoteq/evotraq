import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../core/network/token_manager.dart';
import '../../../core/config/app_config.dart';

class DataConsistencyService {
  final http.Client _client;
  final TokenManager _tokenManager;
  final AppConfig _appConfig;

  DataConsistencyService({
    required http.Client client,
    required TokenManager tokenManager,
    required AppConfig appConfig,
  }) : _client = client,
       _tokenManager = tokenManager,
       _appConfig = appConfig;

  /// Perform consistency validation for a list of events
  Future<Map<String, dynamic>> performConsistencyValidation(List<String> eventIds) async {
    final token = await _tokenManager.getToken();
    final response = await _client.post(
      Uri.parse('${_appConfig.apiBaseUrl}/api/data/consistency/validate/events'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(eventIds),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to perform consistency validation: ${response.statusCode}');
    }
  }

  /// Validate supply chain consistency for a specific EPC
  Future<Map<String, dynamic>> validateSupplyChainConsistency(
    String epc,
    DateTime startTime,
    DateTime endTime,
  ) async {
    final token = await _tokenManager.getToken();
    final response = await _client.get(
      Uri.parse('${_appConfig.apiBaseUrl}/api/data/consistency/validate/supply-chain/$epc')
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
      throw Exception('Failed to validate supply chain consistency: ${response.statusCode}');
    }
  }

  /// Run data integrity verification job
  Future<Map<String, dynamic>> runDataIntegrityVerificationJob(Map<String, dynamic> jobParams) async {
    final token = await _tokenManager.getToken();
    final response = await _client.post(
      Uri.parse('${_appConfig.apiBaseUrl}/api/data/consistency/integrity/verify'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(jobParams),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to run integrity verification job: ${response.statusCode}');
    }
  }

  /// Get data integrity verification job status
  Future<Map<String, dynamic>> getIntegrityJobStatus(String jobId) async {
    final token = await _tokenManager.getToken();
    final response = await _client.get(
      Uri.parse('${_appConfig.apiBaseUrl}/api/data/consistency/integrity/verify/$jobId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get job status: ${response.statusCode}');
    }
  }

  /// Get detailed integrity verification results for completed job
  Future<Map<String, dynamic>> getIntegrityJobResults(String jobId) async {
    final status = await getIntegrityJobStatus(jobId);
    if (status['status'] == 'COMPLETED' && status.containsKey('results')) {
      return status['results'];
    } else {
      throw Exception('Job not completed or results not available');
    }
  }

  /// Detect data anomalies in event patterns
  Future<List<dynamic>> detectDataAnomalies(
    Map<String, DateTime> timeRange,
    List<String> eventTypes,
  ) async {
    final token = await _tokenManager.getToken();
    final response = await _client.post(
      Uri.parse('${_appConfig.apiBaseUrl}/api/data/consistency/anomalies/detect'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'time_range': {
          'start': timeRange['start']?.toIso8601String(),
          'end': timeRange['end']?.toIso8601String(),
        },
        'event_types': eventTypes,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List;
    } else {
      throw Exception('Failed to detect anomalies: ${response.statusCode}');
    }
  }

  /// Generate comprehensive consistency report
  Future<Map<String, dynamic>> generateConsistencyReport(
    DateTime startTime,
    DateTime endTime,
    List<String> eventTypes,
  ) async {
    final token = await _tokenManager.getToken();
    final response = await _client.post(
      Uri.parse('${_appConfig.apiBaseUrl}/api/data/consistency/reports/generate')
          .replace(queryParameters: {
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
        'eventTypes': eventTypes,
      }),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to generate consistency report: ${response.statusCode}');
    }
  }

  /// Validate business logic consistency
  Future<Map<String, dynamic>> validateBusinessLogicConsistency(List<Map<String, dynamic>> events) async {
    final token = await _tokenManager.getToken();
    final response = await _client.post(
      Uri.parse('${_appConfig.apiBaseUrl}/api/data/consistency/validate/business-logic'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(events),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to validate business logic consistency: ${response.statusCode}');
    }
  }

  /// Check for missing events in expected sequence
  Future<Map<String, dynamic>> checkMissingEvents(
    String epc,
    List<String> expectedSequence,
  ) async {
    final token = await _tokenManager.getToken();
    final response = await _client.get(
      Uri.parse('${_appConfig.apiBaseUrl}/api/data/consistency/validate/missing-events/$epc')
          .replace(queryParameters: {
        'expectedSequence': expectedSequence,
      }),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to check missing events: ${response.statusCode}');
    }
  }

  /// Validate event timing consistency
  Future<Map<String, dynamic>> validateEventTimingConsistency(List<Map<String, dynamic>> events) async {
    final token = await _tokenManager.getToken();
    final response = await _client.post(
      Uri.parse('${_appConfig.apiBaseUrl}/api/data/consistency/validate/timing'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(events),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to validate timing consistency: ${response.statusCode}');
    }
  }

  /// Cross-validate events against external data sources
  Future<Map<String, dynamic>> crossValidateWithExternalSources(
    List<Map<String, dynamic>> events,
    List<String> externalSources,
  ) async {
    final token = await _tokenManager.getToken();
    final response = await _client.post(
      Uri.parse('${_appConfig.apiBaseUrl}/api/data/consistency/validate/cross-validation'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'events': events,
        'external_sources': externalSources,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to cross-validate: ${response.statusCode}');
    }
  }
}
