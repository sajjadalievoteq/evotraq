import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';
import 'package:traqtrace_app/features/tobacco/models/gtin_tobacco_extension_model.dart';

/// Service for GTIN tobacco extension operations
/// Provides CRUD operations for tobacco-specific product attributes
class GTINTobaccoExtensionService {
  final DioService _dioService;

  GTINTobaccoExtensionService({
    required DioService dioService,
  }) : _dioService = dioService;

  String get _baseUrl => '${_dioService.baseUrl}/tobacco/products';

  Future<Map<String, String>> get _headers async {
    final token = await _dioService.getAuthToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Create tobacco extension for a GTIN by code
  Future<GTINTobaccoExtension> createByGtinCode(
    String gtinCode,
    GTINTobaccoExtension extension,
  ) async {
    final response = await _dioService.post(
      '$_baseUrl/gtin/$gtinCode',
      headers: await _headers,
      data: jsonEncode(extension.toJson()),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return GTINTobaccoExtension.fromJson(jsonDecode(response.data));
    } else {
      throw Exception('Failed to create GTIN tobacco extension: ${response.statusCode}');
    }
  }

  /// Save or update tobacco extension for a GTIN
  Future<GTINTobaccoExtension> saveByGtinId(
    int gtinId,
    GTINTobaccoExtension extension,
  ) async {
    final response = await _dioService.post(
      '$_baseUrl',
      headers: await _headers,
      data: jsonEncode({
        ...extension.toJson(),
        'gtinId': gtinId,
      }),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return GTINTobaccoExtension.fromJson(jsonDecode(response.data));
    } else {
      throw Exception('Failed to save GTIN tobacco extension: ${response.statusCode}');
    }
  }

  /// Get tobacco extension by GTIN ID
  Future<GTINTobaccoExtension?> getByGtinId(int gtinId) async {
    final response = await _dioService.get(
      '$_baseUrl/$gtinId',
      headers: await _headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return GTINTobaccoExtension.fromJson(jsonDecode(response.data));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Failed to fetch GTIN tobacco extension: ${response.statusCode}');
    }
  }

  /// Get tobacco extension by GTIN code
  Future<GTINTobaccoExtension?> getByGtinCode(String gtinCode) async {
    final response = await _dioService.get(
      '$_baseUrl/gtin/$gtinCode',
      headers: await _headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return GTINTobaccoExtension.fromJson(jsonDecode(response.data));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Failed to fetch GTIN tobacco extension: ${response.statusCode}');
    }
  }

  /// Update tobacco extension
  Future<GTINTobaccoExtension> update(
    int extensionId,
    GTINTobaccoExtension extension,
  ) async {
    final response = await _dioService.put(
      '$_baseUrl/$extensionId',
      headers: await _headers,
      data: jsonEncode(extension.toJson()),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return GTINTobaccoExtension.fromJson(jsonDecode(response.data));
    } else {
      throw Exception('Failed to update GTIN tobacco extension: ${response.statusCode}');
    }
  }

  /// Delete tobacco extension
  Future<void> delete(int extensionId) async {
    final response = await _dioService.delete(
      '$_baseUrl/$extensionId',
      headers: await _headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete GTIN tobacco extension: ${response.statusCode}');
    }
  }
}
