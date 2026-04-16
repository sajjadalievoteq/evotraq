import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';
import 'package:traqtrace_app/features/epcis/models/operations/receiving_models.dart';

class ReceivingOperationService {
  final DioService _dioService;

  ReceivingOperationService({
    required DioService dioService,
  }) : _dioService = dioService;

  String get _baseUrl => '${_dioService.baseUrl}/operations/receiving';

  Future<Map<String, String>> get _headers async {
    final token = await _dioService.getAuthToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<ReceivingResponse> createReceivingOperation(ReceivingRequest receivingRequest) async {
    try {
      final headers = await _headers;
      final response = await _dioService.post(
        _baseUrl,
        headers: headers,
        data: jsonEncode(receivingRequest.toJson()),
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = jsonDecode(response.data);
        return ReceivingResponse.fromJson(responseData);
      } else {
        final errorData = jsonDecode(response.data);
        throw ReceivingOperationException(
          'Failed to create receiving operation: ${errorData['message'] ?? 'Unknown error'}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ReceivingOperationException) rethrow;
      throw ReceivingOperationException('Network error: $e');
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
      } else {
        final errorData = jsonDecode(response.data);
        throw ReceivingOperationException(
          'Failed to get receiving operation: ${errorData['message'] ?? 'Not found'}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ReceivingOperationException) rethrow;
      throw ReceivingOperationException('Network error: $e');
    }
  }

  Future<List<ReceivingResponse>> getAllReceivingOperations({int page = 0, int size = 20}) async {
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
        return operations.map((op) => ReceivingResponse.fromJson(op)).toList();
      } else {
        final errorData = jsonDecode(response.data);
        throw ReceivingOperationException(
          'Failed to get receiving operations: ${errorData['message'] ?? 'Unknown error'}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ReceivingOperationException) rethrow;
      throw ReceivingOperationException('Network error: $e');
    }
  }

  Future<List<ReceivingResponse>> getReceivingOperationsByReference(String reference) async {
    try {
      final headers = await _headers;
      final response = await _dioService.get(
        '$_baseUrl/reference/${Uri.encodeComponent(reference)}',
        headers: headers,
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.data) as List;
        return responseData.map((op) => ReceivingResponse.fromJson(op)).toList();
      } else {
        final errorData = jsonDecode(response.data);
        throw ReceivingOperationException(
          'Failed to get receiving operations by reference: ${errorData['message'] ?? 'Unknown error'}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ReceivingOperationException) rethrow;
      throw ReceivingOperationException('Network error: $e');
    }
  }

  Future<List<ReceivingResponse>> getReceivingOperationsByReceivingGLN(String receivingGLN) async {
    try {
      final headers = await _headers;
      final response = await _dioService.get(
        '$_baseUrl/receiving-location/${Uri.encodeComponent(receivingGLN)}',
        headers: headers,
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.data) as List;
        return responseData.map((op) => ReceivingResponse.fromJson(op)).toList();
      } else {
        final errorData = jsonDecode(response.data);
        throw ReceivingOperationException(
          'Failed to get receiving operations by receiving GLN: ${errorData['message'] ?? 'Unknown error'}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ReceivingOperationException) rethrow;
      throw ReceivingOperationException('Network error: $e');
    }
  }

  Future<List<ReceivingResponse>> getReceivingOperationsBySource(String sourceGLN) async {
    try {
      final headers = await _headers;
      final response = await _dioService.get(
        '$_baseUrl/source/${Uri.encodeComponent(sourceGLN)}',
        headers: headers,
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.data) as List;
        return responseData.map((op) => ReceivingResponse.fromJson(op)).toList();
      } else {
        final errorData = jsonDecode(response.data);
        throw ReceivingOperationException(
          'Failed to get receiving operations by source: ${errorData['message'] ?? 'Unknown error'}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ReceivingOperationException) rethrow;
      throw ReceivingOperationException('Network error: $e');
    }
  }

  Future<List<ReceivingResponse>> getReceivingOperationsForEPC(String epc) async {
    try {
      final headers = await _headers;
      final response = await _dioService.get(
        '$_baseUrl/epc/${Uri.encodeComponent(epc)}',
        headers: headers,
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.data) as List;
        return responseData.map((op) => ReceivingResponse.fromJson(op)).toList();
      } else {
        final errorData = jsonDecode(response.data);
        throw ReceivingOperationException(
          'Failed to get receiving operations for EPC: ${errorData['message'] ?? 'Unknown error'}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ReceivingOperationException) rethrow;
      throw ReceivingOperationException('Network error: $e');
    }
  }

  Future<ReceivingResponse> validateReceivingRequest(ReceivingRequest receivingRequest) async {
    try {
      final headers = await _headers;
      final response = await _dioService.post(
        '$_baseUrl/validate',
        headers: headers,
        data: jsonEncode(receivingRequest.toJson()),
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      final responseData = jsonDecode(response.data);
      return ReceivingResponse.fromJson(responseData);
    } catch (e) {
      if (e is ReceivingOperationException) rethrow;
      throw ReceivingOperationException('Network error: $e');
    }
  }
}

/// Exception class for receiving operation errors
class ReceivingOperationException implements Exception {
  final String message;
  final int? statusCode;

  ReceivingOperationException(this.message, {this.statusCode});

  @override
  String toString() => 'ReceivingOperationException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}
