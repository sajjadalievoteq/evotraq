import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/core/utils/app_time.dart';
import 'package:traqtrace_app/features/operations/shared/utils/operation_event_time_codec.dart';

void main() {
  test('parses offset and legacy offset-less API timestamps as UTC', () {
    expect(
      AppTime.parseApi('2026-08-31T08:30:00Z'),
      DateTime.utc(2026, 8, 31, 8, 30),
    );
    expect(
      AppTime.parseApi('2026-08-31T12:30:00+04:00'),
      DateTime.utc(2026, 8, 31, 8, 30),
    );
    expect(
      AppTime.parseApi('2026-08-31T08:30:00'),
      DateTime.utc(2026, 8, 31, 8, 30),
    );
  });

  test('formats an instant at the UAE UTC+4 wall-clock time', () {
    final formatted = AppTime.formatUae(
      DateTime.utc(2026, 8, 31, 8, 30),
      DateFormat('yyyy-MM-dd HH:mm'),
    );
    expect(formatted, '2026-08-31 12:30');
  });

  test('operation requests always use the UAE offset', () {
    final fields = OperationEventTimeCodec.fieldsForRequest(
      DateTime(2026, 8, 31, 12, 30),
    );
    expect(fields['eventTime'], '2026-08-31T12:30:00+04:00');
    expect(fields['eventTimeZoneOffset'], '+04:00');
  });
}
