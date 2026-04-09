import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:traqtrace_app/core/config/app_config.dart';
import 'package:traqtrace_app/core/network/token_manager.dart';
import 'package:traqtrace_app/features/epcis/models/operations/receiving_models.dart';

/// Service for receiving operations.
/// Provides simplified API for operational users to create and manage receiving events.
abstract class ReceivingOperationService {
  /// Create a receiving operation with multiple EPCs
  Future<ReceivingResponse> createReceivingOperation(ReceivingRequest receivingRequest);
  
  /// Get receiving operation by ID
  Future<ReceivingResponse> getReceivingOperation(String operationId);
  
  /// Get all receiving operations with pagination
  Future<List<ReceivingResponse>> getAllReceivingOperations({int page = 0, int size = 20});
  
  /// Get receiving operations by reference
  Future<List<ReceivingResponse>> getReceivingOperationsByReference(String reference);
  
  /// Get receiving operations by receiving GLN
  Future<List<ReceivingResponse>> getReceivingOperationsByReceivingGLN(String receivingGLN);
  
  /// Get receiving operations by source GLN
  Future<List<ReceivingResponse>> getReceivingOperationsBySource(String sourceGLN);
  
  /// Get receiving operations for specific EPC
  Future<List<ReceivingResponse>> getReceivingOperationsForEPC(String epc);
  
  /// Validate receiving request without creating events
  Future<ReceivingResponse> validateReceivingRequest(ReceivingRequest receivingRequest);
}

/// Implementation of ReceivingOperationService using REST API
class ReceivingOperationServiceImpl implements ReceivingOperationService {
  final TokenManager _tokenManager;
  final http.Client _httpClient;
  final AppConfig _appConfig;

  ReceivingOperationServiceImpl({
    required TokenManager tokenManager,
    http.Client? httpClient,
    required AppConfig appConfig,
  })  : _tokenManager = tokenManager,
        _httpClient = httpClient ?? http.Client(),
        _appConfig = appConfig;

  String get _baseUrl => '${_appConfig.apiBaseUrl}/operations/receiving';

  Future<Map<String, String>> get _headers async {
    final token = await _tokenManager.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  @override
  Future<ReceivingResponse> createReceivingOperation(ReceivingRequest receivingRequest) async {
    try {
      final headers = await _headers;
      final response = await _httpClient.post(
        Uri.parse(_baseUrl),
        headers: headers,
        body: jsonEncode(receivingRequest.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return ReceivingResponse.fromJson(responseData);
      } else {
        final errorData = jsonDecode(response.body);
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

  @override
  Future<ReceivingResponse> getReceivingOperation(String operationId) async {
    try {
      final headers = await _headers;
      final response = await _httpClient.get(
        Uri.parse('$_baseUrl/$operationId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return ReceivingResponse.fromJson(responseData);
      } else {
        final errorData = jsonDecode(response.body);
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

  @override
  Future<List<ReceivingResponse>> getAllReceivingOperations({int page = 0, int size = 20}) async {
    try {
      final headers = await _headers;
      final response = await _httpClient.get(
        Uri.parse('$_baseUrl?page=$page&size=$size'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final operations = responseData['operations'] as List;
        return operations.map((op) => ReceivingResponse.fromJson(op)).toList();
      } else {
        final errorData = jsonDecode(response.body);
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

  @override
  Future<List<ReceivingResponse>> getReceivingOperationsByReference(String reference) async {
    try {
      final headers = await _headers;
      final response = await _httpClient.get(
        Uri.parse('$_baseUrl/reference/${Uri.encodeComponent(reference)}'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as List;
        return responseData.map((op) => ReceivingResponse.fromJson(op)).toList();
      } else {
        final errorData = jsonDecode(response.body);
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

  @override
  Future<List<ReceivingResponse>> getReceivingOperationsByReceivingGLN(String receivingGLN) async {
    try {
      final headers = await _headers;
      final response = await _httpClient.get(
        Uri.parse('$_baseUrl/receiving-location/${Uri.encodeComponent(receivingGLN)}'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as List;
        return responseData.map((op) => ReceivingResponse.fromJson(op)).toList();
      } else {
        final errorData = jsonDecode(response.body);
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

  @override
  Future<List<ReceivingResponse>> getReceivingOperationsBySource(String sourceGLN) async {
    try {
      final headers = await _headers;
      final response = await _httpClient.get(
        Uri.parse('$_baseUrl/source/${Uri.encodeComponent(sourceGLN)}'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as List;
        return responseData.map((op) => ReceivingResponse.fromJson(op)).toList();
      } else {
        final errorData = jsonDecode(response.body);
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

  @override
  Future<List<ReceivingResponse>> getReceivingOperationsForEPC(String epc) async {
    try {
      final headers = await _headers;
      final response = await _httpClient.get(
        Uri.parse('$_baseUrl/epc/${Uri.encodeComponent(epc)}'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as List;
        return responseData.map((op) => ReceivingResponse.fromJson(op)).toList();
      } else {
        final errorData = jsonDecode(response.body);
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

  @override
  Future<ReceivingResponse> validateReceivingRequest(ReceivingRequest receivingRequest) async {
    try {
      final headers = await _headers;
      final response = await _httpClient.post(
        Uri.parse('$_baseUrl/validate'),
        headers: headers,
        body: jsonEncode(receivingRequest.toJson()),
      );

      final responseData = jsonDecode(response.body);
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
