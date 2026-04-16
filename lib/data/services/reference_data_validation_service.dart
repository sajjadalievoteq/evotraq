import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';
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

class ReferenceDataValidationService {
  final DioService _dioService;

  ReferenceDataValidationService({required DioService dioService})
    : _dioService = dioService;

  String get _baseUrl => '${_dioService.baseUrl}/validate';

  Future<Map<String, String>> get _headers async {
    final token = await _dioService.getAuthToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<EPCValidationResult> validateSSCC(String ssccCode) async {
    try {
      final response = await _dioService.get(
        '$_baseUrl/sscc/$ssccCode',
        headers: await _headers,
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.data);
        return EPCValidationResult.fromJson(json);
      } else {
        throw ApiException(
          statusCode: response.statusCode,
          message: 'Failed to validate SSCC: ${response.statusMessage}',
        );
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException(message: 'Error validating SSCC: $e');
    }
  }

  Future<EPCValidationResult> validateSGTIN(String sgtinCode) async {
    try {
      final response = await _dioService.get(
        '$_baseUrl/sgtin/$sgtinCode',
        headers: await _headers,
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.data);
        return EPCValidationResult.fromJson(json);
      } else {
        throw ApiException(
          statusCode: response.statusCode,
          message: 'Failed to validate SGTIN: ${response.statusMessage}',
        );
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException(message: 'Error validating SGTIN: $e');
    }
  }

  Future<BatchEPCValidationResult> validateEPCs(List<String> epcs) async {
    try {
      final requestBody = {'epcs': epcs};

      final response = await _dioService.post(
        '$_baseUrl/epcs',
        headers: await _headers,
        data: jsonEncode(requestBody),
        responseType: ResponseType.plain,
        acceptAllStatusCodes: true,
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.data);
        return BatchEPCValidationResult.fromJson(json);
      } else {
        throw ApiException(
          statusCode: response.statusCode,
          message: 'Failed to validate EPCs: ${response.statusMessage}',
        );
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException(message: 'Error validating EPCs: $e');
    }
  }
}
