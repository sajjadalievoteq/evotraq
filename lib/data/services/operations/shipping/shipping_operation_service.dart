import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';
import 'package:traqtrace_app/data/models/operations/shipping/shipping_page_response.dart';
import 'package:traqtrace_app/data/models/operations/shipping/shipping_request_model.dart';
import 'package:traqtrace_app/data/models/operations/shipping/shipping_response_model.dart';

class ShippingOperationService {
  ShippingOperationService({
    required DioService dioService,
  }) : _dioService = dioService;

  final DioService _dioService;

  String get _baseUrl => '${_dioService.baseUrl}/operations/shipping';

  Future<Map<String, String>> get _headers async {
    final token = await _dioService.getAuthToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<ShippingResponse> createShippingOperation(
    ShippingRequest shippingRequest,
  ) async {
    try {
      final headers = await _headers;
      final response = await _dioService.post(
        _baseUrl,
        headers: headers,
        data: jsonEncode(shippingRequest.toJson()),
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      if (response.statusCode == 201 ||
          response.statusCode == 200 ||
          response.statusCode == 207 ||
          response.statusCode == 422) {
        final responseData = jsonDecode(response.data);
        return ShippingResponse.fromJson(responseData);
      }

      throw _apiExceptionFromResponse(
        response,
        fallbackMessage: 'Failed to create shipping operation',
      );
    } on ApiException {
      rethrow;
    } on DioException catch (e, stackTrace) {
      throw _apiExceptionFromDio(
        e,
        stackTrace: stackTrace,
        fallbackMessage: 'Network error while creating shipping operation',
      );
    } catch (e, stackTrace) {
      debugPrint('[ShippingOperationService.create] unexpected: $e\n$stackTrace');
      throw ApiException(
        message: 'Unexpected error creating shipping operation',
        originalException: e,
      );
    }
  }

  Future<ShippingResponse> getShippingOperation(String operationId) async {
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
        return ShippingResponse.fromJson(responseData);
      }

      throw _apiExceptionFromResponse(
        response,
        fallbackMessage: 'Failed to get shipping operation',
      );
    } on ApiException {
      rethrow;
    } on DioException catch (e, stackTrace) {
      throw _apiExceptionFromDio(
        e,
        stackTrace: stackTrace,
        fallbackMessage: 'Network error while loading shipping operation',
      );
    } catch (e, stackTrace) {
      debugPrint('[ShippingOperationService.get] unexpected: $e\n$stackTrace');
      throw ApiException(
        message: 'Unexpected error loading shipping operation',
        originalException: e,
      );
    }
  }

  Future<List<ShippingResponse>> getAllShippingOperations({
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
        return operations.map((op) => ShippingResponse.fromJson(op)).toList();
      }

      throw _apiExceptionFromResponse(
        response,
        fallbackMessage: 'Failed to get shipping operations',
      );
    } on ApiException {
      rethrow;
    } on DioException catch (e, stackTrace) {
      throw _apiExceptionFromDio(
        e,
        stackTrace: stackTrace,
        fallbackMessage: 'Network error while loading shipping operations',
      );
    } catch (e, stackTrace) {
      debugPrint('[ShippingOperationService.list] unexpected: $e\n$stackTrace');
      throw ApiException(
        message: 'Unexpected error loading shipping operations',
        originalException: e,
      );
    }
  }

  Future<List<ShippingResponse>> getShippingOperationsByReference(
    String reference,
  ) async {
    try {
      final headers = await _headers;
      final response = await _dioService.get(
        '$_baseUrl/search/by-reference',
        queryParameters: {'reference': reference},
        headers: headers,
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.data) as List;
        return responseData.map((op) => ShippingResponse.fromJson(op)).toList();
      }

      throw _apiExceptionFromResponse(
        response,
        fallbackMessage: 'Failed to get shipping operations by reference',
      );
    } on ApiException {
      rethrow;
    } on DioException catch (e, stackTrace) {
      throw _apiExceptionFromDio(
        e,
        stackTrace: stackTrace,
        fallbackMessage: 'Network error while searching shipping operations',
      );
    } catch (e, stackTrace) {
      debugPrint('[ShippingOperationService.search] unexpected: $e\n$stackTrace');
      throw ApiException(
        message: 'Unexpected error searching shipping operations',
        originalException: e,
      );
    }
  }

  Future<List<ShippingResponse>> getShippingOperationsByContainer(
    String parentContainerId,
  ) async {
    try {
      final headers = await _headers;
      final response = await _dioService.get(
        '$_baseUrl/search/by-container',
        queryParameters: {'containerId': parentContainerId},
        headers: headers,
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.data) as List;
        return responseData.map((op) => ShippingResponse.fromJson(op)).toList();
      }

      throw _apiExceptionFromResponse(
        response,
        fallbackMessage: 'Failed to get shipping operations by container',
      );
    } on ApiException {
      rethrow;
    } on DioException catch (e, stackTrace) {
      throw _apiExceptionFromDio(
        e,
        stackTrace: stackTrace,
        fallbackMessage: 'Network error while searching shipping operations',
      );
    } catch (e, stackTrace) {
      debugPrint('[ShippingOperationService.search] unexpected: $e\n$stackTrace');
      throw ApiException(
        message: 'Unexpected error searching shipping operations',
        originalException: e,
      );
    }
  }

  Future<List<ShippingResponse>> getShippingOperationsByLocation(
    String locationGLN,
  ) async {
    try {
      final headers = await _headers;
      final response = await _dioService.get(
        '$_baseUrl/search/by-location',
        queryParameters: {'locationGLN': locationGLN},
        headers: headers,
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.data) as List;
        return responseData.map((op) => ShippingResponse.fromJson(op)).toList();
      }

      throw _apiExceptionFromResponse(
        response,
        fallbackMessage: 'Failed to get shipping operations by location',
      );
    } on ApiException {
      rethrow;
    } on DioException catch (e, stackTrace) {
      throw _apiExceptionFromDio(
        e,
        stackTrace: stackTrace,
        fallbackMessage: 'Network error while searching shipping operations',
      );
    } catch (e, stackTrace) {
      debugPrint('[ShippingOperationService.search] unexpected: $e\n$stackTrace');
      throw ApiException(
        message: 'Unexpected error searching shipping operations',
        originalException: e,
      );
    }
  }

  Future<ShippingResponse> validateShippingRequest(
    ShippingRequest shippingRequest,
  ) async {
    try {
      final headers = await _headers;
      final response = await _dioService.post(
        '$_baseUrl/validate',
        headers: headers,
        data: jsonEncode(shippingRequest.toJson()),
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      if (response.statusCode == 200 || response.statusCode == 422) {
        final responseData = jsonDecode(response.data);
        return ShippingResponse.fromJson(responseData);
      }

      throw _apiExceptionFromResponse(
        response,
        fallbackMessage: 'Shipping validation failed',
      );
    } on ApiException {
      rethrow;
    } on DioException catch (e, stackTrace) {
      throw _apiExceptionFromDio(
        e,
        stackTrace: stackTrace,
        fallbackMessage: 'Network error while validating shipping request',
      );
    } catch (e, stackTrace) {
      debugPrint('[ShippingOperationService.validate] unexpected: $e\n$stackTrace');
      throw ApiException(
        message: 'Unexpected error validating shipping request',
        originalException: e,
      );
    }
  }

  Future<ShippingPageResponse> getShippingOperationsPage({
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
        return ShippingPageResponse.fromJson(responseData);
      }

      throw _apiExceptionFromResponse(
        response,
        fallbackMessage: 'Failed to get shipping operations',
      );
    } on ApiException {
      rethrow;
    } on DioException catch (e, stackTrace) {
      throw _apiExceptionFromDio(
        e,
        stackTrace: stackTrace,
        fallbackMessage: 'Network error while loading shipping operations',
      );
    } catch (e, stackTrace) {
      debugPrint('[ShippingOperationService.page] unexpected: $e\n$stackTrace');
      throw ApiException(
        message: 'Unexpected error loading shipping operations',
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
      '[ShippingOperationService] ApiException '
      'status=${exception.statusCode} message=${exception.message}',
    );
    if (exception.responseBody != null && exception.responseBody!.isNotEmpty) {
      debugPrint(
        '[ShippingOperationService] responseBody: ${exception.responseBody}',
      );
    }
    if (stackTrace != null) {
      debugPrint('[ShippingOperationService] $stackTrace');
    }
  }
}
