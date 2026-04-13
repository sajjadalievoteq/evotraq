import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:traqtrace_app/core/config/app_config.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/core/network/token_manager.dart';

class EPCConversionService {
  final http.Client _client;
  final TokenManager _tokenManager;
  final AppConfig _appConfig;

  EPCConversionService({
    required http.Client client,
    required TokenManager tokenManager,
    required AppConfig appConfig,
  })  : _client = client,
        _tokenManager = tokenManager,
        _appConfig = appConfig;

  Future<String> convertSGTINToEPC(String gtin, String serial) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final response = await _client.get(
      Uri.parse('${_appConfig.apiBaseUrl}/api/epc/sgtin/to-epc?gtin=$gtin&serialNumber=$serial'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return data['epcUri'];
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: _parseErrorMessage(response.body) ?? 'Failed to convert SGTIN to EPC URI',
      );
    }
  }

  Future<String> convertSSCCToEPC(String sscc) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final response = await _client.get(
      Uri.parse('${_appConfig.apiBaseUrl}/api/epc/sscc/to-epc?sscc=$sscc'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return data['epcUri'];
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: _parseErrorMessage(response.body) ?? 'Failed to convert SSCC to EPC URI',
      );
    }
  }

  Future<String> convertEPCToGTIN(String epcUri) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final encodedEpc = Uri.encodeComponent(epcUri);
    final response = await _client.get(
      Uri.parse('${_appConfig.apiBaseUrl}/api/epc/sgtin/from-epc?epcUri=$encodedEpc'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return data['gtin'];
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: _parseErrorMessage(response.body) ?? 'Failed to convert EPC URI to GTIN',
      );
    }
  }

  Future<String> convertEPCToSSCC(String epcUri) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final encodedEpc = Uri.encodeComponent(epcUri);
    final response = await _client.get(
      Uri.parse('${_appConfig.apiBaseUrl}/api/epc/sscc/from-epc?epcUri=$encodedEpc'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return data['sscc'];
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: _parseErrorMessage(response.body) ?? 'Failed to convert EPC URI to SSCC',
      );
    }
  }

  Future<String> convertGLNToEPC(String gln, String? extension) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final Uri uri = extension != null
        ? Uri.parse('${_appConfig.apiBaseUrl}/api/epc/gln/to-epc?gln=$gln&extension=$extension')
        : Uri.parse('${_appConfig.apiBaseUrl}/api/epc/gln/to-epc?gln=$gln');

    final response = await _client.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return data['epcUri'];
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: _parseErrorMessage(response.body) ?? 'Failed to convert GLN to EPC URI',
      );
    }
  }

  Future<String> convertEPCToGLN(String epcUri) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final encodedEpc = Uri.encodeComponent(epcUri);
    final response = await _client.get(
      Uri.parse('${_appConfig.apiBaseUrl}/api/epc/gln/from-epc?epcUri=$encodedEpc'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return data['gln'];
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: _parseErrorMessage(response.body) ?? 'Failed to convert EPC URI to GLN',
      );
    }
  }

  Future<String> extractSerialNumberFromEPC(String epcUri) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final encodedEpc = Uri.encodeComponent(epcUri);
    final response = await _client.get(
      Uri.parse('${_appConfig.apiBaseUrl}/api/epc/sgtin/from-epc?epcUri=$encodedEpc'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return data['serialNumber'];
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: _parseErrorMessage(response.body) ?? 'Failed to extract serial number from EPC URI',
      );
    }
  }

  Future<bool> isValidEPC(String epcUri) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final encodedEpc = Uri.encodeComponent(epcUri);
    final response = await _client.get(
      Uri.parse('${_appConfig.apiBaseUrl}/api/epc/validate?epcUri=$encodedEpc'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return data['isValid'];
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: _parseErrorMessage(response.body) ?? 'Failed to validate EPC URI',
      );
    }
  }

  Future<String> convertGTINToClassEPC(String gtin) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final response = await _client.get(
      Uri.parse('${_appConfig.apiBaseUrl}/api/epc/class-level/from-gtin?gtin=$gtin'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return data['epcPattern'];
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: _parseErrorMessage(response.body) ?? 'Failed to convert GTIN to class-level EPC URI',
      );
    }
  }

  Future<String> convertGS1ElementStringToEPC(String elementString) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final encodedString = Uri.encodeComponent(elementString);
    final response = await _client.get(
      Uri.parse('${_appConfig.apiBaseUrl}/api/epc/from-element-string?elementString=$encodedString'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return data['epcUri'];
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: _parseErrorMessage(response.body) ?? 'Failed to convert GS1 element string to EPC URI',
      );
    }
  }

  Future<String> convertEPCToElementString(String epcUri) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final encodedEpc = Uri.encodeComponent(epcUri);
    final response = await _client.get(
      Uri.parse('${_appConfig.apiBaseUrl}/api/epc/to-element-string?epcUri=$encodedEpc'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return data['elementString'];
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: _parseErrorMessage(response.body) ?? 'Failed to convert EPC URI to GS1 element string',
      );
    }
  }

  Future<String?> getEPCType(String epcUri) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final encodedEpc = Uri.encodeComponent(epcUri);
    final response = await _client.get(
      Uri.parse('${_appConfig.apiBaseUrl}/api/epc/info?epcUri=$encodedEpc'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return data['epcType'];
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: _parseErrorMessage(response.body) ?? 'Failed to get EPC type',
      );
    }
  }

  Future<bool> isClassLevelEPC(String epcUri) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final encodedEpc = Uri.encodeComponent(epcUri);
    final response = await _client.get(
      Uri.parse('${_appConfig.apiBaseUrl}/api/epc/info?epcUri=$encodedEpc'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return data['isClassLevel'];
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: _parseErrorMessage(response.body) ?? 'Failed to check if EPC is class level',
      );
    }
  }

  Future<bool> isInstanceLevelEPC(String epcUri) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final encodedEpc = Uri.encodeComponent(epcUri);
    final response = await _client.get(
      Uri.parse('${_appConfig.apiBaseUrl}/api/epc/info?epcUri=$encodedEpc'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return data['isInstanceLevel'];
    } else {      throw ApiException(
        statusCode: response.statusCode,
        message: _parseErrorMessage(response.body) ?? 'Failed to check if EPC is instance level',
      );
    }
  }

  Future<List<Map<String, String>>> convertEPCListToSGTINs(List<String> epcList) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final response = await _client.post(
      Uri.parse('${_appConfig.apiBaseUrl}/api/epc/sgtin/batch/from-epc'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'epcUris': epcList,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final List<dynamic> items = responseData['items'];

      return items.map<Map<String, String>>((dynamic item) {
        return {
          'gtin': item['gtin'] as String,
          'serialNumber': item['serialNumber'] as String,
          'serial': item['serialNumber'] as String, // Include both keys for backward compatibility
        };
      }).toList();
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: _parseErrorMessage(response.body) ?? 'Failed to convert EPC list to SGTINs',
      );
    }
  }

  Future<List<String>> convertSGTINsToEPCList(List<Map<String, String>> gtinSerialPairs) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final requestBody = gtinSerialPairs.map((pair) {
      return {
        'gtin': pair['gtin'],
        'serialNumber': pair['serial'] ?? pair['serialNumber'],
      };
    }).toList();

    final response = await _client.post(
      Uri.parse('${_appConfig.apiBaseUrl}/api/epc/sgtin/batch/to-epc'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final List<dynamic> epcUris = responseData['epcUris'];
      return epcUris.map((uri) => uri.toString()).toList();
    } else {      throw ApiException(
        statusCode: response.statusCode,
        message: _parseErrorMessage(response.body) ?? 'Failed to convert SGTIN pairs to EPC list',
      );
    }
  }

  Future<Map<String, String>> convertEPCToSGTIN(String epcUri) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final encodedEpc = Uri.encodeComponent(epcUri);
    final response = await _client.get(
      Uri.parse('${_appConfig.apiBaseUrl}/api/epc/sgtin/from-epc?epcUri=$encodedEpc'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return {
        'gtin': data['gtin'],
        'serial': data['serialNumber'],
        'serialNumber': data['serialNumber'], // Include both keys for backward compatibility
      };
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: _parseErrorMessage(response.body) ?? 'Failed to convert EPC URI to SGTIN',
      );
    }
  }

  // Helper method to parse error messages from API responses
  String? _parseErrorMessage(String responseBody) {
    try {
      final jsonBody = jsonDecode(responseBody);
      if (jsonBody['message'] != null) {
        return jsonBody['message'];
      } else if (jsonBody['error'] != null) {
        return jsonBody['error'];
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
