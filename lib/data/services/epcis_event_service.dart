import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:traqtrace_app/core/config/app_config.dart';
import 'package:traqtrace_app/core/network/token_manager.dart';
import 'package:traqtrace_app/features/epcis/models/epcis_document_dto.dart';
import 'package:traqtrace_app/features/epcis/models/epcis_event.dart';
import 'package:traqtrace_app/features/epcis/models/epcis_query_parameters_dto.dart';


/// Implementation of the EPCIS Event Service using HTTP
class EPCISEventService {
  final http.Client _httpClient;
  final TokenManager _tokenManager;
  final AppConfig _appConfig;
  
  /// Base endpoint for EPCIS events API
  late final String _baseUrl;
    EPCISEventService({
    required http.Client httpClient,
    required TokenManager tokenManager,
    required AppConfig appConfig,
  }) : _httpClient = httpClient,
       _tokenManager = tokenManager,
       _appConfig = appConfig {
    _baseUrl = '${_appConfig.apiBaseUrl}/events';
  }
  /// Get authorization headers for API requests
  Future<Map<String, String>> _getHeaders() async {
    final token = await _tokenManager.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<EPCISEvent>> getAllEvents() async {
    final headers = await _getHeaders();
    final response = await _httpClient.get(
      Uri.parse(_baseUrl),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> eventList = json.decode(response.body);
      return eventList.map((json) => EPCISEvent.fromJson(json)).toList();
    } else {
      throw Exception('Failed to get events: ${response.statusCode}');
    }
  }
  
  Future<Map<String, dynamic>> getAllEventsPaginated(int page, int size) async {
    final headers = await _getHeaders();
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl?page=$page&size=$size'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> content = data['content'] ?? [];
      
      return {
        'content': content.map((json) => EPCISEvent.fromJson(json)).toList(),
        'totalElements': data['totalElements'] ?? 0,
        'totalPages': data['totalPages'] ?? 0,
        'number': data['number'] ?? 0,
        'size': data['size'] ?? 0,
      };
    } else {
      throw Exception('Failed to get paginated events: ${response.statusCode}');
    }
  }

  Future<void> deleteEvent(String id) async {
    final headers = await _getHeaders();
    final response = await _httpClient.delete(
      Uri.parse('$_baseUrl/$id'),
      headers: headers,
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete event: ${response.statusCode}');
    }
  }

  Future<List<EPCISEvent>> findEventsByTimeWindow(DateTime startTime, DateTime endTime) async {
    final headers = await _getHeaders();
    final String startTimeStr = startTime.toUtc().toIso8601String();
    final String endTimeStr = endTime.toUtc().toIso8601String();

    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/time-range?startTime=$startTimeStr&endTime=$endTimeStr'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> eventList = json.decode(response.body);
      return eventList.map((json) => EPCISEvent.fromJson(json)).toList();
    } else {
      throw Exception('Failed to find events by time window: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> captureEvents(EPCISDocumentDTO epcisDocument) async {
    final headers = await _getHeaders();
    final response = await _httpClient.post(
      Uri.parse('$_baseUrl/capture'),
      headers: headers,
      body: json.encode(epcisDocument.toJson()),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to capture events: ${response.statusCode}');
    }
  }

  Future<EPCISEvent> getEventById(String id) async {
    final headers = await _getHeaders();
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/$id'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return EPCISEvent.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to get event: ${response.statusCode}');
    }
  }

  Future<List<EPCISEvent>> getEventsByEPC(String epc) async {
    final headers = await _getHeaders();
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/epc/$epc'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> eventList = json.decode(response.body);
      return eventList.map((json) => EPCISEvent.fromJson(json)).toList();
    } else {
      throw Exception('Failed to get events by EPC: ${response.statusCode}');
    }
  }

  Future<List<EPCISEvent>> queryEvents(EPCISQueryParametersDTO queryParams) async {
    final headers = await _getHeaders();
    final response = await _httpClient.post(
      Uri.parse('$_baseUrl/query'),
      headers: headers,
      body: json.encode(queryParams.toJson()),
    );

    if (response.statusCode == 200) {
      final List<dynamic> eventList = json.decode(response.body);
      return eventList.map((json) => EPCISEvent.fromJson(json)).toList();
    } else {
      throw Exception('Failed to query events: ${response.statusCode}');
    }
  }

  Future<List<EPCISEvent>> getEventsByBusinessStep(String businessStep) async {
    final headers = await _getHeaders();
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/business-step/$businessStep'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> eventList = json.decode(response.body);
      return eventList.map((json) => EPCISEvent.fromJson(json)).toList();
    } else {
      throw Exception('Failed to get events by business step: ${response.statusCode}');
    }
  }

  Future<List<EPCISEvent>> getEventsByDisposition(String disposition) async {
    final headers = await _getHeaders();
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/disposition/$disposition'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> eventList = json.decode(response.body);
      return eventList.map((json) => EPCISEvent.fromJson(json)).toList();
    } else {
      throw Exception('Failed to get events by disposition: ${response.statusCode}');
    }
  }

  Future<List<EPCISEvent>> getEventsByLocation(String locationGLN) async {
    final headers = await _getHeaders();
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/location/$locationGLN'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> eventList = json.decode(response.body);
      return eventList.map((json) => EPCISEvent.fromJson(json)).toList();
    } else {
      throw Exception('Failed to get events by location: ${response.statusCode}');
    }
  }

  Future<List<EPCISEvent>> getItemHistory(String epc) async {
    final headers = await _getHeaders();
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/track/$epc'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> eventList = json.decode(response.body);
      return eventList.map((json) => EPCISEvent.fromJson(json)).toList();
    } else {
      throw Exception('Failed to get item history: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> getItemStatus(String epc) async {
    final headers = await _getHeaders();
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/status/$epc'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get item status: ${response.statusCode}');
    }
  }
}
