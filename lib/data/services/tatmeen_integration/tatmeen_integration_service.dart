import 'package:dio/dio.dart';
import 'package:traqtrace_app/core/network/api_exception_mapper.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';
import 'package:traqtrace_app/data/models/tatmeen_integration/tatmeen_dashboard_models.dart';
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

  Future<TatmeenDashboardStats> getTatmeenDashboardStats() async {
    final now = DateTime.now().toLocal();
    return TatmeenDashboardStats(
      totalSynced: 12840,
      successfulThisMonth: 11204,
      failedThisMonth: 87,
      pendingInQueue: 23,
      successfulTrendPct: 7.4,
      failedTrendPct: -3.1,
      pendingTrendPct: 1.8,
      lastSyncedAt: now.subtract(const Duration(minutes: 2)),
    );
  }

  Future<List<TatmeenChartPoint>> getTatmeenChartData({int days = 30}) async {
    final now = DateTime.now().toLocal();
    return List.generate(days, (index) {
      final day = now.subtract(Duration(days: days - 1 - index));
      final successful = 290 + ((index * 7) % 90) + (index % 4) * 14;
      final failed = 2 + (index % 5) + (index % 3 == 0 ? 2 : 0);
      return TatmeenChartPoint(
        date: DateTime(day.year, day.month, day.day),
        successful: successful,
        failed: failed,
      );
    });
  }

  Future<TatmeenStatusBreakdown> getTatmeenStatusBreakdown() async {
    return const TatmeenStatusBreakdown(
      successful: 11204,
      failed: 87,
      pending: 23,
    );
  }

  Future<List<TatmeenSyncEvent>> getTatmeenRecentActivity({int limit = 10}) async {
    final now = DateTime.now().toLocal();
    final seed = <TatmeenSyncEvent>[
      TatmeenSyncEvent(
        timestamp: now.subtract(const Duration(minutes: 3)),
        recordType: 'Serialized Pack',
        recordId: 'SGTIN-6291041500012.99887766',
        status: TatmeenSyncStatus.successful,
        message: 'Synchronized successfully',
      ),
      TatmeenSyncEvent(
        timestamp: now.subtract(const Duration(minutes: 11)),
        recordType: 'Aggregation',
        recordId: 'AGG-782991',
        status: TatmeenSyncStatus.pending,
        message: 'Queued for Tatmeen acknowledgment',
      ),
      TatmeenSyncEvent(
        timestamp: now.subtract(const Duration(minutes: 18)),
        recordType: 'Shipment',
        recordId: 'SHIP-440128',
        status: TatmeenSyncStatus.failed,
        message: 'Remote endpoint timeout after 15s',
      ),
      TatmeenSyncEvent(
        timestamp: now.subtract(const Duration(minutes: 26)),
        recordType: 'Decommission',
        recordId: 'SGTIN-6291041500012.88776611',
        status: TatmeenSyncStatus.successful,
        message: 'Lifecycle status accepted',
      ),
      TatmeenSyncEvent(
        timestamp: now.subtract(const Duration(minutes: 34)),
        recordType: 'Return Receiving',
        recordId: 'RET-77109',
        status: TatmeenSyncStatus.successful,
        message: 'Synchronized successfully',
      ),
    ];

    return List.generate(limit, (index) => seed[index % seed.length]);
  }

  Future<List<TatmeenErrorSummaryItem>> getTatmeenErrorSummary() async {
    return const [
      TatmeenErrorSummaryItem(
        message: 'Remote endpoint timeout after 15s',
        count: 27,
      ),
      TatmeenErrorSummaryItem(
        message: 'Authentication token expired while sending batch',
        count: 16,
      ),
      TatmeenErrorSummaryItem(
        message: 'Payload rejected: missing mandatory serial metadata',
        count: 13,
      ),
      TatmeenErrorSummaryItem(
        message: 'Duplicate transaction reference detected by Tatmeen',
        count: 8,
      ),
      TatmeenErrorSummaryItem(
        message: 'Transport unavailable: TLS handshake failure',
        count: 5,
      ),
    ];
  }
}
