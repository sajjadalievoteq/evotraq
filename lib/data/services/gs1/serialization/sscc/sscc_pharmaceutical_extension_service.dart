import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';
import 'package:traqtrace_app/data/models/gs1/serialization/sscc/sscc_pharmaceutical_extension_model.dart';
import 'package:traqtrace_app/data/services/gs1/serialization/sscc/sscc_service_constants.dart';

/// Service for SSCC pharmaceutical extension operations
class SSCCPharmaceuticalExtensionService {
  final DioService _dioService;

  SSCCPharmaceuticalExtensionService({
    required DioService dioService,
  }) : _dioService = dioService;

  /// Spec-aligned CRUD routes under `/identifiers/ssccs`.
  String get _specCrudBase =>
      '${_dioService.baseUrl}${SsccServiceConstants.pathBase}';

  /// Legacy query routes (cold-chain, GDP, etc.).
  String get _legacyQueryBase => '${_dioService.baseUrl}/pharmaceutical/sscc';

  /// Auth is handled transparently by [DioService]'s interceptor.
  static const _headers = {
    SsccServiceConstants.headerContentType: SsccServiceConstants.contentTypeJson,
  };

  /// Create pharmaceutical extension for an SSCC by code
  Future<SSCCPharmaceuticalExtension> createBySsccCode(
    String ssccCode,
    SSCCPharmaceuticalExtension extension,
  ) async {
    final response = await _dioService.post(
      '$_specCrudBase/code/$ssccCode/pharmaceutical-extension',
      headers: _headers,
      data: jsonEncode(extension.toJson()),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return SSCCPharmaceuticalExtension.fromJson(jsonDecode(response.data));
    } else {
      throw ApiException(message:
        'Failed to create SSCC pharmaceutical extension: ${response.statusCode}',
      );
    }
  }

  /// Save or update pharmaceutical extension for an SSCC
  Future<SSCCPharmaceuticalExtension> saveBySsccId(
    int ssccId,
    SSCCPharmaceuticalExtension extension,
  ) async {
    final response = await _dioService.post(
      '$_specCrudBase/$ssccId/pharmaceutical-extension',
      headers: _headers,
      data: jsonEncode(extension.toJson()),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return SSCCPharmaceuticalExtension.fromJson(jsonDecode(response.data));
    } else {
      throw ApiException(message:
        'Failed to save SSCC pharmaceutical extension: ${response.statusCode}',
      );
    }
  }

  /// Get pharmaceutical extension by SSCC ID
  Future<SSCCPharmaceuticalExtension?> getBySsccId(int ssccId) async {
    final response = await _dioService.get(
      '$_specCrudBase/$ssccId/pharmaceutical-extension',
      headers: _headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return SSCCPharmaceuticalExtension.fromJson(jsonDecode(response.data));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw ApiException(message:
        'Failed to fetch SSCC pharmaceutical extension: ${response.statusCode}',
      );
    }
  }

  /// Get pharmaceutical extension by SSCC code
  Future<SSCCPharmaceuticalExtension?> getBySsccCode(String ssccCode) async {
    final response = await _dioService.get(
      '$_specCrudBase/code/$ssccCode/pharmaceutical-extension',
      headers: _headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return SSCCPharmaceuticalExtension.fromJson(jsonDecode(response.data));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw ApiException(message:
        'Failed to fetch SSCC pharmaceutical extension: ${response.statusCode}',
      );
    }
  }

  /// Delete pharmaceutical extension for an SSCC
  Future<void> delete(int ssccId) async {
    final response = await _dioService.delete(
      '$_specCrudBase/$ssccId/pharmaceutical-extension',
      headers: _headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw ApiException(message:
        'Failed to delete SSCC pharmaceutical extension: ${response.statusCode}',
      );
    }
  }

  /// Check if an SSCC has pharmaceutical extension
  Future<bool> hasPharmaceuticalExtension(int ssccId) async {
    final response = await _dioService.get(
      '$_legacyQueryBase/$ssccId/exists',
      headers: _headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.data) as bool;
    } else {
      throw ApiException(message:
        'Failed to check SSCC pharmaceutical extension: ${response.statusCode}',
      );
    }
  }

  // ===== Cold Chain Queries =====

  /// Find all cold chain required shipments
  Future<List<SSCCPharmaceuticalExtension>> findColdChainShipments() async {
    final response = await _dioService.get(
      '$_legacyQueryBase/cold-chain',
      headers: _headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.data);
      return data
          .map((json) => SSCCPharmaceuticalExtension.fromJson(json))
          .toList();
    } else {
      throw ApiException(message:
        'Failed to fetch cold chain shipments: ${response.statusCode}',
      );
    }
  }

  /// Find shipments requiring temperature monitoring
  Future<List<SSCCPharmaceuticalExtension>>
      findTemperatureMonitoredShipments() async {
    final response = await _dioService.get(
      '$_legacyQueryBase/temperature-monitored',
      headers: _headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.data);
      return data
          .map((json) => SSCCPharmaceuticalExtension.fromJson(json))
          .toList();
    } else {
      throw ApiException(message:
        'Failed to fetch temperature monitored shipments: ${response.statusCode}',
      );
    }
  }

  // ===== GDP Compliance Queries =====

  /// Find GDP compliant shipments
  Future<List<SSCCPharmaceuticalExtension>> findGdpCompliantShipments() async {
    final response = await _dioService.get(
      '$_legacyQueryBase/gdp-compliant',
      headers: _headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.data);
      return data
          .map((json) => SSCCPharmaceuticalExtension.fromJson(json))
          .toList();
    } else {
      throw ApiException(message:
        'Failed to fetch GDP compliant shipments: ${response.statusCode}',
      );
    }
  }

  // ===== Controlled Substance Queries =====

  /// Find controlled substance shipments
  Future<List<SSCCPharmaceuticalExtension>>
      findControlledSubstanceShipments() async {
    final response = await _dioService.get(
      '$_legacyQueryBase/controlled-substance',
      headers: _headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.data);
      return data
          .map((json) => SSCCPharmaceuticalExtension.fromJson(json))
          .toList();
    } else {
      throw ApiException(message:
        'Failed to fetch controlled substance shipments: ${response.statusCode}',
      );
    }
  }

  /// Find by DEA schedule
  Future<List<SSCCPharmaceuticalExtension>> findByDeaSchedule(
      String deaSchedule) async {
    final response = await _dioService.get(
      '$_legacyQueryBase/dea-schedule/$deaSchedule',
      headers: _headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.data);
      return data
          .map((json) => SSCCPharmaceuticalExtension.fromJson(json))
          .toList();
    } else {
      throw ApiException(message:
        'Failed to fetch DEA schedule shipments: ${response.statusCode}',
      );
    }
  }

  // ===== Hazmat Queries =====

  /// Find all hazmat shipments
  Future<List<SSCCPharmaceuticalExtension>> findHazmatShipments() async {
    final response = await _dioService.get(
      '$_legacyQueryBase/hazmat',
      headers: _headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.data);
      return data
          .map((json) => SSCCPharmaceuticalExtension.fromJson(json))
          .toList();
    } else {
      throw ApiException(message:
        'Failed to fetch hazmat shipments: ${response.statusCode}',
      );
    }
  }

  // ===== Chain of Custody Queries =====

  /// Find shipments requiring chain of custody
  Future<List<SSCCPharmaceuticalExtension>> findChainOfCustodyShipments() async {
    final response = await _dioService.get(
      '$_legacyQueryBase/chain-of-custody',
      headers: _headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.data);
      return data
          .map((json) => SSCCPharmaceuticalExtension.fromJson(json))
          .toList();
    } else {
      throw ApiException(message:
        'Failed to fetch chain of custody shipments: ${response.statusCode}',
      );
    }
  }

  /// Find shipments requiring signature on receipt
  Future<List<SSCCPharmaceuticalExtension>>
      findSignatureRequiredShipments() async {
    final response = await _dioService.get(
      '$_legacyQueryBase/signature-required',
      headers: _headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.data);
      return data
          .map((json) => SSCCPharmaceuticalExtension.fromJson(json))
          .toList();
    } else {
      throw ApiException(message:
        'Failed to fetch signature required shipments: ${response.statusCode}',
      );
    }
  }

  // ===== Clinical Trial Queries =====

  /// Find clinical trial shipments
  Future<List<SSCCPharmaceuticalExtension>> findClinicalTrialShipments() async {
    final response = await _dioService.get(
      '$_legacyQueryBase/clinical-trial',
      headers: _headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.data);
      return data
          .map((json) => SSCCPharmaceuticalExtension.fromJson(json))
          .toList();
    } else {
      throw ApiException(message:
        'Failed to fetch clinical trial shipments: ${response.statusCode}',
      );
    }
  }

  // ===== Special Handling Queries =====

  /// Find fragile shipments
  Future<List<SSCCPharmaceuticalExtension>> findFragileShipments() async {
    final response = await _dioService.get(
      '$_legacyQueryBase/fragile',
      headers: _headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.data);
      return data
          .map((json) => SSCCPharmaceuticalExtension.fromJson(json))
          .toList();
    } else {
      throw ApiException(message:
        'Failed to fetch fragile shipments: ${response.statusCode}',
      );
    }
  }

  /// Find do-not-stack shipments
  Future<List<SSCCPharmaceuticalExtension>> findDoNotStackShipments() async {
    final response = await _dioService.get(
      '$_legacyQueryBase/do-not-stack',
      headers: _headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.data);
      return data
          .map((json) => SSCCPharmaceuticalExtension.fromJson(json))
          .toList();
    } else {
      throw ApiException(message:
        'Failed to fetch do-not-stack shipments: ${response.statusCode}',
      );
    }
  }
}
