import 'package:dio/dio.dart';
import 'package:traqtrace_app/core/network/api_exception_mapper.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';
import 'package:traqtrace_app/data/models/tatmeen_integration/tatmeen_integration_settings.dart';

class TatmeenIntegrationService {
  TatmeenIntegrationService({required DioService dioService})
    : _dioService = dioService;

  final DioService _dioService;

  static const _settingsPath = '/tatmeen-integration/settings';
  static const _testConnectionPath = '/tatmeen-integration/test-connection';

  Future<TatmeenIntegrationSettings> fetchSettings() async {
    try {
      final response = await _dioService.get(_settingsPath);
      return _decodeSettings(response.data);
    } on DioException catch (e) {
      throw ApiExceptionMapper.fromDio(
        e,
        fallbackMessage: 'Failed to load Tatmeen integration settings.',
      );
    }
  }

  Future<TatmeenIntegrationSettings> updateSettings(
    UpdateTatmeenIntegrationSettingsRequest request,
  ) async {
    try {
      final response = await _dioService.patch(
        _settingsPath,
        data: request.toJson(),
      );
      return _decodeSettings(response.data);
    } on DioException catch (e) {
      throw ApiExceptionMapper.fromDio(
        e,
        fallbackMessage: 'Failed to update Tatmeen integration settings.',
      );
    }
  }

  Future<TatmeenConnectionTestResult> testConnection() async {
    try {
      final response = await _dioService.post(_testConnectionPath, data: {});
      return _decodeConnectionResult(response.data);
    } on DioException catch (e) {
      throw ApiExceptionMapper.fromDio(
        e,
        fallbackMessage: 'Failed to test Tatmeen connection.',
      );
    }
  }

  TatmeenIntegrationSettings _decodeSettings(dynamic data) {
    if (data is! Map) {
      throw const FormatException(
        'Tatmeen integration settings response was not a JSON object',
      );
    }
    final enabled = data['enabled'];
    if (enabled is! bool) {
      throw FormatException(
        'Tatmeen integration settings response missing boolean enabled: $data',
      );
    }
    return TatmeenIntegrationSettings.fromJson(Map<String, dynamic>.from(data));
  }

  TatmeenConnectionTestResult _decodeConnectionResult(dynamic data) {
    if (data is! Map) {
      throw const FormatException(
        'Tatmeen connection test response was not a JSON object',
      );
    }
    return TatmeenConnectionTestResult.fromJson(
      Map<String, dynamic>.from(data),
    );
  }
}
