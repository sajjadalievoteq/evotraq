import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';
import 'package:traqtrace_app/data/models/epcis/transaction_event.dart';


class TransactionEventService {
  final DioService dioService;

  late final String baseUrl;

  TransactionEventService({required DioService dioService})
    : dioService = dioService {
    baseUrl = '${dioService.baseUrl}/events/transaction';
  }

  Future<Map<String, String>> getHeaders() async {
    final token = await dioService.getAuthToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<TransactionEvent> getTransactionEventById(String id) async {
    final headers = await getHeaders();

    String cleanId;
    if (id.contains(':')) {
      cleanId = id.split(':').last;
    } else {
      cleanId = id;
    }

    try {
      final response = await dioService.get(
        '$baseUrl/$cleanId',
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
    final headers = await getHeaders();
    final response = await dioService.get(
      '$baseUrl/event-id',
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
    final headers = await getHeaders();
    final response = await dioService.post(
      baseUrl,
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
    final headers = await getHeaders();
    final response = await dioService.put(
      '$baseUrl/$id',
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
    final headers = await getHeaders();
    final response = await dioService.delete(
      '$baseUrl/$id',
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
    final headers = await getHeaders();
    final response = await dioService.get(
      '$baseUrl/action/$action',
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
    final headers = await getHeaders();
    final response = await dioService.get(
      '$baseUrl/epc',
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
    final headers = await getHeaders();
    final response = await dioService.get(
      '$baseUrl/epcclass',
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
    final headers = await getHeaders();
    final response = await dioService.get(
      '$baseUrl/biz-transaction',
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
    final headers = await getHeaders();
    final response = await dioService.get(
      '$baseUrl/business-step/$businessStep',
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
    final headers = await getHeaders();
    final response = await dioService.get(
      '$baseUrl/business-step/$businessStep/epc',
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
    final headers = await getHeaders();
    final response = await dioService.get(
      '$baseUrl/disposition/$disposition/epc',
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
    final headers = await getHeaders();
    final response = await dioService.get(
      '$baseUrl/location',
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
    final headers = await getHeaders();
    final response = await dioService.get(
      '$baseUrl/active/epc',
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
    final headers = await getHeaders();
    final response = await dioService.get(
      '$baseUrl/history/epc',
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
}
