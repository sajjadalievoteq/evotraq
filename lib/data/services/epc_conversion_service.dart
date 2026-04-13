import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/core/network/http_service.dart';

class EPCConversionService {
  final HttpService _httpService;

  EPCConversionService({required HttpService httpService})
    : _httpService = httpService;

  String get _primaryBaseUrl {
    final base = _httpService.baseUrl.replaceAll(RegExp(r'/$'), '');
    return '$base/epc';
  }

  String get _fallbackBaseUrl {
    final base = _httpService.baseUrl.replaceAll(RegExp(r'/$'), '');
    return '$base/api/epc';
  }

  Future<Response> _getPlainWithFallback(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    required Map<String, String> headers,
  }) async {
    final primaryResponse = await _httpService.get(
      '$_primaryBaseUrl$endpoint',
      queryParameters: queryParameters,
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (primaryResponse.statusCode != 404) {
      return primaryResponse;
    }

    return await _httpService.get(
      '$_fallbackBaseUrl$endpoint',
      queryParameters: queryParameters,
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );
  }

  Future<Response> _postPlainWithFallback(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    required Map<String, String> headers,
    required String data,
  }) async {
    final primaryResponse = await _httpService.post(
      '$_primaryBaseUrl$endpoint',
      queryParameters: queryParameters,
      headers: headers,
      data: data,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (primaryResponse.statusCode != 404) {
      return primaryResponse;
    }

    return await _httpService.post(
      '$_fallbackBaseUrl$endpoint',
      queryParameters: queryParameters,
      headers: headers,
      data: data,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _httpService.getAuthToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }
    return {'Authorization': 'Bearer $token'};
  }

  Future<String> convertSGTINToEPC(String gtin, String serial) async {
    final headers = await _getHeaders();

    final response = await _getPlainWithFallback(
      '/sgtin/to-epc',
      queryParameters: {'gtin': gtin, 'serialNumber': serial},
      headers: headers,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.data);
      return data['epcUri'];
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message:
            _parseErrorMessage(response.data) ??
            'Failed to convert SGTIN to EPC URI',
      );
    }
  }

  Future<String> convertSSCCToEPC(String sscc) async {
    final headers = await _getHeaders();

    final response = await _getPlainWithFallback(
      '/sscc/to-epc',
      queryParameters: {'sscc': sscc},
      headers: headers,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.data);
      return data['epcUri'];
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message:
            _parseErrorMessage(response.data) ??
            'Failed to convert SSCC to EPC URI',
      );
    }
  }

  Future<String> convertEPCToGTIN(String epcUri) async {
    final headers = await _getHeaders();

    final response = await _getPlainWithFallback(
      '/sgtin/from-epc',
      queryParameters: {'epcUri': epcUri},
      headers: headers,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.data);
      return data['gtin'];
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message:
            _parseErrorMessage(response.data) ??
            'Failed to convert EPC URI to GTIN',
      );
    }
  }

  Future<String> convertEPCToSSCC(String epcUri) async {
    final headers = await _getHeaders();

    final response = await _getPlainWithFallback(
      '/sscc/from-epc',
      queryParameters: {'epcUri': epcUri},
      headers: headers,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.data);
      return data['sscc'];
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message:
            _parseErrorMessage(response.data) ??
            'Failed to convert EPC URI to SSCC',
      );
    }
  }

  Future<String> convertGLNToEPC(String gln, String? extension) async {
    final headers = await _getHeaders();

    final queryParams = {'gln': gln};
    if (extension != null) {
      queryParams['extension'] = extension;
    }

    final response = await _getPlainWithFallback(
      '/gln/to-epc',
      queryParameters: queryParams,
      headers: headers,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.data);
      return data['epcUri'];
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message:
            _parseErrorMessage(response.data) ??
            'Failed to convert GLN to EPC URI',
      );
    }
  }

  Future<String> convertEPCToGLN(String epcUri) async {
    final headers = await _getHeaders();

    final response = await _getPlainWithFallback(
      '/gln/from-epc',
      queryParameters: {'epcUri': epcUri},
      headers: headers,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.data);
      return data['gln'];
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message:
            _parseErrorMessage(response.data) ??
            'Failed to convert EPC URI to GLN',
      );
    }
  }

  Future<String> extractSerialNumberFromEPC(String epcUri) async {
    final headers = await _getHeaders();

    final response = await _getPlainWithFallback(
      '/sgtin/from-epc',
      queryParameters: {'epcUri': epcUri},
      headers: headers,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.data);
      return data['serialNumber'];
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message:
            _parseErrorMessage(response.data) ??
            'Failed to extract serial number from EPC URI',
      );
    }
  }

  Future<bool> isValidEPC(String epcUri) async {
    final headers = await _getHeaders();

    final response = await _getPlainWithFallback(
      '/validate',
      queryParameters: {'epcUri': epcUri},
      headers: headers,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.data);
      return data['isValid'];
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message:
            _parseErrorMessage(response.data) ?? 'Failed to validate EPC URI',
      );
    }
  }

  Future<String> convertGTINToClassEPC(String gtin) async {
    final headers = await _getHeaders();

    final response = await _getPlainWithFallback(
      '/class-level/from-gtin',
      queryParameters: {'gtin': gtin},
      headers: headers,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.data);
      return data['epcPattern'];
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message:
            _parseErrorMessage(response.data) ??
            'Failed to convert GTIN to class-level EPC URI',
      );
    }
  }

  Future<String> convertGS1ElementStringToEPC(String elementString) async {
    final headers = await _getHeaders();

    final response = await _getPlainWithFallback(
      '/from-element-string',
      queryParameters: {'elementString': elementString},
      headers: headers,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.data);
      return data['epcUri'];
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message:
            _parseErrorMessage(response.data) ??
            'Failed to convert GS1 element string to EPC URI',
      );
    }
  }

  Future<String> convertEPCToElementString(String epcUri) async {
    final headers = await _getHeaders();

    final response = await _getPlainWithFallback(
      '/to-element-string',
      queryParameters: {'epcUri': epcUri},
      headers: headers,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.data);
      return data['elementString'];
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message:
            _parseErrorMessage(response.data) ??
            'Failed to convert EPC URI to GS1 element string',
      );
    }
  }

  Future<String?> getEPCType(String epcUri) async {
    final headers = await _getHeaders();

    final response = await _getPlainWithFallback(
      '/info',
      queryParameters: {'epcUri': epcUri},
      headers: headers,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.data);
      return data['epcType'];
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: _parseErrorMessage(response.data) ?? 'Failed to get EPC type',
      );
    }
  }

  Future<bool> isClassLevelEPC(String epcUri) async {
    final headers = await _getHeaders();

    final response = await _getPlainWithFallback(
      '/info',
      queryParameters: {'epcUri': epcUri},
      headers: headers,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.data);
      return data['isClassLevel'];
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message:
            _parseErrorMessage(response.data) ??
            'Failed to check if EPC is class level',
      );
    }
  }

  Future<bool> isInstanceLevelEPC(String epcUri) async {
    final headers = await _getHeaders();

    final response = await _getPlainWithFallback(
      '/info',
      queryParameters: {'epcUri': epcUri},
      headers: headers,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.data);
      return data['isInstanceLevel'];
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message:
            _parseErrorMessage(response.data) ??
            'Failed to check if EPC is instance level',
      );
    }
  }

  Future<List<Map<String, String>>> convertEPCListToSGTINs(
    List<String> epcList,
  ) async {
    final headers = await _getHeaders();
    headers['Content-Type'] = 'application/json';

    final response = await _postPlainWithFallback(
      '/sgtin/batch/from-epc',
      headers: headers,
      data: jsonEncode({'epcUris': epcList}),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.data);
      final List<dynamic> items = responseData['items'];

      return items.map<Map<String, String>>((dynamic item) {
        return {
          'gtin': item['gtin'] as String,
          'serialNumber': item['serialNumber'] as String,
          'serial': item['serialNumber'] as String,
        };
      }).toList();
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message:
            _parseErrorMessage(response.data) ??
            'Failed to convert EPC list to SGTINs',
      );
    }
  }

  Future<List<String>> convertSGTINsToEPCList(
    List<Map<String, String>> gtinSerialPairs,
  ) async {
    final headers = await _getHeaders();
    headers['Content-Type'] = 'application/json';

    final requestBody = gtinSerialPairs.map((pair) {
      return {
        'gtin': pair['gtin'],
        'serialNumber': pair['serial'] ?? pair['serialNumber'],
      };
    }).toList();

    final response = await _postPlainWithFallback(
      '/sgtin/batch/to-epc',
      headers: headers,
      data: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.data);
      final List<dynamic> epcUris = responseData['epcUris'];
      return epcUris.map((uri) => uri.toString()).toList();
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message:
            _parseErrorMessage(response.data) ??
            'Failed to convert SGTIN pairs to EPC list',
      );
    }
  }

  Future<Map<String, String>> convertEPCToSGTIN(String epcUri) async {
    final headers = await _getHeaders();

    final response = await _getPlainWithFallback(
      '/sgtin/from-epc',
      queryParameters: {'epcUri': epcUri},
      headers: headers,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.data);
      return {
        'gtin': data['gtin'],
        'serial': data['serialNumber'],
        'serialNumber': data['serialNumber'],
      };
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message:
            _parseErrorMessage(response.data) ??
            'Failed to convert EPC URI to SGTIN',
      );
    }
  }

  // Helper method to parse error messages from API responses
  String? _parseErrorMessage(dynamic responseData) {
    try {
      if (responseData is String) {
        final jsonBody = jsonDecode(responseData);
        if (jsonBody['message'] != null) {
          return jsonBody['message'];
        } else if (jsonBody['error'] != null) {
          return jsonBody['error'];
        }
      } else if (responseData is Map) {
        if (responseData['message'] != null) {
          return responseData['message'];
        } else if (responseData['error'] != null) {
          return responseData['error'];
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
