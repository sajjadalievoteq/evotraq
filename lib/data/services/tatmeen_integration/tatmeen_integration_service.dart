import 'package:dio/dio.dart';
import 'package:traqtrace_app/core/network/api_exception_mapper.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';
import 'package:traqtrace_app/data/models/tatmeen_integration/tatmeen_dashboard_models.dart';
import 'package:traqtrace_app/data/models/tatmeen_integration/tatmeen_integration_settings.dart';
import 'package:traqtrace_app/data/models/tatmeen_integration/tatmeen_records_models.dart';

class TatmeenIntegrationService {
  TatmeenIntegrationService({required DioService dioService})
    : _dioService = dioService;

  final DioService _dioService;

  static const _settingsPath = '/tatmeen-integration/settings';
  static const _testConnectionPath = '/tatmeen-integration/test-connection';
  static const _recordsPath = '/tatmeen-integration/records';
  static const _commissioningPath = '/tatmeen-integration/commissioning';

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

  Future<TatmeenDashboardStats> getTatmeenDashboardStats() async {
    try {
      final response = await _dioService.get('/tatmeen-integration/dashboard/stats');
      return TatmeenDashboardStats.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw ApiExceptionMapper.fromDio(
        e,
        fallbackMessage: 'Failed to load dashboard stats.',
      );
    }
  }

  Future<List<TatmeenChartPoint>> getTatmeenChartData({int days = 30}) async {
    try {
      final response = await _dioService.get(
        '/tatmeen-integration/dashboard/chart',
        queryParameters: {'days': days},
      );
      final raw = response.data;
      if (raw is! List) return const [];
      return [
        for (final item in raw)
          if (item is Map)
            TatmeenChartPoint.fromJson(Map<String, dynamic>.from(item)),
      ];
    } on DioException catch (e) {
      throw ApiExceptionMapper.fromDio(
        e,
        fallbackMessage: 'Failed to load dashboard chart data.',
      );
    }
  }

  Future<TatmeenStatusBreakdown> getTatmeenStatusBreakdown() async {
    try {
      final response = await _dioService.get(
        '/tatmeen-integration/dashboard/breakdown',
      );
      return TatmeenStatusBreakdown.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw ApiExceptionMapper.fromDio(
        e,
        fallbackMessage: 'Failed to load status breakdown.',
      );
    }
  }

  Future<List<TatmeenSyncEvent>> getTatmeenRecentActivity({int limit = 10}) async {
    try {
      final response = await _dioService.get(
        '/tatmeen-integration/dashboard/recent-activity',
        queryParameters: {'limit': limit},
      );
      final raw = response.data;
      if (raw is! List) return const [];
      return [
        for (final item in raw)
          if (item is Map)
            TatmeenSyncEvent.fromJson(Map<String, dynamic>.from(item)),
      ];
    } on DioException catch (e) {
      throw ApiExceptionMapper.fromDio(
        e,
        fallbackMessage: 'Failed to load recent activity.',
      );
    }
  }

  Future<List<TatmeenErrorSummaryItem>> getTatmeenErrorSummary() async {
    try {
      final response = await _dioService.get(
        '/tatmeen-integration/dashboard/error-summary',
      );
      final raw = response.data;
      if (raw is! List) return const [];
      return [
        for (final item in raw)
          if (item is Map)
            TatmeenErrorSummaryItem.fromJson(Map<String, dynamic>.from(item)),
      ];
    } on DioException catch (e) {
      throw ApiExceptionMapper.fromDio(
        e,
        fallbackMessage: 'Failed to load error summary.',
      );
    }
  }

  Future<TatmeenSyncRecordsPage> getSyncRecords(
    TatmeenRecordsQuery query,
  ) async {
    try {
      final response = await _dioService.get(
        _recordsPath,
        queryParameters: {
          if (query.status != TatmeenRecordsStatusFilter.all)
            'status': query.status.name,
          if (query.fromDate != null)
            'fromDate': _dateParam(query.fromDate!),
          if (query.toDate != null) 'toDate': _dateParam(query.toDate!),
          if (query.search != null && query.search!.trim().isNotEmpty)
            'search': query.search!.trim(),
          'page': query.page,
          'pageSize': query.pageSize,
        },
      );
      if (response.data is! Map) {
        throw const FormatException('Tatmeen records response was not a JSON object');
      }
      return TatmeenSyncRecordsPage.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw ApiExceptionMapper.fromDio(
        e,
        fallbackMessage: 'Failed to load sync records.',
      );
    }
  }

  Future<TatmeenRetryOutcome> retrySyncRecord(String operationId) async {
    try {
      final response = await _dioService.post(
        '/tatmeen-integration/failed-queue/$operationId/retry',
      );
      return _parseRetryOutcome(response.data);
    } on DioException catch (e) {
      final data = e.response?.data;
      final status = e.response?.statusCode;
      if (data is Map && (status == 400 || status == 502)) {
        return _parseRetryOutcome(data);
      }
      throw ApiExceptionMapper.fromDio(
        e,
        fallbackMessage: 'Failed to retry sync record.',
      );
    }
  }

  TatmeenRetryOutcome _parseRetryOutcome(dynamic data) {
    if (data is! Map) return const TatmeenRetryOutcome.success();
    final result = data['result']?.toString();
    final error = data['error']?.toString();
    final raw = data['message']?.toString();

    if (result == 'success') return const TatmeenRetryOutcome.success();

    if (error == 'integration_disabled') {
      return TatmeenRetryOutcome.failure(
        'Tatmeen integration is currently disabled. '
        'Go to Settings → Tatmeen to enable it before retrying.',
      );
    }
    if (error == 'credentials_missing') {
      return TatmeenRetryOutcome.failure(
        'Tatmeen credentials are not configured. '
        'Add your API credentials in Settings → Tatmeen first.',
      );
    }
    return TatmeenRetryOutcome.failure(_friendlyBackendMessage(raw));
  }

  String _friendlyBackendMessage(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return 'Retry failed. Please try again later.';
    }
    final lower = raw.toLowerCase();
    if (lower.contains('timed out') || lower.contains('timeout')) {
      return 'Tatmeen is not responding. '
          'The service may be temporarily unavailable — try again later.';
    }
    if (lower.contains('connection refused') ||
        lower.contains('econnrefused') ||
        (lower.contains('connect') && lower.contains('fail'))) {
      return 'Could not reach Tatmeen. '
          'Check that the service is running and your network connection is stable.';
    }
    if (lower.contains('unauthorized') ||
        lower.contains('unauthenticated') ||
        lower.contains('401')) {
      return 'Tatmeen authentication failed. '
          'Your credentials may have expired — check Settings → Tatmeen.';
    }
    if (lower.contains('bad_payload') ||
        lower.contains('invalid') ||
        lower.contains('400')) {
      return 'Tatmeen rejected the request data. '
          'Please contact support if this keeps happening.';
    }
    if (lower.contains('500') || lower.contains('server error')) {
      return 'Tatmeen server error. Please try again in a moment.';
    }
    final trimmed = raw.trim();
    return trimmed.length > 120
        ? 'Retry failed: ${trimmed.substring(0, 120)}…'
        : 'Retry failed: $trimmed';
  }

  Future<void> dismissSyncRecord(String id) async {
    try {
      await _dioService.patch('/tatmeen-integration/failed-queue/$id/dismiss');
    } on DioException catch (e) {
      throw ApiExceptionMapper.fromDio(
        e,
        fallbackMessage: 'Failed to dismiss sync record.',
      );
    }
  }

  Future<String> triggerCommissioning(Map<String, dynamic> payload) async {
    try {
      final response = await _dioService.post(_commissioningPath, data: payload);
      return (response.data as Map)['syncLogId'] as String;
    } on DioException catch (e) {
      throw ApiExceptionMapper.fromDio(
        e,
        fallbackMessage: 'Failed to trigger commissioning sync.',
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

  String _dateParam(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}
