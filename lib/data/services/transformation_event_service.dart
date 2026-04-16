import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';
import 'package:traqtrace_app/features/epcis/models/transformation_event.dart';

/// Implementation of the TransformationEventService interface
class TransformationEventService {
  final DioService _dioService;

  /// Base endpoint for transformation event API
  late final String _baseUrl;
  TransformationEventService({
    required DioService dioService,
  }) : _dioService = dioService {
    _baseUrl = '${_dioService.baseUrl}/transformation-events';
  }

  /// Get authorization headers for API requests
  Future<Map<String, String>> _getHeaders() async {
    final token = await _dioService.getAuthToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<TransformationEvent> getTransformationEventById(String id) async {
    final headers = await _getHeaders();
    final response = await _dioService.get(
      '$_baseUrl/$id',
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return TransformationEvent.fromJson(json.decode(response.data));
    } else {
      throw Exception(
        'Failed to get transformation event: ${response.statusCode}',
      );
    }
  }

  Future<TransformationEvent> getTransformationEventByEventId(
    String eventId,
  ) async {
    final headers = await _getHeaders();
    // Call the specific endpoint for getting event by eventId
    final response = await _dioService.get(
      '$_baseUrl/event/$eventId',
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return TransformationEvent.fromJson(json.decode(response.data));
    } else {
      throw Exception(
        'Failed to get transformation event: ${response.statusCode}',
      );
    }
  }

  Future<TransformationEvent> createTransformationEvent(
    TransformationEvent event,
  ) async {
    final headers = await _getHeaders();
    final response = await _dioService.post(
      _baseUrl,
      headers: headers,
      data: json.encode(event.toJson()),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 201) {
      return TransformationEvent.fromJson(json.decode(response.data));
    } else {
      throw Exception(
        'Failed to create transformation event: ${response.statusCode}',
      );
    }
  }

  Future<TransformationEvent> updateTransformationEvent(
    String id,
    TransformationEvent event,
  ) async {
    final headers = await _getHeaders();
    final response = await _dioService.put(
      '$_baseUrl/$id',
      headers: headers,
      data: json.encode(event.toJson()),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return TransformationEvent.fromJson(json.decode(response.data));
    } else {
      throw Exception(
        'Failed to update transformation event: ${response.statusCode}',
      );
    }
  }

  Future<void> deleteTransformationEvent(String id) async {
    final headers = await _getHeaders();
    final response = await _dioService.delete(
      '$_baseUrl/$id',
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode != 204) {
      throw Exception(
        'Failed to delete transformation event: ${response.statusCode}',
      );
    }
  }

  Future<List<TransformationEvent>> findTransformationEventsByTransformationId(
    String transformationId,
  ) async {
    final headers = await _getHeaders();
    final response = await _dioService.get(
      '$_baseUrl/by-transformation/$transformationId',
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.data);
      return data.map((json) => TransformationEvent.fromJson(json)).toList();
    } else {
      throw Exception(
        'Failed to find transformations by transformation ID: ${response.statusCode}',
      );
    }
  }

  Future<List<TransformationEvent>> findTransformationEventsByInputEPC(
    String inputEPC,
  ) async {
    final headers = await _getHeaders();
    final response = await _dioService.get(
      '$_baseUrl/product/$inputEPC',
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> eventList = json.decode(response.data);
      return eventList
          .map((json) => TransformationEvent.fromJson(json))
          .toList();
    } else {
      throw Exception(
        'Failed to find transformation events: ${response.statusCode}',
      );
    }
  }

  Future<List<TransformationEvent>> findTransformationEventsByOutputEPC(
    String outputEPC,
  ) async {
    final headers = await _getHeaders();
    final response = await _dioService.get(
      '$_baseUrl/product/$outputEPC',
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> eventList = json.decode(response.data);
      return eventList
          .map((json) => TransformationEvent.fromJson(json))
          .toList();
    } else {
      throw Exception(
        'Failed to find transformation events: ${response.statusCode}',
      );
    }
  }

  Future<List<TransformationEvent>> findTransformationEventsByInputEPCClass(
    String inputEPCClass,
  ) async {
    final headers = await _getHeaders();
    final response = await _dioService.get(
      '$_baseUrl/batch/$inputEPCClass',
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> eventList = json.decode(response.data);
      return eventList
          .map((json) => TransformationEvent.fromJson(json))
          .toList();
    } else {
      throw Exception(
        'Failed to find transformation events: ${response.statusCode}',
      );
    }
  }

  Future<List<TransformationEvent>> findTransformationEventsByOutputEPCClass(
    String outputEPCClass,
  ) async {
    final headers = await _getHeaders();
    final response = await _dioService.get(
      '$_baseUrl/batch/$outputEPCClass',
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> eventList = json.decode(response.data);
      return eventList
          .map((json) => TransformationEvent.fromJson(json))
          .toList();
    } else {
      throw Exception(
        'Failed to find transformation events: ${response.statusCode}',
      );
    }
  }

  Future<List<TransformationEvent>> findTransformationEventsByInputAndOutputEPC(
    String inputEPC,
    String outputEPC,
  ) async {
    final headers = await _getHeaders();
    // Use the new input-output endpoint with query parameters
    final response = await _dioService.get(
      '$_baseUrl/input-output',
      queryParameters: {'inputEPC': inputEPC, 'outputEPC': outputEPC},
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.data);
      return data.map((json) => TransformationEvent.fromJson(json)).toList();
    } else {
      throw Exception(
        'Failed to find transformation events: ${response.statusCode}',
      );
    }
  }

  Future<List<TransformationEvent>> findTransformationEventsByParameter(
    String paramName,
    String paramValue,
  ) async {
    final headers = await _getHeaders();
    // There's no direct endpoint for parameter search, so we'll get all events and filter client-side
    final response = await _dioService.get(
      _baseUrl,
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> eventList = json.decode(response.data);
      final allEvents = eventList
          .map((json) => TransformationEvent.fromJson(json))
          .toList();

      // Filter events by parameter
      return allEvents.where((event) {
        final bizData = event.bizData ?? {};
        return bizData[paramName] == paramValue;
      }).toList();
    } else {
      throw Exception(
        'Failed to find transformation events: ${response.statusCode}',
      );
    }
  }

  Future<List<TransformationEvent>> findTransformationHistoryForOutput(
    String outputEPC,
  ) async {
    final headers = await _getHeaders();
    // Use the product endpoint since there's no specific history endpoint
    final response = await _dioService.get(
      '$_baseUrl/product/$outputEPC',
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> eventList = json.decode(response.data);
      final events = eventList
          .map((json) => TransformationEvent.fromJson(json))
          .toList();

      // Sort by event time to get history in chronological order
      events.sort((a, b) => a.eventTime.compareTo(b.eventTime));
      return events;
    } else {
      throw Exception(
        'Failed to find transformation history: ${response.statusCode}',
      );
    }
  }

  Future<List<TransformationEvent>>
  findTransformationEventsByLocationAndTimeWindow(
    String locationGLN,
    DateTime startTime,
    DateTime endTime,
  ) async {
    // While there's no direct endpoint for this combined query, we can use pagination and filters more efficiently
    final headers = await _getHeaders();

    // Use the pagination endpoint with a larger page size
    final response = await _dioService.get(
      _baseUrl,
      queryParameters: {
        'page': '0',
        'size': '100',
        'sortBy': 'eventTime',
        'direction': 'ASC',
      },
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.data);

      if (responseData['content'] != null && responseData['content'] is List) {
        final List<dynamic> eventList = responseData['content'];
        final allEvents = eventList
            .map((json) => TransformationEvent.fromJson(json))
            .toList();

        // Filter by location and time window
        return allEvents
            .where(
              (event) =>
                  event.readPoint != null &&
                  event.readPoint!.toString().contains(locationGLN) &&
                  event.eventTime.isAfter(startTime) &&
                  event.eventTime.isBefore(endTime),
            )
            .toList();
      } else {
        throw Exception('Invalid response format');
      }
    } else {
      throw Exception(
        'Failed to find transformation events: ${response.statusCode}',
      );
    }
  }

  Future<TransformationEvent> createTransformationProcess(
    String transformationId,
    Set<String> inputEPCs,
    Set<String> outputEPCs,
    String locationGLN,
    String businessStep,
    String disposition,
    Map<String, String> parameters,
    Map<String, String> bizData,
  ) async {
    final headers = await _getHeaders();

    // Build a transformation event DTO
    final transformationEventDto = {
      'transformationID': transformationId,
      'inputEPCList': inputEPCs.toList(),
      'outputEPCList': outputEPCs.toList(),
      'businessLocation': locationGLN,
      'businessStep': businessStep,
      'disposition': disposition,
      'bizData': bizData,
      // Add any other required fields
      'eventTime': DateTime.now().toIso8601String(),
      'eventTimeZoneOffset': DateTime.now().timeZoneOffset.toString(),
    };

    final response = await _dioService.post(
      _baseUrl,
      headers: headers,
      data: json.encode(transformationEventDto),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 201) {
      return TransformationEvent.fromJson(json.decode(response.data));
    } else {
      throw Exception(
        'Failed to create transformation process: ${response.statusCode}',
      );
    }
  }

  Future<List<TransformationEvent>> findTransformationsByEPC(String epc) async {
    final headers = await _getHeaders();
    final response = await _dioService.get(
      '$_baseUrl/track/$epc',
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.data);
      return data.map((json) => TransformationEvent.fromJson(json)).toList();
    } else {
      throw Exception(
        'Failed to find transformations for EPC: ${response.statusCode}',
      );
    }
  }

  Future<List<TransformationEvent>> findTransformationsByInputAndOutputEPC(
    String inputEPC,
    String outputEPC,
  ) async {
    final headers = await _getHeaders();
    final response = await _dioService.get(
      '$_baseUrl/input-output',
      queryParameters: {'inputEPC': inputEPC, 'outputEPC': outputEPC},
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.data);
      return data.map((json) => TransformationEvent.fromJson(json)).toList();
    } else {
      throw Exception(
        'Failed to find transformations by input-output relationship: ${response.statusCode}',
      );
    }
  }
}
