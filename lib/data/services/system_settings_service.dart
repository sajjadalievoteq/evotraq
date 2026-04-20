import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:traqtrace_app/core/models/system_settings_model.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';

/// Service for managing system configuration and settings.
class SystemSettingsService {
  final DioService _dioService;

  SystemSettingsService({required DioService dioService})
    : _dioService = dioService;

  Future<Map<String, String>> _getHeaders() async {
    final token = await _dioService.getAuthToken();
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
    final response = await _dioService.get(
      '${_dioService.baseUrl}/system/settings',
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
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
    final response = await _dioService.get(
      '${_dioService.baseUrl}/system/industry-mode',
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
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
    final response = await _dioService.get(
      '${_dioService.baseUrl}/system/industry-modes',
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
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
    final response = await _dioService.get(
      '${_dioService.baseUrl}/system/data-statistics',
      headers: headers,
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
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
    final response = await _dioService.post(
      '${_dioService.baseUrl}/system/industry-mode/change',
      headers: headers,
      data: jsonEncode({
        'newMode': newMode.toApiValue(),
        'confirmDataClear': confirmDataClear,
        if (reason != null) 'reason': reason,
      }),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
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
    final response = await _dioService.post(
      '${_dioService.baseUrl}/system/clear-data',
      headers: headers,
      data: jsonEncode({'confirm': true}),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
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
    final response = await _dioService.put(
      '${_dioService.baseUrl}/system/config/$key',
      headers: headers,
      data: jsonEncode({'value': value, if (reason != null) 'reason': reason}),
      responseType: ResponseType.plain,
      acceptAllStatusCodes: true,
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to update configuration: ${_stringifyResponseData(response.data)}',
      );
    }
  }
}
