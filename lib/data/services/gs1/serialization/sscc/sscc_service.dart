import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';
import 'package:traqtrace_app/core/network/page_response_utils.dart';
import 'package:traqtrace_app/data/models/gs1/serialization/sscc/sscc_model.dart';
import 'package:traqtrace_app/data/services/gs1/serialization/sscc/sscc_service_constants.dart';
import 'package:traqtrace_app/features/gs1/sscc/utils/sscc_list_parsing.dart';

import 'package:traqtrace_app/data/services/gs1/serialization/sscc/sscc_service_operations.dart';

class SSCCService {
  final DioService dioService;

  SSCCService({required DioService dioService}) : dioService = dioService;

  static const headers = {
    SsccServiceConstants.headerContentType:
        SsccServiceConstants.contentTypeJson,
  };

  Future<SSCC> createSSCC(SSCC sscc) async {
    if (sscc.ssccCode.isEmpty) {
      throw ApiException(message: 'SSCC code is required');
    }
    if (sscc.ssccCode.length != 18) {
      throw ApiException(message: 'SSCC code must be exactly 18 digits');
    }

    final response = await dioService.post(
      '${dioService.baseUrl}${SsccServiceConstants.pathBase}',
      headers: headers,
      data: json.encode(sscc.toJson()),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 201) {
      final responseData = json.decode(response.data);

      if (responseData is String) {
        final Map<String, dynamic> ssccJson = {
          'sscc': responseData,
          'unitType': sscc.unitType.name,
          'status': sscc.status.name,
          'packingDate': sscc.packingDate?.toIso8601String(),
          'issuingGLN': sscc.issuingGLN?.glnCode,
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        };
        return SSCC.fromJson(ssccJson);
      } else if (responseData is Map<String, dynamic>) {
        return SSCC.fromJson(responseData);
      } else {
        throw ApiException(
          statusCode: response.statusCode,
          message:
              'Unexpected response format from server: ${responseData.runtimeType}',
          responseBody: response.data is String
              ? response.data as String
              : null,
        );
      }
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to create SSCC: ${response.statusMessage}',
        responseBody: response.data is String ? response.data as String : null,
      );
    }
  }

  Future<SSCC> getSSCCById(String id) async {
    final response = await dioService.get(
      '${dioService.baseUrl}${SsccServiceConstants.pathBase}/$id',
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.data);
      if (responseData is Map<String, dynamic>) {
        SsccServiceOperations.normalizeFields(responseData);
      }
      return SSCC.fromJson(responseData);
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to get SSCC by ID: ${response.statusMessage}',
        responseBody: response.data is String ? response.data as String : null,
      );
    }
  }

  Future<SSCC> getSSCCByCode(String ssccCode) async {
    final response = await dioService.get(
      '${dioService.baseUrl}${SsccServiceConstants.pathByCode}',
      queryParameters: {SsccServiceConstants.qSsccCode: ssccCode},
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.data);
      if (responseData is Map<String, dynamic>) {
        SsccServiceOperations.normalizeFields(responseData);
      }
      return SSCC.fromJson(responseData);
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to get SSCC by code: ${response.statusMessage}',
        responseBody: response.data is String ? response.data as String : null,
      );
    }
  }

  Future<Map<String, dynamic>> fetchSSCCListPage({
    int page = 0,
    int size = 20,
    String sortBy = 'createdAt',
    String direction = 'DESC',
  }) async {
    final queryParams = <String, dynamic>{
      'page': page.toString(),
      'size': size.toString(),
      'sortBy': sortBy,
      'direction': direction,
    };
    final uri = Uri.parse(
      '${dioService.baseUrl}${SsccServiceConstants.pathBase}',
    ).replace(queryParameters: queryParams.map((k, v) => MapEntry(k, '$v')));

    final response = await dioService.get(
      uri.toString(),
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final decoded = json.decode(response.data);
      if (decoded is! Map<String, dynamic>) {
        throw ApiException(
          message: 'Unexpected SSCC list response format',
          responseBody: response.data is String
              ? response.data as String
              : null,
        );
      }
      final List<dynamic> contentList = decoded['content'] is List
          ? decoded['content'] as List<dynamic>
          : const [];
      final List<SSCC> ssccs = parseSsccListFromContent(contentList);

      return {
        'content': ssccs,
        'number': decoded['number'] ?? decoded['pageNumber'] ?? page,
        'totalPages': decoded['totalPages'] ?? 1,
        'totalElements': decoded['totalElements'] ?? ssccs.length,
        'size': decoded['size'] ?? decoded['pageSize'] ?? size,
        'first': decoded['first'] ?? true,
        'last': decoded['last'] ?? true,
      };
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to get all SSCCs: ${response.statusMessage}',
        responseBody: response.data is String ? response.data as String : null,
      );
    }
  }

  Future<SSCC> updateSSCC(String id, SSCC ssccDetails) async {
    final response = await dioService.put(
      '${dioService.baseUrl}${SsccServiceConstants.pathBase}/$id',
      headers: headers,
      data: json.encode(ssccDetails.toJson()),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return SSCC.fromJson(json.decode(response.data));
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to update SSCC: ${response.statusMessage}',
        responseBody: response.data is String ? response.data as String : null,
      );
    }
  }

  Future<void> deleteSSCC(String id) async {
    final response = await dioService.delete(
      '${dioService.baseUrl}${SsccServiceConstants.pathBase}/$id',
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode != 204) {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to delete SSCC: ${response.statusMessage}',
        responseBody: response.data is String ? response.data as String : null,
      );
    }
  }

  Future<SSCC> updateSSCCStatus(String id, LogisticUnitStatus newStatus) async {
    final response = await dioService.put(
      '${dioService.baseUrl}${SsccServiceConstants.pathStatus(id)}',
      headers: headers,
      data: json.encode({'status': newStatus.name}),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return SSCC.fromJson(json.decode(response.data));
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to update SSCC status: ${response.statusMessage}',
        responseBody: response.data is String ? response.data as String : null,
      );
    }
  }

  Future<List<String>> getAvailableTransitions(String id) async {
    final response = await dioService.get(
      '${dioService.baseUrl}${SsccServiceConstants.pathTransitions(id)}',
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == SsccServiceConstants.statusOk) {
      final data = json.decode(response.data) as Map<String, dynamic>;
      final raw = data[SsccServiceConstants.rAvailableTransitions];
      if (raw is List) {
        return raw.map((e) => e.toString()).toList();
      }
      return const [];
    }

    throw ApiException(
      statusCode: response.statusCode,
      message: 'Failed to load SSCC transitions: ${response.statusMessage}',
      responseBody: response.data is String ? response.data as String : null,
    );
  }

  Future<Map<String, dynamic>> _getSsccListPage(
    String path, {
    Map<String, String>? queryParameters,
    required int page,
    required int size,
  }) async {
    final params = <String, String>{
      ...?queryParameters,
      'page': page.toString(),
      'size': PageResponseUtils.clampSize(size).toString(),
    };
    final response = await dioService.get(
      path,
      queryParameters: params,
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return PageResponseUtils.normalizeBody(json.decode(response.data));
    }
    throw ApiException(
      statusCode: response.statusCode,
      message: 'Failed to load SSCC list: ${response.statusMessage}',
      responseBody: response.data is String ? response.data as String : null,
    );
  }

  Future<List<SSCC>> _fetchAllSsccListPages(
    String path, {
    Map<String, String>? queryParameters,
  }) async {
    final all = <SSCC>[];
    var page = 0;
    while (true) {
      final raw = await _getSsccListPage(
        path,
        queryParameters: queryParameters,
        page: page,
        size: PageResponseUtils.maxPageSize,
      );
      all.addAll(parseSsccListFromContent(PageResponseUtils.contentList(raw)));
      if (PageResponseUtils.isLast(raw)) break;
      page++;
    }
    return all;
  }

  Future<List<SSCC>> findSSCCsByUnitType(UnitType unitType) async {
    return _fetchAllSsccListPages(
      '${dioService.baseUrl}${SsccServiceConstants.pathContainerType(unitType.name)}',
    );
  }

  Future<List<SSCC>> findSSCCsByStatus(LogisticUnitStatus status) async {
    return _fetchAllSsccListPages(
      '${dioService.baseUrl}${SsccServiceConstants.pathContainerStatus(status.name)}',
    );
  }

  Future<List<SSCC>> findSSCCsBySourceLocation(String sourceGlnCode) async {
    return _fetchAllSsccListPages(
      '${dioService.baseUrl}${SsccServiceConstants.pathSourceLocation(sourceGlnCode)}',
    );
  }

  Future<List<SSCC>> findSSCCsByDestinationLocation(
    String destinationGlnCode,
  ) async {
    return _fetchAllSsccListPages(
      '${dioService.baseUrl}${SsccServiceConstants.pathDestinationLocation(destinationGlnCode)}',
    );
  }

  Future<List<SSCC>> findSSCCsPackedBetween(
    DateTime startDate,
    DateTime endDate,
  ) async {
    return _fetchAllSsccListPages(
      '${dioService.baseUrl}${SsccServiceConstants.pathPackedBetween}',
      queryParameters: {
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
      },
    );
  }

  Future<List<SSCC>> findSSCCsShippedBetween(
    DateTime startDate,
    DateTime endDate,
  ) async {
    return _fetchAllSsccListPages(
      '${dioService.baseUrl}${SsccServiceConstants.pathShippedBetween}',
      queryParameters: {
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
      },
    );
  }

  Future<List<SSCC>> findChildSSCCs(String parentSsccCode) async {
    final response = await dioService.get(
      '${dioService.baseUrl}${SsccServiceConstants.pathHierarchy}',
      queryParameters: {SsccServiceConstants.qSsccCode: parentSsccCode},
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.data);
      final List<dynamic> children = data['children'] ?? [];
      return children.map((item) => SSCC.fromJson(item)).toList();
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to find child SSCCs: ${response.statusMessage}',
        responseBody: response.data is String ? response.data as String : null,
      );
    }
  }

  Future<List<SSCC>> findSSCCsByGs1CompanyPrefix(
    String gs1CompanyPrefix,
  ) async {
    return _fetchAllSsccListPages(
      '${dioService.baseUrl}${SsccServiceConstants.pathCompanyPrefix(gs1CompanyPrefix)}',
    );
  }

  Future<List<SSCC>> searchSSCCs({
    UnitType? unitType,
    LogisticUnitStatus? status,
    String? sourceLocationId,
    String? destinationLocationId,
  }) async {
    return _fetchAllSsccListPages(
      '${dioService.baseUrl}${SsccServiceConstants.pathSearch}',
      queryParameters: {
        if (unitType != null) 'containerType': unitType.name,
        if (status != null) 'containerStatus': status.name,
        'sourceLocationId': ?sourceLocationId,
        'destinationLocationId': ?destinationLocationId,
      },
    );
  }

  Future<Map<String, dynamic>> searchSSCCsAdvanced({
    String? ssccCode,
    String? containerType,
    String? containerStatus,
    String? sourceLocationName,
    String? destinationLocationName,
    String? gs1CompanyPrefix,
    DateTime? packingDateFrom,
    DateTime? packingDateTo,
    DateTime? shippingDateFrom,
    DateTime? shippingDateTo,
    DateTime? receivingDateFrom,
    DateTime? receivingDateTo,
    int page = 0,
    int size = 20,
    String sortBy = 'ssccCode',
    String direction = 'ASC',
  }) async {
    final queryParams = <String, dynamic>{
      if (ssccCode?.isNotEmpty == true) 'ssccCode': ssccCode!,
      if (containerType?.isNotEmpty == true) 'containerType': containerType!,
      if (containerStatus?.isNotEmpty == true)
        'containerStatus': containerStatus!,
      if (sourceLocationName?.isNotEmpty == true)
        'sourceLocationName': sourceLocationName!,
      if (destinationLocationName?.isNotEmpty == true)
        'destinationLocationName': destinationLocationName!,
      if (gs1CompanyPrefix?.isNotEmpty == true)
        'gs1CompanyPrefix': gs1CompanyPrefix!,
      if (packingDateFrom != null)
        'packingDateFrom': packingDateFrom.toIso8601String(),
      if (packingDateTo != null)
        'packingDateTo': packingDateTo.toIso8601String(),
      if (shippingDateFrom != null)
        'shippingDateFrom': shippingDateFrom.toIso8601String(),
      if (shippingDateTo != null)
        'shippingDateTo': shippingDateTo.toIso8601String(),
      if (receivingDateFrom != null)
        'receivingDateFrom': receivingDateFrom.toIso8601String(),
      if (receivingDateTo != null)
        'receivingDateTo': receivingDateTo.toIso8601String(),
      'page': page.toString(),
      'size': size.toString(),
      'sortBy': sortBy,
      'direction': direction,
    };

    final uri = Uri.parse(
      '${dioService.baseUrl}${SsccServiceConstants.pathSearchAdvanced}',
    ).replace(queryParameters: queryParams.map((k, v) => MapEntry(k, '$v')));

    final response = await dioService.get(
      uri.toString(),
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final decoded = json.decode(response.data);
      if (decoded is! Map<String, dynamic>) {
        throw ApiException(
          message: 'Unexpected SSCC search response format',
          responseBody: response.data is String
              ? response.data as String
              : null,
        );
      }
      final List<dynamic> contentList = decoded['content'] is List
          ? decoded['content'] as List<dynamic>
          : const [];
      final List<SSCC> ssccs = parseSsccListFromContent(contentList);

      return {
        'content': ssccs,
        'number': decoded['number'] ?? decoded['pageNumber'] ?? 0,
        'totalPages': decoded['totalPages'] ?? 1,
        'totalElements': decoded['totalElements'] ?? ssccs.length,
        'size': decoded['size'] ?? decoded['pageSize'] ?? size,
        'first': decoded['first'] ?? true,
        'last': decoded['last'] ?? true,
      };
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to search SSCCs: ${response.statusMessage}',
        responseBody: response.data is String ? response.data as String : null,
      );
    }
  }
}
