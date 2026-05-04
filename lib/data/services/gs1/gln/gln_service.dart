import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/data/services/gs1/gln/gln_api_consts.dart';

/// Implementation of GLNService interface for managing GLNs (Global Location Numbers)
class GLNService {
  final DioService _dioService;

  /// Creates a new GLNServiceImpl instance
  GLNService({
    required DioService dioService,
  }) : _dioService = dioService;

  Future<List<GLN>> getAllGLNs({int? page, int? size}) async {
    final token = await _dioService.getAuthToken();
    if (token == null) {
      throw ApiException(message: GlnApiMessages.noAuthToken);
    }

    String url = '${_dioService.baseUrl}${GlnMasterDataApiConsts.prefix}';
    if (page != null && size != null) {
      url += '?page=$page&size=$size';
    }

    final response = await _dioService.get(
      url,
      headers: {
        GlnApiHttpConsts.contentTypeHeader: GlnApiHttpConsts.contentTypeJson,
        GlnApiHttpConsts.authorizationHeader:
            '${GlnApiHttpConsts.bearerPrefix}$token',
      },
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );
    print('GLN list response status: ${response.statusCode}, body: ${response.data}');
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.data);
      if (responseData.containsKey(GlnApiHttpConsts.jsonKeyContent) &&
          responseData[GlnApiHttpConsts.jsonKeyContent] is List) {
        final List<dynamic> data = responseData[GlnApiHttpConsts.jsonKeyContent];
        return data.map((json) => GLN.fromJson(json)).toList();
      } else {
        if (responseData is List) {
          return (responseData as List).map((json) => GLN.fromJson(json)).toList();
        } else {
          throw ApiException(
            message: GlnApiMessages.unexpectedListFormat,
            responseBody: response.data,
          );
        }
      }
    } else if (response.statusCode == 403) {
      print(GlnApiMessages.authTokenInvalidOrExpired);
      throw ApiException(
        statusCode: response.statusCode,
        message: GlnApiMessages.authFailedLoginAgain,
        responseBody: response.data,
      );
    } else {
      print(
          'GLN list error: ${response.statusCode} - ${response.statusMessage}');
      throw ApiException(
        statusCode: response.statusCode,
        message: GlnApiMessages.failedToLoadGlns(response.statusMessage),
        responseBody: response.data,
      );
    }
  }

  Future<GLN> getGLNById(String id) async {
    final token = await _dioService.getAuthToken();
    if (token == null) {
      throw ApiException(message: GlnApiMessages.noAuthToken);
    }

    print('GLN Service: Fetching GLN with ID: $id');
    final url =
        '${_dioService.baseUrl}${GlnMasterDataApiConsts.byCodePath(id)}';
    print('GLN Service: Request URL: $url');

    final response = await _dioService.get(
      url,
      headers: {
        GlnApiHttpConsts.contentTypeHeader: GlnApiHttpConsts.contentTypeJson,
        GlnApiHttpConsts.authorizationHeader:
            '${GlnApiHttpConsts.bearerPrefix}$token',
      },
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    print('GLN Service: Response status code: ${response.statusCode}');

    if (response.statusCode == 200) {
      print('GLN Service: Raw API Response: ${response.data}');
      final jsonData = json.decode(response.data);
      print('GLN Service: Decoded API Response: $jsonData');
      final gln = GLN.fromJson(jsonData);
      print(
          'GLN Service: Converted to GLN object: ${gln.glnCode}, ${gln.locationName}');
      return gln;
    } else {
      print('GLN Service: Error response: ${response.data}');
      throw ApiException(
        statusCode: response.statusCode,
        message: GlnApiMessages.failedToGetGln(response.statusMessage),
        responseBody: response.data,
      );
    }
  }

  Future<GLN> getGLNByCode(String glnCode) async {
    final token = await _dioService.getAuthToken();
    if (token == null) {
      throw ApiException(message: GlnApiMessages.noAuthToken);
    }

    final response = await _dioService.get(
      '${_dioService.baseUrl}${GlnMasterDataApiConsts.byCodePath(glnCode)}',
      headers: {
        GlnApiHttpConsts.contentTypeHeader: GlnApiHttpConsts.contentTypeJson,
        GlnApiHttpConsts.authorizationHeader:
            '${GlnApiHttpConsts.bearerPrefix}$token',
      },
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return GLN.fromJson(json.decode(response.data));
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: GlnApiMessages.failedToGetGlnByCode(response.statusMessage),
      );
    }
  }

  Future<GLN> createGLN(GLN gln) async {
    final token = await _dioService.getAuthToken();
    if (token == null) {
      throw ApiException(message: GlnApiMessages.noAuthToken);
    }

    final response = await _dioService.post(
      '${_dioService.baseUrl}${GlnMasterDataApiConsts.prefix}',
      headers: {
        GlnApiHttpConsts.contentTypeHeader: GlnApiHttpConsts.contentTypeJson,
        GlnApiHttpConsts.authorizationHeader:
            '${GlnApiHttpConsts.bearerPrefix}$token',
      },
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
      );
    }
  }

  Future<GLN> updateGLN(String id, GLN gln) async {
    final token = await _dioService.getAuthToken();
    if (token == null) {
      throw ApiException(message: GlnApiMessages.noAuthToken);
    }

    final response = await _dioService.put(
      '${_dioService.baseUrl}${GlnMasterDataApiConsts.byCodePath(id)}',
      headers: {
        GlnApiHttpConsts.contentTypeHeader: GlnApiHttpConsts.contentTypeJson,
        GlnApiHttpConsts.authorizationHeader:
            '${GlnApiHttpConsts.bearerPrefix}$token',
      },
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
      );
    }
  }

  Future<bool> deleteGLN(String id) async {
    final token = await _dioService.getAuthToken();
    if (token == null) {
      throw ApiException(message: GlnApiMessages.noAuthToken);
    }

    final response = await _dioService.delete(
      '${_dioService.baseUrl}${GlnMasterDataApiConsts.byCodePath(id)}',
      headers: {
        GlnApiHttpConsts.contentTypeHeader: GlnApiHttpConsts.contentTypeJson,
        GlnApiHttpConsts.authorizationHeader:
            '${GlnApiHttpConsts.bearerPrefix}$token',
      },
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    return response.statusCode == 204;
  }

  Future<List<GLN>> searchGLNs({
    String? searchTerm,
    String? locationType,
    bool? active,
    int? page,
    int? size,
  }) async {
    final token = await _dioService.getAuthToken();
    if (token == null) {
      throw ApiException(message: GlnApiMessages.noAuthToken);
    }

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
      headers: {
        GlnApiHttpConsts.contentTypeHeader: GlnApiHttpConsts.contentTypeJson,
        GlnApiHttpConsts.authorizationHeader:
            '${GlnApiHttpConsts.bearerPrefix}$token',
      },
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.data);
      if (responseData.containsKey(GlnApiHttpConsts.jsonKeyContent) &&
          responseData[GlnApiHttpConsts.jsonKeyContent] is List) {
        final List<dynamic> data = responseData[GlnApiHttpConsts.jsonKeyContent];
        return data.map((json) => GLN.fromJson(json)).toList();
      } else {
        if (responseData is List) {
          return (responseData as List).map((json) => GLN.fromJson(json)).toList();
        } else {
          throw ApiException(
            message: GlnApiMessages.unexpectedSearchFormat,
            responseBody: response.data,
          );
        }
      }
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: GlnApiMessages.failedToSearchGlns(response.statusMessage),
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
    final token = await _dioService.getAuthToken();
    if (token == null) {
      throw ApiException(message: GlnApiMessages.noAuthToken);
    }

    var queryParams = <String, String>{
      'page': page.toString(),
      'size': size.toString(),
      'sortBy': sortBy,
      'direction': direction,
    };

    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }
    if (glnCode != null && glnCode.isNotEmpty) {
      queryParams['glnCode'] = glnCode;
    }
    if (name != null && name.isNotEmpty) {
      queryParams['name'] = name;
    }
    if (address != null && address.isNotEmpty) {
      queryParams['address'] = address;
    }
    if (licenseNo != null && licenseNo.isNotEmpty) {
      queryParams['licenseNo'] = licenseNo;
    }
    if (contactEmail != null && contactEmail.isNotEmpty) {
      queryParams['contactEmail'] = contactEmail;
    }
    if (contactName != null && contactName.isNotEmpty) {
      queryParams['contactName'] = contactName;
    }
    if (active != null) {
      queryParams['active'] = active.toString();
    }
    if (locationType != null && locationType.isNotEmpty) {
      queryParams['locationType'] = locationType;
    }

    final response = await _dioService.get(
      '${_dioService.baseUrl}${GlnMasterDataApiConsts.searchAdvanced}',
      queryParameters: queryParams,
      headers: {
        GlnApiHttpConsts.contentTypeHeader: GlnApiHttpConsts.contentTypeJson,
        GlnApiHttpConsts.authorizationHeader:
            '${GlnApiHttpConsts.bearerPrefix}$token',
      },
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return json.decode(response.data);
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: GlnApiMessages.failedToSearchGlns(response.statusMessage),
      );
    }
  }

  Future<List<GLN>> getExpiredLicenseGLNs() async {
    final token = await _dioService.getAuthToken();
    if (token == null) {
      throw ApiException(message: GlnApiMessages.noAuthToken);
    }
    final response = await _dioService.get(
      '${_dioService.baseUrl}${GlnMasterDataApiConsts.expiredLicenses}',
      headers: {
        GlnApiHttpConsts.contentTypeHeader: GlnApiHttpConsts.contentTypeJson,
        GlnApiHttpConsts.authorizationHeader:
            '${GlnApiHttpConsts.bearerPrefix}$token',
      },
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );
    if (response.statusCode == 200) {
      final responseData = json.decode(response.data);
      if (responseData is Map<String, dynamic> &&
          responseData.containsKey(GlnApiHttpConsts.jsonKeyContent) &&
          responseData[GlnApiHttpConsts.jsonKeyContent] is List) {
        final List<dynamic> data = responseData[GlnApiHttpConsts.jsonKeyContent];
        return data.map((json) => GLN.fromJson(json)).toList();
      } else if (responseData is List) {
        return responseData.map((json) => GLN.fromJson(json)).toList();
      } else {
        throw ApiException(
          message: GlnApiMessages.unexpectedExpiredLicensesFormat,
          responseBody: response.data,
        );
      }
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: GlnApiMessages.failedExpiredLicenses(response.statusMessage),
      );
    }
  }

  Future<List<GLN>> getChildGLNs(String parentGlnCode) async {
    final token = await _dioService.getAuthToken();
    if (token == null) {
      throw ApiException(message: GlnApiMessages.noAuthToken);
    }
    final response = await _dioService.get(
      '${_dioService.baseUrl}${GlnMasterDataApiConsts.parentChildrenPath(parentGlnCode)}',
      headers: {
        GlnApiHttpConsts.contentTypeHeader: GlnApiHttpConsts.contentTypeJson,
        GlnApiHttpConsts.authorizationHeader:
            '${GlnApiHttpConsts.bearerPrefix}$token',
      },
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );
    if (response.statusCode == 200) {
      final responseData = json.decode(response.data);
      if (responseData is Map<String, dynamic> &&
          responseData.containsKey(GlnApiHttpConsts.jsonKeyContent) &&
          responseData[GlnApiHttpConsts.jsonKeyContent] is List) {
        final List<dynamic> data = responseData[GlnApiHttpConsts.jsonKeyContent];
        return data.map((json) => GLN.fromJson(json)).toList();
      } else if (responseData is List) {
        return responseData.map((json) => GLN.fromJson(json)).toList();
      } else {
        throw ApiException(
          message: GlnApiMessages.unexpectedChildGlnsFormat,
          responseBody: response.data,
        );
      }
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: GlnApiMessages.failedChildGlns(response.statusMessage),
      );
    }
  }

  Future<bool> validateGLNCode(String glnCode) async {
    final token = await _dioService.getAuthToken();
    if (token == null) {
      throw ApiException(message: GlnApiMessages.noAuthToken);
    }
    final response = await _dioService.get(
      '${_dioService.baseUrl}${GlnMasterDataApiConsts.validatePath(glnCode)}',
      headers: {
        GlnApiHttpConsts.contentTypeHeader: GlnApiHttpConsts.contentTypeJson,
        GlnApiHttpConsts.authorizationHeader:
            '${GlnApiHttpConsts.bearerPrefix}$token',
      },
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
      );
    }
  }

  /// Derive GS1 identification for chips: [gs1CompanyPrefixLength], [gs1CompanyPrefix], [locationReference], [checkDigit].
  Future<Map<String, dynamic>> deriveIdentification(String glnCode) async {
    final token = await _dioService.getAuthToken();
    if (token == null) {
      throw ApiException(message: GlnApiMessages.noAuthToken);
    }

    final response = await _dioService.post(
      '${_dioService.baseUrl}${GlnMasterDataApiConsts.deriveIdentification}',
      headers: {
        GlnApiHttpConsts.contentTypeHeader: GlnApiHttpConsts.contentTypeJson,
        GlnApiHttpConsts.authorizationHeader:
            '${GlnApiHttpConsts.bearerPrefix}$token',
      },
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
      responseBody: response.data,
    );
  }
}
