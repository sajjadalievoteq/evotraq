import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:traqtrace_app/core/network/token_manager.dart';
import 'package:traqtrace_app/shared/utils/gs1_validator.dart';

class PerformanceTestResult {
  final String testName;
  final bool passed;
  final double operationsPerSecond;
  final int executionTimeMs;
  final double thresholdOperationsPerSecond;
  final String message;

  PerformanceTestResult({
    required this.testName,
    required this.passed,
    required this.operationsPerSecond,
    required this.executionTimeMs,
    required this.thresholdOperationsPerSecond,
    required this.message,
  });

  factory PerformanceTestResult.fromJson(Map<String, dynamic> json) {
    // Handle "Infinity" strings in operationsPerSecond
    double parseOpsPerSecond(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        if (value == "Infinity") return double.infinity;
        try {
          return double.parse(value);
        } catch (_) {
          return 0.0;
        }
      }
      return 0.0;
    }
    
    return PerformanceTestResult(
      testName: json['testName'] ?? 'Unknown Test',
      passed: json['passed'] ?? false,
      operationsPerSecond: parseOpsPerSecond(json['operationsPerSecond']),
      executionTimeMs: json['executionTimeMs'] ?? 0,
      thresholdOperationsPerSecond: parseOpsPerSecond(json['thresholdOperationsPerSecond']),
      message: json['message'] ?? '',
    );
  }
}

class PerformanceTestService {
  final TokenManager _tokenManager;
  final String _baseUrl;
  
  PerformanceTestService({
    TokenManager? tokenManager,
    required String baseUrl,
  }) : _tokenManager = tokenManager ?? TokenManager(),
       _baseUrl = baseUrl;
  
  Future<Map<String, dynamic>> _getWithAuth(String path) async {
    final token = await _tokenManager.getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }
    
    final response = await http.get(
      Uri.parse('$_baseUrl$path'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }
  
  /// Run GS1 identifier validation performance test
  Future<PerformanceTestResult> runGS1ValidationPerformanceTest() async {
    final json = await _getWithAuth('/admin/performance-tests/gs1-validation');
    return PerformanceTestResult.fromJson(json);
  }
  
  /// Run batch event insertion performance test
  Future<PerformanceTestResult> runBatchInsertionPerformanceTest() async {
    final json = await _getWithAuth('/admin/performance-tests/batch-insertion');
    return PerformanceTestResult.fromJson(json);
  }
  
  /// Run query caching performance test
  Future<PerformanceTestResult> runQueryCachingPerformanceTest() async {
    final json = await _getWithAuth('/admin/performance-tests/query-caching');
    return PerformanceTestResult.fromJson(json);
  }
  
  /// Run barcode parsing performance test
  Future<PerformanceTestResult> runBarcodeParsingPerformanceTest() async {
    final json = await _getWithAuth('/admin/performance-tests/barcode-parsing');
    return PerformanceTestResult.fromJson(json);
  }
  
  /// Run all performance tests
  Future<Map<String, PerformanceTestResult>> runAllPerformanceTests() async {
    final json = await _getWithAuth('/admin/performance-tests/run-all');
    
    return json.map((key, value) => MapEntry(
      key, 
      PerformanceTestResult.fromJson(value as Map<String, dynamic>)
    ));
  }
  
  /// Run frontend-only performance tests (for comparison with backend)
  Future<PerformanceTestResult> runFrontendGS1ValidationPerformanceTest() async {
    final Stopwatch stopwatch = Stopwatch()..start();
    const int iterations = 10000;
    
    for (int i = 0; i < iterations; i++) {
      // Use the frontend GS1Validator
      await Future.microtask(() => 
        GS1Validator.isValidGTIN('12345678901231'));
    }
    
    stopwatch.stop();
    final double validationsPerSecond = iterations / (stopwatch.elapsedMilliseconds / 1000);
    const double threshold = 3000.0; // Lower threshold for frontend
    
    return PerformanceTestResult(
      testName: 'Frontend GS1 Validation Performance',
      passed: validationsPerSecond >= threshold,
      operationsPerSecond: validationsPerSecond,
      executionTimeMs: stopwatch.elapsedMilliseconds,
      thresholdOperationsPerSecond: threshold,
      message: 'Processed $iterations validations in ${stopwatch.elapsedMilliseconds} ms',
    );
  }
  
  Future<PerformanceTestResult> runFrontendBarcodeParsingPerformanceTest() async {
    final Stopwatch stopwatch = Stopwatch()..start();
    const int iterations = 5000;
    const String testBarcode = "(01)12345678901231(21)ABC123(10)LOT1234";
    int successCount = 0;
    
    for (int i = 0; i < iterations; i++) {
      await Future.microtask(() {
        final result = GS1Validator.validateBarcodeData(testBarcode);
        if (result == null) successCount++;
      });
    }
    
    stopwatch.stop();
    final double validationsPerSecond = iterations / (stopwatch.elapsedMilliseconds / 1000);
    const double threshold = 800.0; // Lower threshold for frontend
    
    return PerformanceTestResult(
      testName: 'Frontend Barcode Parsing Performance',
      passed: validationsPerSecond >= threshold,
      operationsPerSecond: validationsPerSecond,
      executionTimeMs: stopwatch.elapsedMilliseconds,
      thresholdOperationsPerSecond: threshold,
      message: 'Processed $iterations barcode validations in ${stopwatch.elapsedMilliseconds} ms, $successCount successful',
    );
  }
}
