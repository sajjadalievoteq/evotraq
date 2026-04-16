import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';
import 'package:traqtrace_app/features/gs1/models/gln_model.dart';

/// Implementation of GLNService interface for managing GLNs (Global Location Numbers)
class GLNService {
  final DioService _dioService;

  /// Creates a new GLNServiceImpl instance
  GLNService({
    required DioService dioService,
  }) : _dioService = dioService;

  Future<List<GLN>> getAllGLNs({int? page, int? size}) async {
    final token = await _dioService.getAuthToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    String url = '${_dioService.baseUrl}/master-data/glns';
    if (page != null && size != null) {
      url += '?page=$page&size=$size';
    }

    final response = await _dioService.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );
    print('GLN list response status: ${response.statusCode}, body: ${response.data}');
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.data);
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
            responseBody: response.data,
          );
        }
      }
    } else if (response.statusCode == 403) {
      print('Authentication error: Token might be invalid or expired');
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Authentication failed: Please log in again',
        responseBody: response.data,
      );
    } else {
      print('GLN list error: ${response.statusCode} - ${response.statusMessage}');
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to load GLNs: ${response.statusMessage}',
        responseBody: response.data,
      );
    }
  }

  Future<GLN> getGLNById(String id) async {
    final token = await _dioService.getAuthToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    print('GLN Service: Fetching GLN with ID: $id');
    final url = '${_dioService.baseUrl}/master-data/glns/code/$id';
    print('GLN Service: Request URL: $url');

    final response = await _dioService.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    print('GLN Service: Response status code: ${response.statusCode}');

    if (response.statusCode == 200) {
      print('GLN Service: Raw API Response: ${response.data}');
      final jsonData = json.decode(response.data);
      print('GLN Service: Decoded API Response: $jsonData');
      final gln = GLN.fromJson(jsonData);
      print('GLN Service: Converted to GLN object: ${gln.glnCode}, ${gln.locationName}');
      return gln;
    } else {
      print('GLN Service: Error response: ${response.data}');
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to get GLN: ${response.statusMessage}',
        responseBody: response.data,
      );
    }
  }

  Future<GLN> getGLNByCode(String glnCode) async {
    final token = await _dioService.getAuthToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final response = await _dioService.get(
      '${_dioService.baseUrl}/master-data/glns/code/$glnCode',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return GLN.fromJson(json.decode(response.data));
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to get GLN by code: ${response.statusMessage}',
      );
    }
  }

  Future<GLN> createGLN(GLN gln) async {
    final token = await _dioService.getAuthToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final response = await _dioService.post(
      '${_dioService.baseUrl}/master-data/glns',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      data: json.encode(gln.toJson()),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 201) {
      return GLN.fromJson(json.decode(response.data));
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to create GLN: ${response.statusMessage}',
      );
    }
  }
  Future<GLN> updateGLN(String id, GLN gln) async {
    final token = await _dioService.getAuthToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final response = await _dioService.put(
      '${_dioService.baseUrl}/master-data/glns/code/$id',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      data: json.encode(gln.toJson()),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return GLN.fromJson(json.decode(response.data));
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to update GLN: ${response.statusMessage}',
      );
    }
  }
  Future<bool> deleteGLN(String id) async {
    final token = await _dioService.getAuthToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final response = await _dioService.delete(
      '${_dioService.baseUrl}/master-data/glns/code/$id',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
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
    final token = await _dioService.getAuthToken();
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
    }

    final response = await _dioService.get(
      '${_dioService.baseUrl}/master-data/glns/search',
      queryParameters: queryParams,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.data);
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
            responseBody: response.data,
          );
        }
      }
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to search GLNs: ${response.statusMessage}',
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
    final token = await _dioService.getAuthToken();
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

    final response = await _dioService.get(
      '${_dioService.baseUrl}/master-data/glns/search/advanced',
      queryParameters: queryParams,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return json.decode(response.data);
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to search GLNs: ${response.statusMessage}',
      );
    }
  }

  Future<List<GLN>> getExpiredLicenseGLNs() async {
    final token = await _dioService.getAuthToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }
    final response = await _dioService.get(
      '${_dioService.baseUrl}/master-data/glns/expired-licenses',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );
    if (response.statusCode == 200) {
      final responseData = json.decode(response.data);
      if (responseData is Map<String, dynamic> && responseData.containsKey('content') && responseData['content'] is List) {
        final List<dynamic> data = responseData['content'];
        return data.map((json) => GLN.fromJson(json)).toList();
      } else if (responseData is List) {
        return responseData.map((json) => GLN.fromJson(json)).toList();
      } else {
        throw ApiException(
          message: 'Unexpected response format: GLN data not found in expired licenses response',
          responseBody: response.data,
        );
      }
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to get GLNs with expired licenses: ${response.statusMessage}',
      );
    }
  }

  Future<List<GLN>> getChildGLNs(String parentGlnCode) async {
    final token = await _dioService.getAuthToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }
    final response = await _dioService.get(
      '${_dioService.baseUrl}/master-data/glns/parent/$parentGlnCode/children',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );
    if (response.statusCode == 200) {
      final responseData = json.decode(response.data);
      if (responseData is Map<String, dynamic> && responseData.containsKey('content') && responseData['content'] is List) {
        final List<dynamic> data = responseData['content'];
        return data.map((json) => GLN.fromJson(json)).toList();
      } else if (responseData is List) {
        return responseData.map((json) => GLN.fromJson(json)).toList();
      } else {
        throw ApiException(
          message: 'Unexpected response format: GLN data not found in child GLNs response',
          responseBody: response.data,
        );
      }
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to get child GLNs: ${response.statusMessage}',
      );
    }
  }

  Future<bool> validateGLNCode(String glnCode) async {
    final token = await _dioService.getAuthToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }
    final response = await _dioService.get(
      '${_dioService.baseUrl}/master-data/glns/validate/$glnCode',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.data);
      return data['valid'] as bool;
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to validate GLN code: ${response.statusMessage}',
      );
    }
  }
}
