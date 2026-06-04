import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';
import 'package:traqtrace_app/data/models/gs1/sscc/sscc_aggregation_link_model.dart';
import 'package:traqtrace_app/data/models/gs1/sscc/sscc_model.dart';
import 'package:traqtrace_app/data/services/gs1/serialization/sscc/sscc_service_constants.dart';
import 'package:traqtrace_app/features/gs1/sscc/utils/sscc_list_parsing.dart';
import 'package:traqtrace_app/features/gs1/utils/gs1_utils.dart';

/// Implementation of the SSCCService interface that interacts with the backend API
class SSCCService {
  final DioService _dioService;

  /// Creates a new SSCCServiceImpl instance
  SSCCService({required DioService dioService}) : _dioService = dioService;

  Future<SSCC> createSSCC(SSCC sscc) async {
    final token = await _dioService.getAuthToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    // After multiple attempts, we've determined the backend only needs the SSCC code itself
    // and not the individual components (extensionDigit, serialReference, checkDigit)

    // Validate that the SSCC code is provided and is the correct length (18 digits)
    if (sscc.ssccCode.isEmpty) {
      throw ApiException(message: 'SSCC code is required');
    }

    if (sscc.ssccCode.length != 18) {
      throw ApiException(message: 'SSCC code must be exactly 18 digits');
    }
    final Map<String, dynamic> jsonPayload = sscc.toJson();
    final String jsonBody = json.encode(jsonPayload);

    final response = await _dioService.post(
      '${_dioService.baseUrl}${SsccServiceConstants.pathBase}',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      data: jsonBody,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 201) {
      final responseData = json.decode(response.data);

      // Handle case where backend returns just the SSCC code as a string
      if (responseData is String) {
        // Create a minimal SSCC object with the returned code
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
      }
      // Handle normal case where backend returns full SSCC JSON object
      else if (responseData is Map<String, dynamic>) {
        return SSCC.fromJson(responseData);
      }
      // Unexpected response format
      else {
        throw ApiException(
          statusCode: response.statusCode,
          message:
              'Unexpected response format from server: ${responseData.runtimeType}',
        );
      }
    } else {
      // Try to parse error details from response body
      String errorDetail = response.statusMessage ?? 'Unknown error';
      try {
        final errorJson = json.decode(response.data);
        if (errorJson['message'] != null) {
          errorDetail = errorJson['message'];
        }
      } catch (e) {
        // Failed to parse error JSON
      }

      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to create SSCC: $errorDetail',
        responseBody: response.data,
      );
    }
  }

  Future<SSCC> getSSCCById(String id) async {

    final token = await _dioService.getAuthToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final uri = Uri.parse('${_dioService.baseUrl}${SsccServiceConstants.pathBase}/$id');

    final response = await _dioService.get(
      uri.toString(),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      try {
        final responseData = json.decode(response.data);

        // Make sure to handle the same field mappings as in the list
        if (responseData is Map<String, dynamic>) {
          // Handle 'sscc' vs 'ssccCode' field name discrepancy
          if (responseData.containsKey('sscc') &&
              !responseData.containsKey('ssccCode')) {
            responseData['ssccCode'] = responseData['sscc'];
          }

          // Handle statusDate for createdAt/updatedAt
          if (!responseData.containsKey('createdAt') &&
              responseData.containsKey('statusDate')) {
            responseData['createdAt'] = responseData['statusDate'];
          }
          if (!responseData.containsKey('updatedAt') &&
              responseData.containsKey('statusDate')) {
            responseData['updatedAt'] = responseData['statusDate'];
          }
        }

        return SSCC.fromJson(responseData);
      } catch (e) {
        throw ApiException(message: 'Failed to parse SSCC from response: $e');
      }
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to get SSCC by ID: ${response.statusMessage}',
        responseBody: response.data,
      );
    }
  }

  Future<SSCC> getSSCCByCode(String ssccCode) async {
    final token = await _dioService.getAuthToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final uri = Uri.parse(
      '${_dioService.baseUrl}${SsccServiceConstants.pathBase}/code/$ssccCode',
    );

    final response = await _dioService.get(
      uri.toString(),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      try {
        final responseData = json.decode(response.data);

        // Make sure to handle the same field mappings as in getSSCCById
        if (responseData is Map<String, dynamic>) {
          // Handle 'sscc' vs 'ssccCode' field name discrepancy
          if (responseData.containsKey('sscc') &&
              !responseData.containsKey('ssccCode')) {
            responseData['ssccCode'] = responseData['sscc'];
          }

          // Handle statusDate for createdAt/updatedAt
          if (!responseData.containsKey('createdAt') &&
              responseData.containsKey('statusDate')) {
            responseData['createdAt'] = responseData['statusDate'];
          }
          if (!responseData.containsKey('updatedAt') &&
              responseData.containsKey('statusDate')) {
            responseData['updatedAt'] = responseData['statusDate'];
          }
        }

        return SSCC.fromJson(responseData);
      } catch (e) {
        throw ApiException(message: 'Failed to parse SSCC from response: $e');
      }
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to get SSCC by code: ${response.statusMessage}',
        responseBody: response.data,
      );
    }
  }

  /// Paginated list (GET /identifiers/ssccs) — default when opening the SSCC screen.
  Future<Map<String, dynamic>> fetchSSCCListPage({
    int page = 0,
    int size = 20,
    String sortBy = 'createdAt',
    String direction = 'DESC',
  }) async {
    final token = await _dioService.getAuthToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

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
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
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
    } else if (response.statusCode == 403) {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Authentication failed: Please log in again',
        responseBody: response.data,
      );
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to get all SSCCs: ${response.statusMessage}',
        responseBody: response.data,
      );
    }
  }

  Future<SSCC> updateSSCC(String id, SSCC ssccDetails) async {
    final token = await _dioService.getAuthToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final response = await _dioService.put(
      '${_dioService.baseUrl}${SsccServiceConstants.pathBase}/$id',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
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
      );
    }
  }

  Future<void> deleteSSCC(String id) async {
    final token = await _dioService.getAuthToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final response = await _dioService.delete(
      '${_dioService.baseUrl}${SsccServiceConstants.pathBase}/$id',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode != 204) {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to delete SSCC: ${response.statusMessage}',
      );
    }
  }

  Future<List<SSCC>> findSSCCsByUnitType(UnitType unitType) async {
    final token = await _dioService.getAuthToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final response = await _dioService.get(
      '${_dioService.baseUrl}${SsccServiceConstants.pathBase}/container-type/${unitType.name}',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.data);
      return data.map((item) => SSCC.fromJson(item)).toList();
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message:
            'Failed to find SSCCs by container type: ${response.statusMessage}',
      );
    }
  }

  Future<List<SSCC>> findSSCCsByStatus(LogisticUnitStatus status) async {
    final token = await _dioService.getAuthToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final response = await _dioService.get(
      '${_dioService.baseUrl}${SsccServiceConstants.pathBase}/status/${status.name}',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.data);
      return data.map((item) => SSCC.fromJson(item)).toList();
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message:
            'Failed to find SSCCs by container status: ${response.statusMessage}',
      );
    }
  }

  Future<List<SSCC>> findSSCCsBySourceLocation(String sourceGlnCode) async {
    final token = await _dioService.getAuthToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final response = await _dioService.get(
      '${_dioService.baseUrl}${SsccServiceConstants.pathBase}/source-location/$sourceGlnCode',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.data);
      return data.map((item) => SSCC.fromJson(item)).toList();
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message:
            'Failed to find SSCCs by source location: ${response.statusMessage}',
      );
    }
  }

  Future<List<SSCC>> findSSCCsByDestinationLocation(
    String destinationGlnCode,
  ) async {
    final token = await _dioService.getAuthToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final response = await _dioService.get(
      '${_dioService.baseUrl}${SsccServiceConstants.pathBase}/destination-location/$destinationGlnCode',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.data);
      return data.map((item) => SSCC.fromJson(item)).toList();
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message:
            'Failed to find SSCCs by destination location: ${response.statusMessage}',
      );
    }
  }

  Future<List<SSCC>> findSSCCsPackedBetween(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final token = await _dioService.getAuthToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final queryParams = <String, dynamic>{
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
    };

    final response = await _dioService.get(
      '${_dioService.baseUrl}${SsccServiceConstants.pathBase}/packed-between',
      queryParameters: queryParams,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.data);
      return data.map((item) => SSCC.fromJson(item)).toList();
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message:
            'Failed to find SSCCs packed between dates: ${response.statusMessage}',
      );
    }
  }

  Future<List<SSCC>> findSSCCsShippedBetween(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final token = await _dioService.getAuthToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final queryParams = <String, dynamic>{
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
    };

    final response = await _dioService.get(
      '${_dioService.baseUrl}${SsccServiceConstants.pathBase}/shipped-between',
      queryParameters: queryParams,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.data);
      return data.map((item) => SSCC.fromJson(item)).toList();
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message:
            'Failed to find SSCCs shipped between dates: ${response.statusMessage}',
      );
    }
  }

  Future<List<SSCC>> findChildSSCCs(String parentSsccCode) async {
    final token = await _dioService.getAuthToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final response = await _dioService.get(
      '${_dioService.baseUrl}${SsccServiceConstants.pathBase}/$parentSsccCode/hierarchy',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
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
      );
    }
  }

  Future<List<SSCC>> findSSCCsByGs1CompanyPrefix(
    String gs1CompanyPrefix,
  ) async {
    final token = await _dioService.getAuthToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final queryParams = <String, dynamic>{'companyPrefix': gs1CompanyPrefix};

    final response = await _dioService.get(
      '${_dioService.baseUrl}${SsccServiceConstants.pathBase}/company',
      queryParameters: queryParams,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.data);
      return data.map((item) => SSCC.fromJson(item)).toList();
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message:
            'Failed to find SSCCs by GS1 company prefix: ${response.statusMessage}',
      );
    }
  }

  Future<List<SSCC>> searchSSCCs({
    UnitType? unitType,
    LogisticUnitStatus? status,
    String? sourceLocationId,
    String? destinationLocationId,
  }) async {
    final token = await _dioService.getAuthToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final queryParams = <String, dynamic>{
      if (unitType != null) 'containerType': unitType.name,
      if (status != null) 'containerStatus': status.name,
      ?'sourceLocationId': sourceLocationId,
      ?'destinationLocationId': destinationLocationId,
    };

    final response = await _dioService.get(
      '${_dioService.baseUrl}${SsccServiceConstants.pathBase}/search',
      queryParameters: queryParams,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
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
      );
    }
  }

  Future<SSCC> updateSSCCStatus(String id, LogisticUnitStatus newStatus) async {
    final token = await _dioService.getAuthToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final response = await _dioService.patch(
      '${_dioService.baseUrl}${SsccServiceConstants.pathStatus(id)}?status=${newStatus.name}',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return SSCC.fromJson(json.decode(response.data));
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to update SSCC status: ${response.statusMessage}',
      );
    }
  }

  Future<bool> validateSSCCCode(String ssccCode) async {
    final token = await _dioService.getAuthToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final queryParams = <String, dynamic>{'ssccCode': ssccCode};

    final response = await _dioService.get(
      '${_dioService.baseUrl}${SsccServiceConstants.pathBase}/validate',
      queryParameters: queryParams,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.data);
      return data['isValid'] as bool;
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to validate SSCC code: ${response.statusMessage}',
      );
    }
  }

  Future<String> generateSSCCCode(
    String gs1CompanyPrefix,
    String extensionDigit,
  ) async {
    final token = await _dioService.getAuthToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final Map<String, String> requestBody = {
      'companyPrefix': gs1CompanyPrefix,
      'containerType': 'PALLET', // Default container type
    };

    if (extensionDigit.isNotEmpty) {
      requestBody['extensionDigit'] = extensionDigit;
    }

    final response = await _dioService.post(
      '${_dioService.baseUrl}${SsccServiceConstants.pathBase}/generate',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      data: json.encode(requestBody),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      // Parse the response directly instead of using SSCC.fromJson
      final Map<String, dynamic> responseData = json.decode(response.data);

      // Debug information

      String? ssccCode;
      // Check if the response contains the 'sscc' field directly (from backend standard)
      if (responseData.containsKey('sscc') && responseData['sscc'] != null) {
        ssccCode = responseData['sscc'].toString();
      }
      // Check for ssccCode field (frontend convention)
      else if (responseData.containsKey('ssccCode') &&
          responseData['ssccCode'] != null) {
        ssccCode = responseData['ssccCode'].toString();
      }
      // Try to parse as an SSCC object
      else if (responseData.containsKey('id')) {
        try {
          final SSCC generatedSscc = SSCC.fromJson(responseData);
          ssccCode = generatedSscc.ssccCode;
        } catch (e) {
          // Fall through to error message below
        }
      }

      if (ssccCode != null) {
        // Use the improved validation and fix function from GS1Utils
        final validatedSSCC = GS1Utils.validateAndFixSSCC(ssccCode);

        if (validatedSSCC != null) {
          return validatedSSCC;
        } else {
          // If we can't validate or fix the SSCC, try to generate one locally
          try {
            final localSSCC = GS1Utils.generateSSCC(
              gs1CompanyPrefix,
              extensionDigit,
            );
            return localSSCC;
          } catch (e) {
            throw ApiException(
              message:
                  'Invalid SSCC format from API and local generation failed: $e',
            );
          }
        }
      }

      // If we couldn't extract the SSCC code from the response
      throw ApiException(
        message:
            'Invalid response format: SSCC code not found in response: $responseData',
      );
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to generate SSCC code: ${response.statusMessage}',
        responseBody: response.data,
      );
    }
  }

  Future<String> extractCompanyPrefixFromGLN(String glnInput) async {
    if (glnInput.isEmpty) {
      throw ApiException(message: 'GLN input cannot be empty');
    }

    // First, check if the input is in a special format (GS1 barcode or URN)
    // and extract the actual GLN code
    String? glnCode;

    // Check for URN format that contains company prefix directly
    final urnPrefixRegex = RegExp(r'urn:epc:id:sgln:(\d{7,10})\..*');
    final urnPrefixMatch = urnPrefixRegex.firstMatch(glnInput);

    if (urnPrefixMatch != null && urnPrefixMatch.group(1) != null) {
      // In URN format, we can directly extract the company prefix
      final companyPrefix = urnPrefixMatch.group(1);
      return companyPrefix!;
    }

    // Check if it's already a plain 13-digit GLN
    if (glnInput.length == 13 && RegExp(r'^\d{13}$').hasMatch(glnInput)) {
      glnCode = glnInput;
    } else {
      // Try to parse from GS1 barcode or URN format using the GS1Utils class
      try {
        glnCode = await _parseGLNFromFormat(glnInput);
      } catch (e) {
        throw ApiException(
          message: 'Failed to parse GLN from input: ${e.toString()}',
        );
      }
    }

    // If we couldn't extract a GLN code, throw an error
    if (glnCode == null || glnCode.isEmpty) {
      throw ApiException(
        message:
            'Invalid GLN format. GLN must be in one of these formats: 13 digits, (414)nnnnnnnnnnnn, or urn:epc:id:sgln:prefix.reference.0',
      );
    }

    // Validate GLN format
    if (glnCode.length != 13 || !RegExp(r'^\d{13}$').hasMatch(glnCode)) {
      throw ApiException(message: 'Invalid GLN format. GLN must be 13 digits');
    }

    // Extract the company prefix (typically first 7-10 digits)
    // For simplicity, we'll use a fixed 7 digits in this implementation
    // In a production environment, this should be based on the organization's
    // registered GS1 Company Prefix length
    final companyPrefix = glnCode.substring(0, 7);
    return companyPrefix;
  }

  /// Helper method to parse GLN from different formats
  Future<String?> _parseGLNFromFormat(String input) async {
    // First try using the utility class
    try {
      final result = GS1Utils.extractGLNCode(input);
      if (result != null && result.isNotEmpty) {
        return result;
      }
    } catch (e) {
      // Continue to fallback methods below
    }

    // Fallback to direct parsing

    // Check for GS1 barcode format with AI (414) for GLN
    final barcodeRegex = RegExp(r'\(414\)(\d{13})');
    final barcodeMatch = barcodeRegex.firstMatch(input);

    if (barcodeMatch != null && barcodeMatch.group(1) != null) {
      final result = barcodeMatch.group(1);
      if (result != null && result.isNotEmpty) {
        return result;
      }
    }

    // Check for URN format for GLN
    final urnRegex = RegExp(r'urn:epc:id:sgln:(\d{7,10})\.(\d{1,5})\.(\d)');
    final urnMatch = urnRegex.firstMatch(input);

    if (urnMatch != null) {
      // Combine the parts and calculate check digit
      final companyPrefix = urnMatch.group(1);
      final locationReference = urnMatch.group(2)?.padLeft(5, '0');

      if (companyPrefix != null && locationReference != null) {
        final glnWithoutCheck = companyPrefix + locationReference;
        // Calculate check digit - we'll use the GS1 standard algorithm
        final checkDigit = _calculateGS1CheckDigit(glnWithoutCheck);
        return glnWithoutCheck + checkDigit;
      }
    }

    // If the input itself is already a 13-digit number, it might be a plain GLN
    if (input.length == 13 && RegExp(r'^\d{13}$').hasMatch(input)) {
      return input;
    }

    return null;
  }

  /// Calculate GS1 check digit (same as in GS1Utils class)
  String _calculateGS1CheckDigit(String digits) {
    int sum = 0;

    // Apply the weighting factors (3 and 1)
    for (int i = 0; i < digits.length; i++) {
      final digit = int.parse(digits[digits.length - 1 - i]);
      sum += (i % 2 == 0) ? digit * 3 : digit;
    }

    // Calculate the check digit
    final checkDigit = (10 - (sum % 10)) % 10;
    return checkDigit.toString();
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
    final token = await _dioService.getAuthToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

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
      '${_dioService.baseUrl}${SsccServiceConstants.pathBase}/search/advanced',
    ).replace(queryParameters: queryParams.map((k, v) => MapEntry(k, '$v')));

    try {
      final response = await _dioService.get(
        uri.toString(),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
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
        final responseData = decoded;
        final List<dynamic> contentList = responseData['content'] is List
            ? responseData['content'] as List<dynamic>
            : const [];
        final List<SSCC> ssccs = parseSsccListFromContent(contentList);

        return {
          'content': ssccs,
          'number': responseData['number'] ?? responseData['pageNumber'] ?? 0,
          'totalPages': responseData['totalPages'] ?? 1,
          'totalElements': responseData['totalElements'] ?? ssccs.length,
          'size': responseData['size'] ?? responseData['pageSize'] ?? size,
          'first': responseData['first'] ?? true,
          'last': responseData['last'] ?? true,
        };
      } else {
        final error = json.decode(response.data);
        throw ApiException(
          message: error['message'] ?? 'Failed to search SSCCs',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException(message: 'Failed to search SSCCs: ${e.toString()}');
    }
  }

  Future<List<String>> getAvailableTransitions(String id) async {
    final token = await _dioService.getAuthToken();
    if (token == null) {
      throw ApiException(message: SsccServiceConstants.errNoToken);
    }

    final response = await _dioService.get(
      '${_dioService.baseUrl}${SsccServiceConstants.pathTransitions(id)}',
      headers: SsccServiceConstants.authHeaders(token),
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
    );
  }

  Future<List<SsccAggregationLink>> getAggregationLinksByCode(
    String ssccCode,
  ) async {
    final token = await _dioService.getAuthToken();
    if (token == null) {
      throw ApiException(message: SsccServiceConstants.errNoToken);
    }

    final response = await _dioService.get(
      '${_dioService.baseUrl}${SsccServiceConstants.pathAggregationByCode(ssccCode)}',
      headers: SsccServiceConstants.authHeaders(token),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == SsccServiceConstants.statusOk) {
      final List<dynamic> data = json.decode(response.data);
      return data
          .map((item) =>
              SsccAggregationLink.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    throw ApiException(
      statusCode: response.statusCode,
      message: 'Failed to load aggregation links: ${response.statusMessage}',
    );
  }

  Future<SsccAggregationLink> addAggregationLink(
    String ssccId, {
    required String childEpc,
    required String childKind,
    required String aggregationEventId,
  }) async {
    final token = await _dioService.getAuthToken();
    if (token == null) {
      throw ApiException(message: SsccServiceConstants.errNoToken);
    }

    final response = await _dioService.post(
      '${_dioService.baseUrl}${SsccServiceConstants.pathAggregation(ssccId)}',
      headers: SsccServiceConstants.authHeaders(token),
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
      responseBody: response.data,
    );
  }

  Future<SsccAggregationLink> disaggregateLink(
    int linkId, {
    required String disaggregationEventId,
  }) async {
    final token = await _dioService.getAuthToken();
    if (token == null) {
      throw ApiException(message: SsccServiceConstants.errNoToken);
    }

    final response = await _dioService.patch(
      '${_dioService.baseUrl}${SsccServiceConstants.pathDisaggregate(linkId)}',
      headers: SsccServiceConstants.authHeaders(token),
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
      responseBody: response.data,
    );
  }
}
