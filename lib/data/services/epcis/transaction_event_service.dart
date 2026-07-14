import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';
import 'package:traqtrace_app/data/models/epcis/transaction_event.dart';
import 'package:uuid/uuid.dart';

class TransactionEventService {
  final DioService _dioService;

  late final String _baseUrl;

  TransactionEventService({required DioService dioService})
    : _dioService = dioService {
    _baseUrl = '${_dioService.baseUrl}/events/transaction';
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _dioService.getAuthToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<TransactionEvent> getTransactionEventById(String id) async {
    final headers = await _getHeaders();

    String cleanId;
    if (id.contains(':')) {
      cleanId = id.split(':').last;
    } else {
      cleanId = id;
    }

    try {
      final response = await _dioService.get(
        '$_baseUrl/$cleanId',
        headers: headers,
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );
      if (response.statusCode == 200) {
        final responseBody = json.decode(response.data);
        return TransactionEvent.fromJson(responseBody);
      } else {
        throw Exception(
          'Failed to get transaction event: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error retrieving transaction event: ${e.toString()}');
    }
  }

  Future<TransactionEvent> getTransactionEventByEventId(String eventId) async {
    final headers = await _getHeaders();
    final response = await _dioService.get(
      '$_baseUrl/event-id',
      queryParameters: {'eventId': eventId},
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
      '$_baseUrl/epc',
      queryParameters: {'epc': epc},
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
      '$_baseUrl/epcclass',
      queryParameters: {'epcClass': epcClass},
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
      '$_baseUrl/business-step/$businessStep/epc',
      queryParameters: {'epc': epc},
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
      '$_baseUrl/disposition/$disposition/epc',
      queryParameters: {'epc': epc},
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
    final headers = await _getHeaders();
    final response = await _dioService.get(
      '$_baseUrl/location',
      queryParameters: {'locationGLN': locationGLN},
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> eventList = json.decode(response.data);
      final allEvents = eventList
          .map((json) => TransactionEvent.fromJson(json))
          .toList();

      return allEvents
          .where(
            (event) =>
                !event.eventTime.isBefore(startTime) &&
                !event.eventTime.isAfter(endTime),
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
      '$_baseUrl/active/epc',
      queryParameters: {'epc': epc},
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
      '$_baseUrl/history/epc',
      queryParameters: {'epc': epc},
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

    final bizTransactionList = [
      {'type': bizTransactionType, 'id': bizTransactionId},
    ];
    final formattedEventTime = _formatDateForBackend(eventTime);
    final eventTimeZoneOffset = _getTimezoneOffset();

    final uuid = Uuid();
    final eventId = 'urn:epcglobal:cbv:epcis:event:${uuid.v4()}';
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
          businessStep,
      'disposition': disposition,
      'bizData': bizData,
      'action': 'ADD',
      'parentID':
          'https://id.gs1.org/00/${(DateTime.now().millisecondsSinceEpoch % 100000000000000000).toString().padLeft(18, '0')}',
      'quantityList': <Map<String, dynamic>>[],
    };

    if (locationGLN.isNotEmpty) {
      requestData['businessLocation'] =
          locationGLN;
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

    final bizTransactionList = [
      {'type': bizTransactionType, 'id': bizTransactionId},
    ];
    final formattedEventTime = _formatDateForBackend(eventTime);
    final eventTimeZoneOffset = _getTimezoneOffset();

    final uuid = Uuid();
    final eventId = 'urn:epcglobal:cbv:epcis:event:${uuid.v4()}';
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
          businessStep,
      'disposition': disposition,
      'bizData': bizData,
      'action': 'DELETE',
      'parentID':
          'https://id.gs1.org/00/${(DateTime.now().millisecondsSinceEpoch % 100000000000000000).toString().padLeft(18, '0')}',
      'quantityList': <Map<String, dynamic>>[],
    };

    if (locationGLN.isNotEmpty) {
      requestData['businessLocation'] =
          locationGLN;
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

    final bizTransactionList = [
      {'type': bizTransactionType, 'id': bizTransactionId},
    ];
    final formattedEventTime = _formatDateForBackend(eventTime);
    final eventTimeZoneOffset = _getTimezoneOffset();

    final uuid = Uuid();
    final eventId = 'urn:epcglobal:cbv:epcis:event:${uuid.v4()}';

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
          businessStep,
      'disposition': disposition,
      'bizData': bizData,
      'action': 'OBSERVE',
      'parentID':
          'https://id.gs1.org/00/${(DateTime.now().millisecondsSinceEpoch % 100000000000000000).toString().padLeft(18, '0')}',
      'quantityList': <Map<String, dynamic>>[],
    };

    if (locationGLN.isNotEmpty) {
      requestData['businessLocation'] =
          locationGLN;
      requestData['readPoint'] = locationGLN;
    }

    final body = json.encode(requestData);

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

  String _formatDateForBackend(DateTime dateTime) {
    final utcDateTime = dateTime.toUtc().subtract(const Duration(seconds: 30));
    String isoString = utcDateTime.toIso8601String();

    if (isoString.endsWith('Z') ||
        isoString.contains('+') ||
        isoString.contains('-', isoString.length - 6)) {
      return isoString;
    }

    return '${isoString}Z';
  }

  String _getTimezoneOffset() {
    final offset = DateTime.now().timeZoneOffset;
    final hours = offset.inHours.abs();
    final minutes = (offset.inMinutes.abs() % 60);
    final sign = offset.isNegative ? '-' : '+';
    return '$sign${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }
}
