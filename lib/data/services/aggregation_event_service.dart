import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';
import 'package:traqtrace_app/features/epcis/models/aggregation_event.dart';

class AggregationEventService {
  final DioService _dioService;

  late final String _baseUrl;
  AggregationEventService({required DioService dioService})
    : _dioService = dioService {
    _baseUrl = '${_dioService.baseUrl}/events/aggregation';
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _dioService.getAuthToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<AggregationEvent> getAggregationEventById(String id) async {
    final headers = await _getHeaders();
    final response = await _dioService.get(
      '$_baseUrl/event-id/$id',
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      print('Raw API response for event ID $id: ${response.data}');

      final jsonData = json.decode(response.data);
      print('API response contains readPoint: ${jsonData['readPoint']}');
      print(
        'API response contains businessLocation: ${jsonData['businessLocation']}',
      );
      print('API response contains bizLocation: ${jsonData['bizLocation']}');
      print('API response contains locationGLN: ${jsonData['locationGLN']}');

      print('API response contains sourceList: ${jsonData['sourceList']}');
      print(
        'API response contains destinationList: ${jsonData['destinationList']}',
      );
      print('API response contains bizData: ${jsonData['bizData']}');

      return AggregationEvent.fromJson(jsonData);
    } else {
      throw Exception(
        'Failed to get aggregation event: ${response.statusCode}',
      );
    }
  }

  Future<AggregationEvent> getAggregationEventByEventId(String eventId) async {
    final headers = await _getHeaders();
    final response = await _dioService.get(
      '$_baseUrl/event-id/$eventId',
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      print('Raw API response for event ID $eventId: ${response.data}');

      final jsonData = json.decode(response.data);

      print('API response contains readPoint: ${jsonData['readPoint']}');
      print(
        'API response contains businessLocation: ${jsonData['businessLocation']}',
      );
      print('API response contains bizLocation: ${jsonData['bizLocation']}');
      print('API response contains locationGLN: ${jsonData['locationGLN']}');
      print('API response contains bizData: ${jsonData['bizData']}');

      return AggregationEvent.fromJson(jsonData);
    } else {
      throw Exception(
        'Failed to get aggregation event: ${response.statusCode}',
      );
    }
  }

  Future<AggregationEvent> createAggregationEvent(
    AggregationEvent event,
  ) async {
    final headers = await _getHeaders();

    final offset = DateTime.now().timeZoneOffset;
    final hours = offset.inHours.abs();
    final minutes = (offset.inMinutes.abs() % 60);
    final sign = offset.isNegative ? '-' : '+';

    final String eventTimeZone =
        '$sign${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';

    final eventTime =
        '${event.eventTime.toIso8601String().split('.')[0]}$eventTimeZone';

    Map<String, dynamic> jsonData = event.toJson();

    jsonData['eventType'] =
        'AggregationEvent';
    jsonData['eventId'] = event.eventId.isNotEmpty
        ? event.eventId
        : 'event-${DateTime.now().millisecondsSinceEpoch}';
    jsonData['recordTime'] = DateTime.now()
        .toIso8601String();
    jsonData['epcisVersion'] = '2.0';
    jsonData['certificationInfo'] = [];
    if (jsonData['childQuantityList'] == null) {
      jsonData['childQuantityList'] =
          [];
    }
    jsonData['eventTimeZoneOffset'] =
        eventTimeZone;
    jsonData['eventTimeZone'] = eventTimeZone;
    jsonData['eventTime'] = eventTime;
    if (event.readPoint != null) {
      jsonData['readPoint'] =
          event.readPoint!.glnCode;
    }

    if (event.businessLocation != null) {
      jsonData['businessLocation'] =
          event.businessLocation!.glnCode;
    }

    final jsonPayload = jsonEncode(jsonData);
    print('Aggregation event payload: $jsonPayload');
    final response = await _dioService.post(
      _baseUrl,
      headers: headers,
      data: jsonPayload,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 201) {
      return AggregationEvent.fromJson(json.decode(response.data));
    } else {
      throw Exception(_getDetailedErrorMessage(response));
    }
  }

  Future<AggregationEvent> updateAggregationEvent(
    String id,
    AggregationEvent event,
  ) async {
    final headers = await _getHeaders();

    Map<String, dynamic> jsonData = event.toJson();
    if (event.readPoint != null) {
      jsonData['readPoint'] =
          event.readPoint!.glnCode;
    }

    if (event.businessLocation != null) {
      jsonData['businessLocation'] =
          event.businessLocation!.glnCode;
    }

    final response = await _dioService.put(
      '$_baseUrl/$id',
      headers: headers,
      data: json.encode(jsonData),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return AggregationEvent.fromJson(json.decode(response.data));
    } else {
      throw Exception(
        'Failed to update aggregation event: ${response.statusCode}',
      );
    }
  }

  Future<void> deleteAggregationEvent(String id) async {
    final headers = await _getHeaders();
    final response = await _dioService.delete(
      '$_baseUrl/$id',
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode != 204) {
      throw Exception(
        'Failed to delete aggregation event: ${response.statusCode}',
      );
    }
  }

  Future<List<AggregationEvent>> getAllAggregationEvents(
    int page,
    int size,
  ) async {
    final headers = await _getHeaders();
    final response = await _dioService.get(
      _baseUrl,
      queryParameters: {'page': page.toString(), 'size': size.toString()},
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      print('AggregationEvent API response: ${response.data}');
      final data = json.decode(response.data);
      if (data['content'] != null && data['content'] is List) {
        final List<dynamic> eventList = data['content'];

        if (eventList.isNotEmpty) {
          print('First event sourceList: ${eventList[0]['sourceList']}');
          print(
            'First event destinationList: ${eventList[0]['destinationList']}',
          );
        }

        return eventList
            .map((json) => AggregationEvent.fromJson(json))
            .toList();
      } else {
        if (data is List) {
          return data.map((json) => AggregationEvent.fromJson(json)).toList();
        }
        throw Exception(
          'Invalid response format: content field missing or invalid',
        );
      }
    } else {
      throw Exception(
        'Failed to get all aggregation events: ${response.statusCode} - ${response.data}',
      );
    }
  }

  Future<List<AggregationEvent>> findAggregationEventsByAction(
    String action,
  ) async {
    final headers = await _getHeaders();
    final response = await _dioService.get(
      '$_baseUrl/action/$action',
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> eventList = json.decode(response.data);
      return eventList.map((json) => AggregationEvent.fromJson(json)).toList();
    } else {
      throw Exception(
        'Failed to find aggregation events: ${response.statusCode}',
      );
    }
  }

  Future<List<AggregationEvent>> findAggregationEventsByParentEPC(
    String parentEPC,
  ) async {
    final headers = await _getHeaders();
    final response = await _dioService.get(
      '$_baseUrl/parent/$parentEPC',
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> eventList = json.decode(response.data);
      return eventList.map((json) => AggregationEvent.fromJson(json)).toList();
    } else {
      throw Exception(
        'Failed to find aggregation events: ${response.statusCode}',
      );
    }
  }

  Future<List<AggregationEvent>> findAggregationEventsByChildEPC(
    String childEPC,
  ) async {
    final headers = await _getHeaders();
    final response = await _dioService.get(
      '$_baseUrl/child/$childEPC',
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> eventList = json.decode(response.data);
      return eventList.map((json) => AggregationEvent.fromJson(json)).toList();
    } else {
      throw Exception(
        'Failed to find aggregation events: ${response.statusCode}',
      );
    }
  }

  Future<List<AggregationEvent>> findAggregationEventsByParentEPCAndAction(
    String parentEPC,
    String action,
  ) async {
    final parentEvents = await findAggregationEventsByParentEPC(parentEPC);
    return parentEvents.where((event) => event.action == action).toList();
  }

  Future<List<AggregationEvent>> findAggregationEventsByChildEPCAndAction(
    String childEPC,
    String action,
  ) async {
    final childEvents = await findAggregationEventsByChildEPC(childEPC);
    return childEvents.where((event) => event.action == action).toList();
  }

  Future<List<AggregationEvent>> findCurrentChildrenOfParent(
    String parentEPC,
  ) async {
    final headers = await _getHeaders();

    try {
      final response = await _dioService.get(
        '$_baseUrl/parent/$parentEPC/contents',
        headers: headers,
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      if (response.statusCode == 200) {
        final List<String> childEPCs = List<String>.from(
          json.decode(response.data),
        );

        List<AggregationEvent> events =
            await findAggregationEventsByParentEPCAndAction(parentEPC, 'ADD');

        return events.where((event) {
          return event.childEPCs.any(
            (childEPC) => childEPCs.contains(childEPC),
          );
        }).toList();
      } else {
        throw Exception(_getDetailedErrorMessage(response));
      }
    } catch (e) {
      print('Error finding current children: $e');
      rethrow;
    }
  }

  Future<AggregationEvent> findCurrentParentOfChild(String childEPC) async {
    final headers = await _getHeaders();

    try {
      final response = await _dioService.get(
        '$_baseUrl/child/$childEPC/container',
        headers: headers,
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      if (response.statusCode == 200) {
        final String parentEPC = json.decode(response.data);

        List<AggregationEvent> events =
            await findAggregationEventsByChildEPCAndAction(childEPC, 'ADD');
        return events.firstWhere(
          (event) => event.parentID == parentEPC,
          orElse: () => throw Exception(
            "No active aggregation found for child $childEPC",
          ),
        );
      } else if (response.statusCode == 404) {
        throw Exception("Child $childEPC is not currently in any container");
      } else {
        throw Exception(_getDetailedErrorMessage(response));
      }
    } catch (e) {
      print('Error finding current parent: $e');
      rethrow;
    }
  }

  Future<List<AggregationEvent>> trackParentHistory(String parentEPC) async {
    return findAggregationEventsByParentEPC(parentEPC);
  }

  Future<List<AggregationEvent>> trackChildHistory(String childEPC) async {
    return findAggregationEventsByChildEPC(childEPC);
  }

  Future<List<AggregationEvent>>
  findAggregationEventsByBusinessStepAndParentEPC(
    String businessStep,
    String parentEPC,
  ) async {
    final headers = await _getHeaders();

    try {
      final response = await _dioService.get(
        '$_baseUrl/parent/$parentEPC',
        headers: headers,
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.data);

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

  Future<List<AggregationEvent>> findAggregationEventsByLocationAndTimeWindow(
    String locationGLN,
    DateTime startTime,
    DateTime endTime,
  ) async {
    final headers = await _getHeaders();

    try {
      final String start = startTime.toIso8601String();
      final String end = endTime.toIso8601String();

      final response = await _dioService.get(
        '$_baseUrl/time-range',
        queryParameters: {'startTime': start, 'endTime': end},
        headers: headers,
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.data);

        List<AggregationEvent> events = jsonData
            .map((data) => AggregationEvent.fromJson(data))
            .where(
              (event) =>
                  (event.readPoint?.glnCode == locationGLN) ||
                  (event.businessLocation?.glnCode == locationGLN),
            )
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

  Future<AggregationEvent> createPackEvent(
    String parentEPC,
    List<String> childEPCs,
    String locationGLN,
    String businessStep,
    String disposition,
    Map<String, String> bizData, {
    List<Map<String, dynamic>>? sourceList,
    List<Map<String, dynamic>>? destinationList,
  }) async {
    final headers = await _getHeaders();

    final offset = DateTime.now().timeZoneOffset;
    final hours = offset.inHours.abs();
    final minutes = (offset.inMinutes.abs() % 60);
    final sign = offset.isNegative ? '-' : '+';

    final String eventTimeZone =
        '$sign${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
    final now = DateTime.now();
    final eventTime = '${now.toIso8601String().split('.')[0]}$eventTimeZone';

    final Map<String, dynamic> requestData = {
      'eventType': 'AggregationEvent',
      'action': 'ADD',
      'eventId':
          'pack-${DateTime.now().millisecondsSinceEpoch}',
      'recordTime': now.toIso8601String(),
      'epcisVersion': '2.0',
      'certificationInfo': [],
      'parentID': parentEPC,
      'childEPCs': childEPCs,
      'childQuantityList': [],
      'readPoint': locationGLN,
      'businessLocation': locationGLN,
      'businessStep': businessStep,
      'disposition': disposition,
      'bizData': bizData,
      'eventTimeZoneOffset':
          eventTimeZone,
      'eventTimeZone': eventTimeZone,
      'eventTime': eventTime,
    };

    if (sourceList != null && sourceList.isNotEmpty) {
      requestData['sourceList'] = sourceList;
    }

    if (destinationList != null && destinationList.isNotEmpty) {
      requestData['destinationList'] = destinationList;
    }

    final body = json.encode(requestData);

    print('Pack event payload: $body');
    final response = await _dioService.post(
      '$_baseUrl/pack',
      headers: headers,
      data: body,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 201) {
      return AggregationEvent.fromJson(json.decode(response.data));
    } else {
      throw Exception(_getDetailedErrorMessage(response));
    }
  }

  Future<AggregationEvent> createUnpackEvent(
    String parentEPC,
    List<String>? childEPCs,
    String locationGLN,
    String businessStep,
    String disposition,
    Map<String, String> bizData, {
    List<Map<String, dynamic>>? sourceList,
    List<Map<String, dynamic>>? destinationList,
  }) async {
    final headers = await _getHeaders();

    final offset = DateTime.now().timeZoneOffset;
    final hours = offset.inHours.abs();
    final minutes = (offset.inMinutes.abs() % 60);
    final sign = offset.isNegative ? '-' : '+';

    final String eventTimeZone =
        '$sign${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
    final now = DateTime.now();
    final eventTime = '${now.toIso8601String().split('.')[0]}$eventTimeZone';

    final Map<String, dynamic> requestData = {
      'eventType': 'AggregationEvent',
      'action': 'DELETE',
      'eventId':
          'unpack-${DateTime.now().millisecondsSinceEpoch}',
      'recordTime': now.toIso8601String(),
      'epcisVersion': '2.0',
      'certificationInfo': [],
      'parentID': parentEPC,
      'childEPCs': childEPCs,
      'childQuantityList': [],
      'readPoint': locationGLN,
      'businessLocation': locationGLN,
      'businessStep': businessStep,
      'disposition': disposition,
      'bizData': bizData,
      'eventTimeZoneOffset':
          eventTimeZone,
      'eventTimeZone': eventTimeZone,
      'eventTime': eventTime,
    };

    if (sourceList != null && sourceList.isNotEmpty) {
      requestData['sourceList'] = sourceList;
    }

    if (destinationList != null && destinationList.isNotEmpty) {
      requestData['destinationList'] = destinationList;
    }

    final body = json.encode(requestData);

    print('Unpack event payload: $body');
    final response = await _dioService.post(
      '$_baseUrl/unpack',
      headers: headers,
      data: body,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 201) {
      return AggregationEvent.fromJson(json.decode(response.data));
    } else {
      throw Exception(_getDetailedErrorMessage(response));
    }
  }

  String _getDetailedErrorMessage(Response response) {
    try {
      final Map<String, dynamic> errorData = json.decode(response.data);
      final String message = errorData['message'] ?? 'Unknown error';

      if (errorData.containsKey('errors') && errorData['errors'] is List) {
        List<dynamic> errors = errorData['errors'];

        if (errors.isNotEmpty) {
          List<String> parentErrors = [];
          List<String> childErrors = [];
          List<String> otherErrors = [];

          for (String error in errors) {
            if (error.startsWith('Parent EPC not commissioned')) {
              parentErrors.add(
                error.substring('Parent EPC not commissioned: '.length),
              );
            } else if (error.startsWith('Child EPC not commissioned')) {
              childErrors.add(
                error.substring('Child EPC not commissioned: '.length),
              );
            } else {
              otherErrors.add(error);
            }
          }

          StringBuffer friendlyMessage = StringBuffer('Validation Error:\n');

          if (parentErrors.isNotEmpty) {
            friendlyMessage.write(
              '\nParent container not found in the system. Please create or commission the following container first:\n',
            );
            friendlyMessage.write('• ${parentErrors.join('\n• ')}\n');
          }

          if (childErrors.isNotEmpty) {
            friendlyMessage.write(
              '\nThe following items have not been commissioned in the system:\n',
            );
            friendlyMessage.write('• ${childErrors.join('\n• ')}\n');
            friendlyMessage.write(
              '\nPlease create a commissioning event for these items first.\n',
            );
          }

          if (otherErrors.isNotEmpty) {
            friendlyMessage.write('\nOther issues:\n');
            friendlyMessage.write('• ${otherErrors.join('\n• ')}\n');
          }

          return friendlyMessage.toString();
        }
      }

      return 'Error: $message';
    } catch (e) {
      print('Error parsing error response: $e');
      print('Raw response: ${response.data}');
      return 'Error: Unable to process the request. Please check your input and try again.';
    }
  }

  Future<List<String>> findContainerContents(String parentEPC) async {
    final headers = await _getHeaders();

    try {
      final response = await _dioService.get(
        '$_baseUrl/parent/$parentEPC/contents',
        headers: headers,
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.data);
        return List<String>.from(jsonData);
      } else {
        throw Exception(_getDetailedErrorMessage(response));
      }
    } catch (e) {
      print('Error finding container contents: $e');
      rethrow;
    }
  }

  Future<bool> verifyHierarchy(String epc) async {
    final headers = await _getHeaders();

    try {
      final response = await _dioService.get(
        '$_baseUrl/parent/$epc/contents',
        headers: headers,
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 404) {
        try {
          final containerResponse = await _dioService.get(
            '$_baseUrl/child/$epc/container',
            headers: headers,
            responseType: ResponseType.plain,
            acceptAllStatusCodes: true,
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
