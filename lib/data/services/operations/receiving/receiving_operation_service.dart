import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';
import 'package:traqtrace_app/data/models/operations/receiving/receiving_page_model.dart';
import 'package:traqtrace_app/data/models/operations/receiving/receiving_request_model.dart';
import 'package:traqtrace_app/data/models/operations/receiving/receiving_response_model.dart';

class ReceivingOperationService {
  ReceivingOperationService({
    required DioService dioService,
  }) : _dioService = dioService;

  final DioService _dioService;

  String get _baseUrl => '${_dioService.baseUrl}/operations/receiving';

  Future<Map<String, String>> get _headers async {
    final token = await _dioService.getAuthToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<ReceivingResponse> createReceivingOperation(
    ReceivingRequest receivingRequest,
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
        final responseData = jsonDecode(response.data);
        return ReceivingResponse.fromJson(responseData);
      }

      throw _apiExceptionFromResponse(
        response,
        fallbackMessage: 'Failed to create receiving operation',
      );
    } on ApiException {
      rethrow;
    } on DioException catch (e, stackTrace) {
      throw _apiExceptionFromDio(
        e,
        stackTrace: stackTrace,
        fallbackMessage: 'Network error while creating receiving operation',
      );
    } catch (e, stackTrace) {
      debugPrint(
        '[ReceivingOperationService.create] unexpected: $e\n$stackTrace',
      );
      throw ApiException(
        message: 'Unexpected error creating receiving operation',
        originalException: e,
      );
    }
  }

  Future<ReceivingResponse> getReceivingOperation(String operationId) async {
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
        return ReceivingResponse.fromJson(responseData);
      }

      throw _apiExceptionFromResponse(
        response,
        fallbackMessage: 'Failed to get receiving operation',
      );
    } on ApiException {
      rethrow;
    } on DioException catch (e, stackTrace) {
      throw _apiExceptionFromDio(
        e,
        stackTrace: stackTrace,
        fallbackMessage: 'Network error while loading receiving operation',
      );
    } catch (e, stackTrace) {
      debugPrint('[ReceivingOperationService.get] unexpected: $e\n$stackTrace');
      throw ApiException(
        message: 'Unexpected error loading receiving operation',
        originalException: e,
      );
    }
  }

  Future<ReceivingPage> getReceivingOperationsPage({
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
        final operations = (responseData['operations'] as List? ?? const [])
            .map((op) => ReceivingResponse.fromJson(op as Map<String, dynamic>))
            .toList();
        final total = (responseData['total'] as num?)?.toInt() ??
            (responseData['totalElements'] as num?)?.toInt() ??
            operations.length;
        final pageSize = (responseData['size'] as num?)?.toInt() ?? size;
        final totalPages = (responseData['totalPages'] as num?)?.toInt() ??
            (pageSize > 0 ? (total / pageSize).ceil() : (total > 0 ? 1 : 0));
        return ReceivingPage(
          operations: operations,
          total: total,
          totalPages: totalPages,
        );
      }

      throw _apiExceptionFromResponse(
        response,
        fallbackMessage: 'Failed to get receiving operations',
      );
    } on ApiException {
      rethrow;
    } on DioException catch (e, stackTrace) {
      throw _apiExceptionFromDio(
        e,
        stackTrace: stackTrace,
        fallbackMessage: 'Network error while loading receiving operations',
      );
    } catch (e, stackTrace) {
      debugPrint('[ReceivingOperationService.page] unexpected: $e\n$stackTrace');
      throw ApiException(
        message: 'Unexpected error loading receiving operations',
        originalException: e,
      );
    }
  }

  Future<ReceivingResponse> acceptGoods({
    required String receivingEventId,
    required String receiverGln,
  }) async {
    try {
      final headers = await _headers;
      final response = await _dioService.post(
        '${_dioService.baseUrl}/operations/accepting',
        headers: headers,
        data: jsonEncode({
          'receivingEventId': receivingEventId,
          'readPoint': receiverGln,
          'bizLocation': receiverGln,
        }),
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = jsonDecode(response.data);
        return ReceivingResponse.fromJson(responseData);
      }

      throw _apiExceptionFromResponse(
        response,
        fallbackMessage: 'Failed to accept goods',
      );
    } on ApiException {
      rethrow;
    } on DioException catch (e, stackTrace) {
      throw _apiExceptionFromDio(
        e,
        stackTrace: stackTrace,
        fallbackMessage: 'Network error while accepting goods',
      );
    } catch (e, stackTrace) {
      debugPrint(
        '[ReceivingOperationService.acceptGoods] unexpected: $e\n$stackTrace',
      );
      throw ApiException(
        message: 'Unexpected error accepting goods',
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
      '[ReceivingOperationService] ApiException '
      'status=${exception.statusCode} message=${exception.message}',
    );
    if (exception.responseBody != null && exception.responseBody!.isNotEmpty) {
      debugPrint(
        '[ReceivingOperationService] responseBody: ${exception.responseBody}',
      );
    }
    if (stackTrace != null) {
      debugPrint('[ReceivingOperationService] $stackTrace');
    }
  }
}
