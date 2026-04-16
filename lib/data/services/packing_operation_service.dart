import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';
import 'package:traqtrace_app/features/epcis/models/operations/packing_models.dart';

class PackingOperationService {
  final DioService _dioService;

  PackingOperationService({
    required DioService dioService,
  }) : _dioService = dioService;

  String get _baseUrl => '${_dioService.baseUrl}/operations/packing';

  Future<Map<String, String>> get _headers async {
    final token = await _dioService.getAuthToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<PackingResponse> createPackingOperation(PackingRequest packingRequest) async {
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
        final responseData = jsonDecode(response.data);
        return PackingResponse.fromJson(responseData);
      } else {
        final errorData = jsonDecode(response.data);
        throw PackingOperationException(
          'Failed to create packing operation: ${errorData['message'] ?? 'Unknown error'}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is PackingOperationException) rethrow;
      throw PackingOperationException('Network error: $e');
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
        final responseData = jsonDecode(response.data);
        return PackingResponse.fromJson(responseData);
      } else {
        final errorData = jsonDecode(response.data);
        throw PackingOperationException(
          'Failed to get packing operation: ${errorData['message'] ?? 'Not found'}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is PackingOperationException) rethrow;
      throw PackingOperationException('Network error: $e');
    }
  }

  Future<List<PackingResponse>> getAllPackingOperations({int page = 0, int size = 20}) async {
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
        return operations.map((op) => PackingResponse.fromJson(op)).toList();
      } else {
        final errorData = jsonDecode(response.data);
        throw PackingOperationException(
          'Failed to get packing operations: ${errorData['message'] ?? 'Unknown error'}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is PackingOperationException) rethrow;
      throw PackingOperationException('Network error: $e');
    }
  }

  Future<List<PackingResponse>> getPackingOperationsByReference(String reference) async {
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
        return responseData.map((op) => PackingResponse.fromJson(op)).toList();
      } else {
        final errorData = jsonDecode(response.data);
        throw PackingOperationException(
          'Failed to get packing operations by reference: ${errorData['message'] ?? 'Unknown error'}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is PackingOperationException) rethrow;
      throw PackingOperationException('Network error: $e');
    }
  }

  Future<List<PackingResponse>> getPackingOperationsByContainer(String parentContainerId) async {
    try {
      final headers = await _headers;
      final response = await _dioService.get(
        '$_baseUrl/search/by-container',
        queryParameters: {'parentContainerId': parentContainerId},
        headers: headers,
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.data) as List;
        return responseData.map((op) => PackingResponse.fromJson(op)).toList();
      } else {
        final errorData = jsonDecode(response.data);
        throw PackingOperationException(
          'Failed to get packing operations by container: ${errorData['message'] ?? 'Unknown error'}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is PackingOperationException) rethrow;
      throw PackingOperationException('Network error: $e');
    }
  }

  Future<List<PackingResponse>> getPackingOperationsByLocation(String locationGLN) async {
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
        return responseData.map((op) => PackingResponse.fromJson(op)).toList();
      } else {
        final errorData = jsonDecode(response.data);
        throw PackingOperationException(
          'Failed to get packing operations by location: ${errorData['message'] ?? 'Unknown error'}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is PackingOperationException) rethrow;
      throw PackingOperationException('Network error: $e');
    }
  }

  Future<PackingResponse> validatePackingRequest(PackingRequest packingRequest) async {
    try {
      final headers = await _headers;
      final response = await _dioService.post(
        '$_baseUrl/validate',
        headers: headers,
        data: jsonEncode(packingRequest.toJson()),
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.data);
        return PackingResponse.fromJson(responseData);
      } else {
        final errorData = jsonDecode(response.data);
        throw PackingOperationException(
          'Validation failed: ${errorData['message'] ?? 'Unknown error'}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is PackingOperationException) rethrow;
      throw PackingOperationException('Network error: $e');
    }
  }
}

/// Exception for packing operations
class PackingOperationException implements Exception {
  final String message;
  final int? statusCode;

  PackingOperationException(this.message, {this.statusCode});

  @override
  String toString() => message;
}
