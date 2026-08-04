import 'package:traqtrace_app/data/models/admin/monitoring_models.dart';

abstract final class MonitoringOverviewStatusUtils {
  static String overallStatus({
    required List<PerformanceAlert> alerts,
    required String performanceStatus,
    required String storageStatus,
    required String integrityStatus,
  }) {
    if (alerts.any((alert) => alert.severity.toUpperCase() == 'CRITICAL')) {
      return 'CRITICAL';
    }
    if (alerts.any((alert) => alert.severity.toUpperCase() == 'HIGH')) {
      return 'WARNING';
    }
    if (performanceStatus == 'POOR' ||
        storageStatus == 'CRITICAL' ||
        integrityStatus == 'POOR') {
      return 'DEGRADED';
    }
    return 'HEALTHY';
  }

  static String performanceStatus(PerformanceMetrics? performance) {
    if (performance == null) return 'UNKNOWN';
    if (performance.successRate < 90) return 'POOR';
    if (performance.successRate < 95) return 'FAIR';
    if (performance.averageProcessingTimeMs > 1000) return 'SLOW';
    return 'GOOD';
  }

  static String storageStatus(StorageStatistics? storage) {
    if (storage == null) return 'UNKNOWN';
    if (storage.storageUtilizationGB > 50) return 'CRITICAL';
    if (storage.storageUtilizationGB > 25) return 'HIGH';
    if (storage.storageUtilizationGB > 10) return 'MODERATE';
    return 'LOW';
  }

  static String integrityStatus(IntegrityStatistics? integrity) {
    if (integrity == null) return 'UNKNOWN';
    if (integrity.overallIntegrityScore < 70) return 'POOR';
    if (integrity.overallIntegrityScore < 90) return 'FAIR';
    return 'EXCELLENT';
  }

  static String alertsStatus(List<PerformanceAlert> alerts) {
    if (alerts.isEmpty) return 'NONE';
    if (alerts.any((alert) => alert.severity.toUpperCase() == 'CRITICAL')) {
      return 'CRITICAL';
    }
    if (alerts.any((alert) => alert.severity.toUpperCase() == 'HIGH')) {
      return 'HIGH';
    }
    return 'ACTIVE';
  }
}
