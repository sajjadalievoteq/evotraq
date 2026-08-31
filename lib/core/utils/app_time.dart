import 'package:intl/intl.dart';

/// Application-wide timestamp policy.
///
/// API instants are UTC. Legacy values without an offset are interpreted as
/// UTC. UAE presentation uses UTC+04:00; the UAE has no daylight-saving time.
abstract final class AppTime {
  static const uaeOffset = Duration(hours: 4);

  static DateTime nowUtc() => DateTime.now().toUtc();

  static DateTime nowUae() => toUae(nowUtc());

  static DateTime toUae(DateTime value) => value.toUtc().add(uaeOffset);

  static DateTime parseApi(dynamic value) {
    if (value is DateTime) return value.toUtc();
    final raw = value?.toString().trim();
    if (raw == null || raw.isEmpty) {
      throw const FormatException('Timestamp is required');
    }
    final hasZone = RegExp(r'(?:[zZ]|[+-]\d{2}:?\d{2})$').hasMatch(raw);
    return DateTime.parse(hasZone ? raw : '${raw}Z').toUtc();
  }

  static DateTime? tryParseApi(dynamic value) {
    try {
      return value == null ? null : parseApi(value);
    } on FormatException {
      return null;
    }
  }

  static String toApi(DateTime value) => value.toUtc().toIso8601String();

  static String formatUae(DateTime value, DateFormat format) =>
      format.format(toUae(value));
}
