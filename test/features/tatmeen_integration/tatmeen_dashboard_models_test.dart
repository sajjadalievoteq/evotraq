import 'package:flutter_test/flutter_test.dart';
import 'package:traqtrace_app/data/models/tatmeen_integration/tatmeen_dashboard_models.dart';

void main() {
  test('parses dashboard when lastSyncedAt is null', () {
    final data = TatmeenDashboardData.fromJson({
      'stats': {
        'totalSynced': 0,
        'successfulThisMonth': 0,
        'failedThisMonth': 0,
        'pendingInQueue': 0,
        'successfulTrendPct': 0,
        'failedTrendPct': 0,
        'pendingTrendPct': 0,
        'lastSyncedAt': null,
      },
      'chartData': [],
      'breakdown': {'successful': 0, 'failed': 0, 'pending': 0},
      'recentActivity': [],
      'errorSummary': [],
    });

    expect(data.stats.lastSyncedAt, isNull);
    expect(data.stats.totalSynced, 0);
  });
}
