import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';
import 'package:traqtrace_app/data/models/epcis/object_event.dart';
import 'package:traqtrace_app/data/models/epcis/epcis_types.dart';
import 'package:traqtrace_app/data/services/epcis/object_event_api_constants.dart';

class ObjectEventService {
  final DioService _dioService;

  late final String _baseUrl;

  ObjectEventService({required DioService dioService})
    : _dioService = dioService {
    _baseUrl = '${_dioService.baseUrl}${ObjectEventApiConstants.basePath}';
  }

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
      queryParameters: {
        ObjectEventApiConstants.queryPage: page.toString(),
        ObjectEventApiConstants.querySize: size.toString(),
      },
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
      '$_baseUrl/${ObjectEventApiConstants.segmentEventId}',
      queryParameters: {ObjectEventApiConstants.queryEventId: eventId},
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
      ObjectEventApiConstants.jsonKeyEventId:
          'event_${now.millisecondsSinceEpoch}_${(now.microsecond % 1000).toString().padLeft(3, '0')}',
      ObjectEventApiConstants.jsonKeyEventType:
          ObjectEventApiConstants.eventTypeObject,
      ObjectEventApiConstants.jsonKeyAction: action,
      ObjectEventApiConstants.jsonKeyBusinessStep: businessStep,
      ObjectEventApiConstants.jsonKeyDisposition: disposition,
      ObjectEventApiConstants.jsonKeyEventTime: now.toUtc().toIso8601String(),
      ObjectEventApiConstants.jsonKeyRecordTime: now.toUtc().toIso8601String(),
      ObjectEventApiConstants.jsonKeyEpcisVersion:
          epcisVersion == EPCISVersion.v2_0
              ? ObjectEventApiConstants.epcisVersion20
              : ObjectEventApiConstants.epcisVersion13,
    };

    final offset = now.timeZoneOffset;
    final hours = offset.inHours.abs();
    final minutes = (offset.inMinutes.abs() % 60);
    final sign = offset.isNegative ? '-' : '+';
    final timezoneOffset =
        '$sign${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
    eventData[ObjectEventApiConstants.jsonKeyEventTimeZoneOffset] =
        timezoneOffset;

    if (readPointGLN != null) {
      eventData[ObjectEventApiConstants.jsonKeyReadPoint] = readPointGLN;
    }
    if (businessLocationGLN != null) {
      eventData[ObjectEventApiConstants.jsonKeyBusinessLocation] =
          businessLocationGLN;
    }

    if (epcs != null && epcs.isNotEmpty) {
      eventData[ObjectEventApiConstants.jsonKeyEpcList] = epcs;
      eventData[ObjectEventApiConstants.jsonKeyQuantityList] = [];
    } else if (quantities != null && quantities.isNotEmpty) {
      eventData[ObjectEventApiConstants.jsonKeyQuantityList] =
          quantities.map((q) => q.toJson()).toList();
    } else {
      eventData[ObjectEventApiConstants.jsonKeyEpcList] = [];
      eventData[ObjectEventApiConstants.jsonKeyQuantityList] = [];
    }

    if (ilmd != null) {
      eventData[ObjectEventApiConstants.jsonKeyIlmd] = ilmd;
    }
    if (bizData != null) {
      eventData[ObjectEventApiConstants.jsonKeyBizData] = bizData;
    }
    if (sources != null && sources.isNotEmpty) {
      eventData[ObjectEventApiConstants.jsonKeySourceList] = sources
          .map((s) => {'sourceType': s.type, 'sourceID': s.id})
          .toList();
    }
    if (destinations != null && destinations.isNotEmpty) {
      eventData[ObjectEventApiConstants.jsonKeyDestinationList] = destinations
          .map((d) => {'destinationType': d.type, 'destinationID': d.id})
          .toList();
    }
    if (persistentDisposition != null) {
      eventData[ObjectEventApiConstants.jsonKeyPersistentDisposition] =
          persistentDisposition;
    }
    if (sensorElements != null) {
      eventData[ObjectEventApiConstants.jsonKeySensorElementList] =
          sensorElements;
    }
    if (certificationInfo != null) {
      eventData[ObjectEventApiConstants.jsonKeyCertificationInfo] =
          certificationInfo;
    }

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
        '$_baseUrl/${ObjectEventApiConstants.segmentValidate}',
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
      '$_baseUrl/${ObjectEventApiConstants.segmentBatch}',
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
      '$_baseUrl/${ObjectEventApiConstants.segmentAction}/$action',
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
      '$_baseUrl/${ObjectEventApiConstants.segmentEpc}/$epc',
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
      '$_baseUrl/${ObjectEventApiConstants.segmentEpcs}',
      queryParameters: {ObjectEventApiConstants.queryEpcs: epcsParam},
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
      '$_baseUrl/${ObjectEventApiConstants.segmentEpcClass}/$epcClass',
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
      '$_baseUrl/${ObjectEventApiConstants.segmentIlmd}',
      queryParameters: {
        ObjectEventApiConstants.queryProperty: property,
        ObjectEventApiConstants.queryValue: value,
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
      '$_baseUrl/${ObjectEventApiConstants.segmentQuantity}',
      queryParameters: {
        ObjectEventApiConstants.queryEpcClass: epcClass,
        ObjectEventApiConstants.queryMin: minQuantity.toString(),
        ObjectEventApiConstants.queryMax: maxQuantity.toString(),
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
      '$_baseUrl/${ObjectEventApiConstants.segmentBusinessStep}/$businessStep',
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
      '$_baseUrl/${ObjectEventApiConstants.segmentDisposition}/$disposition',
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
      '$_baseUrl/${ObjectEventApiConstants.segmentLocation}/$locationGLN',
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
      '$_baseUrl/${ObjectEventApiConstants.segmentTimeRange}',
      queryParameters: {
        ObjectEventApiConstants.queryStartTime: startTimeStr,
        ObjectEventApiConstants.queryEndTime: endTimeStr,
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
      '$_baseUrl/${ObjectEventApiConstants.segmentLocation}/$locationGLN/${ObjectEventApiConstants.segmentTimeRange}',
      queryParameters: {
        ObjectEventApiConstants.queryStartTime: startTimeStr,
        ObjectEventApiConstants.queryEndTime: endTimeStr,
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
        'Failed to fetch object events by location and time window: ${response.data}',
      );
    }
  }

  Future<Map<String, dynamic>> getEventStatistics({
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    final headers = await _getHeaders();

    final queryParams = <String, String>{};
    if (startTime != null) {
      queryParams[ObjectEventApiConstants.queryStartTime] =
          startTime.toIso8601String();
    }
    if (endTime != null) {
      queryParams[ObjectEventApiConstants.queryEndTime] =
          endTime.toIso8601String();
    }

    final uri = Uri.parse(
      '$_baseUrl/${ObjectEventApiConstants.segmentStatistics}',
    ).replace(queryParameters: queryParams);
    final response = await _dioService.get(
      uri.toString(),
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.data);

      Map<String, dynamic> transformedData = {
        'totalEvents': data['totalEvents'] ?? 0,
        'recentEvents': data['recentEvents'] ?? 0,
      };

      if (data['eventsByAction'] != null) {
        transformedData['actionCounts'] = data['eventsByAction'];
      }

      if (data['topBusinessSteps'] != null) {
        transformedData['businessStepCounts'] = data['topBusinessSteps'];
      }

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
      '$_baseUrl/${ObjectEventApiConstants.segmentEpc}/$epc',
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
      ObjectEventApiConstants.jsonKeyAction: ObjectEventApiConstants.actionAdd,
      ObjectEventApiConstants.jsonKeyEpcList: [epc],
      ObjectEventApiConstants.jsonKeyBusinessLocation: locationGLN,
      ObjectEventApiConstants.jsonKeyBusinessStep: businessStep,
      ObjectEventApiConstants.jsonKeyDisposition: disposition,
      ObjectEventApiConstants.jsonKeyIlmd: ilmd,
      ObjectEventApiConstants.jsonKeyBizData: bizData,
      ObjectEventApiConstants.jsonKeyEventTime:
          DateTime.now().toUtc().toIso8601String(),
    };

    final response = await _dioService.post(
      '$_baseUrl/${ObjectEventApiConstants.segmentAdd}',
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
      ObjectEventApiConstants.jsonKeyAction:
          ObjectEventApiConstants.actionObserve,
      ObjectEventApiConstants.jsonKeyEpcList: [epc],
      ObjectEventApiConstants.jsonKeyBusinessLocation: locationGLN,
      ObjectEventApiConstants.jsonKeyBusinessStep: businessStep,
      ObjectEventApiConstants.jsonKeyDisposition: disposition,
      ObjectEventApiConstants.jsonKeyBizData: bizData,
      ObjectEventApiConstants.jsonKeyEventTime:
          DateTime.now().toUtc().toIso8601String(),
    };

    final response = await _dioService.post(
      '$_baseUrl/${ObjectEventApiConstants.segmentObserve}',
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
      ObjectEventApiConstants.jsonKeyAction:
          ObjectEventApiConstants.actionDelete,
      ObjectEventApiConstants.jsonKeyEpcList: [epc],
      ObjectEventApiConstants.jsonKeyBusinessLocation: locationGLN,
      ObjectEventApiConstants.jsonKeyBusinessStep: businessStep,
      ObjectEventApiConstants.jsonKeyDisposition: disposition,
      ObjectEventApiConstants.jsonKeyBizData: bizData,
      ObjectEventApiConstants.jsonKeyEventTime:
          DateTime.now().toUtc().toIso8601String(),
    };

    final response = await _dioService.post(
      '$_baseUrl/${ObjectEventApiConstants.segmentDelete}',
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
    final headers = await _getHeaders();
    final response = await _dioService.get(
      _baseUrl,
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
      '$_baseUrl/${ObjectEventApiConstants.segmentBusinessStep}/$businessStep/${ObjectEventApiConstants.segmentEpc}/$epc',
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

  /// Paginated multi-filter search — hits GET /events/object/search.
  Future<Map<String, dynamic>> searchObjectEvents({
    String? action,
    String? bizStep,
    String? disposition,
    String? locationGLN,
    String? searchText,
    DateTime? startTime,
    DateTime? endTime,
    int page = 0,
    int size = 20,
    String direction = 'DESC',
  }) async {
    final headers = await _getHeaders();
    final params = <String, String>{
      ObjectEventApiConstants.queryPage: page.toString(),
      ObjectEventApiConstants.querySize: size.toString(),
      ObjectEventApiConstants.queryDirection: direction,
    };
    if (action != null) {
      params[ObjectEventApiConstants.queryAction] = action;
    }
    if (bizStep != null) {
      params[ObjectEventApiConstants.queryBizStep] = bizStep;
    }
    if (disposition != null) {
      params[ObjectEventApiConstants.queryDisposition] = disposition;
    }
    if (locationGLN != null) {
      params[ObjectEventApiConstants.queryLocationGln] = locationGLN;
    }
    if (searchText != null) {
      params[ObjectEventApiConstants.querySearchText] = searchText;
    }
    if (startTime != null) {
      params[ObjectEventApiConstants.queryStartTime] =
          startTime.toUtc().toIso8601String();
    }
    if (endTime != null) {
      params[ObjectEventApiConstants.queryEndTime] =
          endTime.toUtc().toIso8601String();
    }

    final response = await _dioService.get(
      '$_baseUrl/${ObjectEventApiConstants.segmentSearch}',
      queryParameters: params,
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
      throw Exception('Failed to search object events: ${response.statusCode}');
    }
  }

  /// Chronological event history for an EPC — hits GET /events/object/epc/{epc}/history.
  Future<List<ObjectEvent>> getEpcHistory(String epc) async {
    final headers = await _getHeaders();
    final response = await _dioService.get(
      '$_baseUrl/${ObjectEventApiConstants.segmentEpc}/$epc/${ObjectEventApiConstants.segmentHistory}',
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
}
