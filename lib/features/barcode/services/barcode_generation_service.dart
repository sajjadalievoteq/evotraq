import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:traqtrace_app/core/config/app_config.dart';
import 'package:traqtrace_app/core/network/token_manager.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';

/// Service for generating barcodes using the backend API
class BarcodeGenerationService {
  final http.Client _client;
  final TokenManager _tokenManager;
  final AppConfig _appConfig;
  late final String _baseUrl;
  
  BarcodeGenerationService({
    required http.Client client,
    required TokenManager tokenManager,
    required AppConfig appConfig,
  }) : _client = client,
       _tokenManager = tokenManager,
       _appConfig = appConfig {
    _baseUrl = '${_appConfig.apiBaseUrl}/api/barcode/generate';
  }

  /// Get authorization headers for API requests
  Future<Map<String, String>> _getHeaders() async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// Generate a GS1 DataMatrix barcode
  Future<Uint8List> generateDataMatrix({
    required String gs1ElementString,
    int width = 300,
    int height = 300,
  }) async {
    final headers = await _getHeaders();

    final uri = Uri.parse('$_baseUrl/datamatrix').replace(
      queryParameters: {
        'gs1ElementString': gs1ElementString,
        'width': width.toString(),
        'height': height.toString(),
      },
    );

    final response = await _client.get(uri, headers: headers);

    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: _parseErrorMessage(response.body) ?? 'Failed to generate DataMatrix barcode',
      );
    }
  }
  
  /// Generate a GS1-128 linear barcode
  Future<Uint8List> generateGS1128({
    required String gs1ElementString,
    int width = 400,
    int height = 150,
  }) async {
    final headers = await _getHeaders();

    final uri = Uri.parse('$_baseUrl/gs1-128').replace(
      queryParameters: {
        'gs1ElementString': gs1ElementString,
        'width': width.toString(),
        'height': height.toString(),
      },
    );

    final response = await _client.get(uri, headers: headers);

    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: _parseErrorMessage(response.body) ?? 'Failed to generate GS1-128 barcode',
      );
    }
  }
  
  /// Generate an SGTIN DataMatrix barcode with product information
  Future<Uint8List> generateSGTINDataMatrix({
    required String gtin,
    required String serialNumber,
    String? expiryDate,
    String? batchLot,
    int width = 300,
    int height = 300,
  }) async {
    final headers = await _getHeaders();

    // Build query parameters
    final queryParams = {
      'gtin': gtin,
      'serialNumber': serialNumber,
      'width': width.toString(),
      'height': height.toString(),
    };

    // Add optional parameters if provided
    if (expiryDate != null) {
      queryParams['expiryDate'] = expiryDate;
    }

    if (batchLot != null) {
      queryParams['batchLot'] = batchLot;
    }

    final uri = Uri.parse('$_baseUrl/sgtin-datamatrix').replace(
      queryParameters: queryParams,
    );

    final response = await _client.get(uri, headers: headers);

    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: _parseErrorMessage(response.body) ?? 'Failed to generate SGTIN DataMatrix barcode',
      );
    }
  }
  
  /// Generate an SSCC barcode for shipping containers
  Future<Uint8List> generateSSCCBarcode({
    required String sscc,
    String format = 'gs1-128',
    int width = 400,
    int height = 150,
  }) async {
    final headers = await _getHeaders();

    final uri = Uri.parse('$_baseUrl/sscc').replace(
      queryParameters: {
        'sscc': sscc,
        'format': format,
        'width': width.toString(),
        'height': height.toString(),
      },
    );

    final response = await _client.get(uri, headers: headers);

    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: _parseErrorMessage(response.body) ?? 'Failed to generate SSCC barcode',
      );
    }
  }
  
  /// Generic barcode generation for multiple formats
  Future<Uint8List> generateGenericBarcode({
    required String data,
    required String format,
    int width = 300,
    int height = 150,
  }) async {
    final headers = await _getHeaders();

    final uri = Uri.parse('$_baseUrl/generic').replace(
      queryParameters: {
        'data': data,
        'format': format,
        'width': width.toString(),
        'height': height.toString(),
      },
    );

    final response = await _client.get(uri, headers: headers);

    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: _parseErrorMessage(response.body) ?? 'Failed to generate barcode',
      );
    }
  }

  /// Helper to parse error messages from API responses
  String? _parseErrorMessage(String responseBody) {
    try {
      final jsonBody = json.decode(responseBody);
      return jsonBody['message'] ?? jsonBody['error'];
    } catch (_) {
      return null;
    }
  }
}
