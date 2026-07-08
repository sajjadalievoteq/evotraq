abstract final class OperationEventTimeCodec {
  static String localTimezoneOffset([DateTime? reference]) {
    final offset = (reference ?? DateTime.now()).timeZoneOffset;
    final hours = offset.inHours.abs().toString().padLeft(2, '0');
    final minutes = (offset.inMinutes.abs() % 60).toString().padLeft(2, '0');
    final sign = offset.isNegative ? '-' : '+';
    return '$sign$hours:$minutes';
  }

  static String encodeLocal(DateTime local) {
    final offset = local.timeZoneOffset;
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

  static Map<String, String> fieldsForRequest(DateTime? eventTime) {
    final local = eventTime ?? DateTime.now();
    return {
      'eventTime': encodeLocal(local),
      'eventTimeZoneOffset': localTimezoneOffset(local),
    };
  }
}
