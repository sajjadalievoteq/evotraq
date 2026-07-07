import 'package:intl/intl.dart';

abstract final class JourneyFormatters {
  static String shortDate(DateTime dt) =>
      DateFormat('MMM dd, HH:mm').format(dt);

  static String longDate(DateTime dt) =>
      DateFormat('MMM dd, yyyy HH:mm:ss').format(dt);

  static String duration(Duration? d) {
    if (d == null) return 'N/A';
    if (d.inDays > 0) return '${d.inDays}d';
    if (d.inHours > 0) return '${d.inHours}h';
    if (d.inMinutes > 0) return '${d.inMinutes}m';
    return '<1m';
  }

  /// Returns a compact, human-readable duration string.
  /// Examples: "2y 3mo", "1y", "4mo", "12d", "6h", "30m", "<1m"
  static String humanDuration(Duration d) {
    if (d.isNegative || d.inSeconds < 60) return '<1m';

    final totalDays = d.inDays;

    final years = totalDays ~/ 365;
    final months = (totalDays % 365) ~/ 30;
    final days = totalDays % 30;

    if (years > 0 && months > 0) return '${years}y ${months}mo';
    if (years > 0) return '${years}y';
    if (months > 0 && days > 0) return '${months}mo ${days}d';
    if (months > 0) return '${months}mo';
    if (totalDays > 0) return '${totalDays}d';
    if (d.inHours > 0) return '${d.inHours}h';
    return '${d.inMinutes}m';
  }

  static String identifierTypeLabel(String type) {
    return switch (type.toUpperCase()) {
      'SGTIN' => 'Serial Item',
      'SSCC' => 'Container',
      'GTIN' => 'Product',
      _ => 'EPC',
    };
  }
}
