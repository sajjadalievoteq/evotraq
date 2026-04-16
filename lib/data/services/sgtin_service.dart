import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';
import 'package:traqtrace_app/features/gs1/models/sgtin_model.dart';

/// Implementation of SGTINService interface for managing SGTINs
class SGTINService {
  final DioService _dioService;

  /// Creates a new SGTINServiceImpl instance
  SGTINService({required DioService dioService}) : _dioService = dioService;

  Future<SGTIN> getSGTINById(String id) async {
    final token = await _dioService.getAuthToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final response = await _dioService.get(
      '${_dioService.baseUrl}/identifiers/sgtins/$id',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return SGTIN.fromJson(json.decode(response.data));
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to load SGTIN: ${response.statusMessage}',
      );
    }
  }

  Future<SGTIN> getSGTINBySerialNumber(String serialNumber) async {
    final token = await _dioService.getAuthToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final response = await _dioService.get(
      '${_dioService.baseUrl}/identifiers/sgtins/serial/$serialNumber',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return SGTIN.fromJson(json.decode(response.data));
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message:
            'Failed to load SGTIN by serial number: ${response.statusMessage}',
      );
    }
  }

  Future<List<SGTIN>> getAllSGTINs({int page = 0, int size = 20}) async {
    final token = await _dioService.getAuthToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final queryParams = <String, dynamic>{'page': page, 'size': size};

    final response = await _dioService.get(
      '${_dioService.baseUrl}/identifiers/sgtins',
      queryParameters: queryParams,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.data);
      if (data['content'] != null) {
        return (data['content'] as List)
            .map((item) => SGTIN.fromJson(item))
            .toList();
      }
      return [];
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to load SGTINs: ${response.statusMessage}',
      );
    }
  }

  Future<SGTIN> createSGTIN(SGTIN sgtin) async {
    final token = await _dioService.getAuthToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final jsonData = sgtin.toJson();
    print('Creating SGTIN with JSON: $jsonData');
    print('currentLocation in SGTIN object: ${sgtin.currentLocation}');
    print('currentLocation GLN code: ${sgtin.currentLocation?.glnCode}');

    final response = await _dioService.post(
      '${_dioService.baseUrl}/identifiers/sgtins',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      data: json.encode(jsonData),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );
    if (response.statusCode == 201) {
      return SGTIN.fromJson(json.decode(response.data));
    } else {
      // Try to parse the error response if it's in JSON format
      Map<String, dynamic>? errorBody;
      try {
        errorBody = json.decode(response.data) as Map<String, dynamic>;
      } catch (_) {
        // If we can't parse the response as JSON, use the default error handling
      }

      // Check for specific error conditions
      if (response.statusCode == 404 &&
          errorBody != null &&
          errorBody['message']?.toString().contains('GTIN not found') == true) {
        throw ApiException(
          statusCode: response.statusCode,
          message:
              'GTIN code not found in the system. Please use a valid GTIN.',
        );
      } else if (response.statusCode == 409) {
        throw ApiException(
          statusCode: response.statusCode,
          message:
              'Serial number already exists. Please use a different serial number.',
        );
      } else if (response.statusCode == 400 && errorBody != null) {
        throw ApiException(
          statusCode: response.statusCode,
          message:
              errorBody['message'] ??
              'Invalid SGTIN data. Please check all fields.',
        );
      } else {
        throw ApiException(
          statusCode: response.statusCode,
          message:
              errorBody?['message'] ??
              'Failed to create SGTIN: ${response.statusMessage}',
        );
      }
    }
  }

  Future<SGTIN> updateSGTIN(String id, SGTIN sgtin) async {
    final token = await _dioService.getAuthToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final response = await _dioService.put(
      '${_dioService.baseUrl}/identifiers/sgtins/$id',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      data: json.encode(sgtin.toJson()),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return SGTIN.fromJson(json.decode(response.data));
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to update SGTIN: ${response.statusMessage}',
      );
    }
  }

  Future<void> deleteSGTIN(String id) async {
    final token = await _dioService.getAuthToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final response = await _dioService.delete(
      '${_dioService.baseUrl}/identifiers/sgtins/$id',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode != 204) {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to delete SGTIN: ${response.statusMessage}',
      );
    }
  }

  Future<List<SGTIN>> findSGTINsByGTIN(String gtinCode) async {
    final token = await _dioService.getAuthToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final response = await _dioService.get(
      '${_dioService.baseUrl}/identifiers/sgtins/gtin/$gtinCode',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return (json.decode(response.data) as List)
          .map((item) => SGTIN.fromJson(item))
          .toList();
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to find SGTINs by GTIN: ${response.statusMessage}',
      );
    }
  }

  Future<List<SGTIN>> findSGTINsByBatchLotNumber(String batchLotNumber) async {
    final token = await _dioService.getAuthToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final queryParams = <String, dynamic>{'batchLotNumber': batchLotNumber};

    final response = await _dioService.get(
      '${_dioService.baseUrl}/identifiers/sgtins/batch',
      queryParameters: queryParams,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return (json.decode(response.data) as List)
          .map((item) => SGTIN.fromJson(item))
          .toList();
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message:
            'Failed to find SGTINs by batch/lot: ${response.statusMessage}',
      );
    }
  }

  Future<List<SGTIN>> findSGTINsByStatus(ItemStatus status) async {
    final token = await _dioService.getAuthToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final queryParams = <String, dynamic>{'status': status.name};

    final response = await _dioService.get(
      '${_dioService.baseUrl}/identifiers/sgtins/status',
      queryParameters: queryParams,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return (json.decode(response.data) as List)
          .map((item) => SGTIN.fromJson(item))
          .toList();
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to find SGTINs by status: ${response.statusMessage}',
      );
    }
  }

  Future<List<SGTIN>> findSGTINsByLocation(String glnCode) async {
    final token = await _dioService.getAuthToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final response = await _dioService.get(
      '${_dioService.baseUrl}/identifiers/sgtins/location/$glnCode',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return (json.decode(response.data) as List)
          .map((item) => SGTIN.fromJson(item))
          .toList();
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to find SGTINs by location: ${response.statusMessage}',
      );
    }
  }

  Future<List<SGTIN>> findSGTINsBySSCC(String ssccCode) async {
    final token = await _dioService.getAuthToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final response = await _dioService.get(
      '${_dioService.baseUrl}/identifiers/sgtins/sscc/$ssccCode',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return (json.decode(response.data) as List)
          .map((item) => SGTIN.fromJson(item))
          .toList();
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to find SGTINs by SSCC: ${response.statusMessage}',
      );
    }
  }

  Future<List<SGTIN>> findSGTINsExpiringBefore(DateTime date) async {
    final token = await _dioService.getAuthToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final dateStr = DateFormat('yyyy-MM-dd').format(date);

    final queryParams = <String, dynamic>{'date': dateStr};

    final response = await _dioService.get(
      '${_dioService.baseUrl}/identifiers/sgtins/expiring',
      queryParameters: queryParams,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return (json.decode(response.data) as List)
          .map((item) => SGTIN.fromJson(item))
          .toList();
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to find expiring SGTINs: ${response.statusMessage}',
      );
    }
  }

  Future<List<SGTIN>> findSGTINsByRegulatoryMarket(
    String regulatoryMarket,
  ) async {
    final token = await _dioService.getAuthToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final queryParams = <String, dynamic>{'market': regulatoryMarket};

    final response = await _dioService.get(
      '${_dioService.baseUrl}/identifiers/sgtins/market',
      queryParameters: queryParams,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return (json.decode(response.data) as List)
          .map((item) => SGTIN.fromJson(item))
          .toList();
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to find SGTINs by market: ${response.statusMessage}',
      );
    }
  }

  Future<List<SGTIN>> searchSGTINs({
    int? gtinId,
    String? batchLotNumber,
    ItemStatus? status,
    int? locationId,
    int page = 0,
    int size = 20,
  }) async {
    final token = await _dioService.getAuthToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final queryParams = <String, dynamic>{
      'page': page,
      'size': size,
      if (gtinId != null) 'gtinId': gtinId,
      if (batchLotNumber != null) 'batchLotNumber': batchLotNumber,
      if (status != null) 'status': status.name,
      if (locationId != null) 'locationId': locationId,
    };

    final response = await _dioService.get(
      '${_dioService.baseUrl}/identifiers/sgtins/search',
      queryParameters: queryParams,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.data);
      if (data['content'] != null) {
        return (data['content'] as List)
            .map((item) => SGTIN.fromJson(item))
            .toList();
      }
      return [];
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to search SGTINs: ${response.statusMessage}',
      );
    }
  }

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
    final token = await _dioService.getAuthToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final queryParams = <String, dynamic>{
      'page': page,
      'size': size,
      'sortBy': sortBy,
      'direction': sortDirection,
      if (gtinCode != null && gtinCode.isNotEmpty) 'gtinCode': gtinCode,
      if (serialNumber != null && serialNumber.isNotEmpty)
        'serialNumber': serialNumber,
      if (batchLotNumber != null && batchLotNumber.isNotEmpty)
        'batchLotNumber': batchLotNumber,
      if (status != null) 'status': status.name,
      if (locationName != null && locationName.isNotEmpty)
        'locationName': locationName,
    };

    final response = await _dioService.get(
      '${_dioService.baseUrl}/identifiers/sgtins/search/advanced',
      queryParameters: queryParams,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.data);
      return {
        'content':
            (data['content'] as List?)
                ?.map((item) => SGTIN.fromJson(item))
                .toList() ??
            [],
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
        message: 'Failed to search SGTINs: ${response.statusMessage}',
      );
    }
  }

  Future<SGTIN> updateSGTINStatus(
    String serialNumber,
    ItemStatus newStatus,
  ) async {
    final token = await _dioService.getAuthToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final response = await _dioService.put(
      '${_dioService.baseUrl}/identifiers/sgtins/$serialNumber/status',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      data: json.encode({'status': newStatus.name}),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return SGTIN.fromJson(json.decode(response.data));
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to update SGTIN status: ${response.statusMessage}',
      );
    }
  }

  Future<SGTIN> assignSGTINToLocation(
    String serialNumber,
    String glnCode,
  ) async {
    final token = await _dioService.getAuthToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final response = await _dioService.put(
      '${_dioService.baseUrl}/identifiers/sgtins/$serialNumber/location',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      data: json.encode({'glnCode': glnCode}),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return SGTIN.fromJson(json.decode(response.data));
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message:
            'Failed to assign SGTIN to location: ${response.statusMessage}',
      );
    }
  }

  Future<SGTIN> packSGTINIntoSSCC(String serialNumber, String ssccCode) async {
    final token = await _dioService.getAuthToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final response = await _dioService.put(
      '${_dioService.baseUrl}/identifiers/sgtins/$serialNumber/pack',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      data: json.encode({'ssccCode': ssccCode}),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return SGTIN.fromJson(json.decode(response.data));
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to pack SGTIN: ${response.statusMessage}',
      );
    }
  }

  Future<String> generateSerialNumber(
    String gtinCode, {
    bool randomized = true,
  }) async {
    final token = await _dioService.getAuthToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final queryParams = <String, dynamic>{'randomized': randomized.toString()};

    final response = await _dioService.get(
      '${_dioService.baseUrl}/identifiers/sgtins/generate-serial/$gtinCode',
      queryParameters: queryParams,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.data);
      return data['serialNumber'] ?? '';
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to generate serial number: ${response.statusMessage}',
      );
    }
  }

  Future<bool> validateSGTIN(String gtinCode, String serialNumber) async {
    final token = await _dioService.getAuthToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final response = await _dioService.post(
      '${_dioService.baseUrl}/identifiers/sgtins/validate',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      data: json.encode({'gtinCode': gtinCode, 'serialNumber': serialNumber}),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.data);
      return data['valid'] ?? false;
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to validate SGTIN: ${response.statusMessage}',
      );
    }
  }

  Future<int> countSGTINsByGTINAndStatus(
    String gtinCode,
    ItemStatus status,
  ) async {
    final token = await _dioService.getAuthToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final queryParams = <String, dynamic>{'status': status.name};

    final response = await _dioService.get(
      '${_dioService.baseUrl}/identifiers/sgtins/count/$gtinCode',
      queryParameters: queryParams,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.data);
      return data['count'] ?? 0;
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to count SGTINs: ${response.statusMessage}',
      );
    }
  }

  Future<List<SGTIN>> commissionMultipleSGTINs({
    required String gtinCode,
    required int quantity,
    required String batchLotNumber,
    required DateTime expiryDate,
    String? currentLocation,
  }) async {
    final token = await _dioService.getAuthToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final expiryDateStr = DateFormat('yyyy-MM-dd').format(expiryDate);

    final response = await _dioService.post(
      '${_dioService.baseUrl}/identifiers/sgtins/commission-multiple',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      data: json.encode({
        'gtinCode': gtinCode,
        'quantity': quantity,
        'batchLotNumber': batchLotNumber,
        'expiryDate': expiryDateStr,
        if (currentLocation != null) 'currentLocation': currentLocation,
      }),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 201) {
      return (json.decode(response.data) as List)
          .map((item) => SGTIN.fromJson(item))
          .toList();
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to commission SGTINs: ${response.statusMessage}',
      );
    }
  }

  Future<SGTIN> decommissionSGTIN(String serialNumber, String reason) async {
    final token = await _dioService.getAuthToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final response = await _dioService.put(
      '${_dioService.baseUrl}/identifiers/sgtins/$serialNumber/decommission',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      data: json.encode({'reason': reason}),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return SGTIN.fromJson(json.decode(response.data));
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to decommission SGTIN: ${response.statusMessage}',
      );
    }
  }
}
