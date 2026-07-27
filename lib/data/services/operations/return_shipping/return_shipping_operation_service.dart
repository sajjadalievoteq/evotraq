import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/core/network/api_exception_mapper.dart';
import 'package:traqtrace_app/core/network/api_response_body.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';
import 'package:traqtrace_app/data/models/operations/shared/operation_page.dart';
import 'package:traqtrace_app/data/models/operations/return_shipping/return_shipping_request_model.dart';
import 'package:traqtrace_app/data/models/operations/return_shipping/return_shipping_response_model.dart';
import 'package:traqtrace_app/features/operations/shared/utils/operation_api_error_message.dart';

class ReturnShippingOperationService {
  ReturnShippingOperationService({
    required DioService dioService,
  }) : _dioService = dioService;

  final DioService _dioService;

  String get _baseUrl => '${_dioService.baseUrl}/operations/return-shipping';

  Future<Map<String, String>> get _headers async {
    final token = await _dioService.getAuthToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<ReturnShippingResponse> createReturnShippingOperation(
    ReturnShippingRequest shippingRequest,
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

      final statusCode = response.statusCode;
      final body = response.data?.toString();

      if (statusCode == 201 ||
          statusCode == 200 ||
          statusCode == 207 ||
          statusCode == 422 ||
          statusCode == 400) {
        if (body == null || body.trim().isEmpty) {
          throw ApiExceptionMapper.fromHttpResponse(
            response,
            fallbackMessage: 'Failed to create return shipping operation',
          );
        }
        final responseData = jsonDecode(body) as Map<String, dynamic>;
        if (OperationApiErrorMessage.isStructuredErrorBody(responseData)) {
          throw ApiExceptionMapper.fromHttpResponse(
            response,
            fallbackMessage: 'Failed to create return shipping operation',
          );
        }
        return ReturnShippingResponse.fromJson(responseData);
      }

      throw ApiExceptionMapper.fromHttpResponse(
        response,
        fallbackMessage: 'Failed to create return shipping operation',
      );
    } on ApiException {
      rethrow;
    } on DioException catch (e, stackTrace) {
      throw ApiExceptionMapper.fromDio(
        e,
        stackTrace: stackTrace,
        fallbackMessage: 'Network error while creating shipping operation',
      );
    } catch (e, stackTrace) {
      debugPrint('[ReturnShippingOperationService.create] unexpected: $e\n$stackTrace');
      throw ApiException(
        message: 'Unexpected error creating shipping operation',
        originalException: e,
      );
    }
  }

  Future<ReturnShippingResponse> getReturnShippingOperation(String operationId) async {
    try {
      final headers = await _headers;
      final response = await _dioService.get(
        '$_baseUrl/$operationId',
        headers: headers,
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      if (response.statusCode == 200) {
        final responseData = decodeApiResponseBody(response.data);
        return ReturnShippingResponse.fromJson(responseData);
      }

      throw ApiExceptionMapper.fromHttpResponse(
        response,
        fallbackMessage: 'Failed to get shipping operation',
      );
    } on ApiException {
      rethrow;
    } on DioException catch (e, stackTrace) {
      throw ApiExceptionMapper.fromDio(
        e,
        stackTrace: stackTrace,
        fallbackMessage: 'Network error while loading shipping operation',
      );
    } catch (e, stackTrace) {
      debugPrint('[ReturnShippingOperationService.get] unexpected: $e\n$stackTrace');
      throw ApiException(
        message: 'Unexpected error loading shipping operation',
        originalException: e,
      );
    }
  }

  Future<List<ReturnShippingResponse>> getAllReturnShippingOperations({
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
        final responseData = decodeApiResponseMap(response.data);
        final operations = responseData['operations'] as List;
        return operations.map((op) => ReturnShippingResponse.fromJson(op as Map<String, dynamic>)).toList();
      }

      throw ApiExceptionMapper.fromHttpResponse(
        response,
        fallbackMessage: 'Failed to get shipping operations',
      );
    } on ApiException {
      rethrow;
    } on DioException catch (e, stackTrace) {
      throw ApiExceptionMapper.fromDio(
        e,
        stackTrace: stackTrace,
        fallbackMessage: 'Network error while loading shipping operations',
      );
    } catch (e, stackTrace) {
      debugPrint('[ReturnShippingOperationService.list] unexpected: $e\n$stackTrace');
      throw ApiException(
        message: 'Unexpected error loading shipping operations',
        originalException: e,
      );
    }
  }

  Future<List<ReturnShippingResponse>> getReturnShippingOperationsByReference(
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
        final responseData = decodeApiResponseList(response.data);
        return responseData.map((op) => ReturnShippingResponse.fromJson(op as Map<String, dynamic>)).toList();
      }

      throw ApiExceptionMapper.fromHttpResponse(
        response,
        fallbackMessage: 'Failed to get shipping operations by reference',
      );
    } on ApiException {
      rethrow;
    } on DioException catch (e, stackTrace) {
      throw ApiExceptionMapper.fromDio(
        e,
        stackTrace: stackTrace,
        fallbackMessage: 'Network error while searching shipping operations',
      );
    } catch (e, stackTrace) {
      debugPrint('[ReturnShippingOperationService.search] unexpected: $e\n$stackTrace');
      throw ApiException(
        message: 'Unexpected error searching shipping operations',
        originalException: e,
      );
    }
  }

  Future<List<ReturnShippingResponse>> getReturnShippingOperationsByContainer(
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
        final responseData = decodeApiResponseList(response.data);
        return responseData.map((op) => ReturnShippingResponse.fromJson(op as Map<String, dynamic>)).toList();
      }

      throw ApiExceptionMapper.fromHttpResponse(
        response,
        fallbackMessage: 'Failed to get shipping operations by container',
      );
    } on ApiException {
      rethrow;
    } on DioException catch (e, stackTrace) {
      throw ApiExceptionMapper.fromDio(
        e,
        stackTrace: stackTrace,
        fallbackMessage: 'Network error while searching shipping operations',
      );
    } catch (e, stackTrace) {
      debugPrint('[ReturnShippingOperationService.search] unexpected: $e\n$stackTrace');
      throw ApiException(
        message: 'Unexpected error searching shipping operations',
        originalException: e,
      );
    }
  }

  Future<List<ReturnShippingResponse>> getReturnShippingOperationsByLocation(
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
        final responseData = decodeApiResponseList(response.data);
        return responseData.map((op) => ReturnShippingResponse.fromJson(op as Map<String, dynamic>)).toList();
      }

      throw ApiExceptionMapper.fromHttpResponse(
        response,
        fallbackMessage: 'Failed to get shipping operations by location',
      );
    } on ApiException {
      rethrow;
    } on DioException catch (e, stackTrace) {
      throw ApiExceptionMapper.fromDio(
        e,
        stackTrace: stackTrace,
        fallbackMessage: 'Network error while searching shipping operations',
      );
    } catch (e, stackTrace) {
      debugPrint('[ReturnShippingOperationService.search] unexpected: $e\n$stackTrace');
      throw ApiException(
        message: 'Unexpected error searching shipping operations',
        originalException: e,
      );
    }
  }

  Future<ReturnShippingResponse> validateReturnShippingRequest(
    ReturnShippingRequest shippingRequest,
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

      final statusCode = response.statusCode;
      final body = response.data?.toString();

      if (statusCode == 200 || statusCode == 422 || statusCode == 400) {
        if (body == null || body.trim().isEmpty) {
          throw ApiExceptionMapper.fromHttpResponse(
            response,
            fallbackMessage: 'Return shipping validation failed',
          );
        }
        final responseData = jsonDecode(body) as Map<String, dynamic>;
        if (OperationApiErrorMessage.isStructuredErrorBody(responseData)) {
          throw ApiExceptionMapper.fromHttpResponse(
            response,
            fallbackMessage: 'Return shipping validation failed',
          );
        }
        return ReturnShippingResponse.fromJson(responseData);
      }

      throw ApiExceptionMapper.fromHttpResponse(
        response,
        fallbackMessage: 'Return shipping validation failed',
      );
    } on ApiException {
      rethrow;
    } on DioException catch (e, stackTrace) {
      throw ApiExceptionMapper.fromDio(
        e,
        stackTrace: stackTrace,
        fallbackMessage: 'Network error while validating shipping request',
      );
    } catch (e, stackTrace) {
      debugPrint('[ReturnShippingOperationService.validate] unexpected: $e\n$stackTrace');
      throw ApiException(
        message: 'Unexpected error validating shipping request',
        originalException: e,
      );
    }
  }

  Future<OperationPage<ReturnShippingResponse>> getReturnShippingOperationsPage({
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
        final responseData = decodeApiResponseMap(response.data);
        return OperationPage.fromJson(responseData, ReturnShippingResponse.fromJson);
      }

      throw ApiExceptionMapper.fromHttpResponse(
        response,
        fallbackMessage: 'Failed to get shipping operations',
      );
    } on ApiException {
      rethrow;
    } on DioException catch (e, stackTrace) {
      throw ApiExceptionMapper.fromDio(
        e,
        stackTrace: stackTrace,
        fallbackMessage: 'Network error while loading shipping operations',
      );
    } catch (e, stackTrace) {
      debugPrint('[ReturnShippingOperationService.page] unexpected: $e\n$stackTrace');
      throw ApiException(
        message: 'Unexpected error loading shipping operations',
        originalException: e,
      );
    }
  }
}
