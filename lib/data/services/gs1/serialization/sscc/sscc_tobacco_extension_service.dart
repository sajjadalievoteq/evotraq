import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';
import 'package:traqtrace_app/data/models/gs1/serialization/sscc/sscc_tobacco_extension_model.dart';

class SSCCTobaccoExtensionService {
  final DioService _dioService;

  SSCCTobaccoExtensionService({required DioService dioService})
    : _dioService = dioService;

  String get _baseUrl => '${_dioService.baseUrl}/tobacco/sscc';

  static const _headers = {'Content-Type': 'application/json'};

  Future<SSCCTobaccoExtension> createBySsccCode(
    String ssccCode,
    SSCCTobaccoExtension extension,
  ) async {
    final response = await _dioService.post(
      '$_baseUrl/code/$ssccCode',
      headers: _headers,
      data: jsonEncode(extension.toJson()),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return SSCCTobaccoExtension.fromJson(jsonDecode(response.data));
    } else {
      throw ApiException(message:
        'Failed to create SSCC tobacco extension: ${response.statusCode}',
      );
    }
  }

  Future<SSCCTobaccoExtension> saveBySsccId(
    int ssccId,
    SSCCTobaccoExtension extension,
  ) async {
    final response = await _dioService.post(
      '$_baseUrl/$ssccId',
      headers: _headers,
      data: jsonEncode(extension.toJson()),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return SSCCTobaccoExtension.fromJson(jsonDecode(response.data));
    } else {
      throw ApiException(message:
        'Failed to save SSCC tobacco extension: ${response.statusCode}',
      );
    }
  }

  Future<SSCCTobaccoExtension?> getBySsccId(int ssccId) async {
    final response = await _dioService.get(
      '$_baseUrl/$ssccId',
      headers: _headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return SSCCTobaccoExtension.fromJson(jsonDecode(response.data));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw ApiException(message:
        'Failed to fetch SSCC tobacco extension: ${response.statusCode}',
      );
    }
  }

  Future<SSCCTobaccoExtension?> getBySsccCode(String ssccCode) async {
    final response = await _dioService.get(
      '$_baseUrl/code/$ssccCode',
      headers: _headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return SSCCTobaccoExtension.fromJson(jsonDecode(response.data));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw ApiException(message:
        'Failed to fetch SSCC tobacco extension: ${response.statusCode}',
      );
    }
  }

  Future<void> delete(int ssccId) async {
    final response = await _dioService.delete(
      '$_baseUrl/$ssccId',
      headers: _headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw ApiException(message:
        'Failed to delete SSCC tobacco extension: ${response.statusCode}',
      );
    }
  }

  Future<bool> hasTobaccoExtension(int ssccId) async {
    final response = await _dioService.get(
      '$_baseUrl/$ssccId/exists',
      headers: _headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.data) as bool;
    } else {
      throw ApiException(message:
        'Failed to check SSCC tobacco extension: ${response.statusCode}',
      );
    }
  }

  Future<List<SSCCTobaccoExtension>>
  findShipmentsToEuFirstRetailOutlets() async {
    final response = await _dioService.get(
      '$_baseUrl/eu-first-retail-outlets',
      headers: _headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.data);
      return data.map((json) => SSCCTobaccoExtension.fromJson(json)).toList();
    } else {
      throw ApiException(message:
        'Failed to fetch EU first retail outlet shipments: ${response.statusCode}',
      );
    }
  }

  Future<List<SSCCTobaccoExtension>> findByCountryOfDestination(
    String countryCode,
  ) async {
    final response = await _dioService.get(
      '$_baseUrl/destination/$countryCode',
      headers: _headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.data);
      return data.map((json) => SSCCTobaccoExtension.fromJson(json)).toList();
    } else {
      throw ApiException(message:
        'Failed to fetch shipments by destination: ${response.statusCode}',
      );
    }
  }

  Future<SSCCTobaccoExtension?> findBySealNumber(String sealNumber) async {
    final response = await _dioService.get(
      '$_baseUrl/seal/$sealNumber',
      headers: _headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return SSCCTobaccoExtension.fromJson(jsonDecode(response.data));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw ApiException(message:
        'Failed to fetch SSCC by seal number: ${response.statusCode}',
      );
    }
  }

  Future<List<SSCCTobaccoExtension>> findByCarrierLicenseNumber(
    String licenseNumber,
  ) async {
    final response = await _dioService.get(
      '$_baseUrl/carrier/$licenseNumber',
      headers: _headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.data);
      return data.map((json) => SSCCTobaccoExtension.fromJson(json)).toList();
    } else {
      throw ApiException(message:
        'Failed to fetch shipments by carrier: ${response.statusCode}',
      );
    }
  }

  Future<List<SSCCTobaccoExtension>> findContainersWithMultipleBatches() async {
    final response = await _dioService.get(
      '$_baseUrl/multiple-batches',
      headers: _headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.data);
      return data.map((json) => SSCCTobaccoExtension.fromJson(json)).toList();
    } else {
      throw ApiException(message:
        'Failed to fetch multi-batch containers: ${response.statusCode}',
      );
    }
  }
}
