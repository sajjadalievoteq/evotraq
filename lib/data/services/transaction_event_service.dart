import 'dart:convert';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';
import 'package:traqtrace_app/features/epcis/models/transaction_event.dart';
import 'package:uuid/uuid.dart';

/// Implementation of the TransactionEventService interface
class TransactionEventService {
  final DioService _dioService;

  /// Base endpoint for transaction event API
  late final String _baseUrl;

  TransactionEventService({required DioService dioService})
    : _dioService = dioService {
    _baseUrl = '${_dioService.baseUrl}/events/transaction';
  }

  /// Get authorization headers for API requests
  Future<Map<String, String>> _getHeaders() async {
    final token = await _dioService.getAuthToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<TransactionEvent> getTransactionEventById(String id) async {
    final headers = await _getHeaders();

    // Extract UUID if the ID is in URN format
    String cleanId;
    if (id.contains(':')) {
      cleanId = id.split(':').last;
      print('DEBUG: Extracted UUID from eventId: $cleanId');
    } else {
      cleanId = id;
      print('DEBUG: Using ID as is: $cleanId');
    }

    try {
      print('DEBUG: Sending request to: $_baseUrl/$cleanId');
      final response = await _dioService.get(
        '$_baseUrl/$cleanId',
        headers: headers,
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );
      if (response.statusCode == 200) {
        print('DEBUG: Successfully retrieved transaction event');
        final responseBody = json.decode(response.data);
        print(
          'DEBUG: Transaction event data: ${responseBody.toString().substring(0, min(500, responseBody.toString().length))}',
        );
        print(
          'DEBUG: businessStep: ${responseBody['businessStep']}, bizStep: ${responseBody['bizStep']}',
        );
        return TransactionEvent.fromJson(responseBody);
      } else {
        print('DEBUG: Failed to get transaction event: ${response.statusCode}');
        print('DEBUG: Response body: ${response.data}');
        throw Exception(
          'Failed to get transaction event: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('DEBUG: Error retrieving transaction event: ${e.toString()}');
      throw Exception('Error retrieving transaction event: ${e.toString()}');
    }
  }

  Future<TransactionEvent> getTransactionEventByEventId(String eventId) async {
    final headers = await _getHeaders();
    final response = await _dioService.get(
      '$_baseUrl/event-id/$eventId',
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return TransactionEvent.fromJson(json.decode(response.data));
    } else {
      throw Exception(
        'Failed to get transaction event: ${response.statusCode}',
      );
    }
  }

  Future<TransactionEvent> createTransactionEvent(
    TransactionEvent event,
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
      return TransactionEvent.fromJson(json.decode(response.data));
    } else {
      throw Exception(
        'Failed to create transaction event: ${response.statusCode}',
      );
    }
  }

  Future<TransactionEvent> updateTransactionEvent(
    String id,
    TransactionEvent event,
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
      return TransactionEvent.fromJson(json.decode(response.data));
    } else {
      throw Exception(
        'Failed to update transaction event: ${response.statusCode}',
      );
    }
  }

  Future<void> deleteTransactionEvent(String id) async {
    final headers = await _getHeaders();
    final response = await _dioService.delete(
      '$_baseUrl/$id',
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode != 204) {
      throw Exception(
        'Failed to delete transaction event: ${response.statusCode}',
      );
    }
  }

  Future<List<TransactionEvent>> findTransactionEventsByAction(
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
      return eventList.map((json) => TransactionEvent.fromJson(json)).toList();
    } else {
      throw Exception(
        'Failed to find transaction events: ${response.statusCode}',
      );
    }
  }

  Future<List<TransactionEvent>> findTransactionEventsByEPC(String epc) async {
    final headers = await _getHeaders();
    final response = await _dioService.get(
      '$_baseUrl/epc/$epc',
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> eventList = json.decode(response.data);
      return eventList.map((json) => TransactionEvent.fromJson(json)).toList();
    } else {
      throw Exception(
        'Failed to find transaction events: ${response.statusCode}',
      );
    }
  }

  Future<List<TransactionEvent>> findTransactionEventsByEPCClass(
    String epcClass,
  ) async {
    final headers = await _getHeaders();
    final response = await _dioService.get(
      '$_baseUrl/epcclass/$epcClass',
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> eventList = json.decode(response.data);
      return eventList.map((json) => TransactionEvent.fromJson(json)).toList();
    } else {
      throw Exception(
        'Failed to find transaction events: ${response.statusCode}',
      );
    }
  }

  Future<List<TransactionEvent>> findTransactionEventsByBizTransaction(
    String type,
    String id,
  ) async {
    final headers = await _getHeaders();
    final response = await _dioService.get(
      '$_baseUrl/biz-transaction',
      queryParameters: {'type': type, 'id': id},
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> eventList = json.decode(response.data);
      return eventList.map((json) => TransactionEvent.fromJson(json)).toList();
    } else {
      throw Exception(
        'Failed to find transaction events: ${response.statusCode}',
      );
    }
  }

  Future<List<TransactionEvent>> findTransactionEventsByBusinessStep(
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
      final List<dynamic> eventList = json.decode(response.data);
      return eventList.map((json) => TransactionEvent.fromJson(json)).toList();
    } else {
      throw Exception(
        'Failed to find transaction events: ${response.statusCode}',
      );
    }
  }

  Future<List<TransactionEvent>> findTransactionEventsByBusinessStepAndEPC(
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
      final List<dynamic> eventList = json.decode(response.data);
      return eventList.map((json) => TransactionEvent.fromJson(json)).toList();
    } else {
      throw Exception(
        'Failed to find transaction events: ${response.statusCode}',
      );
    }
  }

  Future<List<TransactionEvent>> findTransactionEventsByDispositionAndEPC(
    String disposition,
    String epc,
  ) async {
    final headers = await _getHeaders();
    final response = await _dioService.get(
      '$_baseUrl/disposition/$disposition/epc/$epc',
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> eventList = json.decode(response.data);
      return eventList.map((json) => TransactionEvent.fromJson(json)).toList();
    } else {
      throw Exception(
        'Failed to find transaction events: ${response.statusCode}',
      );
    }
  }

  Future<List<TransactionEvent>> findTransactionEventsByLocationAndTimeWindow(
    String locationGLN,
    DateTime startTime,
    DateTime endTime,
  ) async {
    // Since there's no direct endpoint for this combined query, we'll get events by time and then filter by location
    final headers = await _getHeaders();
    final startTimeStr = startTime.toIso8601String();
    final endTimeStr = endTime.toIso8601String();
    final response = await _dioService.get(
      '$_baseUrl/time-range',
      queryParameters: {'startTime': startTimeStr, 'endTime': endTimeStr},
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> eventList = json.decode(response.data);
      final allEvents = eventList
          .map((json) => TransactionEvent.fromJson(json))
          .toList();

      // Filter by location
      return allEvents
          .where(
            (event) =>
                event.businessLocation != null &&
                event.businessLocation!.glnCode == locationGLN,
          )
          .toList();
    } else {
      throw Exception(
        'Failed to find transaction events: ${response.statusCode}',
      );
    }
  }

  Future<List<TransactionEvent>> findActiveTransactionsForEPC(
    String epc,
  ) async {
    final headers = await _getHeaders();
    final response = await _dioService.get(
      '$_baseUrl/active/$epc',
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> eventList = json.decode(response.data);
      return eventList.map((json) => TransactionEvent.fromJson(json)).toList();
    } else {
      throw Exception(
        'Failed to find active transactions: ${response.statusCode}',
      );
    }
  }

  Future<List<TransactionEvent>> findTransactionHistoryForEPC(
    String epc,
  ) async {
    final headers = await _getHeaders();
    final response = await _dioService.get(
      '$_baseUrl/history/$epc',
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> eventList = json.decode(response.data);
      return eventList.map((json) => TransactionEvent.fromJson(json)).toList();
    } else {
      throw Exception(
        'Failed to find transaction history: ${response.statusCode}',
      );
    }
  }

  Future<TransactionEvent> createAddTransactionEvent(
    String bizTransactionType,
    String bizTransactionId,
    List<String> epcs,
    String locationGLN,
    String businessStep,
    String disposition,
    Map<String, String> bizData,
    DateTime eventTime,
  ) async {
    final headers = await _getHeaders();

    // Build bizTransactionList in the format expected by the backend
    final bizTransactionList = [
      {'type': bizTransactionType, 'id': bizTransactionId},
    ];
    // Format date with timezone information for Java ZonedDateTime compatibility
    final formattedEventTime = _formatDateForBackend(eventTime);
    final eventTimeZoneOffset = _getTimezoneOffset();

    // Generate a unique event ID using the UUID package
    final uuid = Uuid();
    final eventId = 'urn:epcglobal:cbv:epcis:event:${uuid.v4()}';
    // Ensure GLN codes are sent correctly for lookup on the backend
    final Map<String, dynamic> requestData = {
      'eventId': eventId,
      'eventTime': formattedEventTime,
      'recordTime': _formatDateForBackend(DateTime.now()),
      'eventTimeZoneOffset': eventTimeZoneOffset,
      'eventType': 'TransactionEvent',
      'epcisVersion': '2.0',
      'certificationInfo': <String>[],
      'bizTransactionList': bizTransactionList,
      'epcList': epcs,
      'businessStep':
          businessStep, // Send businessStep field as expected by the backend
      'disposition': disposition,
      'bizData': bizData,
      'action': 'ADD',
      'parentID':
          'urn:epc:id:sscc:${DateTime.now().millisecondsSinceEpoch % 1000000000000}.0000000000',
      'quantityList': <Map<String, dynamic>>[],
    };

    // Only add GLN codes if they are not empty
    if (locationGLN.isNotEmpty) {
      requestData['businessLocation'] =
          locationGLN; // Use businessLocation instead of bizLocation as field name
      requestData['readPoint'] = locationGLN;
    }

    final body = json.encode(requestData);

    final response = await _dioService.post(
      '$_baseUrl/add',
      headers: headers,
      data: body,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 201) {
      return TransactionEvent.fromJson(json.decode(response.data));
    } else {
      final errorBody = response.data;
      try {
        final errorJson = json.decode(errorBody);
        final message =
            errorJson['message'] ?? 'Failed to create ADD transaction event';
        throw Exception('$message (Status: ${response.statusCode})');
      } catch (_) {
        throw Exception(
          'Failed to create ADD transaction event: ${response.statusCode} - $errorBody',
        );
      }
    }
  }

  Future<TransactionEvent> createDeleteTransactionEvent(
    String bizTransactionType,
    String bizTransactionId,
    List<String> epcs,
    String locationGLN,
    String businessStep,
    String disposition,
    Map<String, String> bizData,
    DateTime eventTime,
  ) async {
    final headers = await _getHeaders();

    // Build bizTransactionList in the format expected by the backend
    final bizTransactionList = [
      {'type': bizTransactionType, 'id': bizTransactionId},
    ];
    // Format date with timezone information for Java ZonedDateTime compatibility
    final formattedEventTime = _formatDateForBackend(eventTime);
    final eventTimeZoneOffset = _getTimezoneOffset();

    // Generate a unique event ID using the UUID package
    final uuid = Uuid();
    final eventId = 'urn:epcglobal:cbv:epcis:event:${uuid.v4()}';
    // Ensure GLN codes are sent correctly for lookup on the backend
    final Map<String, dynamic> requestData = {
      'eventId': eventId,
      'eventTime': formattedEventTime,
      'recordTime': _formatDateForBackend(DateTime.now()),
      'eventTimeZoneOffset': eventTimeZoneOffset,
      'eventType': 'TransactionEvent',
      'epcisVersion': '2.0',
      'certificationInfo': <String>[],
      'bizTransactionList': bizTransactionList,
      'epcList': epcs,
      'businessStep':
          businessStep, // Send businessStep field as expected by the backend
      'disposition': disposition,
      'bizData': bizData,
      'action': 'DELETE',
      'parentID':
          'urn:epc:id:sscc:${DateTime.now().millisecondsSinceEpoch % 1000000000000}.0000000000',
      'quantityList': <Map<String, dynamic>>[],
    };

    // Only add GLN codes if they are not empty
    if (locationGLN.isNotEmpty) {
      requestData['businessLocation'] =
          locationGLN; // Use businessLocation instead of bizLocation as field name
      requestData['readPoint'] = locationGLN;
    }

    final body = json.encode(requestData);

    final response = await _dioService.post(
      '$_baseUrl/delete',
      headers: headers,
      data: body,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 201) {
      return TransactionEvent.fromJson(json.decode(response.data));
    } else {
      final errorBody = response.data;
      try {
        final errorJson = json.decode(errorBody);
        final message =
            errorJson['message'] ?? 'Failed to create DELETE transaction event';
        throw Exception('$message (Status: ${response.statusCode})');
      } catch (_) {
        throw Exception(
          'Failed to create DELETE transaction event: ${response.statusCode} - $errorBody',
        );
      }
    }
  }

  Future<TransactionEvent> createObserveTransactionEvent(
    String bizTransactionType,
    String bizTransactionId,
    List<String> epcs,
    String locationGLN,
    String businessStep,
    String disposition,
    Map<String, String> bizData,
    DateTime eventTime,
  ) async {
    final headers = await _getHeaders();

    // Build bizTransactionList in the format expected by the backend
    final bizTransactionList = [
      {'type': bizTransactionType, 'id': bizTransactionId},
    ];
    // Format date with timezone information for Java ZonedDateTime compatibility
    final formattedEventTime = _formatDateForBackend(eventTime);
    final eventTimeZoneOffset = _getTimezoneOffset();

    // Generate a unique event ID using the UUID package
    final uuid = Uuid();
    final eventId = 'urn:epcglobal:cbv:epcis:event:${uuid.v4()}';

    // Ensure GLN codes are sent correctly for lookup on the backend
    final Map<String, dynamic> requestData = {
      'eventId': eventId,
      'eventTime': formattedEventTime,
      'recordTime': _formatDateForBackend(DateTime.now()),
      'eventTimeZoneOffset': eventTimeZoneOffset,
      'eventType': 'TransactionEvent',
      'epcisVersion': '2.0',
      'certificationInfo': <String>[],
      'bizTransactionList': bizTransactionList,
      'epcList': epcs,
      'businessStep':
          businessStep, // Send businessStep field as expected by the backend
      'disposition': disposition,
      'bizData': bizData,
      'action': 'OBSERVE',
      'parentID':
          'urn:epc:id:sscc:${DateTime.now().millisecondsSinceEpoch % 1000000000000}.0000000000',
      'quantityList': <Map<String, dynamic>>[],
    };

    // Only add GLN codes if they are not empty
    if (locationGLN.isNotEmpty) {
      requestData['businessLocation'] =
          locationGLN; // Use businessLocation instead of bizLocation as field name
      requestData['readPoint'] = locationGLN;
    }

    final body = json.encode(requestData);

    // Since we might not have a dedicated endpoint for OBSERVE, we'll use the general create endpoint
    final response = await _dioService.post(
      _baseUrl,
      headers: headers,
      data: body,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 201) {
      return TransactionEvent.fromJson(json.decode(response.data));
    } else {
      final errorBody = response.data;
      try {
        final errorJson = json.decode(errorBody);
        final message =
            errorJson['message'] ??
            'Failed to create OBSERVE transaction event';
        throw Exception('$message (Status: ${response.statusCode})');
      } catch (_) {
        throw Exception(
          'Failed to create OBSERVE transaction event: ${response.statusCode} - $errorBody',
        );
      }
    }
  }

  /// Helper method to format date with proper timezone for Java ZonedDateTime
  String _formatDateForBackend(DateTime dateTime) {
    // Ensure we're working with UTC time and add extra buffer for safety
    final utcDateTime = dateTime.toUtc().subtract(const Duration(seconds: 30));
    String isoString = utcDateTime.toIso8601String();

    // Check if it already has timezone information
    if (isoString.endsWith('Z') ||
        isoString.contains('+') ||
        isoString.contains('-', isoString.length - 6)) {
      return isoString;
    }

    // Add timezone offset
    return '${isoString}Z'; // Use Z for UTC
  }

  /// Get timezone offset string for backend
  String _getTimezoneOffset() {
    final offset = DateTime.now().timeZoneOffset;
    final hours = offset.inHours.abs();
    final minutes = (offset.inMinutes.abs() % 60);
    final sign = offset.isNegative ? '-' : '+';
    return '$sign${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }
}
