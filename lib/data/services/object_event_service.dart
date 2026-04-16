import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';
import 'package:traqtrace_app/features/epcis/models/object_event.dart';
import 'package:traqtrace_app/features/epcis/models/epcis_types.dart';

/// Enhanced implementation of ObjectEventService for Phase 3 capabilities
/// Supports comprehensive Object Event management with validation and advanced querying
class ObjectEventService {
  final DioService _dioService;

  /// Base endpoint for object event API
  late final String _baseUrl;

  ObjectEventService({required DioService dioService})
    : _dioService = dioService {
    _baseUrl = '${_dioService.baseUrl}/events/object';
  }

  /// Get authorization headers for API requests
  Future<Map<String, String>> _getHeaders() async {
    final token = await _dioService.getAuthToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
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
      final List<dynamic> content = data['content'];

      return {
        'content': content.map((e) => ObjectEvent.fromJson(e)).toList(),
        'totalElements': data['totalElements'],
        'totalPages': data['totalPages'],
        'currentPage': data['number'],
        'size': data['size'],
        'first': data['first'],
        'last': data['last'],
      };
    } else {
      throw Exception('Failed to load events: ${response.statusCode}');
    }
  }

  Future<ObjectEvent> getObjectEventById(String id) async {
    final headers = await _getHeaders();
    final response = await _dioService.get(
      '$_baseUrl/$id',
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return ObjectEvent.fromJson(json.decode(response.data));
    } else {
      throw Exception('Failed to fetch object event: ${response.statusCode}');
    }
  }

  Future<ObjectEvent> getObjectEventByEventId(String eventId) async {
    final headers = await _getHeaders();
    final response = await _dioService.get(
      '$_baseUrl/event-id/$eventId',
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return ObjectEvent.fromJson(json.decode(response.data));
    } else {
      throw Exception('Failed to fetch object event: ${response.statusCode}');
    }
  }

  Future<ObjectEvent> createObjectEvent({
    required String action,
    required String businessStep,
    required String disposition,
    String? readPointGLN,
    String? businessLocationGLN,
    List<String>? epcs,
    List<String>? epcClasses,
    List<QuantityElement>? quantities,
    Map<String, dynamic>? ilmd,
    Map<String, String>? bizData,
    List<SourceDestination>? sources,
    List<SourceDestination>? destinations,
    String? persistentDisposition,
    List<Map<String, dynamic>>? sensorElements,
    List<Map<String, dynamic>>? certificationInfo,
    EPCISVersion epcisVersion = EPCISVersion.v2_0,
  }) async {
    final headers = await _getHeaders();

    final now = DateTime.now();
    final eventData = <String, dynamic>{
      'eventId':
          'event_${now.millisecondsSinceEpoch}_${(now.microsecond % 1000).toString().padLeft(3, '0')}', // Generate unique event ID
      'eventType': 'ObjectEvent', // Required by schema
      'action': action,
      'businessStep': businessStep,
      'disposition': disposition,
      'eventTime': now.toUtc().toIso8601String(),
      'recordTime': now.toUtc().toIso8601String(), // Required by schema
      'epcisVersion': epcisVersion == EPCISVersion.v2_0 ? '2.0' : '1.3',
    };

    // Add timezone offset in ISO format
    final offset = now.timeZoneOffset;
    final hours = offset.inHours.abs();
    final minutes = (offset.inMinutes.abs() % 60);
    final sign = offset.isNegative ? '-' : '+';
    final timezoneOffset =
        '$sign${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
    eventData['eventTimeZoneOffset'] = timezoneOffset;

    if (readPointGLN != null) eventData['readPoint'] = readPointGLN;
    if (businessLocationGLN != null)
      eventData['businessLocation'] = businessLocationGLN;

    // Handle the schema's oneOf constraint: either epcList OR quantityList, not both
    if (epcs != null && epcs.isNotEmpty) {
      eventData['epcList'] = epcs;
      // For schema compliance, ensure quantityList is either null or empty array when epcList is present
      eventData['quantityList'] = [];
    } else if (quantities != null && quantities.isNotEmpty) {
      eventData['quantityList'] = quantities.map((q) => q.toJson()).toList();
      // For schema compliance, ensure epcList is null when quantityList is present
      // Don't include epcList field at all in this case
    } else {
      // If neither is provided, default to empty epcList to satisfy schema requirements
      eventData['epcList'] = [];
      eventData['quantityList'] = [];
    }

    if (ilmd != null) eventData['ilmd'] = ilmd;
    if (bizData != null) eventData['bizData'] = bizData;
    if (sources != null && sources.isNotEmpty) {
      eventData['sourceList'] = sources
          .map((s) => {'sourceType': s.type, 'sourceID': s.id})
          .toList();
    }
    if (destinations != null && destinations.isNotEmpty) {
      eventData['destinationList'] = destinations
          .map((d) => {'destinationType': d.type, 'destinationID': d.id})
          .toList();
    }
    if (persistentDisposition != null)
      eventData['persistentDisposition'] = persistentDisposition;
    if (sensorElements != null) eventData['sensorElementList'] = sensorElements;
    if (certificationInfo != null)
      eventData['certificationInfo'] = certificationInfo;

    final response = await _dioService.post(
      _baseUrl,
      headers: headers,
      data: json.encode(eventData),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 201) {
      try {
        final responseData = json.decode(response.data);
        return ObjectEvent.fromJson(responseData);
      } catch (e) {
        throw Exception(
          'Failed to parse object event response: $e. Response body: ${response.data}',
        );
      }
    } else {
      throw Exception(
        'Failed to create object event: ${response.statusCode} - ${response.data}',
      );
    }
  }

  Future<Map<String, dynamic>> validateObjectEvent(ObjectEvent event) async {
    final headers = await _getHeaders();
    try {
      final response = await _dioService.post(
        '${_dioService.baseUrl}/validate/object-event',
        headers: headers,
        data: json.encode(event.toJson()),
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      final responseData = json.decode(response.data) as Map<String, dynamic>;

      return responseData;
    } catch (e) {
      return {
        'valid': false,
        'error': 'Failed to validate object event: $e',
        'validationErrors': [],
      };
    }
  }

  Future<List<ObjectEvent>> createObjectEventsBatch(
    List<ObjectEvent> events,
  ) async {
    final headers = await _getHeaders();
    final response = await _dioService.post(
      '$_baseUrl/batch',
      headers: headers,
      data: json.encode(events.map((e) => e.toJson()).toList()),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.data);
      final List<dynamic> eventsData = data['events'];
      return eventsData.map((e) => ObjectEvent.fromJson(e)).toList();
    } else {
      throw Exception('Failed to create object events batch: ${response.data}');
    }
  }

  Future<ObjectEvent> updateObjectEvent(String id, ObjectEvent event) async {
    final headers = await _getHeaders();
    final response = await _dioService.put(
      '$_baseUrl/$id',
      headers: headers,
      data: json.encode(event.toJson()),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return ObjectEvent.fromJson(json.decode(response.data));
    } else {
      throw Exception('Failed to update object event: ${response.statusCode}');
    }
  }

  Future<void> deleteObjectEvent(String id) async {
    final headers = await _getHeaders();
    final response = await _dioService.delete(
      '$_baseUrl/$id',
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete object event: ${response.statusCode}');
    }
  }

  Future<List<ObjectEvent>> findObjectEventsByAction(String action) async {
    final headers = await _getHeaders();
    final response = await _dioService.get(
      '$_baseUrl/action/$action',
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.data);
      return data.map((e) => ObjectEvent.fromJson(e)).toList();
    } else {
      throw Exception(
        'Failed to fetch object events by action: ${response.statusCode}',
      );
    }
  }

  Future<List<ObjectEvent>> findObjectEventsByEPC(String epc) async {
    final headers = await _getHeaders();
    final response = await _dioService.get(
      '$_baseUrl/epc/$epc',
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.data);
      return data.map((e) => ObjectEvent.fromJson(e)).toList();
    } else {
      throw Exception(
        'Failed to fetch object events by EPC: ${response.statusCode}',
      );
    }
  }

  Future<List<ObjectEvent>> findObjectEventsByEPCs(List<String> epcs) async {
    final headers = await _getHeaders();
    final epcsParam = epcs.join(',');
    final response = await _dioService.get(
      '$_baseUrl/epcs',
      queryParameters: {'epcs': epcsParam},
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.data);
      return data.map((e) => ObjectEvent.fromJson(e)).toList();
    } else {
      throw Exception(
        'Failed to fetch object events by EPCs: ${response.data}',
      );
    }
  }

  Future<List<ObjectEvent>> findObjectEventsByEPCClass(String epcClass) async {
    final headers = await _getHeaders();
    final response = await _dioService.get(
      '$_baseUrl/epc-class/$epcClass',
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.data);
      return data.map((e) => ObjectEvent.fromJson(e)).toList();
    } else {
      throw Exception(
        'Failed to fetch object events by EPC class: ${response.statusCode}',
      );
    }
  }

  Future<List<ObjectEvent>> findObjectEventsByILMD(
    String property,
    String value,
  ) async {
    final headers = await _getHeaders();
    final response = await _dioService.get(
      '$_baseUrl/ilmd',
      queryParameters: {'property': property, 'value': value},
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.data);
      return data.map((e) => ObjectEvent.fromJson(e)).toList();
    } else {
      throw Exception(
        'Failed to fetch object events by ILMD: ${response.data}',
      );
    }
  }

  Future<List<ObjectEvent>> findObjectEventsByQuantity(
    String epcClass,
    double minQuantity,
    double maxQuantity,
  ) async {
    final headers = await _getHeaders();
    final response = await _dioService.get(
      '$_baseUrl/quantity',
      queryParameters: {
        'epcClass': epcClass,
        'min': minQuantity.toString(),
        'max': maxQuantity.toString(),
      },
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.data);
      return data.map((e) => ObjectEvent.fromJson(e)).toList();
    } else {
      throw Exception(
        'Failed to fetch object events by quantity: ${response.statusCode}',
      );
    }
  }

  Future<List<ObjectEvent>> findObjectEventsByBusinessStep(
    String businessStep,
  ) async {
    final headers = await _getHeaders();
    final response = await _dioService.get(
      '$_baseUrl/business-step/$businessStep',
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.data);
      return data.map((e) => ObjectEvent.fromJson(e)).toList();
    } else {
      throw Exception(
        'Failed to fetch object events by business step: ${response.data}',
      );
    }
  }

  Future<List<ObjectEvent>> findObjectEventsByDisposition(
    String disposition,
  ) async {
    final headers = await _getHeaders();
    final response = await _dioService.get(
      '$_baseUrl/disposition/$disposition',
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.data);
      return data.map((e) => ObjectEvent.fromJson(e)).toList();
    } else {
      throw Exception(
        'Failed to fetch object events by disposition: ${response.data}',
      );
    }
  }

  Future<List<ObjectEvent>> findObjectEventsByLocation(
    String locationGLN,
  ) async {
    final headers = await _getHeaders();
    final response = await _dioService.get(
      '$_baseUrl/location/$locationGLN',
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.data);
      return data.map((e) => ObjectEvent.fromJson(e)).toList();
    } else {
      throw Exception(
        'Failed to fetch object events by location: ${response.data}',
      );
    }
  }

  Future<List<ObjectEvent>> findObjectEventsByTimeWindow(
    DateTime startTime,
    DateTime endTime,
  ) async {
    final headers = await _getHeaders();
    final startTimeStr = startTime.toUtc().toIso8601String();
    final endTimeStr = endTime.toUtc().toIso8601String();
    final response = await _dioService.get(
      '$_baseUrl/time-range',
      queryParameters: {'startTime': startTimeStr, 'endTime': endTimeStr},
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.data);
      return data.map((e) => ObjectEvent.fromJson(e)).toList();
    } else {
      throw Exception(
        'Failed to fetch object events by time window: ${response.data}',
      );
    }
  }

  Future<List<ObjectEvent>> findObjectEventsByLocationAndTimeWindow(
    String locationGLN,
    DateTime startTime,
    DateTime endTime,
  ) async {
    final headers = await _getHeaders();
    final startTimeStr = startTime.toUtc().toIso8601String();
    final endTimeStr = endTime.toUtc().toIso8601String();
    final response = await _dioService.get(
      '$_baseUrl/location/$locationGLN/time-range',
      queryParameters: {'startTime': startTimeStr, 'endTime': endTimeStr},
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.data);
      return data.map((e) => ObjectEvent.fromJson(e)).toList();
    } else {
      throw Exception(
        'Failed to fetch object events by location and time window: ${response.data}',
      );
    }
  }

  Future<Map<String, dynamic>> getEventStatistics({
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    final headers = await _getHeaders();

    // Build query parameters
    final queryParams = <String, String>{};
    if (startTime != null) {
      queryParams['startTime'] = startTime.toIso8601String();
    }
    if (endTime != null) {
      queryParams['endTime'] = endTime.toIso8601String();
    }

    final uri = Uri.parse(
      '$_baseUrl/statistics',
    ).replace(queryParameters: queryParams);
    final response = await _dioService.get(
      uri.toString(),
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.data);

      // Transform backend response to match frontend expectations
      Map<String, dynamic> transformedData = {
        'totalEvents': data['totalEvents'] ?? 0,
        'recentEvents': data['recentEvents'] ?? 0,
      };

      // Transform eventsByAction to actionCounts
      if (data['eventsByAction'] != null) {
        transformedData['actionCounts'] = data['eventsByAction'];
      }

      // Transform topBusinessSteps to businessStepCounts
      if (data['topBusinessSteps'] != null) {
        transformedData['businessStepCounts'] = data['topBusinessSteps'];
      }

      // Transform topDispositions to dispositionCounts
      if (data['topDispositions'] != null) {
        transformedData['dispositionCounts'] = data['topDispositions'];
      } else {
        transformedData['dispositionCounts'] = <String, int>{};
      }

      return transformedData;
    } else {
      throw Exception('Failed to fetch event statistics: ${response.data}');
    }
  }

  Future<List<ObjectEvent>> findEPCHistory(String epc) async {
    final headers = await _getHeaders();
    final response = await _dioService.get(
      '$_baseUrl/epc/$epc',
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.data);
      return data.map((e) => ObjectEvent.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch EPC history: ${response.statusCode}');
    }
  }

  Future<ObjectEvent> getCurrentStatusOfEPC(String epc) async {
    final history = await findEPCHistory(epc);
    if (history.isEmpty) {
      throw Exception('No events found for EPC: $epc');
    }
    // Return the most recent event (assuming they're sorted by time)
    return history.first;
  }

  Future<ObjectEvent> createAddEvent(
    String epc,
    String locationGLN,
    String businessStep,
    String disposition,
    Map<String, dynamic> ilmd,
    Map<String, String> bizData,
  ) async {
    final headers = await _getHeaders();

    final eventData = {
      'action': 'ADD',
      'epcList': [epc],
      'businessLocation': locationGLN,
      'businessStep': businessStep,
      'disposition': disposition,
      'ilmd': ilmd,
      'bizData': bizData,
      'eventTime': DateTime.now().toUtc().toIso8601String(),
    };

    final response = await _dioService.post(
      '$_baseUrl/add',
      headers: headers,
      data: json.encode(eventData),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 201) {
      return ObjectEvent.fromJson(json.decode(response.data));
    } else {
      throw Exception('Failed to create ADD event: ${response.data}');
    }
  }

  Future<ObjectEvent> createObserveEvent(
    String epc,
    String locationGLN,
    String businessStep,
    String disposition,
    Map<String, String> bizData,
  ) async {
    final headers = await _getHeaders();

    final eventData = {
      'action': 'OBSERVE',
      'epcList': [epc],
      'businessLocation': locationGLN,
      'businessStep': businessStep,
      'disposition': disposition,
      'bizData': bizData,
      'eventTime': DateTime.now().toUtc().toIso8601String(),
    };

    final response = await _dioService.post(
      '$_baseUrl/observe',
      headers: headers,
      data: json.encode(eventData),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 201) {
      return ObjectEvent.fromJson(json.decode(response.data));
    } else {
      throw Exception('Failed to create OBSERVE event: ${response.data}');
    }
  }

  Future<ObjectEvent> createDeleteEvent(
    String epc,
    String locationGLN,
    String businessStep,
    String disposition,
    Map<String, String> bizData,
  ) async {
    final headers = await _getHeaders();

    final eventData = {
      'action': 'DELETE',
      'epcList': [epc],
      'businessLocation': locationGLN,
      'businessStep': businessStep,
      'disposition': disposition,
      'bizData': bizData,
      'eventTime': DateTime.now().toUtc().toIso8601String(),
    };

    final response = await _dioService.post(
      '$_baseUrl/delete',
      headers: headers,
      data: json.encode(eventData),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 201) {
      return ObjectEvent.fromJson(json.decode(response.data));
    } else {
      throw Exception('Failed to create DELETE event: ${response.data}');
    }
  }

  Future<List<ObjectEvent>> findObjectEventsWithSensorData(
    Map<String, dynamic> sensorCriteria,
  ) async {
    // For EPCIS 2.0 sensor data queries
    final headers = await _getHeaders();
    final response = await _dioService.get(
      _baseUrl, // Would filter events with sensor data
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.data);
      final List<dynamic> content = data['content'];
      return content
          .map((e) => ObjectEvent.fromJson(e))
          .where(
            (event) =>
                event.sensorElementList != null &&
                event.sensorElementList!.isNotEmpty,
          )
          .toList();
    } else {
      throw Exception(
        'Failed to fetch object events with sensor data: ${response.data}',
      );
    }
  }

  Future<bool> validateEPC(String epc) async {
    // GS1 EPC validation using regex patterns
    final RegExp sgtin = RegExp(
      r'^urn:epc:id:sgtin:(\d+)\.(\d+)\.(\w+)$',
      caseSensitive: false,
    );

    final RegExp sscc = RegExp(
      r'^urn:epc:id:sscc:(\d+)\.(\d+)$',
      caseSensitive: false,
    );

    final RegExp sgln = RegExp(
      r'^urn:epc:id:sgln:(\d+)\.(\d+)\.(\w*)$',
      caseSensitive: false,
    );

    return sgtin.hasMatch(epc) || sscc.hasMatch(epc) || sgln.hasMatch(epc);
  }

  Future<String> convertGS1ElementStringToEPC(String gs1ElementString) async {
    // Convert GS1 Element String to EPC URI format
    if (gs1ElementString.startsWith('01') && gs1ElementString.contains('21')) {
      final gtin = gs1ElementString.substring(2, 16);
      final serial = gs1ElementString.substring(
        gs1ElementString.indexOf('21') + 2,
      );

      final companyPrefix = gtin.substring(1, 7);
      final itemReference = gtin.substring(7, 13);

      return 'urn:epc:id:sgtin:$companyPrefix.$itemReference.$serial';
    }

    if (gs1ElementString.startsWith('00')) {
      final sscc = gs1ElementString.substring(2, 20);
      final companyPrefix = sscc.substring(1, 8);
      final serialReference = sscc.substring(8, 18);

      return 'urn:epc:id:sscc:$companyPrefix.$serialReference';
    }

    throw Exception('Unsupported GS1 element string format');
  }

  Future<List<ObjectEvent>> findObjectEventsByBusinessStepAndEPC(
    String businessStep,
    String epc,
  ) async {
    final headers = await _getHeaders();
    final response = await _dioService.get(
      '$_baseUrl/business-step/$businessStep/epc/$epc',
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.data);
      return data.map((e) => ObjectEvent.fromJson(e)).toList();
    } else {
      throw Exception(
        'Failed to fetch object events by business step and EPC: ${response.data}',
      );
    }
  }
}
