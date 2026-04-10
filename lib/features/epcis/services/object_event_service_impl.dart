import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:traqtrace_app/core/config/app_config.dart';
import 'package:traqtrace_app/core/network/token_manager.dart';
import 'package:traqtrace_app/features/epcis/models/object_event.dart';
import 'package:traqtrace_app/features/epcis/models/epcis_types.dart';
import 'package:traqtrace_app/features/epcis/services/object_event_service.dart';

/// Enhanced implementation of ObjectEventService for Phase 3 capabilities
/// Supports comprehensive Object Event management with validation and advanced querying
class ObjectEventServiceImpl implements ObjectEventService {
  final http.Client _httpClient;
  final TokenManager _tokenManager;
  final AppConfig _appConfig;
  
  /// Base endpoint for object event API
  late final String _baseUrl;

  ObjectEventServiceImpl({
    required http.Client httpClient,
    required TokenManager tokenManager,
    required AppConfig appConfig,
  }) : _httpClient = httpClient,
       _tokenManager = tokenManager,
       _appConfig = appConfig {
    _baseUrl = '${_appConfig.apiBaseUrl}/events/object';
  }

  /// Get authorization headers for API requests
  Future<Map<String, String>> _getHeaders() async {
    final token = await _tokenManager.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  @override
  Future<Map<String, dynamic>> getAllEventsPaginated(int page, int size) async {
    final headers = await _getHeaders();
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl?page=$page&size=$size'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
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

  @override
  Future<ObjectEvent> getObjectEventById(String id) async {
    final headers = await _getHeaders();
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/$id'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return ObjectEvent.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to fetch object event: ${response.statusCode}');
    }
  }
  
  @override
  Future<ObjectEvent> getObjectEventByEventId(String eventId) async {
    final headers = await _getHeaders();
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/event-id/$eventId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return ObjectEvent.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to fetch object event: ${response.statusCode}');
    }
  }
  
  @override
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
      'eventId': 'event_${now.millisecondsSinceEpoch}_${(now.microsecond % 1000).toString().padLeft(3, '0')}',  // Generate unique event ID
      'eventType': 'ObjectEvent',  // Required by schema
      'action': action,
      'businessStep': businessStep,
      'disposition': disposition,
      'eventTime': now.toUtc().toIso8601String(),
      'recordTime': now.toUtc().toIso8601String(),  // Required by schema
      'epcisVersion': epcisVersion == EPCISVersion.v2_0 ? '2.0' : '1.3',
    };

    // Add timezone offset in ISO format
    final offset = now.timeZoneOffset;
    final hours = offset.inHours.abs();
    final minutes = (offset.inMinutes.abs() % 60);
    final sign = offset.isNegative ? '-' : '+';
    final timezoneOffset = '$sign${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
    eventData['eventTimeZoneOffset'] = timezoneOffset;

    if (readPointGLN != null) eventData['readPoint'] = readPointGLN;
    if (businessLocationGLN != null) eventData['businessLocation'] = businessLocationGLN;

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
      eventData['sourceList'] = sources.map((s) => {
        'sourceType': s.type,
        'sourceID': s.id,
      }).toList();
    }
    if (destinations != null && destinations.isNotEmpty) {
      eventData['destinationList'] = destinations.map((d) => {
        'destinationType': d.type,
        'destinationID': d.id,
      }).toList();
    }
    if (persistentDisposition != null) eventData['persistentDisposition'] = persistentDisposition;
    if (sensorElements != null) eventData['sensorElementList'] = sensorElements;
    if (certificationInfo != null) eventData['certificationInfo'] = certificationInfo;

    final response = await _httpClient.post(
      Uri.parse(_baseUrl),
      headers: headers,
      body: json.encode(eventData),
    );

    if (response.statusCode == 201) {
      try {
        final responseData = json.decode(response.body);
        return ObjectEvent.fromJson(responseData);
      } catch (e) {
        throw Exception('Failed to parse object event response: $e. Response body: ${response.body}');
      }
    } else {
      throw Exception('Failed to create object event: ${response.statusCode} - ${response.body}');
    }
  }

  @override
  Future<Map<String, dynamic>> validateObjectEvent(ObjectEvent event) async {
    final headers = await _getHeaders();
    try {
      final response = await _httpClient.post(
        Uri.parse('${_appConfig.apiBaseUrl}/validate/object-event'),
        headers: headers,
        body: json.encode(event.toJson()),
      );

      final responseData = json.decode(response.body) as Map<String, dynamic>;

      return responseData;
    } catch (e) {
      return {
        'valid': false,
        'error': 'Failed to validate object event: $e',
        'validationErrors': [],
      };
    }
  }

  @override
  Future<List<ObjectEvent>> createObjectEventsBatch(List<ObjectEvent> events) async {
    final headers = await _getHeaders();
    final response = await _httpClient.post(
      Uri.parse('$_baseUrl/batch'),
      headers: headers,
      body: json.encode(events.map((e) => e.toJson()).toList()),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> eventsData = data['events'];
      return eventsData.map((e) => ObjectEvent.fromJson(e)).toList();
    } else {
      throw Exception('Failed to create object events batch: ${response.body}');
    }
  }
  
  @override
  Future<ObjectEvent> updateObjectEvent(String id, ObjectEvent event) async {
    final headers = await _getHeaders();
    final response = await _httpClient.put(
      Uri.parse('$_baseUrl/$id'),
      headers: headers,
      body: json.encode(event.toJson()),
    );

    if (response.statusCode == 200) {
      return ObjectEvent.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update object event: ${response.statusCode}');
    }
  }
  
  @override
  Future<void> deleteObjectEvent(String id) async {
    final headers = await _getHeaders();
    final response = await _httpClient.delete(
      Uri.parse('$_baseUrl/$id'),
      headers: headers,
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete object event: ${response.statusCode}');
    }
  }
  
  @override
  Future<List<ObjectEvent>> findObjectEventsByAction(String action) async {
    final headers = await _getHeaders();
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/action/$action'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => ObjectEvent.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch object events by action: ${response.statusCode}');
    }
  }
  
  @override
  Future<List<ObjectEvent>> findObjectEventsByEPC(String epc) async {
    final headers = await _getHeaders();
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/epc/$epc'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => ObjectEvent.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch object events by EPC: ${response.statusCode}');
    }
  }

  @override
  Future<List<ObjectEvent>> findObjectEventsByEPCs(List<String> epcs) async {
    final headers = await _getHeaders();
    final epcsParam = epcs.join(',');
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/epcs?epcs=$epcsParam'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => ObjectEvent.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch object events by EPCs: ${response.body}');
    }
  }
  
  @override
  Future<List<ObjectEvent>> findObjectEventsByEPCClass(String epcClass) async {
    final headers = await _getHeaders();
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/epc-class/$epcClass'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => ObjectEvent.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch object events by EPC class: ${response.statusCode}');
    }
  }

  @override
  Future<List<ObjectEvent>> findObjectEventsByILMD(String property, String value) async {
    final headers = await _getHeaders();
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/ilmd?property=$property&value=$value'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => ObjectEvent.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch object events by ILMD: ${response.body}');
    }
  }
  
  @override
  Future<List<ObjectEvent>> findObjectEventsByQuantity(String epcClass, double minQuantity, double maxQuantity) async {
    final headers = await _getHeaders();
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/quantity?epcClass=$epcClass&min=$minQuantity&max=$maxQuantity'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => ObjectEvent.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch object events by quantity: ${response.statusCode}');
    }
  }

  @override
  Future<List<ObjectEvent>> findObjectEventsByBusinessStep(String businessStep) async {
    final headers = await _getHeaders();
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/business-step/$businessStep'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => ObjectEvent.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch object events by business step: ${response.body}');
    }
  }

  @override
  Future<List<ObjectEvent>> findObjectEventsByDisposition(String disposition) async {
    final headers = await _getHeaders();
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/disposition/$disposition'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => ObjectEvent.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch object events by disposition: ${response.body}');
    }
  }

  @override
  Future<List<ObjectEvent>> findObjectEventsByLocation(String locationGLN) async {
    final headers = await _getHeaders();
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/location/$locationGLN'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => ObjectEvent.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch object events by location: ${response.body}');
    }
  }

  @override
  Future<List<ObjectEvent>> findObjectEventsByTimeWindow(DateTime startTime, DateTime endTime) async {
    final headers = await _getHeaders();
    final startTimeStr = startTime.toUtc().toIso8601String();
    final endTimeStr = endTime.toUtc().toIso8601String();
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/time-range?startTime=$startTimeStr&endTime=$endTimeStr'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => ObjectEvent.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch object events by time window: ${response.body}');
    }
  }

  @override
  Future<List<ObjectEvent>> findObjectEventsByLocationAndTimeWindow(
      String locationGLN, DateTime startTime, DateTime endTime) async {
    final headers = await _getHeaders();
    final startTimeStr = startTime.toUtc().toIso8601String();
    final endTimeStr = endTime.toUtc().toIso8601String();
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/location/$locationGLN/time-range?startTime=$startTimeStr&endTime=$endTimeStr'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => ObjectEvent.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch object events by location and time window: ${response.body}');
    }
  }

  @override
  Future<Map<String, dynamic>> getEventStatistics({DateTime? startTime, DateTime? endTime}) async {
    final headers = await _getHeaders();

    // Build query parameters
    final queryParams = <String, String>{};
    if (startTime != null) {
      queryParams['startTime'] = startTime.toIso8601String();
    }
    if (endTime != null) {
      queryParams['endTime'] = endTime.toIso8601String();
    }

    final uri = Uri.parse('$_baseUrl/statistics').replace(queryParameters: queryParams);
    final response = await _httpClient.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      
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
      throw Exception('Failed to fetch event statistics: ${response.body}');
    }
  }

  @override
  Future<List<ObjectEvent>> findEPCHistory(String epc) async {
    final headers = await _getHeaders();
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/epc/$epc'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => ObjectEvent.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch EPC history: ${response.statusCode}');
    }
  }
  
  @override
  Future<ObjectEvent> getCurrentStatusOfEPC(String epc) async {
    final history = await findEPCHistory(epc);
    if (history.isEmpty) {
      throw Exception('No events found for EPC: $epc');
    }
    // Return the most recent event (assuming they're sorted by time)
    return history.first;
  }

  @override
  Future<ObjectEvent> createAddEvent(String epc, String locationGLN, String businessStep,
      String disposition, Map<String, dynamic> ilmd, Map<String, String> bizData) async {
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

    final response = await _httpClient.post(
      Uri.parse('$_baseUrl/add'),
      headers: headers,
      body: json.encode(eventData),
    );

    if (response.statusCode == 201) {
      return ObjectEvent.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create ADD event: ${response.body}');
    }
  }

  @override
  Future<ObjectEvent> createObserveEvent(String epc, String locationGLN, String businessStep,
      String disposition, Map<String, String> bizData) async {
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

    final response = await _httpClient.post(
      Uri.parse('$_baseUrl/observe'),
      headers: headers,
      body: json.encode(eventData),
    );

    if (response.statusCode == 201) {
      return ObjectEvent.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create OBSERVE event: ${response.body}');
    }
  }

  @override
  Future<ObjectEvent> createDeleteEvent(String epc, String locationGLN, String businessStep,
      String disposition, Map<String, String> bizData) async {
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

    final response = await _httpClient.post(
      Uri.parse('$_baseUrl/delete'),
      headers: headers,
      body: json.encode(eventData),
    );

    if (response.statusCode == 201) {
      return ObjectEvent.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create DELETE event: ${response.body}');
    }
  }

  @override
  Future<List<ObjectEvent>> findObjectEventsWithSensorData(Map<String, dynamic> sensorCriteria) async {
    // For EPCIS 2.0 sensor data queries
    final headers = await _getHeaders();
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl'), // Would filter events with sensor data
      headers: headers,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> content = data['content'];
      return content
          .map((e) => ObjectEvent.fromJson(e))
          .where((event) => event.sensorElementList != null && event.sensorElementList!.isNotEmpty)
          .toList();
    } else {
      throw Exception('Failed to fetch object events with sensor data: ${response.body}');
    }
  }

  @override
  Future<bool> validateEPC(String epc) async {
    // GS1 EPC validation using regex patterns
    final RegExp sgtin = RegExp(
      r'^urn:epc:id:sgtin:(\d+)\.(\d+)\.(\w+)$',
      caseSensitive: false
    );

    final RegExp sscc = RegExp(
      r'^urn:epc:id:sscc:(\d+)\.(\d+)$',
      caseSensitive: false
    );

    final RegExp sgln = RegExp(
      r'^urn:epc:id:sgln:(\d+)\.(\d+)\.(\w*)$',
      caseSensitive: false
    );

    return sgtin.hasMatch(epc) || sscc.hasMatch(epc) || sgln.hasMatch(epc);
  }
  
  @override
  Future<String> convertGS1ElementStringToEPC(String gs1ElementString) async {
    // Convert GS1 Element String to EPC URI format
    if (gs1ElementString.startsWith('01') && gs1ElementString.contains('21')) {
      final gtin = gs1ElementString.substring(2, 16);
      final serial = gs1ElementString.substring(gs1ElementString.indexOf('21') + 2);

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

  @override
  Future<List<ObjectEvent>> findObjectEventsByBusinessStepAndEPC(String businessStep, String epc) async {
    final headers = await _getHeaders();
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/business-step/$businessStep/epc/$epc'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => ObjectEvent.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch object events by business step and EPC: ${response.body}');
    }
  }
}
