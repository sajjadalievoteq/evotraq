import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:traqtrace_app/core/config/app_config.dart';
import 'package:traqtrace_app/core/network/token_manager.dart';
import 'package:traqtrace_app/features/epcis/models/operations/shipping_models.dart';

/// Service for shipping operations.
/// Provides simplified API for operational users to create and manage shipping events.
abstract class ShippingOperationService {
  /// Create a shipping operation with multiple EPCs
  Future<ShippingResponse> createShippingOperation(ShippingRequest shippingRequest);
  
  /// Get shipping operation by ID
  Future<ShippingResponse> getShippingOperation(String operationId);
  
  /// Get all shipping operations with pagination
  Future<List<ShippingResponse>> getAllShippingOperations({int page = 0, int size = 20});
  
  /// Get shipping operations by reference
  Future<List<ShippingResponse>> getShippingOperationsByReference(String reference);
  
  /// Get shipping operations by destination GLN
  Future<List<ShippingResponse>> getShippingOperationsByDestination(String destinationGLN);
  
  /// Get shipping operations by source GLN
  Future<List<ShippingResponse>> getShippingOperationsBySource(String sourceGLN);
  
  /// Get shipping operations for specific EPC
  Future<List<ShippingResponse>> getShippingOperationsForEPC(String epc);
  
  /// Validate shipping request without creating events
  Future<ShippingResponse> validateShippingRequest(ShippingRequest shippingRequest);
}

/// Implementation of ShippingOperationService using REST API
class ShippingOperationServiceImpl implements ShippingOperationService {
  final TokenManager _tokenManager;
  final http.Client _httpClient;
  final AppConfig _appConfig;

  ShippingOperationServiceImpl({
    required TokenManager tokenManager,
    http.Client? httpClient,
    required AppConfig appConfig,
  })  : _tokenManager = tokenManager,
        _httpClient = httpClient ?? http.Client(),
        _appConfig = appConfig;

  String get _baseUrl => '${_appConfig.apiBaseUrl}/operations/shipping';

  Future<Map<String, String>> get _headers async {
    final token = await _tokenManager.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  @override
  Future<ShippingResponse> createShippingOperation(ShippingRequest shippingRequest) async {
    try {
      final headers = await _headers;
      final response = await _httpClient.post(
        Uri.parse(_baseUrl),
        headers: headers,
        body: jsonEncode(shippingRequest.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return ShippingResponse.fromJson(responseData);
      } else {
        final errorData = jsonDecode(response.body);
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

  @override
  Future<ShippingResponse> getShippingOperation(String operationId) async {
    try {
      final headers = await _headers;
      final response = await _httpClient.get(
        Uri.parse('$_baseUrl/$operationId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return ShippingResponse.fromJson(responseData);
      } else {
        final errorData = jsonDecode(response.body);
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

  @override
  Future<List<ShippingResponse>> getAllShippingOperations({int page = 0, int size = 20}) async {
    try {
      final headers = await _headers;
      final response = await _httpClient.get(
        Uri.parse('$_baseUrl?page=$page&size=$size'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final operations = responseData['operations'] as List;
        return operations.map((op) => ShippingResponse.fromJson(op)).toList();
      } else {
        final errorData = jsonDecode(response.body);
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

  @override
  Future<List<ShippingResponse>> getShippingOperationsByReference(String reference) async {
    try {
      final headers = await _headers;
      final response = await _httpClient.get(
        Uri.parse('$_baseUrl/reference/${Uri.encodeComponent(reference)}'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as List;
        return responseData.map((op) => ShippingResponse.fromJson(op)).toList();
      } else {
        final errorData = jsonDecode(response.body);
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

  @override
  Future<List<ShippingResponse>> getShippingOperationsByDestination(String destinationGLN) async {
    try {
      final headers = await _headers;
      final response = await _httpClient.get(
        Uri.parse('$_baseUrl/destination/${Uri.encodeComponent(destinationGLN)}'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as List;
        return responseData.map((op) => ShippingResponse.fromJson(op)).toList();
      } else {
        final errorData = jsonDecode(response.body);
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

  @override
  Future<List<ShippingResponse>> getShippingOperationsBySource(String sourceGLN) async {
    try {
      final headers = await _headers;
      final response = await _httpClient.get(
        Uri.parse('$_baseUrl/source/${Uri.encodeComponent(sourceGLN)}'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as List;
        return responseData.map((op) => ShippingResponse.fromJson(op)).toList();
      } else {
        final errorData = jsonDecode(response.body);
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

  @override
  Future<List<ShippingResponse>> getShippingOperationsForEPC(String epc) async {
    try {
      final headers = await _headers;
      final response = await _httpClient.get(
        Uri.parse('$_baseUrl/epc/${Uri.encodeComponent(epc)}'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as List;
        return responseData.map((op) => ShippingResponse.fromJson(op)).toList();
      } else {
        final errorData = jsonDecode(response.body);
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

  @override
  Future<ShippingResponse> validateShippingRequest(ShippingRequest shippingRequest) async {
    try {
      final headers = await _headers;
      final response = await _httpClient.post(
        Uri.parse('$_baseUrl/validate'),
        headers: headers,
        body: jsonEncode(shippingRequest.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 400) {
        final responseData = jsonDecode(response.body);
        return ShippingResponse.fromJson(responseData);
      } else {
        final errorData = jsonDecode(response.body);
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