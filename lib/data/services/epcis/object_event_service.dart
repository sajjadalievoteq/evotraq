import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';
import 'package:traqtrace_app/core/network/page_response_utils.dart';
import 'package:traqtrace_app/core/utils/gs1/gs1_converter.dart';
import 'package:traqtrace_app/data/models/epcis/object_event.dart';
import 'package:traqtrace_app/data/models/epcis/epcis_types.dart';
import 'package:traqtrace_app/data/models/epcis/cbv_vocabulary_formatter.dart';
import 'package:traqtrace_app/data/services/epcis/object_event_api_constants.dart';

part 'object_event_service_operations.dart';
part 'object_event_service_convenience_operations.dart';

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
    final raw = await _getObjectEventsPage(_baseUrl, page: page, size: size);
    final content = PageResponseUtils.contentList(
      raw,
    ).map((e) => ObjectEvent.fromJson(e as Map<String, dynamic>)).toList();
    return PageResponseUtils.toResultMap(content: content, raw: raw);
  }

  Future<Map<String, dynamic>> _getObjectEventsPage(
    String path, {
    Map<String, String>? queryParameters,
    required int page,
    required int size,
  }) async {
    final headers = await _getHeaders();
    final params = <String, String>{
      ...?queryParameters,
      ObjectEventApiConstants.queryPage: page.toString(),
      ObjectEventApiConstants.querySize: PageResponseUtils.clampSize(
        size,
      ).toString(),
    };
    final response = await _dioService.get(
      path,
      queryParameters: params,
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return PageResponseUtils.normalizeBody(json.decode(response.data));
    }
    throw Exception('Failed to load object events: ${response.statusCode}');
  }

  Future<List<ObjectEvent>> _fetchAllObjectEvents(
    String path, {
    Map<String, String>? queryParameters,
  }) {
    return PageResponseUtils.fetchAllPages(
      fetchPage: (page, size) => _getObjectEventsPage(
        path,
        queryParameters: queryParameters,
        page: page,
        size: size,
      ),
      parseItem: ObjectEvent.fromJson,
    );
  }

  Future<ObjectEvent> getObjectEventById(String id) async {
    final headers = await _getHeaders();
    final path = '$_baseUrl/$id';
    final response = await _dioService.get(
      path,
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    _logObjectEventDetailResponse(
      lookup: 'id=$id',
      path: path,
      statusCode: response.statusCode,
      body: response.data,
    );

    if (response.statusCode == 200) {
      return ObjectEvent.fromJson(json.decode(response.data));
    } else {
      throw Exception('Failed to fetch object event: ${response.statusCode}');
    }
  }

  Future<ObjectEvent> getObjectEventByEventId(String eventId) async {
    final trimmedEventId = eventId.trim();
    if (trimmedEventId.isEmpty) {
      throw ArgumentError('eventId must not be empty');
    }

    final headers = await _getHeaders();
    final path = '$_baseUrl/${ObjectEventApiConstants.segmentEventId}';
    final response = await _dioService.get(
      path,
      queryParameters: {ObjectEventApiConstants.queryEventId: trimmedEventId},
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    _logObjectEventDetailResponse(
      lookup: 'eventId=$trimmedEventId',
      path: '$path?${ObjectEventApiConstants.queryEventId}=$trimmedEventId',
      statusCode: response.statusCode,
      body: response.data,
    );

    if (response.statusCode == 200) {
      return ObjectEvent.fromJson(json.decode(response.data));
    } else {
      throw Exception('Failed to fetch object event: ${response.statusCode}');
    }
  }

  static void _logObjectEventDetailResponse({
    required String lookup,
    required String path,
    required int? statusCode,
    required dynamic body,
  }) {
    debugPrint(
      '[ObjectEventService.getObjectEventDetail] $lookup '
      'status=$statusCode path=$path',
    );
    if (body == null) {
      debugPrint(
        '[ObjectEventService.getObjectEventDetail] responseBody: null',
      );
      return;
    }
    final bodyString = body is String ? body : body.toString();
    if (bodyString.isEmpty) {
      debugPrint(
        '[ObjectEventService.getObjectEventDetail] responseBody: (empty)',
      );
      return;
    }
    try {
      final decoded = json.decode(bodyString);
      final pretty = const JsonEncoder.withIndent('  ').convert(decoded);
      debugPrint(
        '[ObjectEventService.getObjectEventDetail] responseBody:\n$pretty',
      );
    } catch (_) {
      debugPrint(
        '[ObjectEventService.getObjectEventDetail] responseBody: $bodyString',
      );
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

    final versionString = epcisVersion == EPCISVersion.v2_0 ? '2.0' : '1.3';

    final now = DateTime.now();
    final eventData = <String, dynamic>{
      ObjectEventApiConstants.jsonKeyEventId:
          'event_${now.millisecondsSinceEpoch}_${(now.microsecond % 1000).toString().padLeft(3, '0')}',
      ObjectEventApiConstants.jsonKeyEventType:
          ObjectEventApiConstants.eventTypeObject,
      ObjectEventApiConstants.jsonKeyAction: action,
      ObjectEventApiConstants.jsonKeyBusinessStep:
          CbvVocabularyFormatter.formatBizStep(versionString, businessStep),
      ObjectEventApiConstants.jsonKeyDisposition:
          CbvVocabularyFormatter.formatDisposition(versionString, disposition),
      ObjectEventApiConstants.jsonKeyEventTime: now.toIso8601String(),
      ObjectEventApiConstants.jsonKeyRecordTime: now.toIso8601String(),
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
      eventData[ObjectEventApiConstants.jsonKeyQuantityList] = quantities
          .map((q) => q.toJson())
          .toList();
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

    try {
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
        } catch (e, st) {
          final parseError = ApiException(
            statusCode: response.statusCode,
            message:
                'Failed to parse object event response: $e. Response body: ${response.data}',
            responseBody: response.data?.toString(),
            originalException: e,
          );
          _logCreateObjectEventApiException(parseError, stackTrace: st);
          throw parseError;
        }
      }

      final apiException = ApiException(
        statusCode: response.statusCode,
        message:
            _parseCreateObjectEventErrorMessage(response.data) ??
            'Failed to create object event',
        responseBody: response.data?.toString(),
      );
      _logCreateObjectEventApiException(apiException);
      throw apiException;
    } on DioException catch (e, st) {
      final apiException = ApiException(
        statusCode: e.response?.statusCode,
        message: e.message ?? 'Network error while creating object event',
        originalException: e,
        responseBody: e.response?.data?.toString(),
      );
      _logCreateObjectEventApiException(apiException, stackTrace: st);
      throw apiException;
    } on ApiException catch (e, st) {
      _logCreateObjectEventApiException(e, stackTrace: st);
      rethrow;
    }
  }

  static void _logCreateObjectEventApiException(
    ApiException e, {
    StackTrace? stackTrace,
  }) {
    debugPrint(
      '[ObjectEventService.createObjectEvent] ApiException '
      'status=${e.statusCode} message=${e.message}',
    );
    if (e.responseBody != null && e.responseBody!.isNotEmpty) {
      debugPrint(
        '[ObjectEventService.createObjectEvent] responseBody: ${e.responseBody}',
      );
    }
    if (e.originalException != null) {
      debugPrint(
        '[ObjectEventService.createObjectEvent] original: ${e.originalException}',
      );
    }
    if (stackTrace != null) {
      debugPrint('[ObjectEventService.createObjectEvent] $stackTrace');
    }
  }

  static String? _parseCreateObjectEventErrorMessage(dynamic data) {
    if (data == null) return null;
    try {
      final dynamic decoded = data is String ? json.decode(data) : data;
      if (decoded is Map) {
        final message = decoded['message'];
        if (message != null && message.toString().isNotEmpty) {
          return message.toString();
        }
        final error = decoded['error'];
        if (error != null && error.toString().isNotEmpty) {
          return error.toString();
        }
      }
    } catch (_) {}
    return data.toString();
  }
}
