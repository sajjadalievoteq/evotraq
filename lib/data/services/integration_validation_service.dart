import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';

class ValidationResultDTO {
  final String testName;
  final bool passed;
  final List<String> validationSteps;
  final List<String> passedSteps;
  final List<String> failedSteps;
  final String message;

  ValidationResultDTO({
    required this.testName,
    required this.passed,
    required this.validationSteps,
    required this.passedSteps,
    required this.failedSteps,
    required this.message,
  });

  factory ValidationResultDTO.fromJson(Map<String, dynamic> json) {
    return ValidationResultDTO(
      testName: json['testName'] ?? 'Unknown Test',
      passed: json['passed'] ?? false,
      validationSteps: List<String>.from(json['validationSteps'] ?? []),
      passedSteps: List<String>.from(json['passedSteps'] ?? []),
      failedSteps: List<String>.from(json['failedSteps'] ?? []),
      message: json['message'] ?? '',
    );
  }
}

class IntegrationValidationService {
  final DioService _dioService;
  
  IntegrationValidationService({
    required DioService dioService,
  }) : _dioService = dioService;

  Future<Map<String, dynamic>> _getWithAuth(String path) async {
    final token = await _dioService.getAuthToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final response = await _dioService.get(
      '${_dioService.baseUrl}$path',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.data) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }

  /// Run GS1 identifier generation validation test
  Future<ValidationResultDTO> validateGS1IdentifierGeneration() async {
    final json = await _getWithAuth('/admin/integration-validation/gs1-identifier-generation');
    return ValidationResultDTO.fromJson(json);
  }
  
  /// Validate barcode generation and reading
  Future<ValidationResultDTO> validateBarcodeGenerationAndReading() async {
    final json = await _getWithAuth('/admin/integration-validation/barcode-generation-reading');
    return ValidationResultDTO.fromJson(json);
  }
  
  /// Validate EPCIS event creation flows
  Future<ValidationResultDTO> validateEPCISEventCreation() async {
    final json = await _getWithAuth('/admin/integration-validation/epcis-event-creation');
    return ValidationResultDTO.fromJson(json);
  }
  
  /// Validate relationship mapping functionality
  Future<ValidationResultDTO> validateRelationshipMapping() async {
    final json = await _getWithAuth('/admin/integration-validation/relationship-mapping');
    return ValidationResultDTO.fromJson(json);
  }
  
  /// Validate API contracts
  Future<ValidationResultDTO> validateAPIContracts() async {
    final json = await _getWithAuth('/admin/integration-validation/api-contracts');
    return ValidationResultDTO.fromJson(json);
  }
  
  /// Test error handling scenarios
  Future<ValidationResultDTO> testErrorHandling() async {
    final json = await _getWithAuth('/admin/integration-validation/error-handling');
    return ValidationResultDTO.fromJson(json);
  }
  
  /// Validate response formats
  Future<ValidationResultDTO> validateResponseFormats() async {
    final json = await _getWithAuth('/admin/integration-validation/response-formats');
    return ValidationResultDTO.fromJson(json);
  }
  
  /// Check authorization controls
  Future<ValidationResultDTO> checkAuthorizationControls() async {
    final json = await _getWithAuth('/admin/integration-validation/authorization-controls');
    return ValidationResultDTO.fromJson(json);
  }
  
  /// Run all integration validation tests
  Future<Map<String, ValidationResultDTO>> runAllValidationTests() async {
    final json = await _getWithAuth('/admin/integration-validation/run-all');

    return json.map((key, value) => MapEntry(
      key,
      ValidationResultDTO.fromJson(value as Map<String, dynamic>)
    ));
  }
}
