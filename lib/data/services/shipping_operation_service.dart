import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';
import 'package:traqtrace_app/features/epcis/models/operations/shipping_models.dart';

class ShippingOperationService {
  final DioService _dioService;

  ShippingOperationService({
    required DioService dioService,
  }) : _dioService = dioService;

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

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = jsonDecode(response.data);
        return ShippingResponse.fromJson(responseData);
      } else {
        final errorData = jsonDecode(response.data);
        throw ShippingOperationException(
          'Failed to create shipping operation: ${errorData['message'] ?? 'Unknown error'}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ShippingOperationException) rethrow;
      throw ShippingOperationException('Network error: $e');
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
      } else {
        final errorData = jsonDecode(response.data);
        throw ShippingOperationException(
          'Failed to get shipping operation: ${errorData['message'] ?? 'Not found'}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ShippingOperationException) rethrow;
      throw ShippingOperationException('Network error: $e');
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
      } else {
        final errorData = jsonDecode(response.data);
        throw ShippingOperationException(
          'Failed to get shipping operations: ${errorData['message'] ?? 'Unknown error'}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ShippingOperationException) rethrow;
      throw ShippingOperationException('Network error: $e');
    }
  }

  Future<List<ShippingResponse>> getShippingOperationsByReference(
    String reference,
  ) async {
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
        return responseData.map((op) => ShippingResponse.fromJson(op)).toList();
      } else {
        final errorData = jsonDecode(response.data);
        throw ShippingOperationException(
          'Failed to get shipping operations by reference: ${errorData['message'] ?? 'Unknown error'}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ShippingOperationException) rethrow;
      throw ShippingOperationException('Network error: $e');
    }
  }

  Future<List<ShippingResponse>> getShippingOperationsByDestination(
    String destinationGLN,
  ) async {
    try {
      final headers = await _headers;
      final response = await _dioService.get(
        '$_baseUrl/destination/${Uri.encodeComponent(destinationGLN)}',
        headers: headers,
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.data) as List;
        return responseData.map((op) => ShippingResponse.fromJson(op)).toList();
      } else {
        final errorData = jsonDecode(response.data);
        throw ShippingOperationException(
          'Failed to get shipping operations by destination: ${errorData['message'] ?? 'Unknown error'}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ShippingOperationException) rethrow;
      throw ShippingOperationException('Network error: $e');
    }
  }

  Future<List<ShippingResponse>> getShippingOperationsBySource(
    String sourceGLN,
  ) async {
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
        return responseData.map((op) => ShippingResponse.fromJson(op)).toList();
      } else {
        final errorData = jsonDecode(response.data);
        throw ShippingOperationException(
          'Failed to get shipping operations by source: ${errorData['message'] ?? 'Unknown error'}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ShippingOperationException) rethrow;
      throw ShippingOperationException('Network error: $e');
    }
  }

  Future<List<ShippingResponse>> getShippingOperationsForEPC(String epc) async {
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
        return responseData.map((op) => ShippingResponse.fromJson(op)).toList();
      } else {
        final errorData = jsonDecode(response.data);
        throw ShippingOperationException(
          'Failed to get shipping operations for EPC: ${errorData['message'] ?? 'Unknown error'}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ShippingOperationException) rethrow;
      throw ShippingOperationException('Network error: $e');
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

      if (response.statusCode == 200 || response.statusCode == 400) {
        final responseData = jsonDecode(response.data);
        return ShippingResponse.fromJson(responseData);
      } else {
        final errorData = jsonDecode(response.data);
        throw ShippingOperationException(
          'Failed to validate shipping request: ${errorData['message'] ?? 'Unknown error'}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ShippingOperationException) rethrow;
      throw ShippingOperationException('Network error: $e');
    }
  }
}

/// Exception thrown by shipping operations
class ShippingOperationException implements Exception {
  final String message;
  final int? statusCode;

  ShippingOperationException(this.message, {this.statusCode});

  @override
  String toString() => 'ShippingOperationException: $message';
}
