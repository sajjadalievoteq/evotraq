import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';
import 'package:traqtrace_app/features/epcis/models/epcis_document_dto.dart';
import 'package:traqtrace_app/features/epcis/models/epcis_event.dart';
import 'package:traqtrace_app/features/epcis/models/epcis_query_parameters_dto.dart';


/// Implementation of the EPCIS Event Service using HTTP
class EPCISEventService {
  final DioService _dioService;
  
  /// Base endpoint for EPCIS events API
  late final String _baseUrl;
  EPCISEventService({required DioService dioService}) : _dioService = dioService {
    _baseUrl = '${_dioService.baseUrl}/events';
  }

  /// Get authorization headers for API requests
  Future<Map<String, String>> _getHeaders() async {
    final token = await _dioService.getAuthToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<EPCISEvent>> getAllEvents() async {
    final headers = await _getHeaders();
    final response = await _dioService.get(
      _baseUrl,
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> eventList = json.decode(response.data);
      return eventList.map((json) => EPCISEvent.fromJson(json)).toList();
    } else {
      throw Exception('Failed to get events: ${response.statusCode}');
    }
  }
  
  Future<Map<String, dynamic>> getAllEventsPaginated(int page, int size) async {
    final headers = await _getHeaders();
    final response = await _dioService.get(
      _baseUrl,
      queryParameters: {'page': page.toString(), 'size': size.toString()},
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.data);
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
    final response = await _dioService.delete(
      '$_baseUrl/$id',
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete event: ${response.statusCode}');
    }
  }

  Future<List<EPCISEvent>> findEventsByTimeWindow(DateTime startTime, DateTime endTime) async {
    final headers = await _getHeaders();
    final String startTimeStr = startTime.toUtc().toIso8601String();
    final String endTimeStr = endTime.toUtc().toIso8601String();

    final response = await _dioService.get(
      '$_baseUrl/time-range',
      queryParameters: {'startTime': startTimeStr, 'endTime': endTimeStr},
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> eventList = json.decode(response.data);
      return eventList.map((json) => EPCISEvent.fromJson(json)).toList();
    } else {
      throw Exception('Failed to find events by time window: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> captureEvents(EPCISDocumentDTO epcisDocument) async {
    final headers = await _getHeaders();
    final response = await _dioService.post(
      '$_baseUrl/capture',
      headers: headers,
      data: json.encode(epcisDocument.toJson()),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 201) {
      return json.decode(response.data);
    } else {
      throw Exception('Failed to capture events: ${response.statusCode}');
    }
  }

  Future<EPCISEvent> getEventById(String id) async {
    final headers = await _getHeaders();
    final response = await _dioService.get(
      '$_baseUrl/$id',
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return EPCISEvent.fromJson(json.decode(response.data));
    } else {
      throw Exception('Failed to get event: ${response.statusCode}');
    }
  }

  Future<List<EPCISEvent>> getEventsByEPC(String epc) async {
    final headers = await _getHeaders();
    final response = await _dioService.get(
      '$_baseUrl/epc/$epc',
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> eventList = json.decode(response.data);
      return eventList.map((json) => EPCISEvent.fromJson(json)).toList();
    } else {
      throw Exception('Failed to get events by EPC: ${response.statusCode}');
    }
  }

  Future<List<EPCISEvent>> queryEvents(EPCISQueryParametersDTO queryParams) async {
    final headers = await _getHeaders();
    final response = await _dioService.post(
      '$_baseUrl/query',
      headers: headers,
      data: json.encode(queryParams.toJson()),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> eventList = json.decode(response.data);
      return eventList.map((json) => EPCISEvent.fromJson(json)).toList();
    } else {
      throw Exception('Failed to query events: ${response.statusCode}');
    }
  }

  Future<List<EPCISEvent>> getEventsByBusinessStep(String businessStep) async {
    final headers = await _getHeaders();
    final response = await _dioService.get(
      '$_baseUrl/business-step/$businessStep',
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> eventList = json.decode(response.data);
      return eventList.map((json) => EPCISEvent.fromJson(json)).toList();
    } else {
      throw Exception('Failed to get events by business step: ${response.statusCode}');
    }
  }

  Future<List<EPCISEvent>> getEventsByDisposition(String disposition) async {
    final headers = await _getHeaders();
    final response = await _dioService.get(
      '$_baseUrl/disposition/$disposition',
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> eventList = json.decode(response.data);
      return eventList.map((json) => EPCISEvent.fromJson(json)).toList();
    } else {
      throw Exception('Failed to get events by disposition: ${response.statusCode}');
    }
  }

  Future<List<EPCISEvent>> getEventsByLocation(String locationGLN) async {
    final headers = await _getHeaders();
    final response = await _dioService.get(
      '$_baseUrl/location/$locationGLN',
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> eventList = json.decode(response.data);
      return eventList.map((json) => EPCISEvent.fromJson(json)).toList();
    } else {
      throw Exception('Failed to get events by location: ${response.statusCode}');
    }
  }

  Future<List<EPCISEvent>> getItemHistory(String epc) async {
    final headers = await _getHeaders();
    final response = await _dioService.get(
      '$_baseUrl/track/$epc',
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> eventList = json.decode(response.data);
      return eventList.map((json) => EPCISEvent.fromJson(json)).toList();
    } else {
      throw Exception('Failed to get item history: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> getItemStatus(String epc) async {
    final headers = await _getHeaders();
    final response = await _dioService.get(
      '$_baseUrl/status/$epc',
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return json.decode(response.data);
    } else {
      throw Exception('Failed to get item status: ${response.statusCode}');
    }
  }
}
