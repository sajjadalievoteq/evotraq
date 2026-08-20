import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';
import 'package:traqtrace_app/core/network/page_response_utils.dart';
import 'package:traqtrace_app/data/models/epcis/aggregation_event.dart';

import 'package:traqtrace_app/data/services/epcis/aggregation_event_service_operations.dart';

class AggregationEventService {
  final DioService dioService;

  late final String baseUrl;
  AggregationEventService({required DioService dioService})
    : dioService = dioService {
    baseUrl = '${dioService.baseUrl}/events/aggregation';
  }

  Future<Map<String, String>> getHeaders() async {
    final token = await dioService.getAuthToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<AggregationEvent> getAggregationEventByIdentifier(String id) async {
    final trimmed = id.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('event identifier must not be empty');
    }

    final headers = await getHeaders();

    if (RegExp(r'^\d+$').hasMatch(trimmed)) {
      final response = await dioService.get(
        '$baseUrl/$trimmed',
        headers: headers,
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );
      if (response.statusCode == 200) {
        return AggregationEvent.fromJson(json.decode(response.data));
      }
    }

    final response = await dioService.get(
      '$baseUrl/event-id',
      queryParameters: {'eventId': trimmed},
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return AggregationEvent.fromJson(json.decode(response.data));
    }

    throw Exception('Failed to get aggregation event: ${response.statusCode}');
  }

  Future<AggregationEvent> createAggregationEvent(
    AggregationEvent event,
  ) async {
    final headers = await getHeaders();

    final offset = DateTime.now().timeZoneOffset;
    final hours = offset.inHours.abs();
    final minutes = (offset.inMinutes.abs() % 60);
    final sign = offset.isNegative ? '-' : '+';

    final String eventTimeZone =
        '$sign${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';

    final eventTime =
        '${event.eventTime.toIso8601String().split('.')[0]}$eventTimeZone';

    Map<String, dynamic> jsonData = event.toJson();

    jsonData['eventType'] = 'AggregationEvent';
    jsonData['eventId'] = event.eventId.isNotEmpty
        ? event.eventId
        : 'event-${DateTime.now().millisecondsSinceEpoch}';
    jsonData['recordTime'] = DateTime.now().toIso8601String();
    jsonData['epcisVersion'] = '2.0';
    jsonData['certificationInfo'] = [];
    if (jsonData['childQuantityList'] == null) {
      jsonData['childQuantityList'] = [];
    }
    jsonData['eventTimeZoneOffset'] = eventTimeZone;
    jsonData['eventTimeZone'] = eventTimeZone;
    jsonData['eventTime'] = eventTime;
    if (event.readPoint != null) {
      jsonData['readPoint'] = event.readPoint!.glnCode;
    }

    if (event.businessLocation != null) {
      jsonData['businessLocation'] = event.businessLocation!.glnCode;
    }

    final jsonPayload = jsonEncode(jsonData);
    final response = await dioService.post(
      baseUrl,
      headers: headers,
      data: jsonPayload,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return AggregationEvent.fromJson(json.decode(response.data));
    } else {
      throw Exception(getDetailedErrorMessage(response));
    }
  }

  Future<Map<String, dynamic>> getAllAggregationEvents(
    int page,
    int size, {
    String sortBy = 'eventTime',
    String direction = 'DESC',
  }) async {
    final raw = await _getAggregationEventsPage(
      baseUrl,
      page: page,
      size: size,
      extraQueryParameters: {'sortBy': sortBy, 'direction': direction},
    );
    final content = PageResponseUtils.contentList(raw)
        .map((json) => AggregationEvent.fromJson(json as Map<String, dynamic>))
        .toList();
    return PageResponseUtils.toResultMap(content: content, raw: raw);
  }

  Future<Map<String, dynamic>> _getAggregationEventsPage(
    String path, {
    Map<String, String>? extraQueryParameters,
    required int page,
    required int size,
  }) async {
    final headers = await getHeaders();
    final queryParameters = <String, String>{
      ...?extraQueryParameters,
      'page': page.toString(),
      'size': PageResponseUtils.clampSize(size).toString(),
    };
    final response = await dioService.get(
      path,
      queryParameters: queryParameters,
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return PageResponseUtils.normalizeBody(json.decode(response.data));
    }
    throw Exception(
      'Failed to get aggregation events: ${response.statusCode} - ${response.data}',
    );
  }

  Future<List<AggregationEvent>> _fetchAllAggregationEvents(
    String path, {
    Map<String, String>? extraQueryParameters,
  }) {
    return PageResponseUtils.fetchAllPages(
      fetchPage: (page, size) => _getAggregationEventsPage(
        path,
        extraQueryParameters: extraQueryParameters,
        page: page,
        size: size,
      ),
      parseItem: AggregationEvent.fromJson,
    );
  }

  Future<List<AggregationEvent>> findAggregationEventsByAction(
    String action,
  ) async {
    return _fetchAllAggregationEvents('$baseUrl/action/$action');
  }

  Future<List<AggregationEvent>> findAggregationEventsByParentEPC(
    String parentEPC,
  ) async {
    return _fetchAllAggregationEvents(
      '$baseUrl/parent',
      extraQueryParameters: {'parentEPC': parentEPC},
    );
  }

  Future<List<AggregationEvent>> findAggregationEventsByChildEPC(
    String childEPC,
  ) async {
    return _fetchAllAggregationEvents(
      '$baseUrl/child',
      extraQueryParameters: {'childEPC': childEPC},
    );
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

  Future<List<AggregationEvent>> findAggregationEventsByBusinessStep(
    String businessStep,
  ) async {
    return _fetchAllAggregationEvents('$baseUrl/business-step/$businessStep');
  }

  Future<List<AggregationEvent>> findAggregationEventsByDisposition(
    String disposition,
  ) async {
    return _fetchAllAggregationEvents('$baseUrl/disposition/$disposition');
  }

  /// Resolves the active parent of [childEPC] via `/container` only.
  /// Does not re-fetch child ADD events (use event history APIs for that).
  Future<AggregationEvent> findCurrentParentOfChild(String childEPC) async {
    final headers = await getHeaders();

    try {
      final response = await dioService.get(
        '$baseUrl/container',
        queryParameters: {'childEPC': childEPC},
        headers: headers,
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.data);
        final parentEPC = decoded is String
            ? decoded
            : decoded?.toString() ?? '';
        final cleaned = parentEPC.replaceAll('"', '').trim();
        if (cleaned.isEmpty || cleaned == 'null') {
          throw Exception("Child $childEPC is not currently in any container");
        }
        final now = DateTime.now();
        return AggregationEvent(
          eventId: 'active-parent-$childEPC',
          eventTime: now,
          recordTime: now,
          eventTimeZone: '+00:00',
          action: 'ADD',
          parentID: cleaned,
          childEPCs: [childEPC],
        );
      } else if (response.statusCode == 404) {
        throw Exception("Child $childEPC is not currently in any container");
      } else {
        throw Exception(getDetailedErrorMessage(response));
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<AggregationEvent>>
  findAggregationEventsByBusinessStepAndParentEPC(
    String businessStep,
    String parentEPC,
  ) async {
    final events = await findAggregationEventsByParentEPC(parentEPC);
    return events.where((event) => event.businessStep == businessStep).toList();
  }

  Future<List<AggregationEvent>> findAggregationEventsByLocationAndTimeWindow(
    String locationGLN,
    DateTime startTime,
    DateTime endTime,
  ) async {
    final events = await _fetchAllAggregationEvents(
      '$baseUrl/time-range',
      extraQueryParameters: {
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
      },
    );
    return events
        .where(
          (event) =>
              (event.readPoint?.glnCode == locationGLN) ||
              (event.businessLocation?.glnCode == locationGLN),
        )
        .toList();
  }
}
