import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/config/app_config.dart';
import '../../../core/network/token_manager.dart';
import '../models/sscc_tobacco_extension_model.dart';

/// Service for SSCC tobacco extension operations
class SSCCTobaccoExtensionService {
  final http.Client _httpClient;
  final TokenManager _tokenManager;
  final AppConfig _appConfig;

  SSCCTobaccoExtensionService({
    required http.Client httpClient,
    required TokenManager tokenManager,
    required AppConfig appConfig,
  })  : _httpClient = httpClient,
        _tokenManager = tokenManager,
        _appConfig = appConfig;

  String get _baseUrl => '${_appConfig.apiBaseUrl}/tobacco/sscc';

  Future<Map<String, String>> get _headers async {
    final token = await _tokenManager.getToken();
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
    final response = await _httpClient.post(
      Uri.parse('$_baseUrl/code/$ssccCode'),
      headers: await _headers,
      body: jsonEncode(extension.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return SSCCTobaccoExtension.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(
          'Failed to create SSCC tobacco extension: ${response.statusCode}');
    }
  }

  /// Save or update tobacco extension for an SSCC
  Future<SSCCTobaccoExtension> saveBySsccId(
    int ssccId,
    SSCCTobaccoExtension extension,
  ) async {
    final response = await _httpClient.post(
      Uri.parse('$_baseUrl/$ssccId'),
      headers: await _headers,
      body: jsonEncode(extension.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return SSCCTobaccoExtension.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(
          'Failed to save SSCC tobacco extension: ${response.statusCode}');
    }
  }

  /// Get tobacco extension by SSCC ID
  Future<SSCCTobaccoExtension?> getBySsccId(int ssccId) async {
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/$ssccId'),
      headers: await _headers,
    );

    if (response.statusCode == 200) {
      return SSCCTobaccoExtension.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception(
          'Failed to fetch SSCC tobacco extension: ${response.statusCode}');
    }
  }

  /// Get tobacco extension by SSCC code
  Future<SSCCTobaccoExtension?> getBySsccCode(String ssccCode) async {
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/code/$ssccCode'),
      headers: await _headers,
    );

    if (response.statusCode == 200) {
      return SSCCTobaccoExtension.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception(
          'Failed to fetch SSCC tobacco extension: ${response.statusCode}');
    }
  }

  /// Delete tobacco extension for an SSCC
  Future<void> delete(int ssccId) async {
    final response = await _httpClient.delete(
      Uri.parse('$_baseUrl/$ssccId'),
      headers: await _headers,
    );

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception(
          'Failed to delete SSCC tobacco extension: ${response.statusCode}');
    }
  }

  /// Check if an SSCC has tobacco extension
  Future<bool> hasTobaccoExtension(int ssccId) async {
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/$ssccId/exists'),
      headers: await _headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as bool;
    } else {
      throw Exception(
          'Failed to check SSCC tobacco extension: ${response.statusCode}');
    }
  }

  /// Find shipments to EU first retail outlets
  Future<List<SSCCTobaccoExtension>> findShipmentsToEuFirstRetailOutlets() async {
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/eu-first-retail-outlets'),
      headers: await _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((json) => SSCCTobaccoExtension.fromJson(json))
          .toList();
    } else {
      throw Exception(
          'Failed to fetch EU first retail outlet shipments: ${response.statusCode}');
    }
  }

  /// Find by country of destination
  Future<List<SSCCTobaccoExtension>> findByCountryOfDestination(
      String countryCode) async {
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/destination/$countryCode'),
      headers: await _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((json) => SSCCTobaccoExtension.fromJson(json))
          .toList();
    } else {
      throw Exception(
          'Failed to fetch shipments by destination: ${response.statusCode}');
    }
  }

  /// Find by seal number
  Future<SSCCTobaccoExtension?> findBySealNumber(String sealNumber) async {
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/seal/$sealNumber'),
      headers: await _headers,
    );

    if (response.statusCode == 200) {
      return SSCCTobaccoExtension.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception(
          'Failed to fetch SSCC by seal number: ${response.statusCode}');
    }
  }

  /// Find by carrier license number
  Future<List<SSCCTobaccoExtension>> findByCarrierLicenseNumber(
      String licenseNumber) async {
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/carrier/$licenseNumber'),
      headers: await _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((json) => SSCCTobaccoExtension.fromJson(json))
          .toList();
    } else {
      throw Exception(
          'Failed to fetch shipments by carrier: ${response.statusCode}');
    }
  }

  /// Find containers with multiple batches
  Future<List<SSCCTobaccoExtension>> findContainersWithMultipleBatches() async {
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/multiple-batches'),
      headers: await _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((json) => SSCCTobaccoExtension.fromJson(json))
          .toList();
    } else {
      throw Exception(
          'Failed to fetch multi-batch containers: ${response.statusCode}');
    }
  }
}
