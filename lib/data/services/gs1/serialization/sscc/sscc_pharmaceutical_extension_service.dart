import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/core/network/page_response_utils.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';
import 'package:traqtrace_app/data/models/gs1/serialization/sscc/sscc_pharmaceutical_extension_model.dart';
import 'package:traqtrace_app/data/services/gs1/serialization/sscc/sscc_service_constants.dart';

class SSCCPharmaceuticalExtensionService {
  final DioService _dioService;

  SSCCPharmaceuticalExtensionService({required DioService dioService})
    : _dioService = dioService;

  String get _specCrudBase =>
      '${_dioService.baseUrl}${SsccServiceConstants.pathBase}';

  String get _legacyQueryBase => '${_dioService.baseUrl}/pharmaceutical/sscc';

  static const _headers = {
    SsccServiceConstants.headerContentType:
        SsccServiceConstants.contentTypeJson,
  };

  Future<SSCCPharmaceuticalExtension> createBySsccCode(
    String ssccCode,
    SSCCPharmaceuticalExtension extension,
  ) async {
    final response = await _dioService.post(
      '$_specCrudBase/code/pharmaceutical-extension',
      queryParameters: {SsccServiceConstants.qSsccCode: ssccCode},
      headers: _headers,
      data: jsonEncode(extension.toJson()),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return SSCCPharmaceuticalExtension.fromJson(jsonDecode(response.data));
    } else {
      throw ApiException(
        message:
            'Failed to create SSCC pharmaceutical extension: ${response.statusCode}',
      );
    }
  }

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
      throw ApiException(
        message:
            'Failed to save SSCC pharmaceutical extension: ${response.statusCode}',
      );
    }
  }

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
      throw ApiException(
        message:
            'Failed to fetch SSCC pharmaceutical extension: ${response.statusCode}',
      );
    }
  }

  Future<SSCCPharmaceuticalExtension?> getBySsccCode(String ssccCode) async {
    final response = await _dioService.get(
      '$_specCrudBase/code/pharmaceutical-extension',
      queryParameters: {SsccServiceConstants.qSsccCode: ssccCode},
      headers: _headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return SSCCPharmaceuticalExtension.fromJson(jsonDecode(response.data));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw ApiException(
        message:
            'Failed to fetch SSCC pharmaceutical extension: ${response.statusCode}',
      );
    }
  }

  Future<void> delete(int ssccId) async {
    final response = await _dioService.delete(
      '$_specCrudBase/$ssccId/pharmaceutical-extension',
      headers: _headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw ApiException(
        message:
            'Failed to delete SSCC pharmaceutical extension: ${response.statusCode}',
      );
    }
  }

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
      throw ApiException(
        message:
            'Failed to check SSCC pharmaceutical extension: ${response.statusCode}',
      );
    }
  }

  Future<Map<String, dynamic>> _getPharmaExtensionPage(
    String path, {
    required int page,
    required int size,
  }) async {
    final response = await _dioService.get(
      path,
      queryParameters: {
        'page': page.toString(),
        'size': PageResponseUtils.clampSize(size).toString(),
      },
      headers: _headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return PageResponseUtils.normalizeBody(jsonDecode(response.data));
    }
    throw ApiException(
      message:
          'Failed to fetch pharmaceutical extensions: ${response.statusCode}',
    );
  }

  Future<List<SSCCPharmaceuticalExtension>> _fetchAllPharmaExtensions(
    String path,
  ) {
    return PageResponseUtils.fetchAllPages(
      fetchPage: (page, size) =>
          _getPharmaExtensionPage(path, page: page, size: size),
      parseItem: SSCCPharmaceuticalExtension.fromJson,
    );
  }

  Future<List<SSCCPharmaceuticalExtension>> findColdChainShipments() async {
    return _fetchAllPharmaExtensions('$_legacyQueryBase/cold-chain');
  }

  Future<List<SSCCPharmaceuticalExtension>>
  findTemperatureMonitoredShipments() async {
    return _fetchAllPharmaExtensions('$_legacyQueryBase/temperature-monitored');
  }

  Future<List<SSCCPharmaceuticalExtension>> findGdpCompliantShipments() async {
    return _fetchAllPharmaExtensions('$_legacyQueryBase/gdp-compliant');
  }

  Future<List<SSCCPharmaceuticalExtension>>
  findControlledSubstanceShipments() async {
    return _fetchAllPharmaExtensions('$_legacyQueryBase/controlled-substance');
  }

  Future<List<SSCCPharmaceuticalExtension>> findByDeaSchedule(
    String deaSchedule,
  ) async {
    return _fetchAllPharmaExtensions(
      '$_legacyQueryBase/dea-schedule/$deaSchedule',
    );
  }

  Future<List<SSCCPharmaceuticalExtension>> findHazmatShipments() async {
    return _fetchAllPharmaExtensions('$_legacyQueryBase/hazmat');
  }

  Future<List<SSCCPharmaceuticalExtension>>
  findChainOfCustodyShipments() async {
    return _fetchAllPharmaExtensions('$_legacyQueryBase/chain-of-custody');
  }

  Future<List<SSCCPharmaceuticalExtension>>
  findSignatureRequiredShipments() async {
    return _fetchAllPharmaExtensions('$_legacyQueryBase/signature-required');
  }

  Future<List<SSCCPharmaceuticalExtension>> findClinicalTrialShipments() async {
    return _fetchAllPharmaExtensions('$_legacyQueryBase/clinical-trial');
  }

  Future<List<SSCCPharmaceuticalExtension>> findFragileShipments() async {
    return _fetchAllPharmaExtensions('$_legacyQueryBase/fragile');
  }

  Future<List<SSCCPharmaceuticalExtension>> findDoNotStackShipments() async {
    return _fetchAllPharmaExtensions('$_legacyQueryBase/do-not-stack');
  }
}
