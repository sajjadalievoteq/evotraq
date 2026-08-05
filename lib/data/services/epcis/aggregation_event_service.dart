import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';
import 'package:traqtrace_app/core/network/page_response_utils.dart';
import 'package:traqtrace_app/data/models/epcis/aggregation_event.dart';

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

  Future<AggregationEvent> getAggregationEventByIdentifier(String id) async {
    final trimmed = id.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('event identifier must not be empty');
    }

    final headers = await _getHeaders();

    if (RegExp(r'^\d+$').hasMatch(trimmed)) {
      final response = await _dioService.get(
        '$_baseUrl/$trimmed',
        headers: headers,
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );
      if (response.statusCode == 200) {
        return AggregationEvent.fromJson(json.decode(response.data));
      }
    }

    final response = await _dioService.get(
      '$_baseUrl/event-id',
      queryParameters: {'eventId': trimmed},
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return AggregationEvent.fromJson(json.decode(response.data));
    }

    throw Exception(
      'Failed to get aggregation event: ${response.statusCode}',
    );
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
    final response = await _dioService.post(
      _baseUrl,
      headers: headers,
      data: jsonPayload,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return AggregationEvent.fromJson(json.decode(response.data));
    } else {
      throw Exception(_getDetailedErrorMessage(response));
    }
  }

  Future<Map<String, dynamic>> getAllAggregationEvents(
    int page,
    int size, {
    String sortBy = 'eventTime',
    String direction = 'DESC',
  }) async {
    final raw = await _getAggregationEventsPage(
      _baseUrl,
      page: page,
      size: size,
      extraQueryParameters: {
        'sortBy': sortBy,
        'direction': direction,
      },
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
    final headers = await _getHeaders();
    final queryParameters = <String, String>{
      ...?extraQueryParameters,
      'page': page.toString(),
      'size': PageResponseUtils.clampSize(size).toString(),
    };
    final response = await _dioService.get(
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
    return _fetchAllAggregationEvents('$_baseUrl/action/$action');
  }

  Future<List<AggregationEvent>> findAggregationEventsByParentEPC(
    String parentEPC,
  ) async {
    return _fetchAllAggregationEvents(
      '$_baseUrl/parent',
      extraQueryParameters: {'parentEPC': parentEPC},
    );
  }

  Future<List<AggregationEvent>> findAggregationEventsByChildEPC(
    String childEPC,
  ) async {
    return _fetchAllAggregationEvents(
      '$_baseUrl/child',
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
    return _fetchAllAggregationEvents('$_baseUrl/business-step/$businessStep');
  }

  Future<List<AggregationEvent>> findAggregationEventsByDisposition(
    String disposition,
  ) async {
    return _fetchAllAggregationEvents('$_baseUrl/disposition/$disposition');
  }

  /// Resolves the active parent of [childEPC] via `/container` only.
  /// Does not re-fetch child ADD events (use event history APIs for that).
  Future<AggregationEvent> findCurrentParentOfChild(String childEPC) async {
    final headers = await _getHeaders();

    try {
      final response = await _dioService.get(
        '$_baseUrl/container',
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
        throw Exception(_getDetailedErrorMessage(response));
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
      '$_baseUrl/time-range',
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

  /// @Deprecated Prefer [PackingOperationService.createPackingOperation]
  /// (`POST /operations/packing`). Kept for non-UI callers only.
  @Deprecated('Use PackingOperationService.createPackingOperation instead')
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

    final response = await _dioService.post(
      _baseUrl,
      headers: headers,
      data: body,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return AggregationEvent.fromJson(json.decode(response.data));
    } else {
      throw Exception(_getDetailedErrorMessage(response));
    }
  }

  /// @Deprecated Prefer [UnpackingOperationService.createUnpackingOperation]
  /// (`POST /operations/unpacking`). Kept for non-UI callers only.
  @Deprecated('Use UnpackingOperationService.createUnpackingOperation instead')
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

    final response = await _dioService.post(
      _baseUrl,
      headers: headers,
      data: body,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
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
    } catch (_) {
      return 'Error: Unable to process the request. Please check your input and try again.';
    }
  }

  /// Direct children of [parentEPC] via the canonical hierarchy children API
  /// (`GET /events/aggregation/children`). Prefer this over traversal
  /// `contained-items` for product/ops UIs.
  Future<List<String>> findContainerContents(String parentEPC) async {
    final headers = await _getHeaders();
    const pageSize = 200;
    final all = <String>[];
    var page = 0;

    try {
      while (true) {
        final response = await _dioService.get(
          '$_baseUrl/children',
          queryParameters: {
            'parentEPC': parentEPC,
            'page': page.toString(),
            'size': pageSize.toString(),
          },
          headers: headers,
          responseType: ResponseType.plain,
          acceptAllStatusCodes: true,
        );

        if (response.statusCode != 200) {
          throw Exception(_getDetailedErrorMessage(response));
        }

        final data = json.decode(response.data) as Map<String, dynamic>;
        final children = data['children'] as List<dynamic>? ?? const [];
        for (final raw in children) {
          if (raw is! Map<String, dynamic>) continue;
          final epc = raw['epc']?.toString().trim();
          if (epc != null && epc.isNotEmpty) all.add(epc);
        }

        final hasMore = data['hasMore'] as bool? ?? false;
        final totalPages = (data['totalPages'] as num?)?.toInt() ?? (page + 1);
        if (!hasMore || page + 1 >= totalPages) break;
        page++;
      }
      return all;
    } catch (e) {
      rethrow;
    }
  }

  /// Integrity check using the same children/container APIs as the hierarchy UI
  /// (no separate traversal `contained-items` round-trip).
  Future<bool> verifyHierarchy(String epc) async {
    try {
      await findContainerContents(epc);
      return true;
    } catch (_) {
      try {
        final headers = await _getHeaders();
        final containerResponse = await _dioService.get(
          '$_baseUrl/container',
          queryParameters: {'childEPC': epc},
          headers: headers,
          responseType: ResponseType.plain,
          acceptAllStatusCodes: true,
        );
        return containerResponse.statusCode == 200;
      } catch (_) {
        return false;
      }
    }
  }
}
