import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/core/network/api_exception_mapper.dart';
import 'package:traqtrace_app/core/network/api_response_body.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';
import 'package:traqtrace_app/data/models/operations/shared/operation_page.dart';
import 'package:traqtrace_app/data/models/operations/return_receiving/return_receiving_request_model.dart';
import 'package:traqtrace_app/data/models/operations/return_receiving/return_receiving_response_model.dart';

class ReturnReceivingOperationService {
  ReturnReceivingOperationService({
    required DioService dioService,
  }) : _dioService = dioService;

  final DioService _dioService;

  String get _baseUrl => '${_dioService.baseUrl}/operations/return-receiving';

  Future<Map<String, String>> get _headers async {
    final token = await _dioService.getAuthToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<ReturnReceivingResponse> createReturnReceivingOperation(
    ReturnReceivingRequest receivingRequest,
  ) async {
    try {
      final headers = await _headers;
      final response = await _dioService.post(
        _baseUrl,
        headers: headers,
        data: jsonEncode(receivingRequest.toJson()),
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      if (response.statusCode == 201 ||
          response.statusCode == 200 ||
          response.statusCode == 207) {
        final responseData = decodeApiResponseBody(response.data);
        return ReturnReceivingResponse.fromJson(responseData);
      }

      throw ApiExceptionMapper.fromHttpResponse(
        response,
        fallbackMessage: 'Failed to create receiving operation',
      );
    } on ApiException {
      rethrow;
    } on DioException catch (e, stackTrace) {
      throw ApiExceptionMapper.fromDio(
        e,
        stackTrace: stackTrace,
        fallbackMessage: 'Network error while creating receiving operation',
      );
    } catch (e, stackTrace) {
      debugPrint(
        '[ReturnReceivingOperationService.create] unexpected: $e\n$stackTrace',
      );
      throw ApiException(
        message: 'Unexpected error creating receiving operation',
        originalException: e,
      );
    }
  }

  Future<ReturnReceivingResponse> getReturnReceivingOperation(String operationId) async {
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
        return ReturnReceivingResponse.fromJson(responseData);
      }

      throw ApiExceptionMapper.fromHttpResponse(
        response,
        fallbackMessage: 'Failed to get receiving operation',
      );
    } on ApiException {
      rethrow;
    } on DioException catch (e, stackTrace) {
      throw ApiExceptionMapper.fromDio(
        e,
        stackTrace: stackTrace,
        fallbackMessage: 'Network error while loading receiving operation',
      );
    } catch (e, stackTrace) {
      debugPrint('[ReturnReceivingOperationService.get] unexpected: $e\n$stackTrace');
      throw ApiException(
        message: 'Unexpected error loading receiving operation',
        originalException: e,
      );
    }
  }

  Future<OperationPage<ReturnReceivingResponse>> getReturnReceivingOperationsPage({
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
        return OperationPage.fromJson(
          responseData,
          ReturnReceivingResponse.fromJson,
        );
      }

      throw ApiExceptionMapper.fromHttpResponse(
        response,
        fallbackMessage: 'Failed to get receiving operations',
      );
    } on ApiException {
      rethrow;
    } on DioException catch (e, stackTrace) {
      throw ApiExceptionMapper.fromDio(
        e,
        stackTrace: stackTrace,
        fallbackMessage: 'Network error while loading receiving operations',
      );
    } catch (e, stackTrace) {
      debugPrint('[ReturnReceivingOperationService.page] unexpected: $e\n$stackTrace');
      throw ApiException(
        message: 'Unexpected error loading receiving operations',
        originalException: e,
      );
    }
  }
}
