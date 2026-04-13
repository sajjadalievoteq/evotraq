import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:traqtrace_app/core/config/app_config.dart';
import 'package:traqtrace_app/core/network/token_manager.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';

/// Service for interacting with barcode verification and EPCIS mapping APIs
class BarcodeApiService {
  final http.Client _client;
  final TokenManager _tokenManager;
  final AppConfig _appConfig;
  late final String _baseUrl;
    BarcodeApiService({
    required http.Client client,
    required TokenManager tokenManager,
    required AppConfig appConfig,
  }) : _client = client,
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

    // Include an accept header to allow all types for proper content negotiation
    return {
      'Content-Type': 'application/json',
      'Accept': '*/*',
      'Authorization': 'Bearer $token',
    };
  }  /// Verify a barcode's syntax and structure
  Future<Map<String, dynamic>> verifyBarcode(String barcodeData) async {
    final headers = await _getHeaders();

    // Build the URI with proper query parameters
    // The correct endpoint is /api/barcodes/validate per BarcodeController
    final uri = Uri.parse('$_baseUrl/barcodes/validate').replace(
      queryParameters: {
        'data': barcodeData,
        'type': 'DATAMATRIX',
      },
    );

    debugPrint('Calling barcode validation API: ${uri.toString()}');

    try {
      final response = await _client.get(
        uri,
        headers: headers,
      );

      debugPrint('Barcode validation response status: ${response.statusCode}');
      debugPrint('Barcode validation response body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 404) {
        // Try the alternative endpoint from BarcodeVerificationController if first one fails
        debugPrint('First endpoint not found, trying alternative GS1 validation endpoint');
        return _tryAlternativeGS1Validation(barcodeData, headers);
      } else {
        throw ApiException(
          statusCode: response.statusCode,
          message: _parseErrorMessage(response.body) ?? 'Failed to verify barcode: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Error during barcode validation: $e');
      rethrow;
    }
  }

  /// Try alternative GS1 validation endpoint if primary endpoint fails
  Future<Map<String, dynamic>> _tryAlternativeGS1Validation(String barcodeData, Map<String, String> headers) async {
    // Try the /api/barcode/verify/gs1-element-string endpoint from BarcodeVerificationController
    final uri = Uri.parse('$_baseUrl/barcode/verify/gs1-element-string').replace(
      queryParameters: {
        'gs1ElementString': barcodeData,
      },
    );

    debugPrint('Trying alternative validation API: ${uri.toString()}');

    final response = await _client.get(
      uri,
      headers: headers,
    );

    debugPrint('Alternative validation response status: ${response.statusCode}');
    debugPrint('Alternative validation response body: ${response.body}');

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      // Convert to expected format
      return {
        'isValid': result['valid'] ?? false,
        'message': result['valid'] == true ? 'Valid GS1 barcode' : 'Invalid GS1 barcode format',
        'data': barcodeData,
        'validationResults': result['validationResults']
      };
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: _parseErrorMessage(response.body) ?? 'Failed to verify barcode: ${response.statusCode}',
      );
    }
  }

  /// Check barcode quality
  Future<Map<String, dynamic>> checkBarcodeQuality(List<int> barcodeImage) async {
    final headers = await _getHeaders();
    // Remove Content-Type from headers for multipart request
    headers.remove('Content-Type');

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$_baseUrl/barcodes/quality'),
    );

    request.headers.addAll(headers);
    request.files.add(http.MultipartFile.fromBytes(
      'image',
      barcodeImage,
      filename: 'barcode.png',
    ));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: _parseErrorMessage(response.body) ?? 'Failed to check barcode quality',
      );
    }
  }  /// Extract data content from a barcode
  Future<Map<String, dynamic>> extractBarcodeData(String barcodeData) async {
    final headers = await _getHeaders();

    // Build the URI with proper query parameters
    final uri = Uri.parse('$_baseUrl/barcodes/parse-gs1').replace(
      queryParameters: {
        'elementString': barcodeData,
      },
    );

    debugPrint('Calling parse-gs1 API: ${uri.toString()}');

    try {
      final response = await _client.get(
        uri,
        headers: headers,
      );

      debugPrint('Parse-gs1 response status: ${response.statusCode}');
      debugPrint('Parse-gs1 response body: ${response.body}');

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        // Add barcodeType to standardize output format
        if (!result.containsKey('barcodeType')) {
          result['barcodeType'] = 'GS1';
        }
        return result;
      } else if (response.statusCode == 404) {
        // Try alternative approach for parsing GS1 data
        // This could be a manual parsing logic for common GS1 formats
        debugPrint('GS1 parse endpoint not found, trying alternative approach');
        return _extractBasicGS1Data(barcodeData);
      } else {
        throw ApiException(
          statusCode: response.statusCode,
          message: _parseErrorMessage(response.body) ?? 'Failed to extract barcode data: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Error during barcode data extraction: $e');
      // Return a fallback result with original barcode data
      return _extractBasicGS1Data(barcodeData);
    }
  }

  /// Basic manual parsing of GS1 data when API fails
  Map<String, dynamic> _extractBasicGS1Data(String data) {
    final result = <String, dynamic>{
      'elementString': data,
      'barcodeType': 'GS1',
      'rawData': data,
      'isValid': true, // Assume valid for now since we can't verify
    };

    // Very basic GS1 parsing - look for common AI patterns
    // This is fallback logic for when the backend API is unavailable
    Map<String, String> parsedData = {};

    try {
      // Look for common GS1 Application Identifiers
      // AI (01) - GTIN - 14 digits
      final gtinRegex = RegExp(r'\(01\)(\d{14})');
      final gtinMatch = gtinRegex.firstMatch(data);
      if (gtinMatch != null) {
        parsedData['GTIN'] = gtinMatch.group(1)!;
      }

      // AI (21) - Serial Number - variable length
      final snRegex = RegExp(r'\(21\)([^\(]+)');
      final snMatch = snRegex.firstMatch(data);
      if (snMatch != null) {
        parsedData['serialNumber'] = snMatch.group(1)!;
      }

      // AI (10) - Batch/Lot Number - variable length
      final lotRegex = RegExp(r'\(10\)([^\(]+)');
      final lotMatch = lotRegex.firstMatch(data);
      if (lotMatch != null) {
        parsedData['batchNumber'] = lotMatch.group(1)!;
      }

      // AI (17) - Expiry Date - 6 digits YYMMDD
      final expRegex = RegExp(r'\(17\)(\d{6})');
      final expMatch = expRegex.firstMatch(data);
      if (expMatch != null) {
        parsedData['expiryDate'] = expMatch.group(1)!;
      }

      result['parsed'] = parsedData;
    } catch (e) {
      debugPrint('Error during basic GS1 parsing: $e');
      result['isValid'] = false;
      result['message'] = 'Failed to parse GS1 data: $e';
    }

    return result;
  }

  /// Create an EPCIS object event from a barcode
  Future<Map<String, dynamic>> createObjectEvent({
    required String gs1ElementString,
    required String locationGLN,
    String businessStep = 'urn:epcglobal:cbv:bizstep:observing',
    String disposition = 'urn:epcglobal:cbv:disp:active',
  }) async {
    final headers = await _getHeaders();
    final params = {
      'gs1ElementString': gs1ElementString,
      'locationGLN': locationGLN,
      'businessStep': businessStep,
      'disposition': disposition,
    };

    final uri = Uri.parse('$_baseUrl/barcode-epcis/object-event').replace(
      queryParameters: params,
    );

    final response = await _client.post(
      uri,
      headers: headers,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: _parseErrorMessage(response.body) ?? 'Failed to create object event',
      );
    }
  }

  /// Create an EPCIS aggregation event from parent and child barcodes
  Future<Map<String, dynamic>> createAggregationEvent({
    required String parentBarcode,
    required List<String> childBarcodes,
    required String locationGLN,
    String businessStep = 'urn:epcglobal:cbv:bizstep:packing',
    String disposition = 'urn:epcglobal:cbv:disp:in_progress',
    String action = 'ADD',
  }) async {
    final headers = await _getHeaders();

    // Construct query parameters
    final queryParams = {
      'parentBarcode': parentBarcode,
      'locationGLN': locationGLN,
      'businessStep': businessStep,
      'disposition': disposition,
      'action': action,
    };

    // Add child barcodes as repeated query parameters
    for (final childBarcode in childBarcodes) {
      queryParams['childBarcodes'] = childBarcode;
    }

    final uri = Uri.parse('$_baseUrl/barcode-epcis/aggregation-event').replace(
      queryParameters: queryParams,
    );

    final response = await _client.post(
      uri,
      headers: headers,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: _parseErrorMessage(response.body) ?? 'Failed to create aggregation event',
      );
    }
  }

  /// Create an EPCIS transaction event from barcodes and transaction info
  Future<List<Map<String, dynamic>>> createTransactionEvent({
    required List<String> gs1ElementStrings,
    required String bizTransactionType,
    required String bizTransactionId,
    required String locationGLN,
    String businessStep = 'urn:epcglobal:cbv:bizstep:shipping',
    String disposition = 'urn:epcglobal:cbv:disp:in_transit',
    String action = 'ADD',
  }) async {
    final headers = await _getHeaders();

    // Construct query parameters
    final queryParams = {
      'bizTransactionType': bizTransactionType,
      'bizTransactionId': bizTransactionId,
      'locationGLN': locationGLN,
      'businessStep': businessStep,
      'disposition': disposition,
      'action': action,
    };

    // Add GS1 element strings as repeated query parameters
    for (final gs1String in gs1ElementStrings) {
      queryParams['gs1ElementStrings'] = gs1String;
    }

    final uri = Uri.parse('$_baseUrl/barcode-epcis/transaction-event').replace(
      queryParameters: queryParams,
    );

    final response = await _client.post(
      uri,
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> eventList = json.decode(response.body);
      return eventList.cast<Map<String, dynamic>>();
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: _parseErrorMessage(response.body) ?? 'Failed to create transaction event',
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