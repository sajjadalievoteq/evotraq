import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';
import 'package:traqtrace_app/data/models/gs1/serialization/sscc/sscc_aggregation_link_model.dart';
import 'package:traqtrace_app/data/models/gs1/serialization/sscc/sscc_model.dart';
import 'package:traqtrace_app/data/services/gs1/serialization/sscc/sscc_service_constants.dart';
import 'package:traqtrace_app/features/gs1/sscc/utils/sscc_list_parsing.dart';
import 'package:traqtrace_app/core/utils/gs1_utils.dart';

class SSCCService {
  final DioService _dioService;

  SSCCService({required DioService dioService}) : _dioService = dioService;

  static const _headers = {
    SsccServiceConstants.headerContentType: SsccServiceConstants.contentTypeJson,
  };

  Future<SSCC> createSSCC(SSCC sscc) async {
    if (sscc.ssccCode.isEmpty) {
      throw ApiException(message: 'SSCC code is required');
    }
    if (sscc.ssccCode.length != 18) {
      throw ApiException(message: 'SSCC code must be exactly 18 digits');
    }

    final response = await _dioService.post(
      '${_dioService.baseUrl}${SsccServiceConstants.pathBase}',
      headers: _headers,
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
          message: 'Unexpected response format from server: ${responseData.runtimeType}',
          responseBody: response.data is String ? response.data as String : null,
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
    final response = await _dioService.get(
      '${_dioService.baseUrl}${SsccServiceConstants.pathBase}/$id',
      headers: _headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.data);
      if (responseData is Map<String, dynamic>) {
        _normalizeFields(responseData);
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
    final response = await _dioService.get(
      '${_dioService.baseUrl}${SsccServiceConstants.pathBase}/code/$ssccCode',
      headers: _headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.data);
      if (responseData is Map<String, dynamic>) {
        _normalizeFields(responseData);
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
      '${_dioService.baseUrl}${SsccServiceConstants.pathBase}',
    ).replace(queryParameters: queryParams.map((k, v) => MapEntry(k, '$v')));

    final response = await _dioService.get(
      uri.toString(),
      headers: _headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final decoded = json.decode(response.data);
      if (decoded is! Map<String, dynamic>) {
        throw ApiException(
          message: 'Unexpected SSCC list response format',
          responseBody: response.data is String ? response.data as String : null,
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
    final response = await _dioService.put(
      '${_dioService.baseUrl}${SsccServiceConstants.pathBase}/$id',
      headers: _headers,
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
    final response = await _dioService.delete(
      '${_dioService.baseUrl}${SsccServiceConstants.pathBase}/$id',
      headers: _headers,
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
    final response = await _dioService.put(
      '${_dioService.baseUrl}${SsccServiceConstants.pathStatus(id)}',
      headers: _headers,
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
    final response = await _dioService.get(
      '${_dioService.baseUrl}${SsccServiceConstants.pathTransitions(id)}',
      headers: _headers,
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

  Future<List<SSCC>> findSSCCsByUnitType(UnitType unitType) async {
    final response = await _dioService.get(
      '${_dioService.baseUrl}${SsccServiceConstants.pathContainerType(unitType.name)}',
      headers: _headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.data);
      return data.map((item) => SSCC.fromJson(item)).toList();
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to find SSCCs by container type: ${response.statusMessage}',
        responseBody: response.data is String ? response.data as String : null,
      );
    }
  }

  Future<List<SSCC>> findSSCCsByStatus(LogisticUnitStatus status) async {
    final response = await _dioService.get(
      '${_dioService.baseUrl}${SsccServiceConstants.pathContainerStatus(status.name)}',
      headers: _headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.data);
      return data.map((item) => SSCC.fromJson(item)).toList();
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to find SSCCs by container status: ${response.statusMessage}',
        responseBody: response.data is String ? response.data as String : null,
      );
    }
  }

  Future<List<SSCC>> findSSCCsBySourceLocation(String sourceGlnCode) async {
    final response = await _dioService.get(
      '${_dioService.baseUrl}${SsccServiceConstants.pathSourceLocation(sourceGlnCode)}',
      headers: _headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.data);
      return data.map((item) => SSCC.fromJson(item)).toList();
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to find SSCCs by source location: ${response.statusMessage}',
        responseBody: response.data is String ? response.data as String : null,
      );
    }
  }

  Future<List<SSCC>> findSSCCsByDestinationLocation(String destinationGlnCode) async {
    final response = await _dioService.get(
      '${_dioService.baseUrl}${SsccServiceConstants.pathDestinationLocation(destinationGlnCode)}',
      headers: _headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.data);
      return data.map((item) => SSCC.fromJson(item)).toList();
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to find SSCCs by destination location: ${response.statusMessage}',
        responseBody: response.data is String ? response.data as String : null,
      );
    }
  }

  Future<List<SSCC>> findSSCCsPackedBetween(DateTime startDate, DateTime endDate) async {
    final response = await _dioService.get(
      '${_dioService.baseUrl}${SsccServiceConstants.pathPackedBetween}',
      queryParameters: {
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
      },
      headers: _headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.data);
      return data.map((item) => SSCC.fromJson(item)).toList();
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to find SSCCs packed between dates: ${response.statusMessage}',
        responseBody: response.data is String ? response.data as String : null,
      );
    }
  }

  Future<List<SSCC>> findSSCCsShippedBetween(DateTime startDate, DateTime endDate) async {
    final response = await _dioService.get(
      '${_dioService.baseUrl}${SsccServiceConstants.pathShippedBetween}',
      queryParameters: {
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
      },
      headers: _headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.data);
      return data.map((item) => SSCC.fromJson(item)).toList();
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to find SSCCs shipped between dates: ${response.statusMessage}',
        responseBody: response.data is String ? response.data as String : null,
      );
    }
  }

  Future<List<SSCC>> findChildSSCCs(String parentSsccCode) async {
    final response = await _dioService.get(
      '${_dioService.baseUrl}${SsccServiceConstants.pathHierarchy(parentSsccCode)}',
      headers: _headers,
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

  Future<List<SSCC>> findSSCCsByGs1CompanyPrefix(String gs1CompanyPrefix) async {
    final response = await _dioService.get(
      '${_dioService.baseUrl}${SsccServiceConstants.pathCompanyPrefix(gs1CompanyPrefix)}',
      headers: _headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.data);
      return data.map((item) => SSCC.fromJson(item)).toList();
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to find SSCCs by GS1 company prefix: ${response.statusMessage}',
        responseBody: response.data is String ? response.data as String : null,
      );
    }
  }

  Future<List<SSCC>> searchSSCCs({
    UnitType? unitType,
    LogisticUnitStatus? status,
    String? sourceLocationId,
    String? destinationLocationId,
  }) async {
    final queryParams = <String, dynamic>{
      if (unitType != null) 'containerType': unitType.name,
      if (status != null) 'containerStatus': status.name,
      'sourceLocationId': sourceLocationId,
      'destinationLocationId': destinationLocationId,
    };

    final response = await _dioService.get(
      '${_dioService.baseUrl}${SsccServiceConstants.pathSearch}',
      queryParameters: queryParams,
      headers: _headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.data);
      return data.map((item) => SSCC.fromJson(item)).toList();
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to search SSCCs: ${response.statusMessage}',
        responseBody: response.data is String ? response.data as String : null,
      );
    }
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
      if (containerStatus?.isNotEmpty == true) 'containerStatus': containerStatus!,
      if (sourceLocationName?.isNotEmpty == true) 'sourceLocationName': sourceLocationName!,
      if (destinationLocationName?.isNotEmpty == true) 'destinationLocationName': destinationLocationName!,
      if (gs1CompanyPrefix?.isNotEmpty == true) 'gs1CompanyPrefix': gs1CompanyPrefix!,
      if (packingDateFrom != null) 'packingDateFrom': packingDateFrom.toIso8601String(),
      if (packingDateTo != null) 'packingDateTo': packingDateTo.toIso8601String(),
      if (shippingDateFrom != null) 'shippingDateFrom': shippingDateFrom.toIso8601String(),
      if (shippingDateTo != null) 'shippingDateTo': shippingDateTo.toIso8601String(),
      if (receivingDateFrom != null) 'receivingDateFrom': receivingDateFrom.toIso8601String(),
      if (receivingDateTo != null) 'receivingDateTo': receivingDateTo.toIso8601String(),
      'page': page.toString(),
      'size': size.toString(),
      'sortBy': sortBy,
      'direction': direction,
    };

    final uri = Uri.parse(
      '${_dioService.baseUrl}${SsccServiceConstants.pathSearchAdvanced}',
    ).replace(queryParameters: queryParams.map((k, v) => MapEntry(k, '$v')));

    final response = await _dioService.get(
      uri.toString(),
      headers: _headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final decoded = json.decode(response.data);
      if (decoded is! Map<String, dynamic>) {
        throw ApiException(
          message: 'Unexpected SSCC search response format',
          responseBody: response.data is String ? response.data as String : null,
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

  Future<String> generateSSCCCode(String gs1CompanyPrefix, String extensionDigit) async {
    final Map<String, String> requestBody = {
      'companyPrefix': gs1CompanyPrefix,
      'containerType': 'PALLET',
    };
    if (extensionDigit.isNotEmpty) {
      requestBody['extensionDigit'] = extensionDigit;
    }

    final response = await _dioService.post(
      '${_dioService.baseUrl}${SsccServiceConstants.pathGenerate}',
      headers: _headers,
      data: json.encode(requestBody),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.data);

      String? ssccCode;
      if (responseData.containsKey('sscc') && responseData['sscc'] != null) {
        ssccCode = responseData['sscc'].toString();
      } else if (responseData.containsKey('ssccCode') && responseData['ssccCode'] != null) {
        ssccCode = responseData['ssccCode'].toString();
      } else if (responseData.containsKey('id')) {
        try {
          ssccCode = SSCC.fromJson(responseData).ssccCode;
        } catch (_) {}
      }

      if (ssccCode != null) {
        final validatedSSCC = GS1Utils.validateAndFixSSCC(ssccCode);
        if (validatedSSCC != null) {
          return validatedSSCC;
        }
        try {
          return GS1Utils.generateSSCC(gs1CompanyPrefix, extensionDigit);
        } catch (e) {
          throw ApiException(
            message: 'Invalid SSCC format from API and local generation failed: $e',
          );
        }
      }
      throw ApiException(
        message: 'Invalid response format: SSCC code not found in response: $responseData',
      );
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to generate SSCC code: ${response.statusMessage}',
        responseBody: response.data is String ? response.data as String : null,
      );
    }
  }

  Future<bool> validateSSCCCode(String ssccCode) async {
    final response = await _dioService.get(
      '${_dioService.baseUrl}${SsccServiceConstants.pathValidate}',
      queryParameters: {'ssccCode': ssccCode},
      headers: _headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.data);
      return data[SsccServiceConstants.rIsValid] as bool;
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to validate SSCC code: ${response.statusMessage}',
        responseBody: response.data is String ? response.data as String : null,
      );
    }
  }

  Future<List<SsccAggregationLink>> getAggregationLinksByCode(String ssccCode) async {
    final response = await _dioService.get(
      '${_dioService.baseUrl}${SsccServiceConstants.pathAggregationByCode(ssccCode)}',
      headers: _headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == SsccServiceConstants.statusOk) {
      final List<dynamic> data = json.decode(response.data);
      return data.map((item) => SsccAggregationLink.fromJson(item as Map<String, dynamic>)).toList();
    }

    throw ApiException(
      statusCode: response.statusCode,
      message: 'Failed to load aggregation links: ${response.statusMessage}',
      responseBody: response.data is String ? response.data as String : null,
    );
  }

  Future<SsccAggregationLink> addAggregationLink(
    String ssccId, {
    required String childEpc,
    required String childKind,
    required String aggregationEventId,
  }) async {
    final response = await _dioService.post(
      '${_dioService.baseUrl}${SsccServiceConstants.pathAggregation(ssccId)}',
      headers: _headers,
      data: json.encode({
        'childEpc': childEpc,
        'childKind': childKind,
        'aggregationEventId': aggregationEventId,
      }),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == SsccServiceConstants.statusCreated ||
        response.statusCode == SsccServiceConstants.statusOk) {
      return SsccAggregationLink.fromJson(
        json.decode(response.data) as Map<String, dynamic>,
      );
    }

    throw ApiException(
      statusCode: response.statusCode,
      message: 'Failed to add aggregation link: ${response.statusMessage}',
      responseBody: response.data is String ? response.data as String : null,
    );
  }

  Future<SsccAggregationLink> disaggregateLink(
    int linkId, {
    required String disaggregationEventId,
  }) async {
    final response = await _dioService.patch(
      '${_dioService.baseUrl}${SsccServiceConstants.pathDisaggregate(linkId)}',
      headers: _headers,
      data: json.encode({'disaggregationEventId': disaggregationEventId}),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == SsccServiceConstants.statusOk) {
      return SsccAggregationLink.fromJson(
        json.decode(response.data) as Map<String, dynamic>,
      );
    }

    throw ApiException(
      statusCode: response.statusCode,
      message: 'Failed to disaggregate link: ${response.statusMessage}',
      responseBody: response.data is String ? response.data as String : null,
    );
  }

  Future<String> extractCompanyPrefixFromGLN(String glnInput) async {
    if (glnInput.isEmpty) {
      throw ApiException(message: 'GLN input cannot be empty');
    }

    final urnPrefixRegex = RegExp(r'urn:epc:id:sgln:(\d{7,10})\..*');
    final urnPrefixMatch = urnPrefixRegex.firstMatch(glnInput);
    if (urnPrefixMatch != null && urnPrefixMatch.group(1) != null) {
      return urnPrefixMatch.group(1)!;
    }

    String? glnCode;
    if (glnInput.length == 13 && RegExp(r'^\d{13}$').hasMatch(glnInput)) {
      glnCode = glnInput;
    } else {
      try {
        glnCode = await _parseGLNFromFormat(glnInput);
      } catch (e) {
        throw ApiException(message: 'Failed to parse GLN from input: ${e.toString()}');
      }
    }

    if (glnCode == null || glnCode.isEmpty) {
      throw ApiException(
        message: 'Invalid GLN format. GLN must be in one of these formats: '
            '13 digits, (414)nnnnnnnnnnnn, or urn:epc:id:sgln:prefix.reference.0',
      );
    }
    if (glnCode.length != 13 || !RegExp(r'^\d{13}$').hasMatch(glnCode)) {
      throw ApiException(message: 'Invalid GLN format. GLN must be 13 digits');
    }

    return glnCode.substring(0, 7);
  }

  Future<String?> _parseGLNFromFormat(String input) async {
    try {
      final result = GS1Utils.extractGLNCode(input);
      if (result != null && result.isNotEmpty) return result;
    } catch (_) {}

    final barcodeMatch = RegExp(r'\(414\)(\d{13})').firstMatch(input);
    if (barcodeMatch?.group(1) != null) {
      return barcodeMatch!.group(1);
    }

    final urnMatch = RegExp(r'urn:epc:id:sgln:(\d{7,10})\.(\d{1,5})\.(\d)').firstMatch(input);
    if (urnMatch != null) {
      final companyPrefix = urnMatch.group(1);
      final locationReference = urnMatch.group(2)?.padLeft(5, '0');
      if (companyPrefix != null && locationReference != null) {
        final glnWithoutCheck = companyPrefix + locationReference;
        return glnWithoutCheck + _calculateGS1CheckDigit(glnWithoutCheck);
      }
    }

    if (input.length == 13 && RegExp(r'^\d{13}$').hasMatch(input)) return input;
    return null;
  }

  String _calculateGS1CheckDigit(String digits) {
    int sum = 0;
    for (int i = 0; i < digits.length; i++) {
      final digit = int.parse(digits[digits.length - 1 - i]);
      sum += (i % 2 == 0) ? digit * 3 : digit;
    }
    return ((10 - (sum % 10)) % 10).toString();
  }

  static void _normalizeFields(Map<String, dynamic> data) {
    if (data.containsKey('sscc') && !data.containsKey('ssccCode')) {
      data['ssccCode'] = data['sscc'];
    }
    if (!data.containsKey('createdAt') && data.containsKey('statusDate')) {
      data['createdAt'] = data['statusDate'];
    }
    if (!data.containsKey('updatedAt') && data.containsKey('statusDate')) {
      data['updatedAt'] = data['statusDate'];
    }
  }
}
