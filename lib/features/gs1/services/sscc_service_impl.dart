import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:traqtrace_app/core/config/app_config.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/core/network/token_manager.dart';
import 'package:traqtrace_app/features/gs1/models/sscc_model.dart';
import 'package:traqtrace_app/features/gs1/services/sscc_service.dart';
import 'package:traqtrace_app/features/gs1/utils/gs1_utils.dart';

/// Implementation of the SSCCService interface that interacts with the backend API
class SSCCServiceImpl implements SSCCService {
  final http.Client _client;
  final TokenManager _tokenManager;
  final AppConfig _appConfig;

  /// Creates a new SSCCServiceImpl instance
  SSCCServiceImpl({
    required http.Client httpClient,
    required TokenManager tokenManager,
    required AppConfig appConfig,
  })  : _client = httpClient,
        _tokenManager = tokenManager,
        _appConfig = appConfig;  @override
  Future<SSCC> createSSCC(SSCC sscc) async {
    final token = await _tokenManager.getToken();
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
    
    // Create the JSON payload and log it for detailed debugging
    final Map<String, dynamic> jsonPayload = sscc.toJson();
    final String jsonBody = json.encode(jsonPayload);
    print('SSCC Create request payload: $jsonBody');
    print('SSCC Create request payload fields: ${jsonPayload.keys}');
    print('SSCC API endpoint: ${_appConfig.apiBaseUrl}/identifiers/sscc');
    
    // Verify that we're sending ONLY the exact fields the backend accepts
    print('FINAL SSCC CREATE PAYLOAD VERIFICATION:');
    print('Total fields in payload: ${jsonPayload.length}');
    print('Fields included:');
    jsonPayload.forEach((key, value) {
      print(' - $key: $value');
    });
    
    print('Verifying required fields are present:');
    print(' - Has "sscc" field: ${jsonPayload.containsKey('sscc')}');
    print(' - Has "containerType" field: ${jsonPayload.containsKey('containerType')}');
    print(' - Has "containerStatus" field: ${jsonPayload.containsKey('containerStatus')}');
    
    print('Verifying problematic fields are NOT present:');
    print(' - No "companyPrefix" field: ${!jsonPayload.containsKey('companyPrefix')}');
    print(' - No "gs1CompanyPrefix" field: ${!jsonPayload.containsKey('gs1CompanyPrefix')}');
    print(' - No "extensionDigit" field: ${!jsonPayload.containsKey('extensionDigit')}');
    print(' - No "serialReference" field: ${!jsonPayload.containsKey('serialReference')}');
    print(' - No "checkDigit" field: ${!jsonPayload.containsKey('checkDigit')}');
    print(' - No "createdAt" field: ${!jsonPayload.containsKey('createdAt')}');
    print(' - No "updatedAt" field: ${!jsonPayload.containsKey('updatedAt')}');
    
    final response = await _client.post(
      Uri.parse('${_appConfig.apiBaseUrl}/identifiers/sscc'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonBody,
    );

    if (response.statusCode == 201) {
      final responseData = json.decode(response.body);
      print('SSCC Create success response: $responseData');
      print('Response type: ${responseData.runtimeType}');
      
      // Handle case where backend returns just the SSCC code as a string
      if (responseData is String) {
        print('Backend returned SSCC code as string: $responseData');
        // Create a minimal SSCC object with the returned code
        final Map<String, dynamic> ssccJson = {
          'sscc': responseData,
          'containerType': sscc.containerType.name,
          'containerStatus': sscc.containerStatus.name,
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
          message: 'Unexpected response format from server: ${responseData.runtimeType}',
        );
      }
    } else {
      print('SSCC Create error: ${response.statusCode} - ${response.body}');
      
      // Try to parse error details from response body
      String errorDetail = response.reasonPhrase ?? 'Unknown error';
      try {
        final errorJson = json.decode(response.body);
        if (errorJson['message'] != null) {
          errorDetail = errorJson['message'];
        }
      } catch (e) {
        // Failed to parse error JSON
      }
      
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to create SSCC: $errorDetail',
        responseBody: response.body,
      );
    }
  }

  @override  Future<SSCC> getSSCCById(String id) async {
    print('Fetching SSCC with ID: $id');
    
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }
    
    final uri = Uri.parse('${_appConfig.apiBaseUrl}/identifiers/sscc/$id');
    print('Request URI: $uri');
    
    final response = await _client.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );    print('SSCC by ID response status: ${response.statusCode}, body: ${response.body}');
    
    if (response.statusCode == 200) {
      try {
        final responseData = json.decode(response.body);
        print('Response data: $responseData');
        
        // Make sure to handle the same field mappings as in the list
        if (responseData is Map<String, dynamic>) {
          // Handle 'sscc' vs 'ssccCode' field name discrepancy
          if (responseData.containsKey('sscc') && !responseData.containsKey('ssccCode')) {
            responseData['ssccCode'] = responseData['sscc'];
          }
          
          // Handle statusDate for createdAt/updatedAt
          if (!responseData.containsKey('createdAt') && responseData.containsKey('statusDate')) {
            responseData['createdAt'] = responseData['statusDate'];
          }
          if (!responseData.containsKey('updatedAt') && responseData.containsKey('statusDate')) {
            responseData['updatedAt'] = responseData['statusDate'];
          }
        }
        
        return SSCC.fromJson(responseData);
      } catch (e) {
        print('Error parsing SSCC response: $e');
        throw ApiException(message: 'Failed to parse SSCC from response: $e');
      }
    } else {
      print('Failed to get SSCC by ID: ${response.statusCode} - ${response.reasonPhrase}');
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to get SSCC by ID: ${response.reasonPhrase}',
        responseBody: response.body,
      );
    }
  }
  @override
  Future<SSCC> getSSCCByCode(String ssccCode) async {
    print('Fetching SSCC with code: $ssccCode');
    
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }
    
    final uri = Uri.parse('${_appConfig.apiBaseUrl}/identifiers/sscc/code/$ssccCode');
    print('Request URI: $uri');
    
    final response = await _client.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    
    print('SSCC by code response status: ${response.statusCode}, body: ${response.body}');
    
    if (response.statusCode == 200) {
      try {
        final responseData = json.decode(response.body);
        print('Response data: $responseData');
        
        // Make sure to handle the same field mappings as in getSSCCById
        if (responseData is Map<String, dynamic>) {
          // Handle 'sscc' vs 'ssccCode' field name discrepancy
          if (responseData.containsKey('sscc') && !responseData.containsKey('ssccCode')) {
            responseData['ssccCode'] = responseData['sscc'];
          }
          
          // Handle statusDate for createdAt/updatedAt
          if (!responseData.containsKey('createdAt') && responseData.containsKey('statusDate')) {
            responseData['createdAt'] = responseData['statusDate'];
          }
          if (!responseData.containsKey('updatedAt') && responseData.containsKey('statusDate')) {
            responseData['updatedAt'] = responseData['statusDate'];
          }
        }
        
        return SSCC.fromJson(responseData);
      } catch (e) {
        print('Error parsing SSCC response: $e');
        throw ApiException(message: 'Failed to parse SSCC from response: $e');
      }
    } else {
      print('Failed to get SSCC by code: ${response.statusCode} - ${response.reasonPhrase}');
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to get SSCC by code: ${response.reasonPhrase}',
        responseBody: response.body,
      );
    }
  }

  @override
  Future<List<SSCC>> getAllSSCCs({int page = 0, int size = 20}) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }
    
    final queryParams = <String, String>{
      'page': page.toString(),
      'size': size.toString(),
    };
      final uri = Uri.parse('${_appConfig.apiBaseUrl}/identifiers/sscc')
        .replace(queryParameters: queryParams);
    
    final response = await _client.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );    print('SSCC list response status: ${response.statusCode}, body: ${response.body}');
      if (response.statusCode == 200) {
      try {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> content = data['content'] ?? [];
        
        // Add debugging to check structure
        if (content.isNotEmpty) {
          print('First SSCC item structure: ${content[0]}');
          print('SSCC ID from response: ${content[0]['id']}');
        }
        
        // Map each item in content to an SSCC object
        final results = content.map((item) {
          try {
            if (item is Map<String, dynamic>) {
              // Handle 'sscc' vs 'ssccCode' field name discrepancy
              if (item.containsKey('sscc') && !item.containsKey('ssccCode')) {
                item['ssccCode'] = item['sscc'];
              }
              
              // Handle the statusDate field as a fallback for createdAt/updatedAt
              if (!item.containsKey('createdAt') && item.containsKey('statusDate')) {
                item['createdAt'] = item['statusDate'];
              }
              
              if (!item.containsKey('updatedAt') && item.containsKey('statusDate')) {
                item['updatedAt'] = item['statusDate'];
              }

              return SSCC.fromJson(item);
            } else {
              throw FormatException('Expected Map but got ${item.runtimeType}');
            }
          } catch (e) {
            print('Error parsing SSCC item: $e for item: $item');
            // Use a default date for invalid items
            return SSCC(
              ssccCode: item is Map ? (item['sscc'] ?? 'Unknown SSCC') : 'Unknown SSCC',
              containerType: ContainerType.OTHER,
              containerStatus: ContainerStatus.CREATED,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );
          }
        }).toList();
        
        return results;
      } catch (e) {
        print('Error parsing SSCC list: $e');
        throw ApiException(message: 'Failed to parse SSCC list: $e');
      }
    } else if (response.statusCode == 403) {
      print('Authentication error: Token might be invalid or expired');
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Authentication failed: Please log in again',
        responseBody: response.body,
      );
    } else {
      print('SSCC list error: ${response.statusCode} - ${response.reasonPhrase}');
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to get all SSCCs: ${response.reasonPhrase}',
        responseBody: response.body,
      );
    }
  }

  @override
  Future<SSCC> updateSSCC(String id, SSCC ssccDetails) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final response = await _client.put(
      Uri.parse('${_appConfig.apiBaseUrl}/identifiers/sscc/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(ssccDetails.toJson()),
    );

    if (response.statusCode == 200) {
      return SSCC.fromJson(json.decode(response.body));
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to update SSCC: ${response.reasonPhrase}',
      );
    }
  }

  @override
  Future<void> deleteSSCC(String id) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final response = await _client.delete(
      Uri.parse('${_appConfig.apiBaseUrl}/identifiers/sscc/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 204) {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to delete SSCC: ${response.reasonPhrase}',
      );
    }
  }

  @override
  Future<List<SSCC>> findSSCCsByContainerType(ContainerType containerType) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final response = await _client.get(
      Uri.parse('${_appConfig.apiBaseUrl}/identifiers/sscc/container-type/${containerType.name}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => SSCC.fromJson(item)).toList();
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to find SSCCs by container type: ${response.reasonPhrase}',
      );
    }
  }

  @override
  Future<List<SSCC>> findSSCCsByContainerStatus(ContainerStatus containerStatus) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final response = await _client.get(
      Uri.parse('${_appConfig.apiBaseUrl}/identifiers/sscc/status/${containerStatus.name}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => SSCC.fromJson(item)).toList();
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to find SSCCs by container status: ${response.reasonPhrase}',
      );
    }
  }

  @override
  Future<List<SSCC>> findSSCCsBySourceLocation(String sourceGlnCode) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final response = await _client.get(
      Uri.parse('${_appConfig.apiBaseUrl}/identifiers/sscc/source-location/$sourceGlnCode'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => SSCC.fromJson(item)).toList();
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to find SSCCs by source location: ${response.reasonPhrase}',
      );
    }
  }

  @override
  Future<List<SSCC>> findSSCCsByDestinationLocation(String destinationGlnCode) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final response = await _client.get(
      Uri.parse('${_appConfig.apiBaseUrl}/identifiers/sscc/destination-location/$destinationGlnCode'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => SSCC.fromJson(item)).toList();
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to find SSCCs by destination location: ${response.reasonPhrase}',
      );
    }
  }

  @override
  Future<List<SSCC>> findSSCCsPackedBetween(DateTime startDate, DateTime endDate) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }
    
    final queryParams = <String, String>{
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
    };
    
    final uri = Uri.parse('${_appConfig.apiBaseUrl}/identifiers/sscc/packed-between')
        .replace(queryParameters: queryParams);
    
    final response = await _client.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => SSCC.fromJson(item)).toList();
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to find SSCCs packed between dates: ${response.reasonPhrase}',
      );
    }
  }

  @override
  Future<List<SSCC>> findSSCCsShippedBetween(DateTime startDate, DateTime endDate) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }
    
    final queryParams = <String, String>{
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
    };
    
    final uri = Uri.parse('${_appConfig.apiBaseUrl}/identifiers/sscc/shipped-between')
        .replace(queryParameters: queryParams);
    
    final response = await _client.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => SSCC.fromJson(item)).toList();
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to find SSCCs shipped between dates: ${response.reasonPhrase}',
      );
    }
  }

  @override
  Future<List<SSCC>> findChildSSCCs(String parentSsccCode) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final response = await _client.get(
      Uri.parse('${_appConfig.apiBaseUrl}/identifiers/sscc/$parentSsccCode/hierarchy'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> children = data['children'] ?? [];
      return children.map((item) => SSCC.fromJson(item)).toList();
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to find child SSCCs: ${response.reasonPhrase}',
      );
    }
  }

  @override
  Future<List<SSCC>> findSSCCsByGs1CompanyPrefix(String gs1CompanyPrefix) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final queryParams = <String, String>{
      'companyPrefix': gs1CompanyPrefix,
    };
    
    final uri = Uri.parse('${_appConfig.apiBaseUrl}/identifiers/sscc/company')
        .replace(queryParameters: queryParams);

    final response = await _client.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => SSCC.fromJson(item)).toList();
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to find SSCCs by GS1 company prefix: ${response.reasonPhrase}',
      );
    }
  }

  @override
  Future<List<SSCC>> searchSSCCs({
    ContainerType? containerType,
    ContainerStatus? containerStatus,
    String? sourceLocationId,
    String? destinationLocationId,
  }) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }
    
    final queryParams = <String, String>{
      if (containerType != null) 'containerType': containerType.name,
      if (containerStatus != null) 'containerStatus': containerStatus.name,
      if (sourceLocationId != null) 'sourceLocationId': sourceLocationId,
      if (destinationLocationId != null) 'destinationLocationId': destinationLocationId,
    };
    
    final uri = Uri.parse('${_appConfig.apiBaseUrl}/identifiers/sscc/search')
        .replace(queryParameters: queryParams);
    
    final response = await _client.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => SSCC.fromJson(item)).toList();
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to search SSCCs: ${response.reasonPhrase}',
      );
    }
  }

  @override
  Future<SSCC> updateSSCCStatus(String id, ContainerStatus newStatus) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final response = await _client.patch(
      Uri.parse('${_appConfig.apiBaseUrl}/identifiers/sscc/$id/status?status=${newStatus.name}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return SSCC.fromJson(json.decode(response.body));
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to update SSCC status: ${response.reasonPhrase}',
      );
    }
  }

  @override
  Future<bool> validateSSCCCode(String ssccCode) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final queryParams = <String, String>{
      'ssccCode': ssccCode,
    };
    
    final uri = Uri.parse('${_appConfig.apiBaseUrl}/identifiers/sscc/validate')
        .replace(queryParameters: queryParams);

    final response = await _client.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data['isValid'] as bool;
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to validate SSCC code: ${response.reasonPhrase}',
      );
    }
  }  @override  Future<String> generateSSCCCode(String gs1CompanyPrefix, String extensionDigit) async {
    final token = await _tokenManager.getToken();
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
    
    print('Sending SSCC generate request with: $requestBody');
    
    final response = await _client.post(
      Uri.parse('${_appConfig.apiBaseUrl}/identifiers/sscc/generate'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(requestBody),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      // Parse the response directly instead of using SSCC.fromJson
      final Map<String, dynamic> responseData = json.decode(response.body);
      
      // Debug information
      print('SSCC Generation Response: $responseData');
      
      String? ssccCode;
        // Check if the response contains the 'sscc' field directly (from backend standard)
      if (responseData.containsKey('sscc') && responseData['sscc'] != null) {
        ssccCode = responseData['sscc'].toString();
        print('Using sscc field from response: $ssccCode');
      } 
      // Check for ssccCode field (frontend convention)
      else if (responseData.containsKey('ssccCode') && responseData['ssccCode'] != null) {
        ssccCode = responseData['ssccCode'].toString();
        print('Using ssccCode field from response: $ssccCode');
      }
      // Try to parse as an SSCC object
      else if (responseData.containsKey('id')) {
        try {
          final SSCC generatedSscc = SSCC.fromJson(responseData);
          ssccCode = generatedSscc.ssccCode;
          print('Parsed as SSCC object, got code: $ssccCode');
        } catch (e) {
          print('Error parsing as SSCC object: $e');
          // Fall through to error message below
        }
      }
      
      if (ssccCode != null) {
        // Use the improved validation and fix function from GS1Utils
        final validatedSSCC = GS1Utils.validateAndFixSSCC(ssccCode);
        
        if (validatedSSCC != null) {
          print('Validated SSCC: $validatedSSCC');
          return validatedSSCC;
        } else {
          // If we can't validate or fix the SSCC, try to generate one locally
          try {
            print('Generating SSCC locally as a fallback');
            final localSSCC = GS1Utils.generateSSCC(gs1CompanyPrefix, extensionDigit);
            print('Generated local SSCC: $localSSCC');
            return localSSCC;
          } catch (e) {
            print('Failed to generate SSCC locally: $e');
            throw ApiException(
              message: 'Invalid SSCC format from API and local generation failed: $e',
            );
          }
        }
      }
      
      // If we couldn't extract the SSCC code from the response
      throw ApiException(
        message: 'Invalid response format: SSCC code not found in response: $responseData',
      );
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to generate SSCC code: ${response.reasonPhrase}',
        responseBody: response.body,
      );
    }
  }
  @override  Future<String> extractCompanyPrefixFromGLN(String glnInput) async {
    if (glnInput.isEmpty) {
      throw ApiException(message: 'GLN input cannot be empty');
    }
    
    print('Extracting company prefix from GLN input: $glnInput');
    
    // First, check if the input is in a special format (GS1 barcode or URN)
    // and extract the actual GLN code
    String? glnCode;
    
    // Check for URN format that contains company prefix directly
    final urnPrefixRegex = RegExp(r'urn:epc:id:sgln:(\d{7,10})\..*');
    final urnPrefixMatch = urnPrefixRegex.firstMatch(glnInput);
    
    if (urnPrefixMatch != null && urnPrefixMatch.group(1) != null) {
      // In URN format, we can directly extract the company prefix
      final companyPrefix = urnPrefixMatch.group(1);
      print('Extracted company prefix directly from URN: $companyPrefix');
      return companyPrefix!;
    }
    
    // Check if it's already a plain 13-digit GLN
    if (glnInput.length == 13 && RegExp(r'^\d{13}$').hasMatch(glnInput)) {
      glnCode = glnInput;
      print('Input is a plain 13-digit GLN');
    } else {
      // Try to parse from GS1 barcode or URN format using the GS1Utils class
      try {
        glnCode = await _parseGLNFromFormat(glnInput);
        print('Parsed GLN from format: $glnCode');
      } catch (e) {
        print('Error parsing GLN from input: ${e.toString()}');
        throw ApiException(message: 'Failed to parse GLN from input: ${e.toString()}');
      }
    }
    
    // If we couldn't extract a GLN code, throw an error
    if (glnCode == null || glnCode.isEmpty) {
      throw ApiException(message: 'Invalid GLN format. GLN must be in one of these formats: 13 digits, (414)nnnnnnnnnnnn, or urn:epc:id:sgln:prefix.reference.0');
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
    print('Extracted company prefix: $companyPrefix');
    return companyPrefix;
  }  /// Helper method to parse GLN from different formats
  Future<String?> _parseGLNFromFormat(String input) async {
    // First try using the utility class
    try {
      final result = GS1Utils.extractGLNCode(input);
      if (result != null && result.isNotEmpty) {
        return result;
      }
    } catch (e) {
      print('Error using GS1Utils.extractGLNCode: $e');
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

  @override
  Future<Map<String, dynamic>> searchSSCCsAdvanced({
    String? ssccCode,
    String? containerType,
    String? containerStatus,
    String? sourceLocationName,
    String? destinationLocationName,
    String? gs1CompanyPrefix,
    int page = 0,
    int size = 20,
    String sortBy = 'ssccCode',
    String direction = 'ASC',
  }) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw ApiException(message: 'No authentication token found');
    }

    final queryParams = <String, String>{};
    
    if (ssccCode?.isNotEmpty == true) queryParams['ssccCode'] = ssccCode!;
    if (containerType?.isNotEmpty == true) queryParams['containerType'] = containerType!;
    if (containerStatus?.isNotEmpty == true) queryParams['containerStatus'] = containerStatus!;
    if (sourceLocationName?.isNotEmpty == true) queryParams['sourceLocationName'] = sourceLocationName!;
    if (destinationLocationName?.isNotEmpty == true) queryParams['destinationLocationName'] = destinationLocationName!;
    if (gs1CompanyPrefix?.isNotEmpty == true) queryParams['gs1CompanyPrefix'] = gs1CompanyPrefix!;
    
    queryParams['page'] = page.toString();
    queryParams['size'] = size.toString();
    queryParams['sortBy'] = sortBy;
    queryParams['direction'] = direction;

    final uri = Uri.parse('${_appConfig.apiBaseUrl}/identifiers/sscc/search/advanced')
        .replace(queryParameters: queryParams);

    print('SSCC Advanced Search request: $uri');

    try {
      final response = await _client.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('SSCC Advanced Search response status: ${response.statusCode}');
      print('SSCC Advanced Search response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        // Convert content items to SSCC models
        final List<dynamic> contentList = responseData['content'] ?? [];
        final List<SSCC> ssccs = contentList.map((item) => SSCC.fromJson(item)).toList();
        
        return {
          'content': ssccs,
          'number': responseData['number'] ?? 0,
          'totalPages': responseData['totalPages'] ?? 1,
          'totalElements': responseData['totalElements'] ?? ssccs.length,
          'size': responseData['size'] ?? size,
          'first': responseData['first'] ?? true,
          'last': responseData['last'] ?? true,
        };
      } else {
        final error = json.decode(response.body);
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
}
