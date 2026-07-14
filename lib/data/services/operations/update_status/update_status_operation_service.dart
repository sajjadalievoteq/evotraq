import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/core/network/api_exception_mapper.dart';
import 'package:traqtrace_app/core/network/api_response_body.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';
import 'package:traqtrace_app/data/models/operations/shared/operation_page.dart';
import 'package:traqtrace_app/data/models/operations/update_status/update_status_request_model.dart';
import 'package:traqtrace_app/data/models/operations/update_status/update_status_response_model.dart';
import 'package:traqtrace_app/features/operations/shared/utils/operation_api_error_message.dart';

class UpdateStatusOperationService {
  UpdateStatusOperationService({
    required DioService dioService,
  }) : _dioService = dioService;

  final DioService _dioService;

  String get _baseUrl => '${_dioService.baseUrl}/operations/update-status';

  Future<Map<String, String>> get _headers async {
    final token = await _dioService.getAuthToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<UpdateStatusResponse> createUpdateStatusOperation(
    UpdateStatusRequest request,
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
          throw ApiExceptionMapper.fromHttpResponse(
            response,
            fallbackMessage: 'Failed to create decommissioning operation',
          );
        }
        final responseData = jsonDecode(body) as Map<String, dynamic>;
        if (OperationApiErrorMessage.isStructuredErrorBody(responseData)) {
          throw ApiExceptionMapper.fromHttpResponse(
            response,
            fallbackMessage: 'Failed to create decommissioning operation',
          );
        }
        return UpdateStatusResponse.fromJson(responseData);
      }

      throw ApiExceptionMapper.fromHttpResponse(
        response,
        fallbackMessage: 'Failed to create decommissioning operation',
      );
    } on ApiException {
      rethrow;
    } on DioException catch (e, stackTrace) {
      throw ApiExceptionMapper.fromDio(
        e,
        stackTrace: stackTrace,
        fallbackMessage: 'Network error while creating decommissioning operation',
      );
    } catch (e, stackTrace) {
      debugPrint(
        '[UpdateStatusOperationService.create] unexpected: $e\n$stackTrace',
      );
      throw ApiException(
        message: 'Unexpected error creating decommissioning operation',
        originalException: e,
      );
    }
  }

  Future<UpdateStatusResponse> getUpdateStatusOperation(
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
        final responseData = decodeApiResponseBody(response.data);
        return UpdateStatusResponse.fromJson(responseData);
      }

      throw ApiExceptionMapper.fromHttpResponse(
        response,
        fallbackMessage: 'Failed to get decommissioning operation',
      );
    } on ApiException {
      rethrow;
    } on DioException catch (e, stackTrace) {
      throw ApiExceptionMapper.fromDio(
        e,
        stackTrace: stackTrace,
        fallbackMessage: 'Network error while loading decommissioning operation',
      );
    } catch (e, stackTrace) {
      debugPrint('[UpdateStatusOperationService.get] unexpected: $e\n$stackTrace');
      throw ApiException(
        message: 'Unexpected error loading decommissioning operation',
        originalException: e,
      );
    }
  }

  Future<List<UpdateStatusResponse>> getAllUpdateStatusOperations({
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
        return operations
            .map((op) => UpdateStatusResponse.fromJson(op))
            .toList();
      }

      throw ApiExceptionMapper.fromHttpResponse(
        response,
        fallbackMessage: 'Failed to get decommissioning operations',
      );
    } on ApiException {
      rethrow;
    } on DioException catch (e, stackTrace) {
      throw ApiExceptionMapper.fromDio(
        e,
        stackTrace: stackTrace,
        fallbackMessage: 'Network error while loading decommissioning operations',
      );
    } catch (e, stackTrace) {
      debugPrint('[UpdateStatusOperationService.list] unexpected: $e\n$stackTrace');
      throw ApiException(
        message: 'Unexpected error loading decommissioning operations',
        originalException: e,
      );
    }
  }

  Future<OperationPage<UpdateStatusResponse>> getUpdateStatusOperationsPage({
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
        return OperationPage.fromJson(responseData, UpdateStatusResponse.fromJson);
      }

      throw ApiExceptionMapper.fromHttpResponse(
        response,
        fallbackMessage: 'Failed to get decommissioning operations',
      );
    } on ApiException {
      rethrow;
    } on DioException catch (e, stackTrace) {
      throw ApiExceptionMapper.fromDio(
        e,
        stackTrace: stackTrace,
        fallbackMessage: 'Network error while loading decommissioning operations',
      );
    } catch (e, stackTrace) {
      debugPrint('[UpdateStatusOperationService.page] unexpected: $e\n$stackTrace');
      throw ApiException(
        message: 'Unexpected error loading decommissioning operations',
        originalException: e,
      );
    }
  }
}
