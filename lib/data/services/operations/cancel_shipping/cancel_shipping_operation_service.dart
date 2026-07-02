import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';
import 'package:traqtrace_app/data/models/operations/cancel_shipping/cancel_shipping_page_response.dart';
import 'package:traqtrace_app/data/models/operations/cancel_shipping/cancel_shipping_request_model.dart';
import 'package:traqtrace_app/data/models/operations/cancel_shipping/cancel_shipping_response_model.dart';
import 'package:traqtrace_app/features/operations/shared/utils/operation_api_error_message.dart';

class CancelShippingOperationService {
  CancelShippingOperationService({
    required DioService dioService,
  }) : _dioService = dioService;

  final DioService _dioService;

  String get _baseUrl => '${_dioService.baseUrl}/operations/cancel-shipping';

  Future<Map<String, String>> get _headers async {
    final token = await _dioService.getAuthToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<CancelShippingResponse> createCancelShippingOperation(
    CancelShippingRequest request,
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
            fallbackMessage: 'Failed to create cancel shipping operation',
          );
        }
        final responseData = jsonDecode(body) as Map<String, dynamic>;
        if (OperationApiErrorMessage.isStructuredErrorBody(responseData)) {
          throw ApiException(
            statusCode: statusCode,
            message: OperationApiErrorMessage.fromJsonMap(responseData) ??
                'Failed to create cancel shipping operation',
            responseBody: body,
          );
        }
        return CancelShippingResponse.fromJson(responseData);
      }

      throw _apiExceptionFromResponse(
        response,
        fallbackMessage: 'Failed to create cancel shipping operation',
      );
    } on ApiException {
      rethrow;
    } on DioException catch (e, stackTrace) {
      throw _apiExceptionFromDio(
        e,
        stackTrace: stackTrace,
        fallbackMessage: 'Network error while creating cancel shipping operation',
      );
    } catch (e, stackTrace) {
      debugPrint('[CancelShippingOperationService.create] unexpected: $e\n$stackTrace');
      throw ApiException(
        message: 'Unexpected error creating cancel shipping operation',
        originalException: e,
      );
    }
  }

  Future<CancelShippingResponse> getCancelShippingOperation(String operationId) async {
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
        return CancelShippingResponse.fromJson(responseData);
      }

      throw _apiExceptionFromResponse(
        response,
        fallbackMessage: 'Failed to get cancel shipping operation',
      );
    } on ApiException {
      rethrow;
    } on DioException catch (e, stackTrace) {
      throw _apiExceptionFromDio(
        e,
        stackTrace: stackTrace,
        fallbackMessage: 'Network error while loading cancel shipping operation',
      );
    } catch (e, stackTrace) {
      debugPrint('[CancelShippingOperationService.get] unexpected: $e\n$stackTrace');
      throw ApiException(
        message: 'Unexpected error loading cancel shipping operation',
        originalException: e,
      );
    }
  }

  Future<CancelShippingPageResponse> getCancelShippingOperationsPage({
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
        return CancelShippingPageResponse.fromJson(responseData);
      }

      throw _apiExceptionFromResponse(
        response,
        fallbackMessage: 'Failed to get cancel shipping operations',
      );
    } on ApiException {
      rethrow;
    } on DioException catch (e, stackTrace) {
      throw _apiExceptionFromDio(
        e,
        stackTrace: stackTrace,
        fallbackMessage: 'Network error while loading cancel shipping operations',
      );
    } catch (e, stackTrace) {
      debugPrint('[CancelShippingOperationService.page] unexpected: $e\n$stackTrace');
      throw ApiException(
        message: 'Unexpected error loading cancel shipping operations',
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
      '[CancelShippingOperationService] ApiException '
      'status=${exception.statusCode} message=${exception.message}',
    );
    if (exception.responseBody != null && exception.responseBody!.isNotEmpty) {
      debugPrint(
        '[CancelShippingOperationService] responseBody: ${exception.responseBody}',
      );
    }
    if (stackTrace != null) {
      debugPrint('[CancelShippingOperationService] $stackTrace');
    }
  }
}
