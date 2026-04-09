import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/config/app_config.dart';
import '../../../core/network/token_manager.dart';
import '../models/gtin_pharmaceutical_extension_model.dart';

/// Service for pharmaceutical extension operations
class PharmaceuticalService {
  final http.Client _httpClient;
  final TokenManager _tokenManager;
  final AppConfig _appConfig;

  PharmaceuticalService({
    required http.Client httpClient,
    required TokenManager tokenManager,
    required AppConfig appConfig,
  })  : _httpClient = httpClient,
        _tokenManager = tokenManager,
        _appConfig = appConfig;

  String get _baseUrl => '${_appConfig.apiBaseUrl}/pharmaceutical';

  Future<Map<String, String>> get _headers async {
    final token = await _tokenManager.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Create pharmaceutical extension for a GTIN by code (used when creating new GTIN)
  Future<GTINPharmaceuticalExtension> createExtension(
    String gtinCode,
    GTINPharmaceuticalExtension extension,
  ) async {
    final response = await _httpClient.post(
      Uri.parse('$_baseUrl/gtin/code/$gtinCode'),
      headers: await _headers,
      body: jsonEncode(extension.toJson()),
    );

    if (response.statusCode == 200) {
      return GTINPharmaceuticalExtension.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create pharmaceutical extension: ${response.statusCode}');
    }
  }

  /// Save or update pharmaceutical extension for a GTIN
  Future<GTINPharmaceuticalExtension> saveExtension(
    int gtinId,
    GTINPharmaceuticalExtension extension,
  ) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/gtin/$gtinId'),
      headers: await _headers,
      body: jsonEncode(extension.toJson()),
    );

    if (response.statusCode == 200) {
      return GTINPharmaceuticalExtension.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to save pharmaceutical extension: ${response.statusCode}');
    }
  }

  /// Get pharmaceutical extension by GTIN ID
  Future<GTINPharmaceuticalExtension?> getExtensionByGtinId(int gtinId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/gtin/$gtinId'),
      headers: await _headers,
    );

    if (response.statusCode == 200) {
      return GTINPharmaceuticalExtension.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Failed to fetch pharmaceutical extension: ${response.statusCode}');
    }
  }

  /// Get pharmaceutical extension by GTIN code
  Future<GTINPharmaceuticalExtension?> getExtensionByGtinCode(
    String gtinCode,
  ) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/gtin/code/$gtinCode'),
      headers: await _headers,
    );

    if (response.statusCode == 200) {
      return GTINPharmaceuticalExtension.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Failed to fetch pharmaceutical extension: ${response.statusCode}');
    }
  }

  /// Delete pharmaceutical extension for a GTIN
  Future<void> deleteExtension(int gtinId) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/gtin/$gtinId'),
      headers: await _headers,
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete pharmaceutical extension: ${response.statusCode}');
    }
  }

  /// Check if a GTIN has pharmaceutical extension
  Future<bool> hasPharmaceuticalExtension(int gtinId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/gtin/$gtinId/exists'),
      headers: await _headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as bool;
    } else {
      throw Exception('Failed to check pharmaceutical extension: ${response.statusCode}');
    }
  }

  /// Find all controlled substances
  Future<List<GTINPharmaceuticalExtension>> findControlledSubstances() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/controlled-substances'),
      headers: await _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((json) => GTINPharmaceuticalExtension.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to fetch controlled substances: ${response.statusCode}');
    }
  }

  /// Find by DEA schedule
  Future<List<GTINPharmaceuticalExtension>> findByDeaSchedule(
    String schedule,
  ) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/dea-schedule/$schedule'),
      headers: await _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((json) => GTINPharmaceuticalExtension.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to fetch by DEA schedule: ${response.statusCode}');
    }
  }

  /// Find products requiring refrigeration
  Future<List<GTINPharmaceuticalExtension>> findRequiringRefrigeration() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/requiring-refrigeration'),
      headers: await _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((json) => GTINPharmaceuticalExtension.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to fetch refrigeration products: ${response.statusCode}');
    }
  }

  /// Find products requiring prescription
  Future<List<GTINPharmaceuticalExtension>> findRequiringPrescription() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/requiring-prescription'),
      headers: await _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((json) => GTINPharmaceuticalExtension.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to fetch prescription products: ${response.statusCode}');
    }
  }

  /// Find products with black box warning
  Future<List<GTINPharmaceuticalExtension>> findWithBlackBoxWarning() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/black-box-warning'),
      headers: await _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((json) => GTINPharmaceuticalExtension.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to fetch black box warning products: ${response.statusCode}');
    }
  }

  /// Find by therapeutic class
  Future<List<GTINPharmaceuticalExtension>> findByTherapeuticClass(
    String therapeuticClass,
  ) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/therapeutic-class/$therapeuticClass'),
      headers: await _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((json) => GTINPharmaceuticalExtension.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to fetch by therapeutic class: ${response.statusCode}');
    }
  }

  /// Find by ATC code
  Future<List<GTINPharmaceuticalExtension>> findByAtcCode(String atcCode) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/atc-code/$atcCode'),
      headers: await _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((json) => GTINPharmaceuticalExtension.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to fetch by ATC code: ${response.statusCode}');
    }
  }
}
