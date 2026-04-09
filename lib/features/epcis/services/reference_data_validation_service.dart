import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:traqtrace_app/core/config/app_config.dart';
import 'package:traqtrace_app/core/network/token_manager.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';

/// Model for EPC validation result
class EPCValidationResult {
  final String epc;
  final bool exists;
  final String? type;
  final List<String> errors;
  final String? message;

  EPCValidationResult({
    required this.epc,
    required this.exists,
    this.type,
    this.errors = const [],
    this.message,
  });

  factory EPCValidationResult.fromJson(Map<String, dynamic> json) {
    return EPCValidationResult(
      epc: json['epc'] ?? json['ssccCode'] ?? json['sgtinCode'] ?? '',
      exists: json['exists'] ?? false,
      type: json['type'],
      errors: List<String>.from(json['errors'] ?? []),
      message: json['message'],
    );
  }
}

/// Model for batch EPC validation result
class BatchEPCValidationResult {
  final List<EPCValidationResult> results;
  final int totalValidated;
  final int validCount;

  BatchEPCValidationResult({
    required this.results,
    required this.totalValidated,
    required this.validCount,
  });

  factory BatchEPCValidationResult.fromJson(Map<String, dynamic> json) {
    return BatchEPCValidationResult(
      results: (json['results'] as List<dynamic>)
          .map((item) => EPCValidationResult.fromJson(item))
          .toList(),
      totalValidated: json['totalValidated'] ?? 0,
      validCount: json['validCount'] ?? 0,
    );
  }
}

/// Service for validating reference data existence in the database
/// Used primarily for shipping operations to validate scanned SSCC/SGTIN codes
abstract class ReferenceDataValidationService {
  /// Validate if an SSCC exists in the database
  Future<EPCValidationResult> validateSSCC(String ssccCode);
  
  /// Validate if an SGTIN exists in the database
  Future<EPCValidationResult> validateSGTIN(String sgtinCode);
  
  /// Validate multiple EPCs at once
  Future<BatchEPCValidationResult> validateEPCs(List<String> epcs);
}

/// Implementation of ReferenceDataValidationService
class ReferenceDataValidationServiceImpl implements ReferenceDataValidationService {
  final http.Client httpClient;
  final TokenManager tokenManager;
  final AppConfig appConfig;

  ReferenceDataValidationServiceImpl({
    required this.httpClient,
    required this.tokenManager,
    required this.appConfig,
  });

  String get _baseUrl => '${appConfig.apiBaseUrl}/validate';

  Future<Map<String, String>> get _headers async {
    final token = await tokenManager.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  @override
  Future<EPCValidationResult> validateSSCC(String ssccCode) async {
    try {
      final response = await httpClient.get(
        Uri.parse('$_baseUrl/sscc/$ssccCode'),
        headers: await _headers,
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return EPCValidationResult.fromJson(json);
      } else {
        throw ApiException(
          statusCode: response.statusCode,
          message: 'Failed to validate SSCC: ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException(
        message: 'Error validating SSCC: $e',
      );
    }
  }

  @override
  Future<EPCValidationResult> validateSGTIN(String sgtinCode) async {
    try {
      final response = await httpClient.get(
        Uri.parse('$_baseUrl/sgtin/$sgtinCode'),
        headers: await _headers,
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return EPCValidationResult.fromJson(json);
      } else {
        throw ApiException(
          statusCode: response.statusCode,
          message: 'Failed to validate SGTIN: ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException(
        message: 'Error validating SGTIN: $e',
      );
    }
  }

  @override
  Future<BatchEPCValidationResult> validateEPCs(List<String> epcs) async {
    try {
      final requestBody = {
        'epcs': epcs,
      };

      final response = await httpClient.post(
        Uri.parse('$_baseUrl/epcs'),
        headers: await _headers,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return BatchEPCValidationResult.fromJson(json);
      } else {
        throw ApiException(
          statusCode: response.statusCode,
          message: 'Failed to validate EPCs: ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException(
        message: 'Error validating EPCs: $e',
      );
    }
  }
}