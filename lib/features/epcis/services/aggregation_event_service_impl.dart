import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:traqtrace_app/core/config/app_config.dart';
import 'package:traqtrace_app/core/network/token_manager.dart';
import 'package:traqtrace_app/features/epcis/models/aggregation_event.dart';
import 'package:traqtrace_app/features/epcis/services/aggregation_event_service.dart';

/// Implementation of the AggregationEventService interface
class AggregationEventServiceImpl implements AggregationEventService {
  final http.Client _httpClient;
  final TokenManager _tokenManager;
  final AppConfig _appConfig;
  /// Base endpoint for aggregation event API
  late final String _baseUrl;
    AggregationEventServiceImpl({
    required http.Client httpClient,
    required TokenManager tokenManager,
    required AppConfig appConfig,  }) : _httpClient = httpClient,
       _tokenManager = tokenManager,
       _appConfig = appConfig {
    // Use the base URL and append the endpoint for aggregation events
    // Make sure the backend's context path (/api) is correctly handled
    _baseUrl = '${_appConfig.apiBaseUrl}/events/aggregation';
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
  Future<AggregationEvent> getAggregationEventById(String id) async {
    final headers = await _getHeaders();
    // Use the event-id endpoint instead of the ID endpoint
    // This matches how the backend is currently implementing the lookup
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/event-id/$id'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      // Debug: print the raw response to check GLN fields
      print('Raw API response for event ID $id: ${response.body}');

      final jsonData = json.decode(response.body);
        // Check if GLN fields are present
      print('API response contains readPoint: ${jsonData['readPoint']}');
      print('API response contains businessLocation: ${jsonData['businessLocation']}');
      print('API response contains bizLocation: ${jsonData['bizLocation']}');
      print('API response contains locationGLN: ${jsonData['locationGLN']}');

      // Check for source list and destination list
      print('API response contains sourceList: ${jsonData['sourceList']}');
      print('API response contains destinationList: ${jsonData['destinationList']}');
      print('API response contains bizData: ${jsonData['bizData']}');

      return AggregationEvent.fromJson(jsonData);
    } else {
      throw Exception('Failed to get aggregation event: ${response.statusCode}');
    }
  }
  @override
  Future<AggregationEvent> getAggregationEventByEventId(String eventId) async {
    final headers = await _getHeaders();
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/event-id/$eventId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      // Debug: print the raw response to check GLN fields
      print('Raw API response for event ID $eventId: ${response.body}');

      final jsonData = json.decode(response.body);

      // Check if GLN fields are present
      print('API response contains readPoint: ${jsonData['readPoint']}');
      print('API response contains businessLocation: ${jsonData['businessLocation']}');
      print('API response contains bizLocation: ${jsonData['bizLocation']}');
      print('API response contains locationGLN: ${jsonData['locationGLN']}');
      print('API response contains bizData: ${jsonData['bizData']}');

      return AggregationEvent.fromJson(jsonData);
    } else {
      throw Exception('Failed to get aggregation event: ${response.statusCode}');
    }
  }  @override
  Future<AggregationEvent> createAggregationEvent(AggregationEvent event) async {
    final headers = await _getHeaders();

    // Format timezone offset in the ISO 8601 format to ensure consistency
    final offset = DateTime.now().timeZoneOffset;
    final hours = offset.inHours.abs();
    final minutes = (offset.inMinutes.abs() % 60);
    final sign = offset.isNegative ? '-' : '+';

    // Format as +/-HH:MM
    final String eventTimeZone = '$sign${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';

    // Get current date time in ISO format with timezone offset
    final eventTime = '${event.eventTime.toIso8601String().split('.')[0]}$eventTimeZone';

    // Get the base JSON from the event
    Map<String, dynamic> jsonData = event.toJson();

    // Add required fields for enhanced validation
    jsonData['eventType'] = 'AggregationEvent';  // Required by enhanced validation schema
    jsonData['eventId'] = event.eventId.isNotEmpty ? event.eventId : 'event-${DateTime.now().millisecondsSinceEpoch}'; // Ensure eventId is present
    jsonData['recordTime'] = DateTime.now().toIso8601String(); // Record time in ISO format
    jsonData['epcisVersion'] = '2.0';            // Required EPCIS version
    jsonData['certificationInfo'] = [];          // Required empty array
    if (jsonData['childQuantityList'] == null) {
      jsonData['childQuantityList'] = [];        // Required empty array if not using quantities
    }
      // Ensure all timezone variants are included
    jsonData['eventTimeZoneOffset'] = eventTimeZone; // This is the field name expected by the backend DTO
    jsonData['eventTimeZone'] = eventTimeZone;       // For frontend model consistency
    jsonData['eventTime'] = eventTime;               // Add explicit event time with timezone
      // Handle GLN fields explicitly to ensure they're properly sent to the backend
    if (event.readPoint != null) {
      jsonData['readPoint'] = event.readPoint!.glnCode; // Send just the GLN code as a string
    }

    if (event.businessLocation != null) {
      jsonData['businessLocation'] = event.businessLocation!.glnCode; // Send just the GLN code as a string
    }

    // Debug: Print the full JSON payload being sent
    final jsonPayload = jsonEncode(jsonData);
    print('Aggregation event payload: $jsonPayload');
      final response = await _httpClient.post(
      Uri.parse(_baseUrl),
      headers: headers,
      body: jsonPayload,
    );

    if (response.statusCode == 201) {
      return AggregationEvent.fromJson(json.decode(response.body));
    } else {
      throw Exception(_getDetailedErrorMessage(response));
    }
  }  @override
  Future<AggregationEvent> updateAggregationEvent(String id, AggregationEvent event) async {
    final headers = await _getHeaders();

    // Get the base JSON from the event
    Map<String, dynamic> jsonData = event.toJson();
      // Handle GLN fields explicitly to ensure they're properly sent to the backend
    if (event.readPoint != null) {
      jsonData['readPoint'] = event.readPoint!.glnCode; // Send just the GLN code as a string
    }

    if (event.businessLocation != null) {
      jsonData['businessLocation'] = event.businessLocation!.glnCode; // Send just the GLN code as a string
    }

    final response = await _httpClient.put(
      Uri.parse('$_baseUrl/$id'),
      headers: headers,
      body: json.encode(jsonData),
    );

    if (response.statusCode == 200) {
      return AggregationEvent.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update aggregation event: ${response.statusCode}');
    }
  }
  @override
  Future<void> deleteAggregationEvent(String id) async {
    final headers = await _getHeaders();
    final response = await _httpClient.delete(
      Uri.parse('$_baseUrl/$id'),
      headers: headers,
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete aggregation event: ${response.statusCode}');
    }
  }
    @override
  Future<List<AggregationEvent>> getAllAggregationEvents(int page, int size) async {
    final headers = await _getHeaders();
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl?page=$page&size=$size'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      print('AggregationEvent API response: ${response.body}');
      final data = json.decode(response.body);
      if (data['content'] != null && data['content'] is List) {
        final List<dynamic> eventList = data['content'];

        // Debug: Check for source and destination lists in the first event if available
        if (eventList.isNotEmpty) {
          print('First event sourceList: ${eventList[0]['sourceList']}');
          print('First event destinationList: ${eventList[0]['destinationList']}');
        }

        return eventList.map((json) => AggregationEvent.fromJson(json)).toList();
      } else {
        // If the response is an array directly (not wrapped in a PageResponse object)
        if (data is List) {
          return data.map((json) => AggregationEvent.fromJson(json)).toList();
        }
        throw Exception('Invalid response format: content field missing or invalid');
      }
    } else {
      throw Exception('Failed to get all aggregation events: ${response.statusCode} - ${response.body}');
    }
  }
  
  @override
  Future<List<AggregationEvent>> findAggregationEventsByAction(String action) async {
    final headers = await _getHeaders();
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/action/$action'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> eventList = json.decode(response.body);
      return eventList.map((json) => AggregationEvent.fromJson(json)).toList();
    } else {
      throw Exception('Failed to find aggregation events: ${response.statusCode}');
    }
  }
  @override
  Future<List<AggregationEvent>> findAggregationEventsByParentEPC(String parentEPC) async {
    final headers = await _getHeaders();
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/parent/$parentEPC'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> eventList = json.decode(response.body);
      return eventList.map((json) => AggregationEvent.fromJson(json)).toList();
    } else {
      throw Exception('Failed to find aggregation events: ${response.statusCode}');
    }
  }
  @override
  Future<List<AggregationEvent>> findAggregationEventsByChildEPC(String childEPC) async {
    final headers = await _getHeaders();
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/child/$childEPC'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> eventList = json.decode(response.body);
      return eventList.map((json) => AggregationEvent.fromJson(json)).toList();
    } else {
      throw Exception('Failed to find aggregation events: ${response.statusCode}');
    }
  }  @override
  Future<List<AggregationEvent>> findAggregationEventsByParentEPCAndAction(String parentEPC, String action) async {
    // Retrieve events by parent EPC and filter by action in client
    final parentEvents = await findAggregationEventsByParentEPC(parentEPC);
    return parentEvents.where((event) => event.action == action).toList();
  }
  @override
  Future<List<AggregationEvent>> findAggregationEventsByChildEPCAndAction(String childEPC, String action) async {
    // Retrieve events by child EPC and filter by action in client
    final childEvents = await findAggregationEventsByChildEPC(childEPC);
    return childEvents.where((event) => event.action == action).toList();
  }

  @override
  Future<List<AggregationEvent>> findCurrentChildrenOfParent(String parentEPC) async {
    final headers = await _getHeaders();

    try {
      final response = await _httpClient.get(
        Uri.parse('$_baseUrl/parent/$parentEPC/contents'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        // This endpoint returns a list of EPCs, not events
        final List<String> childEPCs = List<String>.from(json.decode(response.body));

        // Since we need to return AggregationEvents, we need to find the most recent
        // ADD event for each child EPC with this parent
        List<AggregationEvent> events = await findAggregationEventsByParentEPCAndAction(parentEPC, 'ADD');

        // Filter events to only include those with the childEPCs from the response
        return events.where((event) {
          return event.childEPCs.any((childEPC) => childEPCs.contains(childEPC));
        }).toList();
      } else {
        throw Exception(_getDetailedErrorMessage(response));
      }
    } catch (e) {
      print('Error finding current children: $e');
      rethrow;
    }
  }
  
  @override
  Future<AggregationEvent> findCurrentParentOfChild(String childEPC) async {
    final headers = await _getHeaders();

    try {
      final response = await _httpClient.get(
        Uri.parse('$_baseUrl/child/$childEPC/container'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        // This endpoint returns the parent EPC as a string
        final String parentEPC = json.decode(response.body);

        // Get the most recent ADD event for this child with this parent
        List<AggregationEvent> events = await findAggregationEventsByChildEPCAndAction(childEPC, 'ADD');
        return events.firstWhere(
          (event) => event.parentID == parentEPC,
          orElse: () => throw Exception("No active aggregation found for child $childEPC"),
        );
      } else if (response.statusCode == 404) {
        // Child is not currently in any container
        throw Exception("Child $childEPC is not currently in any container");
      } else {
        throw Exception(_getDetailedErrorMessage(response));
      }
    } catch (e) {
      print('Error finding current parent: $e');
      rethrow;
    }
  }
  
  @override
  Future<List<AggregationEvent>> trackParentHistory(String parentEPC) async {
    // This returns all events where the EPC was a parent
    return findAggregationEventsByParentEPC(parentEPC);
  }
  
  @override
  Future<List<AggregationEvent>> trackChildHistory(String childEPC) async {
    // This returns all events where the EPC was a child
    return findAggregationEventsByChildEPC(childEPC);
  }
  
  @override
  Future<List<AggregationEvent>> findAggregationEventsByBusinessStepAndParentEPC(
      String businessStep, String parentEPC) async {
    final headers = await _getHeaders();

    try {
      // The backend doesn't have a direct endpoint for this query,
      // so we'll get all events for the parent EPC and filter by business step
      final response = await _httpClient.get(
        Uri.parse('$_baseUrl/parent/$parentEPC'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);

        List<AggregationEvent> events = jsonData
            .map((data) => AggregationEvent.fromJson(data))
            .where((event) => event.businessStep == businessStep)
            .toList();

        return events;
      } else {
        throw Exception(_getDetailedErrorMessage(response));
      }
    } catch (e) {
      print('Error finding events by business step and parent EPC: $e');
      rethrow;
    }
  }
  
  @override
  Future<List<AggregationEvent>> findAggregationEventsByLocationAndTimeWindow(
      String locationGLN, DateTime startTime, DateTime endTime) async {
    final headers = await _getHeaders();

    try {
      // Format dates as ISO8601 strings
      final String start = startTime.toIso8601String();
      final String end = endTime.toIso8601String();

      final response = await _httpClient.get(
        Uri.parse('$_baseUrl/time-range?startTime=$start&endTime=$end'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);

        // Filter by location GLN
        List<AggregationEvent> events = jsonData
            .map((data) => AggregationEvent.fromJson(data))
            .where((event) =>
                (event.readPoint?.glnCode == locationGLN) ||
                (event.businessLocation?.glnCode == locationGLN))
            .toList();

        return events;
      } else {
        throw Exception(_getDetailedErrorMessage(response));
      }
    } catch (e) {
      print('Error finding events by location and time window: $e');
      rethrow;
    }
  }
  @override
  Future<AggregationEvent> createPackEvent(
      String parentEPC,
      List<String> childEPCs,
      String locationGLN,
      String businessStep,
      String disposition,
      Map<String, String> bizData,
      {List<Map<String, dynamic>>? sourceList,
      List<Map<String, dynamic>>? destinationList}) async {
    final headers = await _getHeaders();

    // Format timezone offset in the ISO 8601 format
    final offset = DateTime.now().timeZoneOffset;
    final hours = offset.inHours.abs();
    final minutes = (offset.inMinutes.abs() % 60);
    final sign = offset.isNegative ? '-' : '+';

    // Format as +/-HH:MM
    final String eventTimeZone = '$sign${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
    // Get current date time in ISO format with timezone offset
    final now = DateTime.now();
    final eventTime = '${now.toIso8601String().split('.')[0]}$eventTimeZone';

    final Map<String, dynamic> requestData = {
      'eventType': 'AggregationEvent',  // Required by enhanced validation schema
      'action': 'ADD',                  // Pack events are ADD actions
      'eventId': 'pack-${DateTime.now().millisecondsSinceEpoch}', // Generate unique event ID
      'recordTime': now.toIso8601String(), // Record time in ISO format
      'epcisVersion': '2.0',            // Required EPCIS version
      'certificationInfo': [],          // Required empty array
      'parentID': parentEPC,
      'childEPCs': childEPCs,
      'childQuantityList': [],          // Required empty array if not using quantities
      'readPoint': locationGLN,  // Send as string
      'businessLocation': locationGLN, // Send as string
      'businessStep': businessStep,
      'disposition': disposition,
      'bizData': bizData,
      'eventTimeZoneOffset': eventTimeZone,  // This is the field name expected by the backend DTO
      'eventTimeZone': eventTimeZone,        // For frontend model consistency
      'eventTime': eventTime                 // Add explicit event time
    };

    // Add source list if provided
    if (sourceList != null && sourceList.isNotEmpty) {
      requestData['sourceList'] = sourceList;
    }

    // Add destination list if provided
    if (destinationList != null && destinationList.isNotEmpty) {
      requestData['destinationList'] = destinationList;
    }

    final body = json.encode(requestData);

    // Debug: Print the actual JSON payload being sent
    print('Pack event payload: $body');
      final response = await _httpClient.post(
      Uri.parse('$_baseUrl/pack'),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 201) {
      return AggregationEvent.fromJson(json.decode(response.body));
    } else {
      throw Exception(_getDetailedErrorMessage(response));
    }
  }  @override
  Future<AggregationEvent> createUnpackEvent(
      String parentEPC,
      List<String>? childEPCs,
      String locationGLN,
      String businessStep,
      String disposition,
      Map<String, String> bizData,
      {List<Map<String, dynamic>>? sourceList,
      List<Map<String, dynamic>>? destinationList}) async {
    final headers = await _getHeaders();

    // Format timezone offset in the ISO 8601 format
    final offset = DateTime.now().timeZoneOffset;
    final hours = offset.inHours.abs();
    final minutes = (offset.inMinutes.abs() % 60);
    final sign = offset.isNegative ? '-' : '+';

    // Format as +/-HH:MM
    final String eventTimeZone = '$sign${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
      // Get current date time in ISO format with timezone offset
    final now = DateTime.now();
    final eventTime = '${now.toIso8601String().split('.')[0]}$eventTimeZone';

    final Map<String, dynamic> requestData = {
      'eventType': 'AggregationEvent',  // Required by enhanced validation schema
      'action': 'DELETE',               // Unpack events are DELETE actions
      'eventId': 'unpack-${DateTime.now().millisecondsSinceEpoch}', // Generate unique event ID
      'recordTime': now.toIso8601String(), // Record time in ISO format
      'epcisVersion': '2.0',            // Required EPCIS version
      'certificationInfo': [],          // Required empty array
      'parentID': parentEPC,
      'childEPCs': childEPCs,
      'childQuantityList': [],          // Required empty array if not using quantities
      'readPoint': locationGLN,  // Send as string
      'businessLocation': locationGLN, // Send as string
      'businessStep': businessStep,
      'disposition': disposition,
      'bizData': bizData,
      'eventTimeZoneOffset': eventTimeZone,  // This is the field name expected by the backend DTO
      'eventTimeZone': eventTimeZone,        // For frontend model consistency
      'eventTime': eventTime                 // Add explicit event time
    };

    // Add source list if provided
    if (sourceList != null && sourceList.isNotEmpty) {
      requestData['sourceList'] = sourceList;
    }

    // Add destination list if provided
    if (destinationList != null && destinationList.isNotEmpty) {
      requestData['destinationList'] = destinationList;
    }

    final body = json.encode(requestData);

    // Debug: Print the actual JSON payload being sent
    print('Unpack event payload: $body');
      final response = await _httpClient.post(
      Uri.parse('$_baseUrl/unpack'),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 201) {
      return AggregationEvent.fromJson(json.decode(response.body));
    } else {
      throw Exception(_getDetailedErrorMessage(response));
    }
  }

  // Helper method to handle API errors and provide more detailed error messages
  String _getDetailedErrorMessage(http.Response response) {
    try {
      final Map<String, dynamic> errorData = json.decode(response.body);
      final String message = errorData['message'] ?? 'Unknown error';
      
      // Check if this is a validation error with specific error messages
      if (errorData.containsKey('errors') && errorData['errors'] is List) {
        List<dynamic> errors = errorData['errors'];

        // Format validation errors for better readability
        if (errors.isNotEmpty) {
          // Group errors by type
          List<String> parentErrors = [];
          List<String> childErrors = [];
          List<String> otherErrors = [];

          for (String error in errors) {
            if (error.startsWith('Parent EPC not commissioned')) {
              parentErrors.add(error.substring('Parent EPC not commissioned: '.length));
            } else if (error.startsWith('Child EPC not commissioned')) {
              childErrors.add(error.substring('Child EPC not commissioned: '.length));
            } else {
              otherErrors.add(error);
            }
          }

          // Build a user-friendly message
          StringBuffer friendlyMessage = StringBuffer('Validation Error:\n');

          if (parentErrors.isNotEmpty) {
            friendlyMessage.write('\nParent container not found in the system. Please create or commission the following container first:\n');
            friendlyMessage.write('• ${parentErrors.join('\n• ')}\n');
          }

          if (childErrors.isNotEmpty) {
            friendlyMessage.write('\nThe following items have not been commissioned in the system:\n');
            friendlyMessage.write('• ${childErrors.join('\n• ')}\n');
            friendlyMessage.write('\nPlease create a commissioning event for these items first.\n');
          }

          if (otherErrors.isNotEmpty) {
            friendlyMessage.write('\nOther issues:\n');
            friendlyMessage.write('• ${otherErrors.join('\n• ')}\n');
          }

          return friendlyMessage.toString();
        }
      }

      // If not a validation error or no specific errors provided
      return 'Error: $message';
    } catch (e) {
      // If we can't parse the error JSON, return a more user-friendly message
      print('Error parsing error response: $e');
      print('Raw response: ${response.body}');
      return 'Error: Unable to process the request. Please check your input and try again.';
    }
  }

  @override
  Future<List<String>> findContainerContents(String parentEPC) async {
    final headers = await _getHeaders();

    try {
      final response = await _httpClient.get(
        Uri.parse('$_baseUrl/parent/$parentEPC/contents'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        // The endpoint returns a list of child EPCs as strings
        final List<dynamic> jsonData = json.decode(response.body);
        return List<String>.from(jsonData);
      } else {
        throw Exception(_getDetailedErrorMessage(response));
      }
    } catch (e) {
      print('Error finding container contents: $e');
      rethrow;
    }
  }

  @override
  Future<bool> verifyHierarchy(String epc) async {
    final headers = await _getHeaders();

    try {
      // Get container contents for the given parent EPC
      final response = await _httpClient.get(
        Uri.parse('$_baseUrl/parent/$epc/contents'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        // If we can get contents without error, the parent EPC is valid
        return true;
      } else if (response.statusCode == 404) {
        // No contents found, but that doesn't necessarily mean an invalid hierarchy
        // Let's check if it's a child EPC in another container
        try {
          final containerResponse = await _httpClient.get(
            Uri.parse('$_baseUrl/child/$epc/container'),
            headers: headers,
          );

          return containerResponse.statusCode == 200;
        } catch (childError) {
          print('Error checking as child: $childError');
          return false;
        }
      } else {
        throw Exception(_getDetailedErrorMessage(response));
      }
    } catch (e) {
      print('Error verifying hierarchy: $e');
      return false;
    }
  }
}