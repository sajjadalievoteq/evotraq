import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';

/// Simplified service for interacting with GS1 barcode verification API
class GS1BarcodeApiService {
  final DioService _dioService;
  late final String _baseUrl;

  GS1BarcodeApiService({
    required DioService dioService,
  }) : _dioService = dioService {
    _baseUrl = _dioService.baseUrl;
  }

  /// Get authorization headers for API requests
  Future<Map<String, String>> _getHeaders() async {
    final token = await _dioService.getAuthToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    return {
      'Content-Type': 'application/json',
      'Accept': '*/*',
      'Authorization': 'Bearer $token',
    };
  }

  /// Verify a GS1 barcode using the simplified API endpoint
  Future<Map<String, dynamic>> verifyGS1Barcode(String gs1ElementString) async {
    final headers = await _getHeaders();
    final queryParameters = {'data': gs1ElementString};

    debugPrint(
      'Calling GS1 barcode verification API: $_baseUrl/barcodes/gs1/verify',
    );

    try {
      final response = await _dioService.get(
        '$_baseUrl/barcodes/gs1/verify',
        headers: headers,
        queryParameters: queryParameters,
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      debugPrint(
        'GS1 barcode verification response status: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.data);
        debugPrint('GS1 barcode verification successful: ${result.toString()}');
        return result;
      } else {
        // Try alternative verify endpoint if the first one fails
        return await _tryAlternativeEndpoint(gs1ElementString, headers);
      }
    } catch (e) {
      debugPrint('Error during barcode verification: $e');
      rethrow;
    }
  }

  /// Try alternative verify endpoint if the first one fails
  Future<Map<String, dynamic>> _tryAlternativeEndpoint(String gs1ElementString, Map<String, String> headers) async {
    // Try the /api/barcodes/verify endpoint if gs1/verify fails
    final queryParameters = {'data': gs1ElementString};

    debugPrint(
      'Trying alternative GS1 verification endpoint: $_baseUrl/barcodes/verify',
    );

    final response = await _dioService.get(
      '$_baseUrl/barcodes/verify',
      headers: headers,
      queryParameters: queryParameters,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );
    debugPrint('Alternative endpoint response status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final result = jsonDecode(response.data);
      // Ensure result has the expected format for our GS1 scanner
      if (!result.containsKey('valid') && result.containsKey('success')) {
        // Convert from old format to new format
        return {
          'valid': result['success'],
          'gs1ElementString': gs1ElementString,
          'parsedData': result['extractedData'] ?? {},
          'humanReadable': result['humanReadable'] ?? result['extractedData'] ?? {},
        };
      }
      return result;
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message:
            _parseErrorMessage(response.data.toString()) ??
            'Failed to verify GS1 barcode: ${response.statusCode}',
      );
    }
  }

  /// Parse error message from response body
  String? _parseErrorMessage(String responseBody) {
    try {
      final Map<String, dynamic> errorResponse = json.decode(responseBody);
      return errorResponse['message'] ?? errorResponse['error'] ?? responseBody;
    } catch (e) {
      return null; // Could not parse error message
    }
  }
}
