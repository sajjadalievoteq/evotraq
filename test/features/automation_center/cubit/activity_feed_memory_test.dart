import 'package:flutter_test/flutter_test.dart';
import 'package:traqtrace_app/features/automation_center/cubit/activity_feed_memory.dart';

void main() {
  group('ActivityFeedMemory', () {
    test('appendBounded dedupes by id', () {
      final merged = ActivityFeedMemory.appendBounded<String>(
        existing: ['a', 'b'],
        incoming: ['b', 'c'],
        idOf: (e) => e,
      );
      expect(merged, ['a', 'b', 'c']);
    });

    test('trimNewestSide keeps at most maxRecords by dropping newest pages', () {
      final items = List.generate(ActivityFeedMemory.maxRecords + 25, (i) => 'i$i');
      final trimmed = ActivityFeedMemory.trimNewestSide(items);
      expect(trimmed.length, ActivityFeedMemory.maxRecords);
      expect(trimmed.first, 'i25');
      expect(trimmed.last, items.last);
    });

    test('repeated appendBounded never exceeds maxRecords', () {
      var list = <String>[];
      for (var page = 0; page < 10; page++) {
        final incoming = List.generate(
          ActivityFeedMemory.pageSize,
          (i) => 'p$page-$i',
        );
        list = ActivityFeedMemory.appendBounded(
          existing: list,
          incoming: incoming,
          idOf: (e) => e,
        );
        expect(list.length, lessThanOrEqualTo(ActivityFeedMemory.maxRecords));
      }
      expect(list, isNotEmpty);
      expect(list.last, startsWith('p9-'));
    });
  });
}
