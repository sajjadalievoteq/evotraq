import 'dart:convert';



import 'package:dio/dio.dart';

import 'package:flutter/foundation.dart';

import 'package:traqtrace_app/core/debug/operation_api_debug_trace.dart';

import 'package:traqtrace_app/core/network/api_exception.dart';

import 'package:traqtrace_app/core/network/dio_service.dart';

import 'package:traqtrace_app/data/models/operations/decommissioning/decommissioning_page_response.dart';

import 'package:traqtrace_app/data/models/operations/decommissioning/decommissioning_request_model.dart';

import 'package:traqtrace_app/data/models/operations/decommissioning/decommissioning_response_model.dart';

import 'package:traqtrace_app/features/operations/decommissioning/utils/decommissioning_request_debug.dart';

import 'package:traqtrace_app/features/operations/shared/utils/operation_api_error_message.dart';



class DecommissioningOperationService {

  DecommissioningOperationService({

    required DioService dioService,

  }) : _dioService = dioService;



  final DioService _dioService;



  String get _baseUrl => '${_dioService.baseUrl}/operations/decommissioning';



  Future<Map<String, String>> get _headers async {

    final token = await _dioService.getAuthToken();

    return {

      'Content-Type': 'application/json',

      if (token != null) 'Authorization': 'Bearer $token',

    };

  }



  Future<DecommissioningResponse> createDecommissioningOperation(

    DecommissioningRequest request,

  ) async {

    final started = DateTime.now();

    final headers = await _headers;

    final requestBody = jsonEncode(request.toJson());

    final validationNotes = DecommissioningRequestDebug.validateRequest(request);



    OperationApiDebugTrace buildTrace({

      int? statusCode,

      String? responseBody,

      String? errorMessage,

      StackTrace? stackTrace,

    }) {

      return OperationApiDebugTrace(

        operation: 'Decommissioning create',

        method: 'POST',

        url: _baseUrl,

        timestamp: started,

        requestHeaders: OperationApiDebugTrace.redactHeaders(headers),

        requestBody: requestBody,

        statusCode: statusCode,

        responseBody: responseBody,

        errorMessage: errorMessage,

        durationMs: DateTime.now().difference(started).inMilliseconds,

        stackTrace: stackTrace?.toString(),

        validationNotes: validationNotes,

        extra: {

          'epcCount': request.epcs.length.toString(),

          'locationGLN': request.locationGLN,

          'disposition': request.disposition,

        },

      );

    }



    void logTrace(OperationApiDebugTrace trace) {

      OperationApiDebugTrace.remember(trace);

      if (kDebugMode) {

        debugPrint(trace.fullReport());

      }

    }



    try {

      final response = await _dioService.post(

        _baseUrl,

        headers: headers,

        data: requestBody,

        responseType: ResponseType.plain,

        acceptAllStatusCodes: true,

      );



      final statusCode = response.statusCode;

      final body = response.data?.toString();



      if (statusCode == 201 ||

          statusCode == 200 ||

          statusCode == 207 ||

          statusCode == 422 ||

          statusCode == 400) {

        if (body == null || body.trim().isEmpty) {

          throw _apiExceptionFromResponse(

            response,

            fallbackMessage: 'Failed to create decommissioning operation',

            trace: buildTrace(

              statusCode: statusCode,

              responseBody: body,

              errorMessage: 'Empty response body',

            ),

          );

        }

        final responseData = jsonDecode(body) as Map<String, dynamic>;

        if (OperationApiErrorMessage.isStructuredErrorBody(responseData)) {

          final trace = buildTrace(

            statusCode: statusCode,

            responseBody: body,

            errorMessage: 'Structured error response',

          );

          logTrace(trace);

          throw ApiException(

            statusCode: statusCode,

            message: OperationApiErrorMessage.fromJsonMap(responseData) ??

                'Failed to create decommissioning operation',

            responseBody: body,

            debugTrace: trace,

          );

        }

        return DecommissioningResponse.fromJson(responseData);

      }



      throw _apiExceptionFromResponse(

        response,

        fallbackMessage: 'Failed to create decommissioning operation',

        trace: buildTrace(

          statusCode: statusCode,

          responseBody: body,

          errorMessage: 'Unexpected HTTP $statusCode',

        ),

      );

    } on ApiException catch (e) {

      if (e.debugTrace != null) logTrace(e.debugTrace!);

      rethrow;

    } on DioException catch (e, stackTrace) {

      throw _apiExceptionFromDio(

        e,

        stackTrace: stackTrace,

        fallbackMessage: 'Network error while creating decommissioning operation',

        trace: buildTrace(

          statusCode: e.response?.statusCode,

          responseBody: e.response?.data?.toString(),

          errorMessage: e.message,

          stackTrace: stackTrace,

        ),

      );

    } catch (e, stackTrace) {

      final trace = buildTrace(

        statusCode: null,

        errorMessage: e.toString(),

        stackTrace: stackTrace,

      );
      logTrace(trace);

      debugPrint(

        '[DecommissioningOperationService.create] unexpected: $e\n$stackTrace',

      );

      throw ApiException(

        message: 'Unexpected error creating decommissioning operation',

        originalException: e,

        debugTrace: trace,

      );

    }

  }



  Future<DecommissioningResponse> getDecommissioningOperation(

    String operationId,

  ) async {

    try {

      final headers = await _headers;

      final response = await _dioService.get(

        '$_baseUrl/$operationId',

        headers: headers,

        responseType: ResponseType.plain,

        acceptAllStatusCodes: true,

      );



      if (response.statusCode == 200) {

        final responseData = jsonDecode(response.data);

        return DecommissioningResponse.fromJson(responseData);

      }



      throw _apiExceptionFromResponse(

        response,

        fallbackMessage: 'Failed to get decommissioning operation',

      );

    } on ApiException {

      rethrow;

    } on DioException catch (e, stackTrace) {

      throw _apiExceptionFromDio(

        e,

        stackTrace: stackTrace,

        fallbackMessage: 'Network error while loading decommissioning operation',

      );

    } catch (e, stackTrace) {

      debugPrint('[DecommissioningOperationService.get] unexpected: $e\n$stackTrace');

      throw ApiException(

        message: 'Unexpected error loading decommissioning operation',

        originalException: e,

      );

    }

  }



  Future<List<DecommissioningResponse>> getAllDecommissioningOperations({

    int page = 0,

    int size = 20,

  }) async {

    try {

      final headers = await _headers;

      final response = await _dioService.get(

        _baseUrl,

        queryParameters: {'page': page.toString(), 'size': size.toString()},

        headers: headers,

        responseType: ResponseType.plain,

        acceptAllStatusCodes: true,

      );



      if (response.statusCode == 200) {

        final responseData = jsonDecode(response.data);

        final operations = responseData['operations'] as List;

        return operations

            .map((op) => DecommissioningResponse.fromJson(op))

            .toList();

      }



      throw _apiExceptionFromResponse(

        response,

        fallbackMessage: 'Failed to get decommissioning operations',

      );

    } on ApiException {

      rethrow;

    } on DioException catch (e, stackTrace) {

      throw _apiExceptionFromDio(

        e,

        stackTrace: stackTrace,

        fallbackMessage: 'Network error while loading decommissioning operations',

      );

    } catch (e, stackTrace) {

      debugPrint('[DecommissioningOperationService.list] unexpected: $e\n$stackTrace');

      throw ApiException(

        message: 'Unexpected error loading decommissioning operations',

        originalException: e,

      );

    }

  }



  Future<DecommissioningPageResponse> getDecommissioningOperationsPage({

    int page = 0,

    int size = 20,

  }) async {

    try {

      final headers = await _headers;

      final response = await _dioService.get(

        _baseUrl,

        queryParameters: {'page': page.toString(), 'size': size.toString()},

        headers: headers,

        responseType: ResponseType.plain,

        acceptAllStatusCodes: true,

      );



      if (response.statusCode == 200) {

        final responseData = jsonDecode(response.data) as Map<String, dynamic>;

        return DecommissioningPageResponse.fromJson(responseData);

      }



      throw _apiExceptionFromResponse(

        response,

        fallbackMessage: 'Failed to get decommissioning operations',

      );

    } on ApiException {

      rethrow;

    } on DioException catch (e, stackTrace) {

      throw _apiExceptionFromDio(

        e,

        stackTrace: stackTrace,

        fallbackMessage: 'Network error while loading decommissioning operations',

      );

    } catch (e, stackTrace) {

      debugPrint('[DecommissioningOperationService.page] unexpected: $e\n$stackTrace');

      throw ApiException(

        message: 'Unexpected error loading decommissioning operations',

        originalException: e,

      );

    }

  }



  ApiException _apiExceptionFromResponse(

    Response<dynamic> response, {

    required String fallbackMessage,

    OperationApiDebugTrace? trace,

  }) {

    final body = response.data?.toString();

    final apiException = ApiException(

      statusCode: response.statusCode,

      message: fallbackMessage,

      responseBody: body,

      debugTrace: trace,

    );

    _logApiException(apiException);

    if (trace != null) {

      OperationApiDebugTrace.remember(trace);

      if (kDebugMode) debugPrint(trace.fullReport());

    }

    return apiException;

  }



  ApiException _apiExceptionFromDio(

    DioException exception, {

    required String fallbackMessage,

    StackTrace? stackTrace,

    OperationApiDebugTrace? trace,

  }) {

    final body = exception.response?.data?.toString();

    final apiException = ApiException(

      statusCode: exception.response?.statusCode,

      message: fallbackMessage,

      responseBody: body,

      originalException: exception,

      debugTrace: trace,

    );

    _logApiException(apiException, stackTrace: stackTrace);

    if (trace != null) {

      OperationApiDebugTrace.remember(trace);

      if (kDebugMode) debugPrint(trace.fullReport());

    }

    return apiException;

  }



  void _logApiException(

    ApiException exception, {

    StackTrace? stackTrace,

  }) {

    debugPrint(

      '[DecommissioningOperationService] ApiException '

      'status=${exception.statusCode} message=${exception.message}',

    );

    if (exception.responseBody != null && exception.responseBody!.isNotEmpty) {

      debugPrint(

        '[DecommissioningOperationService] responseBody: ${exception.responseBody}',

      );

    }

    if (exception.debugTrace != null && kDebugMode) {

      debugPrint(exception.debugTrace!.fullReport());

    }

    if (stackTrace != null) {

      debugPrint('[DecommissioningOperationService] $stackTrace');

    }

  }

}

