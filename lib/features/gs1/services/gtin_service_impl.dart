import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:traqtrace_app/core/config/app_config.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/core/network/token_manager.dart';
import 'package:traqtrace_app/features/gs1/models/gtin_model.dart';
import 'package:traqtrace_app/features/gs1/services/gtin_service.dart';

/// Implementation of GTINService interface for managing GTINs (Global Trade Item Numbers)
class GTINServiceImpl implements GTINService {
  final http.Client _client;
  final TokenManager _tokenManager;
  final AppConfig _appConfig;

  /// Creates a new GTINServiceImpl instance
  GTINServiceImpl({
    required http.Client httpClient,
    required TokenManager tokenManager,
    required AppConfig appConfig,
  })  : _client = httpClient,
        _tokenManager = tokenManager,
        _appConfig = appConfig;  @override
  Future<GTIN> getGTIN(String gtinCode) async {    final token = await _tokenManager.getToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final response = await _client.get(
      Uri.parse('${_appConfig.apiBaseUrl}/master-data/gtins/code/$gtinCode'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    
    print('GTIN get response status: ${response.statusCode}, body: ${response.body}');

    if (response.statusCode == 200) {
      try {
        final jsonData = json.decode(response.body);
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
          responseBody: response.body,
        );
      }
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to load GTIN: ${response.reasonPhrase}',
        responseBody: response.body,
      );
    }
  }

  @override
  Future<List<GTIN>> getGTINs({
    String? search,
    String? manufacturer,
    String? status,
    int page = 0,
    int size = 20,
  }) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }
    
    final queryParams = <String, String>{
      'page': page.toString(),
      'size': size.toString(),
      if (search != null) 'search': search,
      if (manufacturer != null) 'manufacturer': manufacturer,
      if (status != null) 'status': status,
    };
    
    final uri = Uri.parse('${_appConfig.apiBaseUrl}/master-data/gtins')
        .replace(queryParameters: queryParams);
    
    final response = await _client.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    
    print('GTIN list response status: ${response.statusCode}, body: ${response.body}');
    
    if (response.statusCode == 200) {
      try {
        final data = json.decode(response.body);
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
          responseBody: response.body,
        );
      }
    } else if (response.statusCode == 403) {
      print('Authentication error: Token might be invalid or expired');
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Authentication failed: Please log in again',
        responseBody: response.body,
      );
    } else {
      print('GTIN list error: ${response.statusCode} - ${response.reasonPhrase}');
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to load GTINs: ${response.reasonPhrase}',
        responseBody: response.body,
      );
    }
  }

  @override
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
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }
    
    final queryParams = <String, String>{
      'page': page.toString(),
      'size': size.toString(),
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
    
    final uri = Uri.parse('${_appConfig.apiBaseUrl}/master-data/gtins/search')
        .replace(queryParameters: queryParams);
    
    print('DEBUG: Constructed URI: $uri');
    print('DEBUG: Query parameters: $queryParams');
    
    final response = await _client.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    
    print('GTIN advanced search response status: ${response.statusCode}, body: ${response.body}');
    
    if (response.statusCode == 200) {
      try {
        final data = json.decode(response.body);
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
          responseBody: response.body,
        );
      }
    } else if (response.statusCode == 403) {
      print('Authentication error: Token might be invalid or expired');
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Authentication failed: Please log in again',
        responseBody: response.body,
      );
    } else {
      print('GTIN advanced search error: ${response.statusCode} - ${response.reasonPhrase}');
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to search GTINs: ${response.reasonPhrase}',
        responseBody: response.body,
      );
    }
  }
  @override
  Future<GTIN> createGTIN(GTIN gtin) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }
    
    // Log the request payload for debugging
    final jsonPayload = gtin.toJson();
    print('Creating GTIN with payload: $jsonPayload');
    
    final response = await _client.post(
      Uri.parse('${_appConfig.apiBaseUrl}/master-data/gtins'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(jsonPayload),
    );

    if (response.statusCode == 201) {
      try {
        return GTIN.fromJson(json.decode(response.body));
      } catch (e) {
        print('Error parsing GTIN response: $e');
        throw ApiException(
          statusCode: response.statusCode,
          message: 'Error processing server response: $e',
          originalException: e,
          responseBody: response.body,
        );
      }
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to create GTIN: ${response.reasonPhrase}',
        responseBody: response.body,
      );
    }
  }
  @override
  Future<GTIN> updateGTIN(GTIN gtin) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }    final response = await _client.put(
      Uri.parse('${_appConfig.apiBaseUrl}/master-data/gtins/${gtin.gtinCode}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(gtin.toJson()),
    );

    if (response.statusCode == 200) {
      try {
        return GTIN.fromJson(json.decode(response.body));
      } catch (e) {
        print('Error parsing GTIN response: $e');
        throw ApiException(
          statusCode: response.statusCode,
          message: 'Error processing server response: $e',
          originalException: e,
          responseBody: response.body,
        );
      }
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to update GTIN: ${response.reasonPhrase}',
        responseBody: response.body,
      );
    }
  }
  @override
  Future<void> updateGTINStatus(String gtinCode, String status) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }    final response = await _client.put(
      Uri.parse('${_appConfig.apiBaseUrl}/master-data/gtins/$gtinCode/status'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'status': status}),
    );

    if (response.statusCode != 200) {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to update GTIN status: ${response.reasonPhrase}',
        responseBody: response.body,
      );
    }
  }

  @override
  Future<bool> validateGTIN(String gtinCode) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }    final uri = Uri.parse('${_appConfig.apiBaseUrl}/master-data/gtins/validate')
        .replace(queryParameters: {'gtinCode': gtinCode});
    
    final response = await _client.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );    if (response.statusCode == 200) {
      try {
        final data = json.decode(response.body);
        return data['isValid'] ?? false;
      } catch (e) {
        print('Error parsing validation response: $e');
        throw ApiException(
          statusCode: response.statusCode,
          message: 'Error processing validation response: $e',
          originalException: e,
          responseBody: response.body,
        );
      }
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to validate GTIN: ${response.reasonPhrase}',
        responseBody: response.body,
      );
    }
  }
}