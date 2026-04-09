import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/config/app_config.dart';
import '../../../core/network/token_manager.dart';
import '../models/sscc_pharmaceutical_extension_model.dart';

/// Service for SSCC pharmaceutical extension operations
class SSCCPharmaceuticalExtensionService {
  final http.Client _httpClient;
  final TokenManager _tokenManager;
  final AppConfig _appConfig;

  SSCCPharmaceuticalExtensionService({
    required http.Client httpClient,
    required TokenManager tokenManager,
    required AppConfig appConfig,
  })  : _httpClient = httpClient,
        _tokenManager = tokenManager,
        _appConfig = appConfig;

  String get _baseUrl => '${_appConfig.apiBaseUrl}/pharmaceutical/sscc';

  Future<Map<String, String>> get _headers async {
    final token = await _tokenManager.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Create pharmaceutical extension for an SSCC by code
  Future<SSCCPharmaceuticalExtension> createBySsccCode(
    String ssccCode,
    SSCCPharmaceuticalExtension extension,
  ) async {
    final response = await _httpClient.post(
      Uri.parse('$_baseUrl/code/$ssccCode'),
      headers: await _headers,
      body: jsonEncode(extension.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return SSCCPharmaceuticalExtension.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(
          'Failed to create SSCC pharmaceutical extension: ${response.statusCode}');
    }
  }

  /// Save or update pharmaceutical extension for an SSCC
  Future<SSCCPharmaceuticalExtension> saveBySsccId(
    int ssccId,
    SSCCPharmaceuticalExtension extension,
  ) async {
    final response = await _httpClient.post(
      Uri.parse('$_baseUrl/$ssccId'),
      headers: await _headers,
      body: jsonEncode(extension.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return SSCCPharmaceuticalExtension.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(
          'Failed to save SSCC pharmaceutical extension: ${response.statusCode}');
    }
  }

  /// Get pharmaceutical extension by SSCC ID
  Future<SSCCPharmaceuticalExtension?> getBySsccId(int ssccId) async {
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/$ssccId'),
      headers: await _headers,
    );

    if (response.statusCode == 200) {
      return SSCCPharmaceuticalExtension.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception(
          'Failed to fetch SSCC pharmaceutical extension: ${response.statusCode}');
    }
  }

  /// Get pharmaceutical extension by SSCC code
  Future<SSCCPharmaceuticalExtension?> getBySsccCode(String ssccCode) async {
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/code/$ssccCode'),
      headers: await _headers,
    );

    if (response.statusCode == 200) {
      return SSCCPharmaceuticalExtension.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception(
          'Failed to fetch SSCC pharmaceutical extension: ${response.statusCode}');
    }
  }

  /// Delete pharmaceutical extension for an SSCC
  Future<void> delete(int ssccId) async {
    final response = await _httpClient.delete(
      Uri.parse('$_baseUrl/$ssccId'),
      headers: await _headers,
    );

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception(
          'Failed to delete SSCC pharmaceutical extension: ${response.statusCode}');
    }
  }

  /// Check if an SSCC has pharmaceutical extension
  Future<bool> hasPharmaceuticalExtension(int ssccId) async {
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/$ssccId/exists'),
      headers: await _headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as bool;
    } else {
      throw Exception(
          'Failed to check SSCC pharmaceutical extension: ${response.statusCode}');
    }
  }

  // ===== Cold Chain Queries =====

  /// Find all cold chain required shipments
  Future<List<SSCCPharmaceuticalExtension>> findColdChainShipments() async {
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/cold-chain'),
      headers: await _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((json) => SSCCPharmaceuticalExtension.fromJson(json))
          .toList();
    } else {
      throw Exception(
          'Failed to fetch cold chain shipments: ${response.statusCode}');
    }
  }

  /// Find shipments requiring temperature monitoring
  Future<List<SSCCPharmaceuticalExtension>>
      findTemperatureMonitoredShipments() async {
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/temperature-monitored'),
      headers: await _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((json) => SSCCPharmaceuticalExtension.fromJson(json))
          .toList();
    } else {
      throw Exception(
          'Failed to fetch temperature monitored shipments: ${response.statusCode}');
    }
  }

  // ===== GDP Compliance Queries =====

  /// Find GDP compliant shipments
  Future<List<SSCCPharmaceuticalExtension>> findGdpCompliantShipments() async {
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/gdp-compliant'),
      headers: await _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((json) => SSCCPharmaceuticalExtension.fromJson(json))
          .toList();
    } else {
      throw Exception(
          'Failed to fetch GDP compliant shipments: ${response.statusCode}');
    }
  }

  // ===== Controlled Substance Queries =====

  /// Find controlled substance shipments
  Future<List<SSCCPharmaceuticalExtension>>
      findControlledSubstanceShipments() async {
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/controlled-substance'),
      headers: await _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((json) => SSCCPharmaceuticalExtension.fromJson(json))
          .toList();
    } else {
      throw Exception(
          'Failed to fetch controlled substance shipments: ${response.statusCode}');
    }
  }

  /// Find by DEA schedule
  Future<List<SSCCPharmaceuticalExtension>> findByDeaSchedule(
      String deaSchedule) async {
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/dea-schedule/$deaSchedule'),
      headers: await _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((json) => SSCCPharmaceuticalExtension.fromJson(json))
          .toList();
    } else {
      throw Exception(
          'Failed to fetch DEA schedule shipments: ${response.statusCode}');
    }
  }

  // ===== Hazmat Queries =====

  /// Find all hazmat shipments
  Future<List<SSCCPharmaceuticalExtension>> findHazmatShipments() async {
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/hazmat'),
      headers: await _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((json) => SSCCPharmaceuticalExtension.fromJson(json))
          .toList();
    } else {
      throw Exception(
          'Failed to fetch hazmat shipments: ${response.statusCode}');
    }
  }

  // ===== Chain of Custody Queries =====

  /// Find shipments requiring chain of custody
  Future<List<SSCCPharmaceuticalExtension>> findChainOfCustodyShipments() async {
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/chain-of-custody'),
      headers: await _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((json) => SSCCPharmaceuticalExtension.fromJson(json))
          .toList();
    } else {
      throw Exception(
          'Failed to fetch chain of custody shipments: ${response.statusCode}');
    }
  }

  /// Find shipments requiring signature on receipt
  Future<List<SSCCPharmaceuticalExtension>>
      findSignatureRequiredShipments() async {
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/signature-required'),
      headers: await _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((json) => SSCCPharmaceuticalExtension.fromJson(json))
          .toList();
    } else {
      throw Exception(
          'Failed to fetch signature required shipments: ${response.statusCode}');
    }
  }

  // ===== Clinical Trial Queries =====

  /// Find clinical trial shipments
  Future<List<SSCCPharmaceuticalExtension>> findClinicalTrialShipments() async {
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/clinical-trial'),
      headers: await _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((json) => SSCCPharmaceuticalExtension.fromJson(json))
          .toList();
    } else {
      throw Exception(
          'Failed to fetch clinical trial shipments: ${response.statusCode}');
    }
  }

  // ===== Special Handling Queries =====

  /// Find fragile shipments
  Future<List<SSCCPharmaceuticalExtension>> findFragileShipments() async {
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/fragile'),
      headers: await _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((json) => SSCCPharmaceuticalExtension.fromJson(json))
          .toList();
    } else {
      throw Exception(
          'Failed to fetch fragile shipments: ${response.statusCode}');
    }
  }

  /// Find do-not-stack shipments
  Future<List<SSCCPharmaceuticalExtension>> findDoNotStackShipments() async {
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/do-not-stack'),
      headers: await _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((json) => SSCCPharmaceuticalExtension.fromJson(json))
          .toList();
    } else {
      throw Exception(
          'Failed to fetch do-not-stack shipments: ${response.statusCode}');
    }
  }
}
