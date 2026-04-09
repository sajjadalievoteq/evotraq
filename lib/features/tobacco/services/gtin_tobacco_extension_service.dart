import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/config/app_config.dart';
import '../../../core/network/token_manager.dart';
import '../models/gtin_tobacco_extension_model.dart';

/// Service for GTIN tobacco extension operations
/// Provides CRUD operations for tobacco-specific product attributes
class GTINTobaccoExtensionService {
  final http.Client _httpClient;
  final TokenManager _tokenManager;
  final AppConfig _appConfig;

  GTINTobaccoExtensionService({
    required http.Client httpClient,
    required TokenManager tokenManager,
    required AppConfig appConfig,
  })  : _httpClient = httpClient,
        _tokenManager = tokenManager,
        _appConfig = appConfig;

  String get _baseUrl => '${_appConfig.apiBaseUrl}/tobacco/products';

  Future<Map<String, String>> get _headers async {
    final token = await _tokenManager.getToken();
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
    final response = await _httpClient.post(
      Uri.parse('$_baseUrl/gtin/$gtinCode'),
      headers: await _headers,
      body: jsonEncode(extension.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return GTINTobaccoExtension.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create GTIN tobacco extension: ${response.statusCode}');
    }
  }

  /// Save or update tobacco extension for a GTIN
  Future<GTINTobaccoExtension> saveByGtinId(
    int gtinId,
    GTINTobaccoExtension extension,
  ) async {
    final response = await _httpClient.post(
      Uri.parse('$_baseUrl'),
      headers: await _headers,
      body: jsonEncode({
        ...extension.toJson(),
        'gtinId': gtinId,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return GTINTobaccoExtension.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to save GTIN tobacco extension: ${response.statusCode}');
    }
  }

  /// Get tobacco extension by GTIN ID
  Future<GTINTobaccoExtension?> getByGtinId(int gtinId) async {
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/$gtinId'),
      headers: await _headers,
    );

    if (response.statusCode == 200) {
      return GTINTobaccoExtension.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Failed to fetch GTIN tobacco extension: ${response.statusCode}');
    }
  }

  /// Get tobacco extension by GTIN code
  Future<GTINTobaccoExtension?> getByGtinCode(String gtinCode) async {
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/gtin/$gtinCode'),
      headers: await _headers,
    );

    if (response.statusCode == 200) {
      return GTINTobaccoExtension.fromJson(jsonDecode(response.body));
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
    final response = await _httpClient.put(
      Uri.parse('$_baseUrl/$extensionId'),
      headers: await _headers,
      body: jsonEncode(extension.toJson()),
    );

    if (response.statusCode == 200) {
      return GTINTobaccoExtension.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update GTIN tobacco extension: ${response.statusCode}');
    }
  }

  /// Delete tobacco extension
  Future<void> delete(int extensionId) async {
    final response = await _httpClient.delete(
      Uri.parse('$_baseUrl/$extensionId'),
      headers: await _headers,
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete GTIN tobacco extension: ${response.statusCode}');
    }
  }
}
