// ignore_for_file: lines_longer_than_80_chars
import 'package:traqtrace_app/data/models/tatmeen_integration/tatmeen_dashboard_models.dart';
import 'package:traqtrace_app/data/models/tatmeen_integration/tatmeen_records_models.dart';

/// Hard-coded demo data for the Tatmeen Integration module.
/// Used when [TatmeenIntegrationService.demoMode] == true.
/// Flip [TatmeenIntegrationService.demoMode] to false to restore live API calls.
abstract final class TatmeenDemoData {
  // ── Dashboard stats ────────────────────────────────────────────────────────

  static TatmeenDashboardStats get dashboardStats => TatmeenDashboardStats(
        totalSynced: 142,
        successfulThisMonth: 58,
        failedThisMonth: 4,
        pendingInQueue: 2,
        successfulTrendPct: 12.5,
        failedTrendPct: -25.0,
        pendingTrendPct: 0.0,
        lastSyncedAt: DateTime.now().subtract(const Duration(minutes: 23)),
      );

  // ── Chart – last N days ────────────────────────────────────────────────────

  // ~60 % of days are "high" (≥ 70), the rest are low — fixed so the chart
  // always looks the same on every build.
  static const _successValues = [
    82, 91, 25, 78, 88, 14, 95, 76, 38, 85, // days 0-9
    74, 93, 22, 87, 79, 42, 96, 83, 17, 89, // days 10-19
    72, 35, 94, 81, 28, 86, 75, 12, 92, 77, // days 20-29
  ];
  static const _failedValues = [
    0, 2, 1, 0, 0, 3, 0, 1, 0, 0,
    2, 0, 0, 1, 0, 0, 0, 2, 1, 0,
    0, 1, 0, 0, 2, 0, 1, 0, 0, 2,
  ];

  static List<TatmeenChartPoint> chartData({int days = 30}) {
    final now = DateTime.now();
    final count = days.clamp(1, _successValues.length);
    return List.generate(count, (i) {
      final date = now.subtract(Duration(days: count - 1 - i));
      return TatmeenChartPoint(
        date: DateTime(date.year, date.month, date.day),
        successful: _successValues[i],
        failed: _failedValues[i],
      );
    });
  }

  // ── Status breakdown ───────────────────────────────────────────────────────

  static const TatmeenStatusBreakdown statusBreakdown = TatmeenStatusBreakdown(
    successful: 136,
    failed: 4,
    pending: 2,
  );

  // ── Recent activity ────────────────────────────────────────────────────────

  static List<TatmeenSyncEvent> recentActivity({int limit = 10}) {
    final now = DateTime.now();
    final all = <TatmeenSyncEvent>[
      TatmeenSyncEvent(
        timestamp: now.subtract(const Duration(minutes: 23)),
        recordType: 'Commissioning',
        recordId: 'OP-2024-08-001',
        status: TatmeenSyncStatus.successful,
        message: '',
      ),
      TatmeenSyncEvent(
        timestamp: now.subtract(const Duration(minutes: 47)),
        recordType: 'Epcis dispatch',
        recordId: 'OP-2024-08-002',
        status: TatmeenSyncStatus.successful,
        message: '',
      ),
      TatmeenSyncEvent(
        timestamp: now.subtract(const Duration(hours: 2, minutes: 10)),
        recordType: 'Aggregation',
        recordId: 'OP-2024-08-003',
        status: TatmeenSyncStatus.failed,
        message: 'Tatmeen service timeout — will retry',
      ),
      TatmeenSyncEvent(
        timestamp: now.subtract(const Duration(hours: 3, minutes: 5)),
        recordType: 'Commissioning',
        recordId: 'OP-2024-08-004',
        status: TatmeenSyncStatus.successful,
        message: '',
      ),
      TatmeenSyncEvent(
        timestamp: now.subtract(const Duration(hours: 4)),
        recordType: 'Decommission',
        recordId: 'OP-2024-08-005',
        status: TatmeenSyncStatus.pending,
        message: 'Queued — awaiting dispatch',
      ),
      TatmeenSyncEvent(
        timestamp: now.subtract(const Duration(hours: 5, minutes: 30)),
        recordType: 'Epcis dispatch',
        recordId: 'OP-2024-08-006',
        status: TatmeenSyncStatus.successful,
        message: '',
      ),
      TatmeenSyncEvent(
        timestamp: now.subtract(const Duration(hours: 7)),
        recordType: 'Commissioning',
        recordId: 'OP-2024-08-007',
        status: TatmeenSyncStatus.successful,
        message: '',
      ),
      TatmeenSyncEvent(
        timestamp: now.subtract(const Duration(hours: 9)),
        recordType: 'Aggregation',
        recordId: 'OP-2024-08-008',
        status: TatmeenSyncStatus.failed,
        message: 'Invalid GTIN format in payload',
      ),
      TatmeenSyncEvent(
        timestamp: now.subtract(const Duration(hours: 11)),
        recordType: 'Commissioning',
        recordId: 'OP-2024-08-009',
        status: TatmeenSyncStatus.successful,
        message: '',
      ),
      TatmeenSyncEvent(
        timestamp: now.subtract(const Duration(hours: 14)),
        recordType: 'Epcis dispatch',
        recordId: 'OP-2024-08-010',
        status: TatmeenSyncStatus.successful,
        message: '',
      ),
    ];
    return all.take(limit.clamp(1, all.length)).toList();
  }

  // ── Error summary ──────────────────────────────────────────────────────────

  static const List<TatmeenErrorSummaryItem> errorSummary = [
    TatmeenErrorSummaryItem(
      message: 'Tatmeen service timeout — request exceeded 30s',
      count: 3,
    ),
    TatmeenErrorSummaryItem(
      message: 'Invalid GTIN format in payload',
      count: 1,
    ),
  ];

  // ── Sync records ───────────────────────────────────────────────────────────

  static TatmeenSyncRecordsPage syncRecordsPage({
    TatmeenRecordsStatusFilter status = TatmeenRecordsStatusFilter.all,
    String? search,
    int page = 1,
    int pageSize = 20,
  }) {
    final now = DateTime.now();
    final all = <TatmeenSyncRecord>[
      _rec(
        id: '1',
        operationId: 'OP-2024-08-001',
        operationType: 'commissioning',
        status: TatmeenSyncStatus.successful,
        attempt: 1,
        durationMs: 1240,
        message: '',
        createdAt: now.subtract(const Duration(minutes: 23)),
      ),
      _rec(
        id: '2',
        operationId: 'OP-2024-08-002',
        operationType: 'epcis_dispatch',
        status: TatmeenSyncStatus.successful,
        attempt: 1,
        durationMs: 890,
        message: '',
        createdAt: now.subtract(const Duration(minutes: 47)),
      ),
      _rec(
        id: '3',
        operationId: 'OP-2024-08-003',
        operationType: 'aggregation',
        status: TatmeenSyncStatus.failed,
        attempt: 3,
        durationMs: 30012,
        message: 'Tatmeen service timeout — request exceeded 30s',
        createdAt: now.subtract(const Duration(hours: 2, minutes: 10)),
      ),
      _rec(
        id: '4',
        operationId: 'OP-2024-08-004',
        operationType: 'commissioning',
        status: TatmeenSyncStatus.successful,
        attempt: 1,
        durationMs: 1100,
        message: '',
        createdAt: now.subtract(const Duration(hours: 3, minutes: 5)),
      ),
      _rec(
        id: '5',
        operationId: 'OP-2024-08-005',
        operationType: 'update_status',
        status: TatmeenSyncStatus.pending,
        attempt: 1,
        durationMs: 0,
        message: 'Queued — awaiting dispatch',
        createdAt: now.subtract(const Duration(hours: 4)),
      ),
      _rec(
        id: '6',
        operationId: 'OP-2024-08-006',
        operationType: 'epcis_dispatch',
        status: TatmeenSyncStatus.successful,
        attempt: 2,
        durationMs: 1560,
        message: '',
        createdAt: now.subtract(const Duration(hours: 5, minutes: 30)),
      ),
      _rec(
        id: '7',
        operationId: 'OP-2024-08-008',
        operationType: 'aggregation',
        status: TatmeenSyncStatus.failed,
        attempt: 3,
        durationMs: 2100,
        message: 'Invalid GTIN format in payload',
        createdAt: now.subtract(const Duration(hours: 8)),
      ),
    ];

    var filtered = status == TatmeenRecordsStatusFilter.all
        ? all
        : all.where((r) => r.status.name == status.name).toList();

    if (search != null && search.trim().isNotEmpty) {
      final needle = search.trim().toLowerCase();
      filtered = filtered
          .where((r) =>
              r.operationId.toLowerCase().contains(needle) ||
              r.operationType.toLowerCase().contains(needle))
          .toList();
    }

    final total = filtered.length;
    final fromIndex = ((page - 1) * pageSize).clamp(0, total);
    final toIndex = (fromIndex + pageSize).clamp(0, total);
    return TatmeenSyncRecordsPage(
      items: filtered.sublist(fromIndex, toIndex),
      total: total,
      page: page,
      pageSize: pageSize,
    );
  }

  static TatmeenSyncRecord _rec({
    required String id,
    required String operationId,
    required String operationType,
    required TatmeenSyncStatus status,
    required int attempt,
    required int durationMs,
    required String message,
    required DateTime createdAt,
  }) =>
      TatmeenSyncRecord(
        id: id,
        operationId: operationId,
        operationType: operationType,
        status: status,
        attemptNumber: attempt,
        maxRetries: 3,
        durationMs: durationMs,
        message: message,
        requestPayload: const {'summary': 'Demo payload'},
        responseBody: const {'summary': 'Demo response'},
        attemptHistory: [
          TatmeenAttemptHistory(
            timestamp: createdAt,
            errorMessage: message,
          ),
        ],
        createdAt: createdAt,
      );
}
