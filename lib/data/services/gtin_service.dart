import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:traqtrace_app/core/network/http_service.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/features/gs1/models/gtin_model.dart';

/// Implementation of GTINService interface for managing GTINs (Global Trade Item Numbers)
class GTINService {
  final HttpService _httpService;

  /// Creates a new GTINServiceImpl instance
  GTINService({
    required HttpService httpService,
  }) : _httpService = httpService;

  Future<GTIN> getGTIN(String gtinCode) async {
    final token = await _httpService.getAuthToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final response = await _httpService.get(
      '${_httpService.baseUrl}/master-data/gtins/code/$gtinCode',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    print('GTIN get response status: ${response.statusCode}, body: ${response.data}');

    if (response.statusCode == 200) {
      try {
        final jsonData = json.decode(response.data);
        print('Parsed GTIN JSON: $jsonData');
        final gtin = GTIN.fromJson(jsonData);
        print('Created GTIN object: $gtin with expirationDate: ${gtin.expirationDate}');
        return gtin;
      } catch (e) {
        print('Error parsing GTIN response: $e');
        throw ApiException(
          statusCode: response.statusCode,
          message: 'Error processing server response: $e',
          originalException: e,
          responseBody: response.data,
        );
      }
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to load GTIN: ${response.statusMessage}',
        responseBody: response.data,
      );
    }
  }

  Future<List<GTIN>> getGTINs({
    String? search,
    String? manufacturer,
    String? status,
    int page = 0,
    int size = 20,
  }) async {
    final token = await _httpService.getAuthToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final queryParams = <String, dynamic>{
      'page': page,
      'size': size,
      if (search != null) 'search': search,
      if (manufacturer != null) 'manufacturer': manufacturer,
      if (status != null) 'status': status,
    };

    final response = await _httpService.get(
      '${_httpService.baseUrl}/master-data/gtins',
      queryParameters: queryParams,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    print('GTIN list response status: ${response.statusCode}, body: ${response.data}');

    if (response.statusCode == 200) {
      try {
        final data = json.decode(response.data);
        if (data['content'] != null) {
          return (data['content'] as List)
              .map((item) => GTIN.fromJson(item))
              .toList();
        }
        return [];
      } catch (e) {
        print('Error parsing GTINs response: $e');
        throw ApiException(
          statusCode: response.statusCode,
          message: 'Error processing server response: $e',
          originalException: e,
          responseBody: response.data,
        );
      }
    } else if (response.statusCode == 403) {
      print('Authentication error: Token might be invalid or expired');
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Authentication failed: Please log in again',
        responseBody: response.data,
      );
    } else {
      print('GTIN list error: ${response.statusCode} - ${response.statusMessage}');
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to load GTINs: ${response.statusMessage}',
        responseBody: response.data,
      );
    }
  }

  Future<Map<String, dynamic>> searchGTINsAdvanced({
    String? search,
    String? productName,
    String? gtinCode,
    String? manufacturer,
    String? status,
    String? packagingLevel,
    String? registrationDateFrom,
    String? registrationDateTo,
    int page = 0,
    int size = 20,
    String sortBy = 'productName',
    String direction = 'ASC',
  }) async {
    final token = await _httpService.getAuthToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final queryParams = <String, dynamic>{
      'page': page,
      'size': size,
      'sortBy': sortBy,
      'direction': direction,
      if (search != null && search.isNotEmpty) 'search': search,
      if (productName != null && productName.isNotEmpty) 'productName': productName,
      if (gtinCode != null && gtinCode.isNotEmpty) 'gtinCode': gtinCode,
      if (manufacturer != null && manufacturer.isNotEmpty) 'manufacturer': manufacturer,
      if (status != null && status.isNotEmpty && status != 'All') 'status': status,
      if (packagingLevel != null && packagingLevel.isNotEmpty && packagingLevel != 'All') 'packagingLevel': packagingLevel,
      if (registrationDateFrom != null && registrationDateFrom.isNotEmpty) 'registrationDateFrom': registrationDateFrom,
      if (registrationDateTo != null && registrationDateTo.isNotEmpty) 'registrationDateTo': registrationDateTo,
    };

    final uri = Uri.parse('${_httpService.baseUrl}/master-data/gtins/search')
        .replace(queryParameters: queryParams.map((k, v) => MapEntry(k, '$v')));

    print('DEBUG: Constructed URI: $uri');
    print('DEBUG: Query parameters: $queryParams');

    final response = await _httpService.get(
      '${_httpService.baseUrl}/master-data/gtins/search',
      queryParameters: queryParams,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    print('GTIN advanced search response status: ${response.statusCode}, body: ${response.data}');

    if (response.statusCode == 200) {
      try {
        final data = json.decode(response.data);
        final gtins = (data['content'] as List?)
            ?.map((item) => GTIN.fromJson(item))
            .toList() ?? [];

        return {
          'gtins': gtins,
          'totalElements': data['totalElements'] ?? 0,
          'totalPages': data['totalPages'] ?? 0,
          'currentPage': data['number'] ?? 0,
          'pageSize': data['size'] ?? size,
          'hasMoreData': !(data['last'] ?? true),
        };
      } catch (e) {
        print('Error parsing GTINs advanced search response: $e');
        throw ApiException(
          statusCode: response.statusCode,
          message: 'Error processing server response: $e',
          originalException: e,
          responseBody: response.data,
        );
      }
    } else if (response.statusCode == 403) {
      print('Authentication error: Token might be invalid or expired');
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Authentication failed: Please log in again',
        responseBody: response.data,
      );
    } else {
      print('GTIN advanced search error: ${response.statusCode} - ${response.statusMessage}');
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to search GTINs: ${response.statusMessage}',
        responseBody: response.data,
      );
    }
  }
  Future<GTIN> createGTIN(GTIN gtin) async {
    final token = await _httpService.getAuthToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    // Log the request payload for debugging
    final jsonPayload = gtin.toJson();
    print('Creating GTIN with payload: $jsonPayload');

    final response = await _httpService.post(
      '${_httpService.baseUrl}/master-data/gtins',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      data: json.encode(jsonPayload),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 201) {
      try {
        return GTIN.fromJson(json.decode(response.data));
      } catch (e) {
        print('Error parsing GTIN response: $e');
        throw ApiException(
          statusCode: response.statusCode,
          message: 'Error processing server response: $e',
          originalException: e,
          responseBody: response.data,
        );
      }
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to create GTIN: ${response.statusMessage}',
        responseBody: response.data,
      );
    }
  }
  Future<GTIN> updateGTIN(GTIN gtin) async {
    final token = await _httpService.getAuthToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final response = await _httpService.put(
      '${_httpService.baseUrl}/master-data/gtins/${gtin.gtinCode}',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      data: json.encode(gtin.toJson()),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      try {
        return GTIN.fromJson(json.decode(response.data));
      } catch (e) {
        print('Error parsing GTIN response: $e');
        throw ApiException(
          statusCode: response.statusCode,
          message: 'Error processing server response: $e',
          originalException: e,
          responseBody: response.data,
        );
      }
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to update GTIN: ${response.statusMessage}',
        responseBody: response.data,
      );
    }
  }
  Future<void> updateGTINStatus(String gtinCode, String status) async {
    final token = await _httpService.getAuthToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final response = await _httpService.put(
      '${_httpService.baseUrl}/master-data/gtins/$gtinCode/status',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      data: json.encode({'status': status}),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode != 200) {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to update GTIN status: ${response.statusMessage}',
        responseBody: response.data,
      );
    }
  }

  Future<bool> validateGTIN(String gtinCode) async {
    final token = await _httpService.getAuthToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final response = await _httpService.get(
      '${_httpService.baseUrl}/master-data/gtins/validate',
      queryParameters: {'gtinCode': gtinCode},
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      try {
        final data = json.decode(response.data);
        return data['isValid'] ?? false;
      } catch (e) {
        print('Error parsing validation response: $e');
        throw ApiException(
          statusCode: response.statusCode,
          message: 'Error processing validation response: $e',
          originalException: e,
          responseBody: response.data,
        );
      }
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to validate GTIN: ${response.statusMessage}',
        responseBody: response.data,
      );
    }
  }
}
