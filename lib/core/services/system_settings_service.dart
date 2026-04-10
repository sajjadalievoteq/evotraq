import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/system_settings_model.dart';
import '../network/token_manager.dart';

/// Service for managing system configuration and settings.
class SystemSettingsService {
  final Dio _dio;
  final String baseUrl;
  final TokenManager tokenManager;

  SystemSettingsService({
    required Dio dio,
    required this.baseUrl,
    required this.tokenManager,
  }) : _dio = dio;

  Future<Map<String, String>> _getHeaders() async {
    final token = await tokenManager.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  dynamic _decodeJson(dynamic data) {
    if (data is String) {
      return json.decode(data);
    }
    return data;
  }

  String _stringifyResponseData(dynamic data) {
    if (data == null) return '';
    if (data is String) return data;
    try {
      return json.encode(data);
    } catch (_) {
      return data.toString();
    }
  }

  /// Get current system settings.
  Future<SystemSettings> getSystemSettings() async {
    final headers = await _getHeaders();
    final response = await _dio.get(
      '$baseUrl/system/settings',
      options: Options(headers: headers, validateStatus: (_) => true),
    );

    if (response.statusCode == 200) {
      return SystemSettings.fromJson(_decodeJson(response.data));
    } else {
      throw Exception(
        'Failed to load system settings: ${_stringifyResponseData(response.data)}',
      );
    }
  }

  /// Get current industry mode.
  Future<IndustryMode> getIndustryMode() async {
    final headers = await _getHeaders();
    final response = await _dio.get(
      '$baseUrl/system/industry-mode',
      options: Options(headers: headers, validateStatus: (_) => true),
    );

    if (response.statusCode == 200) {
      final data = _decodeJson(response.data) as Map;
      return IndustryMode.fromString(data['mode']);
    } else {
      throw Exception(
        'Failed to load industry mode: ${_stringifyResponseData(response.data)}',
      );
    }
  }

  /// Get available industry modes for selection.
  Future<List<Map<String, String>>> getAvailableIndustryModes() async {
    final headers = await _getHeaders();
    final response = await _dio.get(
      '$baseUrl/system/industry-modes',
      options: Options(headers: headers, validateStatus: (_) => true),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = (_decodeJson(response.data) as List).cast();
      return data.map((item) => Map<String, String>.from(item)).toList();
    } else {
      throw Exception(
        'Failed to load industry modes: ${_stringifyResponseData(response.data)}',
      );
    }
  }

  /// Get data statistics (before clearing).
  Future<DataClearStatistics> getDataStatistics() async {
    final headers = await _getHeaders();
    final response = await _dio.get(
      '$baseUrl/system/data-statistics',
      options: Options(headers: headers, validateStatus: (_) => true),
    );

    if (response.statusCode == 200) {
      return DataClearStatistics.fromJson(_decodeJson(response.data));
    } else {
      throw Exception(
        'Failed to load data statistics: ${_stringifyResponseData(response.data)}',
      );
    }
  }

  /// Change industry mode (this will clear all data).
  Future<SystemSettings> changeIndustryMode({
    required IndustryMode newMode,
    required bool confirmDataClear,
    String? reason,
  }) async {
    final headers = await _getHeaders();
    final response = await _dio.post(
      '$baseUrl/system/industry-mode/change',
      options: Options(headers: headers, validateStatus: (_) => true),
      data: {
        'newMode': newMode.toApiValue(),
        'confirmDataClear': confirmDataClear,
        if (reason != null) 'reason': reason,
      },
    );

    if (response.statusCode == 200) {
      final data = _decodeJson(response.data) as Map;
      return SystemSettings.fromJson(data['settings']);
    } else {
      final error = _decodeJson(response.data);
      if (error is Map && error['error'] != null) {
        throw Exception(error['error']);
      }
      throw Exception('Failed to change industry mode');
    }
  }

  /// Clear all transactional data.
  Future<DataClearStatistics> clearAllData() async {
    final headers = await _getHeaders();
    final response = await _dio.post(
      '$baseUrl/system/clear-data',
      options: Options(headers: headers, validateStatus: (_) => true),
      data: {'confirm': true},
    );

    if (response.statusCode == 200) {
      final data = _decodeJson(response.data) as Map;
      return DataClearStatistics.fromJson(data['clearedCounts']);
    } else {
      throw Exception(
        'Failed to clear data: ${_stringifyResponseData(response.data)}',
      );
    }
  }

  /// Update a specific configuration.
  Future<void> updateConfiguration({
    required String key,
    required String value,
    String? reason,
  }) async {
    final headers = await _getHeaders();
    final response = await _dio.put(
      '$baseUrl/system/config/$key',
      options: Options(headers: headers, validateStatus: (_) => true),
      data: {'value': value, if (reason != null) 'reason': reason},
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to update configuration: ${_stringifyResponseData(response.data)}',
      );
    }
  }
}
