import 'package:traqtrace_app/features/automation_center/utils/notification_constants.dart';

abstract final class SubscriptionFormatUtils {
  static List<Map<String, String>> availableFormats(String deliveryMethod) {
    if (deliveryMethod == 'EMAIL') {
      return NotificationConstants.notificationFormats
          .where(
            (format) =>
                format['value'] == 'SUMMARY' || format['value'] == 'EMAIL_HTML',
          )
          .toList();
    }
    return NotificationConstants.notificationFormats
        .where((format) => format['value'] != 'EMAIL_HTML')
        .toList();
  }

  /// Formats [NotificationStats.successRate].
  ///
  /// Backend stores the rate as a **0–100 percentage** (see
  /// `NotificationSubscription.getSuccessRate`). Older clients incorrectly
  /// multiplied by 100 again (producing `10000%`).
  ///
  /// Defensive: values in `(0, 1]` are treated as 0–1 fractions.
  static String successRatePercent(
    double rate, {
    int fractionDigits = 0,
    int delivered = 0,
    int failed = 0,
  }) {
    if (delivered + failed <= 0) {
      return '—';
    }
    final percent = _normalizePercent(rate);
    if (fractionDigits <= 0) {
      return '${percent.round()}%';
    }
    return '${percent.toStringAsFixed(fractionDigits)}%';
  }

  static double _normalizePercent(double rate) {
    if (rate < 0) return 0;
    // Explicit 0–1 fraction (excluding 0 which is already a valid percent).
    if (rate > 0 && rate <= 1.0) {
      return rate * 100.0;
    }
    return rate.clamp(0, 100);
  }

  static String averageDeliveryLabel(double avgDeliveryTimeMs) {
    if (avgDeliveryTimeMs <= 0) return '—';
    if (avgDeliveryTimeMs < 1000) {
      return '${avgDeliveryTimeMs.round()} ms';
    }
    return '${(avgDeliveryTimeMs / 1000).toStringAsFixed(1)} s';
  }
}
