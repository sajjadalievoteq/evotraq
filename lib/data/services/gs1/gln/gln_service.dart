import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/data/services/gs1/gln/gln_api_consts.dart';
import 'package:traqtrace_app/features/gs1/gln/utils/gln_list_parsing.dart';

/// GLN (Global Location Number) master-data API client.
///
/// Auth is handled transparently by [DioService]'s interceptor, which reads
/// the stored Bearer token and attaches it to every request. No manual token
/// handling is needed here.
class GLNService {
  final DioService _dioService;

  GLNService({
    required DioService dioService,
  }) : _dioService = dioService;

  String get _base => '${_dioService.baseUrl}${GlnMasterDataApiConsts.prefix}';

  static const _headers = {
    GlnApiHttpConsts.contentTypeHeader: GlnApiHttpConsts.contentTypeJson,
  };

  Future<List<GLN>> getAllGLNs({int? page, int? size}) async {
    String url = _base;
    if (page != null && size != null) {
      url += '?page=$page&size=$size';
    }

    final response = await _dioService.get(
      url,
      headers: _headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (kDebugMode) {
      debugPrint('[GLNService] getAllGLNs status=${response.statusCode}');
    }

    if (response.statusCode == 200) {
      final decoded = json.decode(response.data);
      return parseGlnListFromResponseData(decoded);
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: GlnApiMessages.failedToLoadGlns(response.statusMessage),
        responseBody: response.data is String ? response.data as String? : null,
      );
    }
  }

  Future<GLN> getGLNById(String id) async {
    final url = '${_dioService.baseUrl}${GlnMasterDataApiConsts.byCodePath(id)}';

    if (kDebugMode) {
      debugPrint('[GLNService] getGLNById url=$url');
    }

    final response = await _dioService.get(
      url,
      headers: _headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (kDebugMode) {
      debugPrint('[GLNService] getGLNById status=${response.statusCode}');
    }

    if (response.statusCode == 200) {
      return GLN.fromJson(json.decode(response.data));
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: GlnApiMessages.failedToGetGln(response.statusMessage),
        responseBody: response.data is String ? response.data as String? : null,
      );
    }
  }

  Future<GLN> getGLNByCode(String glnCode) async {
    final response = await _dioService.get(
      '${_dioService.baseUrl}${GlnMasterDataApiConsts.byCodePath(glnCode)}',
      headers: _headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return GLN.fromJson(json.decode(response.data));
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: GlnApiMessages.failedToGetGlnByCode(response.statusMessage),
        responseBody: response.data is String ? response.data as String? : null,
      );
    }
  }

  Future<GLN> createGLN(GLN gln) async {
    final response = await _dioService.post(
      _base,
      headers: _headers,
      data: json.encode(gln.toJson()),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 201) {
      return GLN.fromJson(json.decode(response.data));
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: GlnApiMessages.failedToCreateGln(response.statusMessage),
        responseBody: response.data is String ? response.data as String? : null,
      );
    }
  }

  Future<GLN> updateGLN(String id, GLN gln) async {
    final response = await _dioService.put(
      '${_dioService.baseUrl}${GlnMasterDataApiConsts.byCodePath(id)}',
      headers: _headers,
      data: json.encode(gln.toJson()),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return GLN.fromJson(json.decode(response.data));
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: GlnApiMessages.failedToUpdateGln(response.statusMessage),
        responseBody: response.data is String ? response.data as String? : null,
      );
    }
  }

  Future<void> updateGLNStatus(String glnCode, String status) async {
    final response = await _dioService.put(
      '$_base/code/$glnCode/status',
      headers: _headers,
      data: json.encode({'status': status}),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode != 200) {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to update GLN status: ${response.statusMessage}',
        responseBody: response.data is String ? response.data as String? : null,
      );
    }
  }

  Future<bool> deleteGLN(String id) async {
    final response = await _dioService.delete(
      '${_dioService.baseUrl}${GlnMasterDataApiConsts.byCodePath(id)}',
      headers: _headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 204) {
      return true;
    }
    throw ApiException(
      statusCode: response.statusCode,
      message: 'Failed to delete GLN: ${response.statusMessage}',
      responseBody: response.data is String ? response.data as String? : null,
    );
  }

  Future<List<GLN>> searchGLNs({
    String? searchTerm,
    String? locationType,
    bool? active,
    int? page,
    int? size,
  }) async {
    var queryParams = <String, String>{};
    if (searchTerm != null && searchTerm.isNotEmpty) {
      queryParams['search'] = searchTerm;
    }
    if (locationType != null && locationType.isNotEmpty) {
      queryParams['locationType'] = locationType;
    }
    if (active != null) {
      queryParams['active'] = active.toString();
    }
    if (page != null) {
      queryParams['page'] = page.toString();
    }
    if (size != null) {
      queryParams['size'] = size.toString();
    }

    final response = await _dioService.get(
      '${_dioService.baseUrl}${GlnMasterDataApiConsts.search}',
      queryParameters: queryParams,
      headers: _headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final decoded = json.decode(response.data);
      return parseGlnListFromResponseData(decoded);
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: GlnApiMessages.failedToSearchGlns(response.statusMessage),
        responseBody: response.data is String ? response.data as String? : null,
      );
    }
  }

  Future<Map<String, dynamic>> searchGLNsAdvanced({
    String? search,
    String? glnCode,
    String? name,
    String? address,
    String? licenseNo,
    String? contactEmail,
    String? contactName,
    bool? active,
    String? locationType,
    int page = 0,
    int size = 20,
    String sortBy = 'name',
    String direction = 'ASC',
  }) async {
    var queryParams = <String, String>{
      'page': page.toString(),
      'size': size.toString(),
      'sortBy': sortBy,
      'direction': direction,
    };

    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (glnCode != null && glnCode.isNotEmpty) queryParams['glnCode'] = glnCode;
    if (name != null && name.isNotEmpty) queryParams['name'] = name;
    if (address != null && address.isNotEmpty) queryParams['address'] = address;
    if (licenseNo != null && licenseNo.isNotEmpty) queryParams['licenseNo'] = licenseNo;
    if (contactEmail != null && contactEmail.isNotEmpty) queryParams['contactEmail'] = contactEmail;
    if (contactName != null && contactName.isNotEmpty) queryParams['contactName'] = contactName;
    if (active != null) queryParams['active'] = active.toString();
    if (locationType != null && locationType.isNotEmpty) queryParams['locationType'] = locationType;

    final response = await _dioService.get(
      '${_dioService.baseUrl}${GlnMasterDataApiConsts.searchAdvanced}',
      queryParameters: queryParams,
      headers: _headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return json.decode(response.data);
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: GlnApiMessages.failedToSearchGlns(response.statusMessage),
        responseBody: response.data is String ? response.data as String? : null,
      );
    }
  }

  Future<List<GLN>> getExpiredLicenseGLNs() async {
    final response = await _dioService.get(
      '${_dioService.baseUrl}${GlnMasterDataApiConsts.expiredLicenses}',
      headers: _headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.data);
      return parseGlnListFromResponseData(responseData);
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: GlnApiMessages.failedExpiredLicenses(response.statusMessage),
        responseBody: response.data is String ? response.data as String? : null,
      );
    }
  }

  Future<List<GLN>> getChildGLNs(String parentGlnCode) async {
    final response = await _dioService.get(
      '${_dioService.baseUrl}${GlnMasterDataApiConsts.parentChildrenPath(parentGlnCode)}',
      headers: _headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.data);
      return parseGlnListFromResponseData(responseData);
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: GlnApiMessages.failedChildGlns(response.statusMessage),
        responseBody: response.data is String ? response.data as String? : null,
      );
    }
  }

  Future<bool> validateGLNCode(String glnCode) async {
    final response = await _dioService.get(
      '${_dioService.baseUrl}${GlnMasterDataApiConsts.validatePath(glnCode)}',
      headers: _headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.data);
      final dynamic v = data[GlnApiHttpConsts.jsonKeyValid] ??
          data[GlnApiHttpConsts.jsonKeyIsValid];
      if (v is bool) return v;
      if (v is String) return v.toLowerCase() == 'true';
      return false;
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: GlnApiMessages.failedValidateGln(response.statusMessage),
        responseBody: response.data is String ? response.data as String? : null,
      );
    }
  }

  /// Derive GS1 identification for chips: [gs1CompanyPrefixLength], [gs1CompanyPrefix],
  /// [locationReference], [checkDigit].
  Future<Map<String, dynamic>> deriveIdentification(String glnCode) async {
    final response = await _dioService.post(
      '${_dioService.baseUrl}${GlnMasterDataApiConsts.deriveIdentification}',
      headers: _headers,
      data: json.encode({GlnApiHttpConsts.jsonKeyGlnCode: glnCode}),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(json.decode(response.data) as Map);
    }
    throw ApiException(
      statusCode: response.statusCode,
      message: GlnApiMessages.failedDeriveIdentification(response.statusMessage),
      responseBody: response.data is String ? response.data as String? : null,
    );
  }
}
