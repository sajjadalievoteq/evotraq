import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:traqtrace_app/core/config/app_config.dart';
import 'package:traqtrace_app/core/network/token_manager.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';

/// Simplified service for interacting with GS1 barcode verification API
class GS1BarcodeApiService {
  final http.Client _client;
  final TokenManager _tokenManager;
  final AppConfig _appConfig;
  late final String _baseUrl;
  
  GS1BarcodeApiService({
    required http.Client client,
    required TokenManager tokenManager,
    required AppConfig appConfig,
  }) : 
    _client = client,
    _tokenManager = tokenManager,
    _appConfig = appConfig {
    // Remove the '/api' suffix as it might be already included in the apiBaseUrl
    _baseUrl = _appConfig.apiBaseUrl.endsWith('/api') 
        ? _appConfig.apiBaseUrl 
        : '${_appConfig.apiBaseUrl}/api';
  }
  
  /// Get authorization headers for API requests
  Future<Map<String, String>> _getHeaders() async {
    final token = await _tokenManager.getToken();
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
      // Build the URI with proper query parameters using the new unified endpoint
    final uri = Uri.parse('$_baseUrl/barcodes/gs1/verify').replace(
      queryParameters: {
        'data': gs1ElementString,
      },
    );
    
    debugPrint('Calling GS1 barcode verification API: ${uri.toString()}');
    
    try {
      final response = await _client.get(
        uri,
        headers: headers,
      );
      
      debugPrint('GS1 barcode verification response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final result = json.decode(response.body);
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
    final uri = Uri.parse('$_baseUrl/barcodes/verify').replace(
      queryParameters: {
        'data': gs1ElementString,
      },
    );
    
    debugPrint('Trying alternative GS1 verification endpoint: ${uri.toString()}');
    
    final response = await _client.get(
      uri,
      headers: headers,
    );
      debugPrint('Alternative endpoint response status: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      final result = json.decode(response.body);
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
        message: _parseErrorMessage(response.body) ?? 'Failed to verify GS1 barcode: ${response.statusCode}',
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
