import 'package:flutter_test/flutter_test.dart';
import 'package:traqtrace_app/data/models/tatmeen_integration/tatmeen_records_models.dart';
import 'package:traqtrace_app/features/tatmeen_integration/data/tatmeen_records_mock_data.dart';

void main() {
  test('records titles match status filter', () {
    expect(
      const RecordsFilter.kpi(TatmeenRecordsStatusFilter.all).title,
      'All Sync Records',
    );
    expect(
      const RecordsFilter.kpi(TatmeenRecordsStatusFilter.failed).title,
      'Failed Syncs',
    );
  });

  test('mock records paginate and filter by status', () {
    final page = TatmeenRecordsMockData.page(
      const TatmeenRecordsQuery(
        status: TatmeenRecordsStatusFilter.failed,
        page: 1,
        pageSize: 10,
      ),
    );
    expect(page.items, isNotEmpty);
    expect(page.items.every((item) => item.status.name == 'failed'), isTrue);
    expect(page.pageSize, 10);
  });
}
