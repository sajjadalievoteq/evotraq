import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:traqtrace_app/core/config/app_config.dart';
import 'package:traqtrace_app/core/network/token_manager.dart';
import 'package:traqtrace_app/features/epcis/models/operations/packing_models.dart';

class PackingOperationService {
  final TokenManager _tokenManager;
  final http.Client _httpClient;
  final AppConfig _appConfig;

  PackingOperationService({
    required TokenManager tokenManager,
    http.Client? httpClient,
    required AppConfig appConfig,
  })  : _tokenManager = tokenManager,
        _httpClient = httpClient ?? http.Client(),
        _appConfig = appConfig;

  String get _baseUrl => '${_appConfig.apiBaseUrl}/operations/packing';

  Future<Map<String, String>> get _headers async {
    final token = await _tokenManager.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<PackingResponse> createPackingOperation(PackingRequest packingRequest) async {
    try {
      final headers = await _headers;
      final response = await _httpClient.post(
        Uri.parse(_baseUrl),
        headers: headers,
        body: jsonEncode(packingRequest.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return PackingResponse.fromJson(responseData);
      } else {
        final errorData = jsonDecode(response.body);
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
      final response = await _httpClient.get(
        Uri.parse('$_baseUrl/$operationId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return PackingResponse.fromJson(responseData);
      } else {
        final errorData = jsonDecode(response.body);
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
      final response = await _httpClient.get(
        Uri.parse('$_baseUrl?page=$page&size=$size'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final operations = responseData['operations'] as List;
        return operations.map((op) => PackingResponse.fromJson(op)).toList();
      } else {
        final errorData = jsonDecode(response.body);
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
      final response = await _httpClient.get(
        Uri.parse('$_baseUrl/search/by-reference?reference=${Uri.encodeComponent(reference)}'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as List;
        return responseData.map((op) => PackingResponse.fromJson(op)).toList();
      } else {
        final errorData = jsonDecode(response.body);
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
      final response = await _httpClient.get(
        Uri.parse('$_baseUrl/search/by-container?parentContainerId=${Uri.encodeComponent(parentContainerId)}'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as List;
        return responseData.map((op) => PackingResponse.fromJson(op)).toList();
      } else {
        final errorData = jsonDecode(response.body);
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
      final response = await _httpClient.get(
        Uri.parse('$_baseUrl/search/by-location?locationGLN=${Uri.encodeComponent(locationGLN)}'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as List;
        return responseData.map((op) => PackingResponse.fromJson(op)).toList();
      } else {
        final errorData = jsonDecode(response.body);
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
      final response = await _httpClient.post(
        Uri.parse('$_baseUrl/validate'),
        headers: headers,
        body: jsonEncode(packingRequest.toJson()),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return PackingResponse.fromJson(responseData);
      } else {
        final errorData = jsonDecode(response.body);
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
