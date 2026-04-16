import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';
import 'package:traqtrace_app/features/tobacco/models/sscc_tobacco_extension_model.dart';

/// Service for SSCC tobacco extension operations
class SSCCTobaccoExtensionService {
  final DioService _dioService;

  SSCCTobaccoExtensionService({required DioService dioService})
    : _dioService = dioService;

  String get _baseUrl => '${_dioService.baseUrl}/tobacco/sscc';

  Future<Map<String, String>> get _headers async {
    final token = await _dioService.getAuthToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Create tobacco extension for an SSCC by code
  Future<SSCCTobaccoExtension> createBySsccCode(
    String ssccCode,
    SSCCTobaccoExtension extension,
  ) async {
    final response = await _dioService.post(
      '$_baseUrl/code/$ssccCode',
      headers: await _headers,
      data: jsonEncode(extension.toJson()),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return SSCCTobaccoExtension.fromJson(jsonDecode(response.data));
    } else {
      throw Exception(
        'Failed to create SSCC tobacco extension: ${response.statusCode}',
      );
    }
  }

  /// Save or update tobacco extension for an SSCC
  Future<SSCCTobaccoExtension> saveBySsccId(
    int ssccId,
    SSCCTobaccoExtension extension,
  ) async {
    final response = await _dioService.post(
      '$_baseUrl/$ssccId',
      headers: await _headers,
      data: jsonEncode(extension.toJson()),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return SSCCTobaccoExtension.fromJson(jsonDecode(response.data));
    } else {
      throw Exception(
        'Failed to save SSCC tobacco extension: ${response.statusCode}',
      );
    }
  }

  /// Get tobacco extension by SSCC ID
  Future<SSCCTobaccoExtension?> getBySsccId(int ssccId) async {
    final response = await _dioService.get(
      '$_baseUrl/$ssccId',
      headers: await _headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return SSCCTobaccoExtension.fromJson(jsonDecode(response.data));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception(
        'Failed to fetch SSCC tobacco extension: ${response.statusCode}',
      );
    }
  }

  /// Get tobacco extension by SSCC code
  Future<SSCCTobaccoExtension?> getBySsccCode(String ssccCode) async {
    final response = await _dioService.get(
      '$_baseUrl/code/$ssccCode',
      headers: await _headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return SSCCTobaccoExtension.fromJson(jsonDecode(response.data));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception(
        'Failed to fetch SSCC tobacco extension: ${response.statusCode}',
      );
    }
  }

  /// Delete tobacco extension for an SSCC
  Future<void> delete(int ssccId) async {
    final response = await _dioService.delete(
      '$_baseUrl/$ssccId',
      headers: await _headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception(
        'Failed to delete SSCC tobacco extension: ${response.statusCode}',
      );
    }
  }

  /// Check if an SSCC has tobacco extension
  Future<bool> hasTobaccoExtension(int ssccId) async {
    final response = await _dioService.get(
      '$_baseUrl/$ssccId/exists',
      headers: await _headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.data) as bool;
    } else {
      throw Exception(
        'Failed to check SSCC tobacco extension: ${response.statusCode}',
      );
    }
  }

  /// Find shipments to EU first retail outlets
  Future<List<SSCCTobaccoExtension>>
  findShipmentsToEuFirstRetailOutlets() async {
    final response = await _dioService.get(
      '$_baseUrl/eu-first-retail-outlets',
      headers: await _headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.data);
      return data.map((json) => SSCCTobaccoExtension.fromJson(json)).toList();
    } else {
      throw Exception(
        'Failed to fetch EU first retail outlet shipments: ${response.statusCode}',
      );
    }
  }

  /// Find by country of destination
  Future<List<SSCCTobaccoExtension>> findByCountryOfDestination(
    String countryCode,
  ) async {
    final response = await _dioService.get(
      '$_baseUrl/destination/$countryCode',
      headers: await _headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.data);
      return data.map((json) => SSCCTobaccoExtension.fromJson(json)).toList();
    } else {
      throw Exception(
        'Failed to fetch shipments by destination: ${response.statusCode}',
      );
    }
  }

  /// Find by seal number
  Future<SSCCTobaccoExtension?> findBySealNumber(String sealNumber) async {
    final response = await _dioService.get(
      '$_baseUrl/seal/$sealNumber',
      headers: await _headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return SSCCTobaccoExtension.fromJson(jsonDecode(response.data));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception(
        'Failed to fetch SSCC by seal number: ${response.statusCode}',
      );
    }
  }

  /// Find by carrier license number
  Future<List<SSCCTobaccoExtension>> findByCarrierLicenseNumber(
    String licenseNumber,
  ) async {
    final response = await _dioService.get(
      '$_baseUrl/carrier/$licenseNumber',
      headers: await _headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.data);
      return data.map((json) => SSCCTobaccoExtension.fromJson(json)).toList();
    } else {
      throw Exception(
        'Failed to fetch shipments by carrier: ${response.statusCode}',
      );
    }
  }

  /// Find containers with multiple batches
  Future<List<SSCCTobaccoExtension>> findContainersWithMultipleBatches() async {
    final response = await _dioService.get(
      '$_baseUrl/multiple-batches',
      headers: await _headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.data);
      return data.map((json) => SSCCTobaccoExtension.fromJson(json)).toList();
    } else {
      throw Exception(
        'Failed to fetch multi-batch containers: ${response.statusCode}',
      );
    }
  }
}
