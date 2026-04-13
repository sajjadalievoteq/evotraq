import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/core/network/http_service.dart';

/// Service for generating barcodes using the backend API
class BarcodeGenerationService {
  final HttpService _httpService;

  BarcodeGenerationService({required HttpService httpService})
    : _httpService = httpService;

  String get _baseUrl {
    final base = _httpService.baseUrl.replaceAll(RegExp(r'/$'), '');
    if (base.endsWith('/api')) {
      return '$base/barcode/generate';
    }
    return '$base/api/barcode/generate';
  }

  String get _fallbackBaseUrl {
    final base = _httpService.baseUrl.replaceAll(RegExp(r'/$'), '');
    if (base.endsWith('/api')) {
      return '$base/api/barcode/generate';
    }
    return '$base/barcode/generate';
  }

  Future<Response> _getBytesWithFallback(
    Uri primaryUri,
    Uri fallbackUri,
    Map<String, String> headers,
  ) async {
    final primaryResponse = await _httpService.get(
      primaryUri.toString(),
      headers: headers,
      responseType: ResponseType.bytes,
      acceptAllStatusCodes: true,
    );
    if (primaryResponse.statusCode != 404) {
      return primaryResponse;
    }
    return await _httpService.get(
      fallbackUri.toString(),
      headers: headers,
      responseType: ResponseType.bytes,
      acceptAllStatusCodes: true,
    );
  }

  /// Get authorization headers for API requests
  Future<Map<String, String>> _getHeaders() async {
    final token = await _httpService.getAuthToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  String _stringifyErrorBody(dynamic data) {
    if (data == null) return '';
    if (data is String) return data;
    if (data is List<int>) {
      try {
        return utf8.decode(data);
      } catch (_) {
        return data.toString();
      }
    }
    try {
      return jsonEncode(data);
    } catch (_) {
      return data.toString();
    }
  }

  /// Generate a GS1 DataMatrix barcode
  Future<Uint8List> generateDataMatrix({
    required String gs1ElementString,
    int width = 300,
    int height = 300,
  }) async {
    final headers = await _getHeaders();

    final primaryUri = Uri.parse('$_baseUrl/datamatrix').replace(
      queryParameters: {
        'gs1ElementString': gs1ElementString,
        'width': width.toString(),
        'height': height.toString(),
      },
    );

    final fallbackUri = Uri.parse(
      '$_fallbackBaseUrl/datamatrix',
    ).replace(queryParameters: primaryUri.queryParameters);
    final response = await _getBytesWithFallback(
      primaryUri,
      fallbackUri,
      headers,
    );

    if (response.statusCode == 200) {
      return Uint8List.fromList((response.data as List<int>));
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message:
            _parseErrorMessage(_stringifyErrorBody(response.data)) ??
            'Failed to generate DataMatrix barcode',
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

    final primaryUri = Uri.parse('$_baseUrl/gs1-128').replace(
      queryParameters: {
        'gs1ElementString': gs1ElementString,
        'width': width.toString(),
        'height': height.toString(),
      },
    );

    final fallbackUri = Uri.parse(
      '$_fallbackBaseUrl/gs1-128',
    ).replace(queryParameters: primaryUri.queryParameters);
    final response = await _getBytesWithFallback(
      primaryUri,
      fallbackUri,
      headers,
    );

    if (response.statusCode == 200) {
      return Uint8List.fromList((response.data as List<int>));
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message:
            _parseErrorMessage(_stringifyErrorBody(response.data)) ??
            'Failed to generate GS1-128 barcode',
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

    final primaryUri = Uri.parse(
      '$_baseUrl/sgtin-datamatrix',
    ).replace(queryParameters: queryParams);
    final fallbackUri = Uri.parse(
      '$_fallbackBaseUrl/sgtin-datamatrix',
    ).replace(queryParameters: primaryUri.queryParameters);
    final response = await _getBytesWithFallback(
      primaryUri,
      fallbackUri,
      headers,
    );

    if (response.statusCode == 200) {
      return Uint8List.fromList((response.data as List<int>));
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message:
            _parseErrorMessage(_stringifyErrorBody(response.data)) ??
            'Failed to generate SGTIN DataMatrix barcode',
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

    final primaryUri = Uri.parse('$_baseUrl/sscc').replace(
      queryParameters: {
        'sscc': sscc,
        'format': format,
        'width': width.toString(),
        'height': height.toString(),
      },
    );

    final fallbackUri = Uri.parse(
      '$_fallbackBaseUrl/sscc',
    ).replace(queryParameters: primaryUri.queryParameters);
    final response = await _getBytesWithFallback(
      primaryUri,
      fallbackUri,
      headers,
    );

    if (response.statusCode == 200) {
      return Uint8List.fromList((response.data as List<int>));
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message:
            _parseErrorMessage(_stringifyErrorBody(response.data)) ??
            'Failed to generate SSCC barcode',
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

    final primaryUri = Uri.parse('$_baseUrl/generic').replace(
      queryParameters: {
        'data': data,
        'format': format,
        'width': width.toString(),
        'height': height.toString(),
      },
    );

    final fallbackUri = Uri.parse(
      '$_fallbackBaseUrl/generic',
    ).replace(queryParameters: primaryUri.queryParameters);
    final response = await _getBytesWithFallback(
      primaryUri,
      fallbackUri,
      headers,
    );

    if (response.statusCode == 200) {
      return Uint8List.fromList((response.data as List<int>));
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message:
            _parseErrorMessage(_stringifyErrorBody(response.data)) ??
            'Failed to generate barcode',
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
