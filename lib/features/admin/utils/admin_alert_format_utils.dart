import 'package:traqtrace_app/data/models/admin/monitoring_models.dart';

abstract final class AdminAlertFormatUtils {
  static String formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }

  static String formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  static String highestSeverity(List<PerformanceAlert> alerts) {
    if (alerts.any((alert) => alert.severity.toUpperCase() == 'CRITICAL')) {
      return 'CRITICAL';
    }
    if (alerts.any((alert) => alert.severity.toUpperCase() == 'HIGH')) {
      return 'HIGH';
    }
    if (alerts.any((alert) => alert.severity.toUpperCase() == 'MEDIUM')) {
      return 'MEDIUM';
    }
    return 'LOW';
  }
}
