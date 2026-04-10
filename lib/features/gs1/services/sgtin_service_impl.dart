import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:traqtrace_app/core/config/app_config.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/core/network/token_manager.dart';
import 'package:traqtrace_app/features/gs1/models/sgtin_model.dart';
import 'package:traqtrace_app/features/gs1/services/sgtin_service.dart';

/// Implementation of SGTINService interface for managing SGTINs
class SGTINServiceImpl implements SGTINService {
  final http.Client _client;
  final TokenManager _tokenManager;
  final AppConfig _appConfig;

  /// Creates a new SGTINServiceImpl instance
  SGTINServiceImpl({
    required http.Client httpClient,
    required TokenManager tokenManager,
    required AppConfig appConfig,
  })  : _client = httpClient,
        _tokenManager = tokenManager,
        _appConfig = appConfig;
  @override
  Future<SGTIN> getSGTINById(String id) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final response = await _client.get(
      Uri.parse('${_appConfig.apiBaseUrl}/identifiers/sgtins/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return SGTIN.fromJson(json.decode(response.body));
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to load SGTIN: ${response.reasonPhrase}',
      );
    }
  }

  @override
  Future<SGTIN> getSGTINBySerialNumber(String serialNumber) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final response = await _client.get(
      Uri.parse('${_appConfig.apiBaseUrl}/identifiers/sgtins/serial/$serialNumber'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return SGTIN.fromJson(json.decode(response.body));
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to load SGTIN by serial number: ${response.reasonPhrase}',
      );
    }
  }

  @override
  Future<List<SGTIN>> getAllSGTINs({int page = 0, int size = 20}) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final queryParams = <String, String>{
      'page': page.toString(),
      'size': size.toString(),
    };

    final uri = Uri.parse('${_appConfig.apiBaseUrl}/identifiers/sgtins')
        .replace(queryParameters: queryParams);

    final response = await _client.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['content'] != null) {
        return (data['content'] as List)
            .map((item) => SGTIN.fromJson(item))
            .toList();
      }
      return [];
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to load SGTINs: ${response.reasonPhrase}',
      );
    }
  }

  @override
  Future<SGTIN> createSGTIN(SGTIN sgtin) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final jsonData = sgtin.toJson();
    print('Creating SGTIN with JSON: $jsonData');
    print('currentLocation in SGTIN object: ${sgtin.currentLocation}');
    print('currentLocation GLN code: ${sgtin.currentLocation?.glnCode}');

    final response = await _client.post(
      Uri.parse('${_appConfig.apiBaseUrl}/identifiers/sgtins'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(jsonData),
    );    if (response.statusCode == 201) {
      return SGTIN.fromJson(json.decode(response.body));
    } else {
      // Try to parse the error response if it's in JSON format
      Map<String, dynamic>? errorBody;
      try {
        errorBody = json.decode(response.body) as Map<String, dynamic>;
      } catch (_) {
        // If we can't parse the response as JSON, use the default error handling
      }

      // Check for specific error conditions
      if (response.statusCode == 404 && errorBody != null &&
          errorBody['message']?.toString().contains('GTIN not found') == true) {
        throw ApiException(
          statusCode: response.statusCode,
          message: 'GTIN code not found in the system. Please use a valid GTIN.',
        );
      } else if (response.statusCode == 409) {
        throw ApiException(
          statusCode: response.statusCode,
          message: 'Serial number already exists. Please use a different serial number.',
        );
      } else if (response.statusCode == 400 && errorBody != null) {
        throw ApiException(
          statusCode: response.statusCode,
          message: errorBody['message'] ?? 'Invalid SGTIN data. Please check all fields.',
        );
      } else {
        throw ApiException(
          statusCode: response.statusCode,
          message: errorBody?['message'] ?? 'Failed to create SGTIN: ${response.reasonPhrase}',
        );
      }
    }
  }

  @override
  Future<SGTIN> updateSGTIN(String id, SGTIN sgtin) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final response = await _client.put(
      Uri.parse('${_appConfig.apiBaseUrl}/identifiers/sgtins/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(sgtin.toJson()),
    );

    if (response.statusCode == 200) {
      return SGTIN.fromJson(json.decode(response.body));
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to update SGTIN: ${response.reasonPhrase}',
      );
    }
  }

  @override
  Future<void> deleteSGTIN(String id) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final response = await _client.delete(
      Uri.parse('${_appConfig.apiBaseUrl}/identifiers/sgtins/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 204) {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to delete SGTIN: ${response.reasonPhrase}',
      );
    }
  }

  @override
  Future<List<SGTIN>> findSGTINsByGTIN(String gtinCode) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final response = await _client.get(
      Uri.parse('${_appConfig.apiBaseUrl}/identifiers/sgtins/gtin/$gtinCode'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return (json.decode(response.body) as List)
          .map((item) => SGTIN.fromJson(item))
          .toList();
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to find SGTINs by GTIN: ${response.reasonPhrase}',
      );
    }
  }

  @override
  Future<List<SGTIN>> findSGTINsByBatchLotNumber(String batchLotNumber) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final queryParams = <String, String>{
      'batchLotNumber': batchLotNumber,
    };

    final uri = Uri.parse('${_appConfig.apiBaseUrl}/identifiers/sgtins/batch')
        .replace(queryParameters: queryParams);

    final response = await _client.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return (json.decode(response.body) as List)
          .map((item) => SGTIN.fromJson(item))
          .toList();
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to find SGTINs by batch/lot: ${response.reasonPhrase}',
      );
    }
  }

  @override
  Future<List<SGTIN>> findSGTINsByStatus(ItemStatus status) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final queryParams = <String, String>{
      'status': status.name,
    };

    final uri = Uri.parse('${_appConfig.apiBaseUrl}/identifiers/sgtins/status')
        .replace(queryParameters: queryParams);

    final response = await _client.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return (json.decode(response.body) as List)
          .map((item) => SGTIN.fromJson(item))
          .toList();
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to find SGTINs by status: ${response.reasonPhrase}',
      );
    }
  }

  @override
  Future<List<SGTIN>> findSGTINsByLocation(String glnCode) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final response = await _client.get(
      Uri.parse('${_appConfig.apiBaseUrl}/identifiers/sgtins/location/$glnCode'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return (json.decode(response.body) as List)
          .map((item) => SGTIN.fromJson(item))
          .toList();
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to find SGTINs by location: ${response.reasonPhrase}',
      );
    }
  }

  @override
  Future<List<SGTIN>> findSGTINsBySSCC(String ssccCode) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final response = await _client.get(
      Uri.parse('${_appConfig.apiBaseUrl}/identifiers/sgtins/sscc/$ssccCode'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return (json.decode(response.body) as List)
          .map((item) => SGTIN.fromJson(item))
          .toList();
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to find SGTINs by SSCC: ${response.reasonPhrase}',
      );
    }
  }

  @override
  Future<List<SGTIN>> findSGTINsExpiringBefore(DateTime date) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final dateStr = DateFormat('yyyy-MM-dd').format(date);

    final queryParams = <String, String>{
      'date': dateStr,
    };

    final uri = Uri.parse('${_appConfig.apiBaseUrl}/identifiers/sgtins/expiring')
        .replace(queryParameters: queryParams);

    final response = await _client.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return (json.decode(response.body) as List)
          .map((item) => SGTIN.fromJson(item))
          .toList();
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to find expiring SGTINs: ${response.reasonPhrase}',
      );
    }
  }

  @override
  Future<List<SGTIN>> findSGTINsByRegulatoryMarket(String regulatoryMarket) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final queryParams = <String, String>{
      'market': regulatoryMarket,
    };

    final uri = Uri.parse('${_appConfig.apiBaseUrl}/identifiers/sgtins/market')
        .replace(queryParameters: queryParams);

    final response = await _client.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return (json.decode(response.body) as List)
          .map((item) => SGTIN.fromJson(item))
          .toList();
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to find SGTINs by market: ${response.reasonPhrase}',
      );
    }
  }

  @override
  Future<List<SGTIN>> searchSGTINs({
    int? gtinId,
    String? batchLotNumber,
    ItemStatus? status,
    int? locationId,
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
      if (gtinId != null) 'gtinId': gtinId.toString(),
      if (batchLotNumber != null) 'batchLotNumber': batchLotNumber,
      if (status != null) 'status': status.name,
      if (locationId != null) 'locationId': locationId.toString(),
    };

    final uri = Uri.parse('${_appConfig.apiBaseUrl}/identifiers/sgtins/search')
        .replace(queryParameters: queryParams);

    final response = await _client.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['content'] != null) {
        return (data['content'] as List)
            .map((item) => SGTIN.fromJson(item))
            .toList();
      }
      return [];
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to search SGTINs: ${response.reasonPhrase}',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> searchSGTINsAdvanced({
    String? gtinCode,
    String? serialNumber,
    String? batchLotNumber,
    ItemStatus? status,
    String? locationName,
    int page = 0,
    int size = 20,
    String sortBy = 'createdAt',
    String sortDirection = 'DESC',
  }) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final queryParams = <String, String>{
      'page': page.toString(),
      'size': size.toString(),
      'sortBy': sortBy,
      'direction': sortDirection,
      if (gtinCode != null && gtinCode.isNotEmpty) 'gtinCode': gtinCode,
      if (serialNumber != null && serialNumber.isNotEmpty) 'serialNumber': serialNumber,
      if (batchLotNumber != null && batchLotNumber.isNotEmpty) 'batchLotNumber': batchLotNumber,
      if (status != null) 'status': status.name,
      if (locationName != null && locationName.isNotEmpty) 'locationName': locationName,
    };

    final uri = Uri.parse('${_appConfig.apiBaseUrl}/identifiers/sgtins/search/advanced')
        .replace(queryParameters: queryParams);

    final response = await _client.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {
        'content': (data['content'] as List?)
            ?.map((item) => SGTIN.fromJson(item))
            .toList() ?? [],
        'totalElements': data['totalElements'] ?? 0,
        'totalPages': data['totalPages'] ?? 0,
        'number': data['number'] ?? 0,
        'size': data['size'] ?? size,
        'first': data['first'] ?? true,
        'last': data['last'] ?? true,
      };
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to search SGTINs: ${response.reasonPhrase}',
      );
    }
  }

  @override
  Future<SGTIN> updateSGTINStatus(String serialNumber, ItemStatus newStatus) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final response = await _client.put(
      Uri.parse('${_appConfig.apiBaseUrl}/identifiers/sgtins/$serialNumber/status'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'status': newStatus.name}),
    );

    if (response.statusCode == 200) {
      return SGTIN.fromJson(json.decode(response.body));
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to update SGTIN status: ${response.reasonPhrase}',
      );
    }
  }

  @override
  Future<SGTIN> assignSGTINToLocation(String serialNumber, String glnCode) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final response = await _client.put(
      Uri.parse('${_appConfig.apiBaseUrl}/identifiers/sgtins/$serialNumber/location'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'glnCode': glnCode}),
    );

    if (response.statusCode == 200) {
      return SGTIN.fromJson(json.decode(response.body));
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to assign SGTIN to location: ${response.reasonPhrase}',
      );
    }
  }

  @override
  Future<SGTIN> packSGTINIntoSSCC(String serialNumber, String ssccCode) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final response = await _client.put(
      Uri.parse('${_appConfig.apiBaseUrl}/identifiers/sgtins/$serialNumber/pack'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'ssccCode': ssccCode}),
    );

    if (response.statusCode == 200) {
      return SGTIN.fromJson(json.decode(response.body));
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to pack SGTIN: ${response.reasonPhrase}',
      );
    }
  }

  @override
  Future<String> generateSerialNumber(String gtinCode, {bool randomized = true}) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final queryParams = <String, String>{
      'randomized': randomized.toString(),
    };

    final uri = Uri.parse('${_appConfig.apiBaseUrl}/identifiers/sgtins/generate-serial/$gtinCode')
        .replace(queryParameters: queryParams);

    final response = await _client.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['serialNumber'] ?? '';
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to generate serial number: ${response.reasonPhrase}',
      );
    }
  }

  @override
  Future<bool> validateSGTIN(String gtinCode, String serialNumber) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final response = await _client.post(
      Uri.parse('${_appConfig.apiBaseUrl}/identifiers/sgtins/validate'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'gtinCode': gtinCode,
        'serialNumber': serialNumber,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['valid'] ?? false;
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to validate SGTIN: ${response.reasonPhrase}',
      );
    }
  }

  @override
  Future<int> countSGTINsByGTINAndStatus(String gtinCode, ItemStatus status) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final queryParams = <String, String>{
      'status': status.name,
    };

    final uri = Uri.parse('${_appConfig.apiBaseUrl}/identifiers/sgtins/count/$gtinCode')
        .replace(queryParameters: queryParams);

    final response = await _client.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['count'] ?? 0;
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to count SGTINs: ${response.reasonPhrase}',
      );
    }
  }

  @override
  Future<List<SGTIN>> commissionMultipleSGTINs({
    required String gtinCode,
    required int quantity,
    required String batchLotNumber,
    required DateTime expiryDate,
    String? currentLocation,
  }) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final expiryDateStr = DateFormat('yyyy-MM-dd').format(expiryDate);

    final response = await _client.post(
      Uri.parse('${_appConfig.apiBaseUrl}/identifiers/sgtins/commission-multiple'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'gtinCode': gtinCode,
        'quantity': quantity,
        'batchLotNumber': batchLotNumber,
        'expiryDate': expiryDateStr,
        if (currentLocation != null) 'currentLocation': currentLocation,
      }),
    );

    if (response.statusCode == 201) {
      return (json.decode(response.body) as List)
          .map((item) => SGTIN.fromJson(item))
          .toList();
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to commission SGTINs: ${response.reasonPhrase}',
      );
    }
  }

  @override
  Future<SGTIN> decommissionSGTIN(String serialNumber, String reason) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final response = await _client.put(
      Uri.parse('${_appConfig.apiBaseUrl}/identifiers/sgtins/$serialNumber/decommission'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'reason': reason}),
    );

    if (response.statusCode == 200) {
      return SGTIN.fromJson(json.decode(response.body));
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to decommission SGTIN: ${response.reasonPhrase}',
      );
    }
  }
}