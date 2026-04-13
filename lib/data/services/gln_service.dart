import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:traqtrace_app/core/config/app_config.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/core/network/token_manager.dart';
import 'package:traqtrace_app/features/gs1/models/gln_model.dart';

/// Implementation of GLNService interface for managing GLNs (Global Location Numbers)
class GLNService {
  final http.Client _client;
  final TokenManager _tokenManager;
  final AppConfig _appConfig;

  /// Creates a new GLNServiceImpl instance
  GLNService({
    required http.Client client,
    required TokenManager tokenManager,
    required AppConfig appConfig,
  })  : _client = client,
        _tokenManager = tokenManager,
        _appConfig = appConfig;

  Future<List<GLN>> getAllGLNs({int? page, int? size}) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }    String url = '${_appConfig.apiBaseUrl}/master-data/glns';
    if (page != null && size != null) {
      url += '?page=$page&size=$size';
    }

    final response = await _client.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );    print('GLN list response status: ${response.statusCode}, body: ${response.body}');
      if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData.containsKey('content') && responseData['content'] is List) {
        final List<dynamic> data = responseData['content'];
        return data.map((json) => GLN.fromJson(json)).toList();
      } else {
        // Fallback in case the response structure changes or is not paginated
        if (responseData is List) {
          return (responseData as List).map((json) => GLN.fromJson(json)).toList();
        } else {
          throw ApiException(
            message: 'Unexpected response format: GLN data not found in response',
            responseBody: response.body,
          );
        }
      }
    } else if (response.statusCode == 403) {
      print('Authentication error: Token might be invalid or expired');
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Authentication failed: Please log in again',
        responseBody: response.body,
      );
    } else {
      print('GLN list error: ${response.statusCode} - ${response.reasonPhrase}');
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to load GLNs: ${response.reasonPhrase}',
        responseBody: response.body,
      );
    }
  }

  Future<GLN> getGLNById(String id) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    print('GLN Service: Fetching GLN with ID: $id');
    final url = '${_appConfig.apiBaseUrl}/master-data/glns/code/$id';
    print('GLN Service: Request URL: $url');

    final response = await _client.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('GLN Service: Response status code: ${response.statusCode}');

    if (response.statusCode == 200) {
      print('GLN Service: Raw API Response: ${response.body}');
      final jsonData = json.decode(response.body);
      print('GLN Service: Decoded API Response: $jsonData');
      final gln = GLN.fromJson(jsonData);
      print('GLN Service: Converted to GLN object: ${gln.glnCode}, ${gln.locationName}');
      return gln;
    } else {
      print('GLN Service: Error response: ${response.body}');
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to get GLN: ${response.reasonPhrase}',
        responseBody: response.body,
      );
    }
  }

  Future<GLN> getGLNByCode(String glnCode) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }    final response = await _client.get(
      Uri.parse('${_appConfig.apiBaseUrl}/master-data/glns/code/$glnCode'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return GLN.fromJson(json.decode(response.body));
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to get GLN by code: ${response.reasonPhrase}',
      );
    }
  }

  Future<GLN> createGLN(GLN gln) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }    final response = await _client.post(
      Uri.parse('${_appConfig.apiBaseUrl}/master-data/glns'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(gln.toJson()),
    );

    if (response.statusCode == 201) {
      return GLN.fromJson(json.decode(response.body));
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to create GLN: ${response.reasonPhrase}',
      );
    }
  }
  Future<GLN> updateGLN(String id, GLN gln) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }    final response = await _client.put(
      Uri.parse('${_appConfig.apiBaseUrl}/master-data/glns/code/$id'), // Changed to use the /code endpoint since id parameter is now glnCode
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(gln.toJson()),
    );

    if (response.statusCode == 200) {
      return GLN.fromJson(json.decode(response.body));
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to update GLN: ${response.reasonPhrase}',
      );
    }
  }
  Future<bool> deleteGLN(String id) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }    final response = await _client.delete(
      Uri.parse('${_appConfig.apiBaseUrl}/master-data/glns/code/$id'), // Changed to use the /code endpoint since id parameter is now glnCode
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    return response.statusCode == 204;
  }

  Future<List<GLN>> searchGLNs({
    String? searchTerm,
    String? locationType,
    bool? active,
    int? page,
    int? size,
  }) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    var queryParams = <String, String>{};
    if (searchTerm != null && searchTerm.isNotEmpty) {
      queryParams['search'] = searchTerm;
    }
    if (locationType != null && locationType.isNotEmpty) {
      queryParams['locationType'] = locationType;
    }
    if (active != null) {
      queryParams['active'] = active.toString();
    }
    if (page != null) {
      queryParams['page'] = page.toString();
    }
    if (size != null) {
      queryParams['size'] = size.toString();
    }    final uri = Uri.parse('${_appConfig.apiBaseUrl}/master-data/glns/search')
        .replace(queryParameters: queryParams);

    final response = await _client.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData.containsKey('content') && responseData['content'] is List) {
        final List<dynamic> data = responseData['content'];
        return data.map((json) => GLN.fromJson(json)).toList();
      } else {
        // Fallback in case the response structure changes or is not paginated
        if (responseData is List) {
          return (responseData as List).map((json) => GLN.fromJson(json)).toList();
        } else {
          throw ApiException(
            message: 'Unexpected response format: GLN data not found in search response',
            responseBody: response.body,
          );
        }
      }
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to search GLNs: ${response.reasonPhrase}',
      );
    }
  }

  Future<Map<String, dynamic>> searchGLNsAdvanced({
    String? search,
    String? glnCode,
    String? name,
    String? address,
    String? licenseNo,
    String? contactEmail,
    String? contactName,
    bool? active,
    String? locationType,
    int page = 0,
    int size = 20,
    String sortBy = 'name',
    String direction = 'ASC',
  }) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    var queryParams = <String, String>{
      'page': page.toString(),
      'size': size.toString(),
      'sortBy': sortBy,
      'direction': direction,
    };

    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }
    if (glnCode != null && glnCode.isNotEmpty) {
      queryParams['glnCode'] = glnCode;
    }
    if (name != null && name.isNotEmpty) {
      queryParams['name'] = name;
    }
    if (address != null && address.isNotEmpty) {
      queryParams['address'] = address;
    }
    if (licenseNo != null && licenseNo.isNotEmpty) {
      queryParams['licenseNo'] = licenseNo;
    }
    if (contactEmail != null && contactEmail.isNotEmpty) {
      queryParams['contactEmail'] = contactEmail;
    }
    if (contactName != null && contactName.isNotEmpty) {
      queryParams['contactName'] = contactName;
    }
    if (active != null) {
      queryParams['active'] = active.toString();
    }
    if (locationType != null && locationType.isNotEmpty) {
      queryParams['locationType'] = locationType;
    }

    final uri = Uri.parse('${_appConfig.apiBaseUrl}/master-data/glns/search/advanced')
        .replace(queryParameters: queryParams);

    final response = await _client.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to search GLNs: ${response.reasonPhrase}',
      );
    }
  }

  Future<List<GLN>> getExpiredLicenseGLNs() async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }    final response = await _client.get(
      Uri.parse('${_appConfig.apiBaseUrl}/master-data/glns/expired-licenses'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData is Map<String, dynamic> && responseData.containsKey('content') && responseData['content'] is List) {
        final List<dynamic> data = responseData['content'];
        return data.map((json) => GLN.fromJson(json)).toList();
      } else if (responseData is List) {
        return responseData.map((json) => GLN.fromJson(json)).toList();
      } else {
        throw ApiException(
          message: 'Unexpected response format: GLN data not found in expired licenses response',
          responseBody: response.body,
        );
      }
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to get GLNs with expired licenses: ${response.reasonPhrase}',
      );
    }
  }

  Future<List<GLN>> getChildGLNs(String parentGlnCode) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }    final response = await _client.get(
      Uri.parse('${_appConfig.apiBaseUrl}/master-data/glns/parent/$parentGlnCode/children'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData is Map<String, dynamic> && responseData.containsKey('content') && responseData['content'] is List) {
        final List<dynamic> data = responseData['content'];
        return data.map((json) => GLN.fromJson(json)).toList();
      } else if (responseData is List) {
        return responseData.map((json) => GLN.fromJson(json)).toList();
      } else {
        throw ApiException(
          message: 'Unexpected response format: GLN data not found in child GLNs response',
          responseBody: response.body,
        );
      }
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to get child GLNs: ${response.reasonPhrase}',
      );
    }
  }

  Future<bool> validateGLNCode(String glnCode) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }    final response = await _client.get(
      Uri.parse('${_appConfig.apiBaseUrl}/master-data/glns/validate/$glnCode'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data['valid'] as bool;
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to validate GLN code: ${response.reasonPhrase}',
      );
    }
  }
}
