import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:traqtrace_app/core/config/app_config.dart';
import 'package:traqtrace_app/core/network/token_manager.dart';
import 'package:traqtrace_app/features/pharmaceutical/models/gln_pharmaceutical_extension_model.dart';

/// Service for GLN pharmaceutical extension operations
class GLNPharmaceuticalExtensionService {
  final http.Client _httpClient;
  final TokenManager _tokenManager;
  final AppConfig _appConfig;

  GLNPharmaceuticalExtensionService({
    required http.Client httpClient,
    required TokenManager tokenManager,
    required AppConfig appConfig,
  })  : _httpClient = httpClient,
        _tokenManager = tokenManager,
        _appConfig = appConfig;

  String get _baseUrl => '${_appConfig.apiBaseUrl}/pharmaceutical/gln';

  Future<Map<String, String>> get _headers async {
    final token = await _tokenManager.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Create pharmaceutical extension for a GLN by code
  Future<GLNPharmaceuticalExtension> createByGlnCode(
    String glnCode,
    GLNPharmaceuticalExtension extension,
  ) async {
    final response = await _httpClient.post(
      Uri.parse('$_baseUrl/code/$glnCode'),
      headers: await _headers,
      body: jsonEncode(extension.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return GLNPharmaceuticalExtension.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create GLN pharmaceutical extension: ${response.statusCode}');
    }
  }

  /// Save or update pharmaceutical extension for a GLN
  Future<GLNPharmaceuticalExtension> saveByGlnId(
    int glnId,
    GLNPharmaceuticalExtension extension,
  ) async {
    final response = await _httpClient.post(
      Uri.parse('$_baseUrl/$glnId'),
      headers: await _headers,
      body: jsonEncode(extension.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return GLNPharmaceuticalExtension.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to save GLN pharmaceutical extension: ${response.statusCode}');
    }
  }

  /// Get pharmaceutical extension by GLN ID
  Future<GLNPharmaceuticalExtension?> getByGlnId(int glnId) async {
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/$glnId'),
      headers: await _headers,
    );

    if (response.statusCode == 200) {
      return GLNPharmaceuticalExtension.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Failed to fetch GLN pharmaceutical extension: ${response.statusCode}');
    }
  }

  /// Get pharmaceutical extension by GLN code
  Future<GLNPharmaceuticalExtension?> getByGlnCode(String glnCode) async {
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/code/$glnCode'),
      headers: await _headers,
    );

    if (response.statusCode == 200) {
      return GLNPharmaceuticalExtension.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Failed to fetch GLN pharmaceutical extension: ${response.statusCode}');
    }
  }

  /// Get extension by ID
  Future<GLNPharmaceuticalExtension?> getById(int id) async {
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/$id'),
      headers: await _headers,
    );

    if (response.statusCode == 200) {
      return GLNPharmaceuticalExtension.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Failed to fetch GLN pharmaceutical extension: ${response.statusCode}');
    }
  }

  /// Create new extension (alias for createByGlnCode when glnCode is available)
  Future<GLNPharmaceuticalExtension?> create(GLNPharmaceuticalExtension extension) async {
    if (extension.glnCode != null) {
      return await createByGlnCode(extension.glnCode!, extension);
    } else if (extension.glnId > 0) {
      return await saveByGlnId(extension.glnId, extension);
    }
    throw Exception('Either glnCode or glnId must be provided to create an extension');
  }

  /// Update extension
  Future<GLNPharmaceuticalExtension> update(
    int id,
    GLNPharmaceuticalExtension extension,
  ) async {
    final response = await _httpClient.put(
      Uri.parse('$_baseUrl/$id'),
      headers: await _headers,
      body: jsonEncode(extension.toJson()),
    );

    if (response.statusCode == 200) {
      return GLNPharmaceuticalExtension.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update GLN pharmaceutical extension: ${response.statusCode}');
    }
  }

  /// Delete pharmaceutical extension for a GLN
  Future<void> deleteByGlnId(int glnId) async {
    final response = await _httpClient.delete(
      Uri.parse('$_baseUrl/gln/$glnId'),
      headers: await _headers,
    );

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Failed to delete GLN pharmaceutical extension: ${response.statusCode}');
    }
  }

  /// Delete by extension ID
  Future<void> delete(int id) async {
    final response = await _httpClient.delete(
      Uri.parse('$_baseUrl/$id'),
      headers: await _headers,
    );

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Failed to delete GLN pharmaceutical extension: ${response.statusCode}');
    }
  }

  /// Check if a GLN has pharmaceutical extension
  Future<bool> exists(int glnId) async {
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/gln/$glnId/exists'),
      headers: await _headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as bool;
    } else {
      throw Exception('Failed to check GLN pharmaceutical extension: ${response.statusCode}');
    }
  }

  /// Find cold chain capable locations
  Future<List<GLNPharmaceuticalExtension>> findColdChainCapable() async {
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/cold-chain-capable'),
      headers: await _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => GLNPharmaceuticalExtension.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch cold chain capable locations: ${response.statusCode}');
    }
  }

  /// Find clinical trial sites
  Future<List<GLNPharmaceuticalExtension>> findClinicalTrialSites() async {
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/clinical-trial-sites'),
      headers: await _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => GLNPharmaceuticalExtension.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch clinical trial sites: ${response.statusCode}');
    }
  }

  /// Find by facility type
  Future<List<GLNPharmaceuticalExtension>> findByFacilityType(
    HealthcareFacilityType facilityType,
  ) async {
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/facility-type/${facilityType.name}'),
      headers: await _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => GLNPharmaceuticalExtension.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch by facility type: ${response.statusCode}');
    }
  }

  /// Find controlled substance authorized locations
  Future<List<GLNPharmaceuticalExtension>> findControlledSubstanceAuthorized() async {
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/controlled-substance-authorized'),
      headers: await _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => GLNPharmaceuticalExtension.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch controlled substance authorized: ${response.statusCode}');
    }
  }

  /// Find compounding pharmacies
  Future<List<GLNPharmaceuticalExtension>> findCompoundingPharmacies() async {
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/compounding-capable'),
      headers: await _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => GLNPharmaceuticalExtension.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch compounding pharmacies: ${response.statusCode}');
    }
  }

  /// Find 24-hour pharmacies
  Future<List<GLNPharmaceuticalExtension>> find24HourPharmacies() async {
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/24-hour-pharmacy'),
      headers: await _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => GLNPharmaceuticalExtension.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch 24-hour pharmacies: ${response.statusCode}');
    }
  }

  /// Search pharmaceutical extensions
  Future<List<GLNPharmaceuticalExtension>> search({
    String? fdaEstablishmentId,
    String? deaRegistrationNumber,
    HealthcareFacilityType? facilityType,
    bool? coldChainCapable,
    bool? clinicalTrialSite,
    bool? controlledSubstanceAuthorized,
  }) async {
    final queryParams = <String, String>{};
    if (fdaEstablishmentId != null) {
      queryParams['fdaEstablishmentId'] = fdaEstablishmentId;
    }
    if (deaRegistrationNumber != null) {
      queryParams['deaRegistrationNumber'] = deaRegistrationNumber;
    }
    if (facilityType != null) {
      queryParams['facilityType'] = facilityType.name;
    }
    if (coldChainCapable != null) {
      queryParams['coldChainCapable'] = coldChainCapable.toString();
    }
    if (clinicalTrialSite != null) {
      queryParams['clinicalTrialSite'] = clinicalTrialSite.toString();
    }
    if (controlledSubstanceAuthorized != null) {
      queryParams['controlledSubstanceAuthorized'] = controlledSubstanceAuthorized.toString();
    }

    final uri = Uri.parse('$_baseUrl/search').replace(queryParameters: queryParams);
    final response = await _httpClient.get(uri, headers: await _headers);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => GLNPharmaceuticalExtension.fromJson(json)).toList();
    } else {
      throw Exception('Failed to search GLN pharmaceutical extensions: ${response.statusCode}');
    }
  }
}
