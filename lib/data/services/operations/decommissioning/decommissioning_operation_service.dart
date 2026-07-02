import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';
import 'package:traqtrace_app/data/models/operations/decommissioning/decommissioning_page_response.dart';
import 'package:traqtrace_app/data/models/operations/decommissioning/decommissioning_request_model.dart';
import 'package:traqtrace_app/data/models/operations/decommissioning/decommissioning_response_model.dart';
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
            fallbackMessage: 'Failed to create decommissioning operation',
          );
        }
        final responseData = jsonDecode(body) as Map<String, dynamic>;
        if (OperationApiErrorMessage.isStructuredErrorBody(responseData)) {
          throw ApiException(
            statusCode: statusCode,
            message: OperationApiErrorMessage.fromJsonMap(responseData) ??
                'Failed to create decommissioning operation',
            responseBody: body,
          );
        }
        return DecommissioningResponse.fromJson(responseData);
      }

      throw _apiExceptionFromResponse(
        response,
        fallbackMessage: 'Failed to create decommissioning operation',
      );
    } on ApiException {
      rethrow;
    } on DioException catch (e, stackTrace) {
      throw _apiExceptionFromDio(
        e,
        stackTrace: stackTrace,
        fallbackMessage: 'Network error while creating decommissioning operation',
      );
    } catch (e, stackTrace) {
      debugPrint(
        '[DecommissioningOperationService.create] unexpected: $e\n$stackTrace',
      );
      throw ApiException(
        message: 'Unexpected error creating decommissioning operation',
        originalException: e,
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
      '[DecommissioningOperationService] ApiException '
      'status=${exception.statusCode} message=${exception.message}',
    );
    if (exception.responseBody != null && exception.responseBody!.isNotEmpty) {
      debugPrint(
        '[DecommissioningOperationService] responseBody: ${exception.responseBody}',
      );
    }
    if (stackTrace != null) {
      debugPrint('[DecommissioningOperationService] $stackTrace');
    }
  }
}
