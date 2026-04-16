import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';
import 'package:traqtrace_app/features/tobacco/models/gln_tobacco_extension_model.dart';

/// Service for GLN tobacco extension operations
class GLNTobaccoExtensionService {
  final DioService _dioService;

  GLNTobaccoExtensionService({required DioService dioService})
    : _dioService = dioService;

  String get _baseUrl => '${_dioService.baseUrl}/tobacco/gln';

  Future<Map<String, String>> get _headers async {
    final token = await _dioService.getAuthToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Create tobacco extension for a GLN by code
  Future<GLNTobaccoExtension> createByGlnCode(
    String glnCode,
    GLNTobaccoExtension extension,
  ) async {
    final response = await _dioService.post(
      '$_baseUrl/code/$glnCode',
      headers: await _headers,
      data: jsonEncode(extension.toJson()),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return GLNTobaccoExtension.fromJson(jsonDecode(response.data));
    } else {
      throw Exception(
        'Failed to create GLN tobacco extension: ${response.statusCode}',
      );
    }
  }

  /// Save or update tobacco extension for a GLN
  Future<GLNTobaccoExtension> saveByGlnId(
    int glnId,
    GLNTobaccoExtension extension,
  ) async {
    final response = await _dioService.post(
      '$_baseUrl/$glnId',
      headers: await _headers,
      data: jsonEncode(extension.toJson()),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return GLNTobaccoExtension.fromJson(jsonDecode(response.data));
    } else {
      throw Exception(
        'Failed to save GLN tobacco extension: ${response.statusCode}',
      );
    }
  }

  /// Get tobacco extension by GLN ID
  Future<GLNTobaccoExtension?> getByGlnId(int glnId) async {
    final response = await _dioService.get(
      '$_baseUrl/$glnId',
      headers: await _headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return GLNTobaccoExtension.fromJson(jsonDecode(response.data));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception(
        'Failed to fetch GLN tobacco extension: ${response.statusCode}',
      );
    }
  }

  /// Get tobacco extension by GLN code
  Future<GLNTobaccoExtension?> getByGlnCode(String glnCode) async {
    final response = await _dioService.get(
      '$_baseUrl/code/$glnCode',
      headers: await _headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return GLNTobaccoExtension.fromJson(jsonDecode(response.data));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception(
        'Failed to fetch GLN tobacco extension: ${response.statusCode}',
      );
    }
  }

  /// Get extension by ID
  Future<GLNTobaccoExtension?> getById(int id) async {
    final response = await _dioService.get(
      '$_baseUrl/$id',
      headers: await _headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return GLNTobaccoExtension.fromJson(jsonDecode(response.data));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception(
        'Failed to fetch GLN tobacco extension: ${response.statusCode}',
      );
    }
  }

  /// Create new extension (alias for createByGlnCode when glnCode is available)
  Future<GLNTobaccoExtension?> create(GLNTobaccoExtension extension) async {
    if (extension.glnCode != null) {
      return await createByGlnCode(extension.glnCode!, extension);
    } else if (extension.glnId > 0) {
      return await saveByGlnId(extension.glnId, extension);
    }
    throw Exception(
      'Either glnCode or glnId must be provided to create an extension',
    );
  }

  /// Update extension
  Future<GLNTobaccoExtension> update(
    int id,
    GLNTobaccoExtension extension,
  ) async {
    final response = await _dioService.put(
      '$_baseUrl/$id',
      headers: await _headers,
      data: jsonEncode(extension.toJson()),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return GLNTobaccoExtension.fromJson(jsonDecode(response.data));
    } else {
      throw Exception(
        'Failed to update GLN tobacco extension: ${response.statusCode}',
      );
    }
  }

  /// Delete tobacco extension for a GLN
  Future<void> deleteByGlnId(int glnId) async {
    final response = await _dioService.delete(
      '$_baseUrl/gln/$glnId',
      headers: await _headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception(
        'Failed to delete GLN tobacco extension: ${response.statusCode}',
      );
    }
  }

  /// Delete by extension ID
  Future<void> delete(int id) async {
    final response = await _dioService.delete(
      '$_baseUrl/$id',
      headers: await _headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception(
        'Failed to delete GLN tobacco extension: ${response.statusCode}',
      );
    }
  }

  /// Check if a GLN has tobacco extension
  Future<bool> exists(int glnId) async {
    final response = await _dioService.get(
      '$_baseUrl/gln/$glnId/exists',
      headers: await _headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.data) as bool;
    } else {
      throw Exception(
        'Failed to check GLN tobacco extension: ${response.statusCode}',
      );
    }
  }

  /// Find EU TPD registered locations
  Future<List<GLNTobaccoExtension>> findEuTpdRegistered() async {
    final response = await _dioService.get(
      '$_baseUrl/eu-tpd-registered',
      headers: await _headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.data);
      return data.map((json) => GLNTobaccoExtension.fromJson(json)).toList();
    } else {
      throw Exception(
        'Failed to fetch EU TPD registered: ${response.statusCode}',
      );
    }
  }

  /// Find PACT Act registered locations
  Future<List<GLNTobaccoExtension>> findPactActRegistered() async {
    final response = await _dioService.get(
      '$_baseUrl/pact-act-registered',
      headers: await _headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.data);
      return data.map((json) => GLNTobaccoExtension.fromJson(json)).toList();
    } else {
      throw Exception(
        'Failed to fetch PACT Act registered: ${response.statusCode}',
      );
    }
  }

  /// Find UI issuers
  Future<List<GLNTobaccoExtension>> findUiIssuers() async {
    final response = await _dioService.get(
      '$_baseUrl/ui-issuers',
      headers: await _headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.data);
      return data.map((json) => GLNTobaccoExtension.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch UI issuers: ${response.statusCode}');
    }
  }

  /// Find manufacturing facilities
  Future<List<GLNTobaccoExtension>> findManufacturingFacilities() async {
    final response = await _dioService.get(
      '$_baseUrl/manufacturing-facilities',
      headers: await _headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.data);
      return data.map((json) => GLNTobaccoExtension.fromJson(json)).toList();
    } else {
      throw Exception(
        'Failed to fetch manufacturing facilities: ${response.statusCode}',
      );
    }
  }

  /// Find first retail outlets
  Future<List<GLNTobaccoExtension>> findFirstRetailOutlets() async {
    final response = await _dioService.get(
      '$_baseUrl/first-retail-outlets',
      headers: await _headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.data);
      return data.map((json) => GLNTobaccoExtension.fromJson(json)).toList();
    } else {
      throw Exception(
        'Failed to fetch first retail outlets: ${response.statusCode}',
      );
    }
  }

  /// Find bonded warehouses
  Future<List<GLNTobaccoExtension>> findBondedWarehouses() async {
    final response = await _dioService.get(
      '$_baseUrl/bonded-warehouses',
      headers: await _headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.data);
      return data.map((json) => GLNTobaccoExtension.fromJson(json)).toList();
    } else {
      throw Exception(
        'Failed to fetch bonded warehouses: ${response.statusCode}',
      );
    }
  }

  /// Find AEO certified locations
  Future<List<GLNTobaccoExtension>> findAeoCertified() async {
    final response = await _dioService.get(
      '$_baseUrl/aeo-certified',
      headers: await _headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.data);
      return data.map((json) => GLNTobaccoExtension.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch AEO certified: ${response.statusCode}');
    }
  }

  /// Find by EU Economic Operator ID
  Future<GLNTobaccoExtension?> findByEuEconomicOperatorId(String eoId) async {
    final response = await _dioService.get(
      '$_baseUrl/eu-economic-operator/$eoId',
      headers: await _headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return GLNTobaccoExtension.fromJson(jsonDecode(response.data));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Failed to fetch by EU EO ID: ${response.statusCode}');
    }
  }

  /// Search tobacco extensions
  Future<List<GLNTobaccoExtension>> search({
    String? euEconomicOperatorId,
    String? fdaTobaccoEstablishmentId,
    bool? euTpdRegistered,
    bool? pactActRegistered,
    bool? isManufacturingFacility,
    bool? isUiIssuer,
    bool? bondedWarehouse,
    String? stateTobaccoLicenseState,
  }) async {
    final queryParams = <String, String>{};
    if (euEconomicOperatorId != null) {
      queryParams['euEconomicOperatorId'] = euEconomicOperatorId;
    }
    if (fdaTobaccoEstablishmentId != null) {
      queryParams['fdaTobaccoEstablishmentId'] = fdaTobaccoEstablishmentId;
    }
    if (euTpdRegistered != null) {
      queryParams['euTpdRegistered'] = euTpdRegistered.toString();
    }
    if (pactActRegistered != null) {
      queryParams['pactActRegistered'] = pactActRegistered.toString();
    }
    if (isManufacturingFacility != null) {
      queryParams['isManufacturingFacility'] = isManufacturingFacility
          .toString();
    }
    if (isUiIssuer != null) {
      queryParams['isUiIssuer'] = isUiIssuer.toString();
    }
    if (bondedWarehouse != null) {
      queryParams['bondedWarehouse'] = bondedWarehouse.toString();
    }
    if (stateTobaccoLicenseState != null) {
      queryParams['stateTobaccoLicenseState'] = stateTobaccoLicenseState;
    }

    final response = await _dioService.get(
      '$_baseUrl/search',
      queryParameters: queryParams,
      headers: await _headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.data);
      return data.map((json) => GLNTobaccoExtension.fromJson(json)).toList();
    } else {
      throw Exception(
        'Failed to search GLN tobacco extensions: ${response.statusCode}',
      );
    }
  }
}
