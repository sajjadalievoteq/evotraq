import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/core/network/api_exception_mapper.dart';
import 'package:traqtrace_app/core/network/api_response_body.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';
import 'package:traqtrace_app/data/models/operations/shared/operation_page.dart';
import 'package:traqtrace_app/data/models/operations/packing/packing_request_model.dart';
import 'package:traqtrace_app/data/models/operations/packing/packing_response_model.dart';

class PackingOperationService {
  PackingOperationService({
    required DioService dioService,
  }) : _dioService = dioService;

  final DioService _dioService;

  String get _baseUrl => '${_dioService.baseUrl}/operations/packing';

  Future<Map<String, String>> get _headers async {
    final token = await _dioService.getAuthToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<PackingResponse> createPackingOperation(
    PackingRequest packingRequest,
  ) async {
    try {
      final headers = await _headers;
      final response = await _dioService.post(
        _baseUrl,
        headers: headers,
        data: jsonEncode(packingRequest.toJson()),
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = decodeApiResponseBody(response.data);
        return PackingResponse.fromJson(responseData);
      }

      throw ApiExceptionMapper.fromHttpResponse(
        response,
        fallbackMessage:
            'Packing could not be submitted. Check the parent container, items, and location.',
      );
    } on ApiException {
      rethrow;
    } on DioException catch (e, stackTrace) {
      throw ApiExceptionMapper.fromDio(
        e,
        stackTrace: stackTrace,
        fallbackMessage: 'Network error — could not submit packing. Check your connection.',
      );
    } catch (e, stackTrace) {
      debugPrint('[PackingOperationService.create] unexpected: $e\n$stackTrace');
      throw ApiException(
        message:
            'An unexpected error occurred while submitting packing. Please try again.',
        originalException: e,
      );
    }
  }

  Future<PackingResponse> getPackingOperation(String operationId) async {
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
        return PackingResponse.fromJson(responseData);
      }

      throw ApiExceptionMapper.fromHttpResponse(
        response,
        fallbackMessage: 'Failed to get packing operation',
      );
    } on ApiException {
      rethrow;
    } on DioException catch (e, stackTrace) {
      throw ApiExceptionMapper.fromDio(
        e,
        stackTrace: stackTrace,
        fallbackMessage: 'Network error while loading packing operation',
      );
    } catch (e, stackTrace) {
      debugPrint('[PackingOperationService.get] unexpected: $e\n$stackTrace');
      throw ApiException(
        message: 'Unexpected error loading packing operation',
        originalException: e,
      );
    }
  }

  Future<List<PackingResponse>> getAllPackingOperations({
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
        final responseData = decodeApiResponseBody(response.data);
        final operations = responseData['operations'] as List;
        return operations.map((op) => PackingResponse.fromJson(op)).toList();
      }

      throw ApiExceptionMapper.fromHttpResponse(
        response,
        fallbackMessage: 'Failed to get packing operations',
      );
    } on ApiException {
      rethrow;
    } on DioException catch (e, stackTrace) {
      throw ApiExceptionMapper.fromDio(
        e,
        stackTrace: stackTrace,
        fallbackMessage: 'Network error while loading packing operations',
      );
    } catch (e, stackTrace) {
      debugPrint('[PackingOperationService.list] unexpected: $e\n$stackTrace');
      throw ApiException(
        message: 'Unexpected error loading packing operations',
        originalException: e,
      );
    }
  }

  Future<List<PackingResponse>> getPackingOperationsByReference(
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
        return responseData.map((op) => PackingResponse.fromJson(op)).toList();
      }

      throw ApiExceptionMapper.fromHttpResponse(
        response,
        fallbackMessage: 'Failed to get packing operations by reference',
      );
    } on ApiException {
      rethrow;
    } on DioException catch (e, stackTrace) {
      throw ApiExceptionMapper.fromDio(
        e,
        stackTrace: stackTrace,
        fallbackMessage: 'Network error while searching packing operations',
      );
    } catch (e, stackTrace) {
      debugPrint('[PackingOperationService.search] unexpected: $e\n$stackTrace');
      throw ApiException(
        message: 'Unexpected error searching packing operations',
        originalException: e,
      );
    }
  }

  Future<List<PackingResponse>> getPackingOperationsByContainer(
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
        return responseData.map((op) => PackingResponse.fromJson(op)).toList();
      }

      throw ApiExceptionMapper.fromHttpResponse(
        response,
        fallbackMessage: 'Failed to get packing operations by container',
      );
    } on ApiException {
      rethrow;
    } on DioException catch (e, stackTrace) {
      throw ApiExceptionMapper.fromDio(
        e,
        stackTrace: stackTrace,
        fallbackMessage: 'Network error while searching packing operations',
      );
    } catch (e, stackTrace) {
      debugPrint('[PackingOperationService.search] unexpected: $e\n$stackTrace');
      throw ApiException(
        message: 'Unexpected error searching packing operations',
        originalException: e,
      );
    }
  }

  Future<List<PackingResponse>> getPackingOperationsByLocation(
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
        return responseData.map((op) => PackingResponse.fromJson(op)).toList();
      }

      throw ApiExceptionMapper.fromHttpResponse(
        response,
        fallbackMessage: 'Failed to get packing operations by location',
      );
    } on ApiException {
      rethrow;
    } on DioException catch (e, stackTrace) {
      throw ApiExceptionMapper.fromDio(
        e,
        stackTrace: stackTrace,
        fallbackMessage: 'Network error while searching packing operations',
      );
    } catch (e, stackTrace) {
      debugPrint('[PackingOperationService.search] unexpected: $e\n$stackTrace');
      throw ApiException(
        message: 'Unexpected error searching packing operations',
        originalException: e,
      );
    }
  }

  Future<PackingResponse> validatePackingRequest(
    PackingRequest packingRequest,
  ) async {
    try {
      final headers = await _headers;
      final response = await _dioService.post(
        '$_baseUrl/validate',
        headers: headers,
        data: jsonEncode(packingRequest.toJson()),
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      if (response.statusCode == 200 || response.statusCode == 422) {
        final responseData = decodeApiResponseBody(response.data);
        return PackingResponse.fromJson(responseData);
      }

      throw ApiExceptionMapper.fromHttpResponse(
        response,
        fallbackMessage: 'Packing validation failed',
      );
    } on ApiException {
      rethrow;
    } on DioException catch (e, stackTrace) {
      throw ApiExceptionMapper.fromDio(
        e,
        stackTrace: stackTrace,
        fallbackMessage: 'Network error while validating packing request',
      );
    } catch (e, stackTrace) {
      debugPrint('[PackingOperationService.validate] unexpected: $e\n$stackTrace');
      throw ApiException(
        message: 'Unexpected error validating packing request',
        originalException: e,
      );
    }
  }

  Future<OperationPage<PackingResponse>> getPackingOperationsPage({
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
        return OperationPage.fromJson(responseData, PackingResponse.fromJson);
      }

      throw ApiExceptionMapper.fromHttpResponse(
        response,
        fallbackMessage: 'Failed to get packing operations',
      );
    } on ApiException {
      rethrow;
    } on DioException catch (e, stackTrace) {
      throw ApiExceptionMapper.fromDio(
        e,
        stackTrace: stackTrace,
        fallbackMessage: 'Network error while loading packing operations',
      );
    } catch (e, stackTrace) {
      debugPrint('[PackingOperationService.page] unexpected: $e\n$stackTrace');
      throw ApiException(
        message: 'Unexpected error loading packing operations',
        originalException: e,
      );
    }
  }
}
