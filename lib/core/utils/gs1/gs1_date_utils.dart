/// GS1 AI date helper (YYMMDD), including day `00` = last day of the month.
abstract final class Gs1DateUtils {
  /// Parses YYMMDD. Day `00` resolves to the last day of that month.
  /// Returns `null` when format/month/day is invalid.
  static DateTime? parseYymmdd(String? yymmdd) {
    final raw = (yymmdd ?? '').trim();
    if (!RegExp(r'^\d{6}$').hasMatch(raw)) return null;
    final yy = int.parse(raw.substring(0, 2));
    final month = int.parse(raw.substring(2, 4));
    final day = int.parse(raw.substring(4, 6));
    if (month < 1 || month > 12) return null;

    final year = 2000 + yy;
    final lastDay = DateTime(year, month + 1, 0).day;
    final resolvedDay = day == 0 ? lastDay : day;
    if (resolvedDay < 1 || resolvedDay > lastDay) return null;
    return DateTime(year, month, resolvedDay);
  }

  /// Formats a calendar date as YYMMDD (does not emit day `00`).
  static String formatYymmdd(DateTime date) {
    final yy = (date.year % 100).toString().padLeft(2, '0');
    final mm = date.month.toString().padLeft(2, '0');
    final dd = date.day.toString().padLeft(2, '0');
    return '$yy$mm$dd';
  }

  /// Returns `null` when valid; otherwise a reason.
  static String? validateYymmdd(String? value, {String label = 'Date'}) {
    if (value == null || value.trim().isEmpty) return '$label is required';
    if (!RegExp(r'^\d{6}$').hasMatch(value.trim())) {
      return '$label must be YYMMDD (6 digits)';
    }
    if (parseYymmdd(value) == null) {
      return '$label is not a valid GS1 calendar date';
    }
    return null;
  }

  /// ISO-8601 date (YYYY-MM-DD) for a valid YYMMDD string.
  static String? toIsoDate(String? yymmdd) {
    final d = parseYymmdd(yymmdd);
    if (d == null) return null;
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }
}
