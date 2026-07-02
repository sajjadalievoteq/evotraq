import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';
import 'package:traqtrace_app/data/models/operations/cancel_receiving/cancel_receiving_page_response.dart';
import 'package:traqtrace_app/data/models/operations/cancel_receiving/cancel_receiving_request_model.dart';
import 'package:traqtrace_app/data/models/operations/cancel_receiving/cancel_receiving_response_model.dart';
import 'package:traqtrace_app/features/operations/shared/utils/operation_api_error_message.dart';

class CancelReceivingOperationService {
  CancelReceivingOperationService({
    required DioService dioService,
  }) : _dioService = dioService;

  final DioService _dioService;

  String get _baseUrl => '${_dioService.baseUrl}/operations/cancel-receiving';

  Future<Map<String, String>> get _headers async {
    final token = await _dioService.getAuthToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<CancelReceivingResponse> createCancelReceivingOperation(
    CancelReceivingRequest request,
  ) async {
    try {
      final headers = await _headers;
      final response = await _dioService.post(
        _baseUrl,
        headers: headers,
        data: jsonEncode(request.toJson()),
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
            fallbackMessage: 'Failed to create cancel receiving operation',
          );
        }
        final responseData = jsonDecode(body) as Map<String, dynamic>;
        if (OperationApiErrorMessage.isStructuredErrorBody(responseData)) {
          throw ApiException(
            statusCode: statusCode,
            message: OperationApiErrorMessage.fromJsonMap(responseData) ??
                'Failed to create cancel receiving operation',
            responseBody: body,
          );
        }
        return CancelReceivingResponse.fromJson(responseData);
      }

      throw _apiExceptionFromResponse(
        response,
        fallbackMessage: 'Failed to create cancel receiving operation',
      );
    } on ApiException {
      rethrow;
    } on DioException catch (e, stackTrace) {
      throw _apiExceptionFromDio(
        e,
        stackTrace: stackTrace,
        fallbackMessage: 'Network error while creating cancel receiving operation',
      );
    } catch (e, stackTrace) {
      debugPrint('[CancelReceivingOperationService.create] unexpected: $e\n$stackTrace');
      throw ApiException(
        message: 'Unexpected error creating cancel receiving operation',
        originalException: e,
      );
    }
  }

  Future<CancelReceivingResponse> getCancelReceivingOperation(String operationId) async {
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
        return CancelReceivingResponse.fromJson(responseData);
      }

      throw _apiExceptionFromResponse(
        response,
        fallbackMessage: 'Failed to get cancel receiving operation',
      );
    } on ApiException {
      rethrow;
    } on DioException catch (e, stackTrace) {
      throw _apiExceptionFromDio(
        e,
        stackTrace: stackTrace,
        fallbackMessage: 'Network error while loading cancel receiving operation',
      );
    } catch (e, stackTrace) {
      debugPrint('[CancelReceivingOperationService.get] unexpected: $e\n$stackTrace');
      throw ApiException(
        message: 'Unexpected error loading cancel receiving operation',
        originalException: e,
      );
    }
  }

  Future<CancelReceivingPageResponse> getCancelReceivingOperationsPage({
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
        return CancelReceivingPageResponse.fromJson(responseData);
      }

      throw _apiExceptionFromResponse(
        response,
        fallbackMessage: 'Failed to get cancel receiving operations',
      );
    } on ApiException {
      rethrow;
    } on DioException catch (e, stackTrace) {
      throw _apiExceptionFromDio(
        e,
        stackTrace: stackTrace,
        fallbackMessage: 'Network error while loading cancel receiving operations',
      );
    } catch (e, stackTrace) {
      debugPrint('[CancelReceivingOperationService.page] unexpected: $e\n$stackTrace');
      throw ApiException(
        message: 'Unexpected error loading cancel receiving operations',
        originalException: e,
      );
    }
  }

  ApiException _apiExceptionFromResponse(
    Response<dynamic> response, {
    required String fallbackMessage,
  }) {
    final body = response.data?.toString();
    final apiException = ApiException(
      statusCode: response.statusCode,
      message: fallbackMessage,
      responseBody: body,
    );
    _logApiException(apiException);
    return apiException;
  }

  ApiException _apiExceptionFromDio(
    DioException exception, {
    required String fallbackMessage,
    StackTrace? stackTrace,
  }) {
    final body = exception.response?.data?.toString();
    final apiException = ApiException(
      statusCode: exception.response?.statusCode,
      message: fallbackMessage,
      responseBody: body,
      originalException: exception,
    );
    _logApiException(apiException, stackTrace: stackTrace);
    return apiException;
  }

  void _logApiException(
    ApiException exception, {
    StackTrace? stackTrace,
  }) {
    debugPrint(
      '[CancelReceivingOperationService] ApiException '
      'status=${exception.statusCode} message=${exception.message}',
    );
    if (exception.responseBody != null && exception.responseBody!.isNotEmpty) {
      debugPrint(
        '[CancelReceivingOperationService] responseBody: ${exception.responseBody}',
      );
    }
    if (stackTrace != null) {
      debugPrint('[CancelReceivingOperationService] $stackTrace');
    }
  }
}
