import 'package:traqtrace_app/core/utils/app_time.dart';

abstract final class OperationEventTimeCodec {
  static String localTimezoneOffset([DateTime? reference]) {
    final offset = AppTime.uaeOffset;
    final hours = offset.inHours.abs().toString().padLeft(2, '0');
    final minutes = (offset.inMinutes.abs() % 60).toString().padLeft(2, '0');
    final sign = offset.isNegative ? '-' : '+';
    return '$sign$hours:$minutes';
  }

  static String encodeLocal(DateTime local) {
    return _encodeWallClock(local, local.timeZoneOffset);
  }

  static String encodeUaeWallClock(DateTime uaeWallClock) {
    return _encodeWallClock(uaeWallClock, AppTime.uaeOffset);
  }

  static String _encodeWallClock(DateTime local, Duration offset) {
    final sign = offset.isNegative ? '-' : '+';
    final hours = offset.inHours.abs().toString().padLeft(2, '0');
    final minutes = (offset.inMinutes.abs() % 60).toString().padLeft(2, '0');
    final y = local.year.toString().padLeft(4, '0');
    final mo = local.month.toString().padLeft(2, '0');
    final d = local.day.toString().padLeft(2, '0');
    final h = local.hour.toString().padLeft(2, '0');
    final mi = local.minute.toString().padLeft(2, '0');
    final s = local.second.toString().padLeft(2, '0');
    return '$y-$mo-${d}T$h:$mi:$s$sign$hours:$minutes';
  }

  static DateTime? parseApiDateTime(Object? raw) {
    final instant = AppTime.tryParseApi(raw);
    return instant == null ? null : AppTime.toUae(instant);
  }

  static Map<String, String> fieldsForRequest(DateTime? eventTime) {
    final local = eventTime ?? AppTime.nowUae();
    return {
      'eventTime': encodeUaeWallClock(local),
      'eventTimeZoneOffset': localTimezoneOffset(local),
    };
  }
}