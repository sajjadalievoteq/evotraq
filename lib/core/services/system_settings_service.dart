import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/system_settings_model.dart';
import '../network/token_manager.dart';

/// Service for managing system configuration and settings.
class SystemSettingsService {
  final String baseUrl;
  final TokenManager tokenManager;

  SystemSettingsService({
    required this.baseUrl,
    required this.tokenManager,
  });

  Future<Map<String, String>> _getHeaders() async {
    final token = await tokenManager.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Get current system settings.
  Future<SystemSettings> getSystemSettings() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/system/settings'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return SystemSettings.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load system settings: ${response.body}');
    }
  }

  /// Get current industry mode.
  Future<IndustryMode> getIndustryMode() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/system/industry-mode'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return IndustryMode.fromString(data['mode']);
    } else {
      throw Exception('Failed to load industry mode: ${response.body}');
    }
  }

  /// Get available industry modes for selection.
  Future<List<Map<String, String>>> getAvailableIndustryModes() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/system/industry-modes'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => Map<String, String>.from(item)).toList();
    } else {
      throw Exception('Failed to load industry modes: ${response.body}');
    }
  }

  /// Get data statistics (before clearing).
  Future<DataClearStatistics> getDataStatistics() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/system/data-statistics'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return DataClearStatistics.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load data statistics: ${response.body}');
    }
  }

  /// Change industry mode (this will clear all data).
  Future<SystemSettings> changeIndustryMode({
    required IndustryMode newMode,
    required bool confirmDataClear,
    String? reason,
  }) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/system/industry-mode/change'),
      headers: headers,
      body: json.encode({
        'newMode': newMode.toApiValue(),
        'confirmDataClear': confirmDataClear,
        if (reason != null) 'reason': reason,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return SystemSettings.fromJson(data['settings']);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['error'] ?? 'Failed to change industry mode');
    }
  }

  /// Clear all transactional data.
  Future<DataClearStatistics> clearAllData() async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/system/clear-data'),
      headers: headers,
      body: json.encode({'confirm': true}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return DataClearStatistics.fromJson(data['clearedCounts']);
    } else {
      throw Exception('Failed to clear data: ${response.body}');
    }
  }

  /// Update a specific configuration.
  Future<void> updateConfiguration({
    required String key,
    required String value,
    String? reason,
  }) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/system/config/$key'),
      headers: headers,
      body: json.encode({
        'value': value,
        if (reason != null) 'reason': reason,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update configuration: ${response.body}');
    }
  }
}
