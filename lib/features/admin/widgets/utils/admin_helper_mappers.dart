import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';

/// Shared helper mappers for admin widget status/severity presentation.
abstract final class AdminHelperMappers {
  static Color bulkJobStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'RUNNING':
        return Colors.blue;
      case 'COMPLETED':
        return Colors.green;
      case 'FAILED':
        return Colors.red;
      case 'PENDING':
        return Colors.orange;
      case 'CANCELLED':
      default:
        return Colors.grey;
    }
  }

  static String bulkJobStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'RUNNING':
        return AppAssets.iconPlay;
      case 'COMPLETED':
        return AppAssets.iconCheckCircle;
      case 'FAILED':
      case 'CANCELLED':
        return AppAssets.iconXCircle;
      case 'PENDING':
        return AppAssets.iconClock;
      default:
        return AppAssets.iconHelpCircle;
    }
  }

  static Color queueJobStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
        return Colors.green;
      case 'RUNNING':
        return Colors.blue;
      case 'FAILED':
        return Colors.red;
      case 'CANCELLED':
        return Colors.orange;
      case 'QUEUED':
      default:
        return Colors.grey;
    }
  }

  static Color exportJobStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
        return Colors.green;
      case 'PROCESSING':
        return Colors.blue;
      case 'FAILED':
        return Colors.red;
      case 'CANCELLED':
        return Colors.orange;
      case 'PENDING':
      default:
        return Colors.grey;
    }
  }

  static Color etlStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
      case 'COMPLETED':
        return Colors.green;
      case 'RUNNING':
        return Colors.blue;
      case 'FAILED':
        return Colors.red;
      case 'INACTIVE':
      case 'SCHEDULED':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  static Color severityColor(String severity) {
    return AppColorMapper.severity(severity);
  }

  static String severityIcon(String severity) {
    switch (severity.toUpperCase()) {
      case 'CRITICAL':
        return AppAssets.iconDangerous;
      case 'HIGH':
        return AppAssets.iconXCircle;
      case 'MEDIUM':
        return AppAssets.iconAlert;
      case 'LOW':
        return AppAssets.iconInfo;
      default:
        return AppAssets.iconHelpCircle;
    }
  }

  static Color scoreColor(double score) {
    return AppColorMapper.score(score);
  }

  static Color dashboardSeverityColor(String severity) {
    return AppColorMapper.dashboardSeverity(severity);
  }

  static Color workflowStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
        return Colors.green;
      case 'IN_PROGRESS':
      case 'PENDING':
        return Colors.blue;
      case 'AWAITING_APPROVAL':
        return Colors.orange;
      case 'FAILED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  static String workflowStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
        return AppAssets.iconCheckCircle;
      case 'IN_PROGRESS':
        return AppAssets.iconSettings;
      case 'PENDING':
      case 'AWAITING_APPROVAL':
        return AppAssets.iconPending;
      case 'FAILED':
        return AppAssets.iconXCircle;
      default:
        return AppAssets.iconHelpCircle;
    }
  }

  static Color successRateColor(double successRate) {
    return AppColorMapper.successRate(successRate);
  }

  static Color usageColor(double usage) {
    return AppColorMapper.usage(usage);
  }

  static Color performanceColor(
    double value,
    double good,
    double warning, {
    bool inverted = false,
  }) {
    return AppColorMapper.performance(
      value,
      good,
      warning,
      inverted: inverted,
    );
  }

  static Color exportFormatColor(String format) {
    switch (format.toUpperCase()) {
      case 'CSV':
        return Colors.green;
      case 'JSON':
        return Colors.blue;
      case 'XML':
        return Colors.purple;
      case 'EPCIS':
        return Colors.orange;
      case 'GS1_DIGITAL_LINK':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  static Color jobTypeColor(String jobType) {
    switch (jobType.toUpperCase()) {
      case 'ETL':
        return Colors.purple;
      case 'EXPORT':
        return Colors.blue;
      case 'BULK_IMPORT':
        return Colors.green;
      case 'NOTIFICATION_BATCH':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  static Color queueHealthColor(String health) {
    switch (health.toLowerCase()) {
      case 'healthy':
        return Colors.green;
      case 'warning':
        return Colors.orange;
      case 'critical':
        return Colors.red;
      default:
        return Colors.green;
    }
  }

  static Color transformationTypeColor(String type) {
    switch (type.toUpperCase()) {
      case 'VALIDATION':
        return Colors.blue;
      case 'ENRICHMENT':
        return Colors.green;
      case 'NORMALIZATION':
        return Colors.purple;
      case 'AGGREGATION':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  static Color qualityScoreColor(double score) {
    if (score >= 0.9) return Colors.green;
    if (score >= 0.7) return Colors.orange;
    return Colors.red;
  }

  static Color integrityScoreColor(double score) {
    if (score >= 95) return Colors.green;
    if (score >= 85) return Colors.orange;
    return Colors.red;
  }

  static Color monitoringOverallStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'CRITICAL':
        return Colors.red[800]!;
      case 'WARNING':
        return Colors.orange;
      case 'DEGRADED':
        return Colors.yellow[700]!;
      case 'HEALTHY':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  static String monitoringOverallStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'CRITICAL':
        return AppAssets.iconDangerous;
      case 'WARNING':
        return AppAssets.iconAlert;
      case 'DEGRADED':
        return AppAssets.iconInfo;
      case 'HEALTHY':
        return AppAssets.iconCheckCircle;
      default:
        return AppAssets.iconHelpCircle;
    }
  }

  static Color monitoringPerformanceStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'POOR':
        return Colors.red;
      case 'FAIR':
        return Colors.orange;
      case 'SLOW':
        return Colors.yellow[700]!;
      case 'GOOD':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  static Color monitoringStorageStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'CRITICAL':
        return Colors.red;
      case 'HIGH':
        return Colors.orange;
      case 'MODERATE':
        return Colors.yellow[700]!;
      case 'LOW':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  static Color monitoringIntegrityStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'POOR':
        return Colors.red;
      case 'FAIR':
        return Colors.orange;
      case 'EXCELLENT':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  static Color monitoringAlertsStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'NONE':
        return Colors.green;
      case 'CRITICAL':
        return Colors.red;
      case 'HIGH':
        return Colors.orange;
      case 'ACTIVE':
        return Colors.yellow[700]!;
      default:
        return Colors.grey;
    }
  }
}
