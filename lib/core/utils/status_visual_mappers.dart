import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';

/// Shared color/icon lookups for status, severity, and job/workflow states used
/// across dashboards (admin monitoring, automation-center job queue, etc.). All
/// colors are theme-aware and resolved from [AppColorMapper] / `OperationPalette`
/// — never raw [Colors].
abstract final class StatusVisualMappers {
  static Color bulkJobStatusColor(BuildContext context, String status) {
    switch (status.toUpperCase()) {
      case 'RUNNING':
        return AppColorMapper.infoColor(context);
      case 'COMPLETED':
        return AppColorMapper.successColor(context);
      case 'FAILED':
        return AppColorMapper.errorColor(context);
      case 'PENDING':
        return AppColorMapper.warningColor(context);
      case 'CANCELLED':
      default:
        return AppColorMapper.neutralColor(context);
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
        return NavIcons.helpSupport;
    }
  }

  static Color queueJobStatusColor(BuildContext context, String status) {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
        return AppColorMapper.successColor(context);
      case 'RUNNING':
        return AppColorMapper.infoColor(context);
      case 'FAILED':
        return AppColorMapper.errorColor(context);
      case 'CANCELLED':
        return AppColorMapper.warningColor(context);
      case 'QUEUED':
      default:
        return AppColorMapper.neutralColor(context);
    }
  }

  static String queueJobStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
        return AppAssets.iconCheckCircle;
      case 'FAILED':
        return AppAssets.iconXCircle;
      case 'CANCELLED':
        return AppAssets.iconMinus;
      case 'RUNNING':
        return AppAssets.iconPlay;
      default:
        return AppAssets.iconClock;
    }
  }

  static Color jobPriorityColor(BuildContext context, int priority) {
    if (priority <= 2) return AppColorMapper.errorColor(context);
    if (priority <= 4) return AppColorMapper.warningColor(context);
    if (priority <= 7) return AppColorMapper.infoColor(context);
    return AppColorMapper.neutralColor(context);
  }

  static Color exportJobStatusColor(BuildContext context, String status) {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
        return AppColorMapper.successColor(context);
      case 'PROCESSING':
        return AppColorMapper.infoColor(context);
      case 'FAILED':
        return AppColorMapper.errorColor(context);
      case 'CANCELLED':
        return AppColorMapper.warningColor(context);
      case 'PENDING':
      default:
        return AppColorMapper.neutralColor(context);
    }
  }

  static Color severityColor(BuildContext context, String severity) {
    return AppColorMapper.severity(context, severity);
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
        return NavIcons.helpSupport;
    }
  }

  static Color scoreColor(BuildContext context, double score) {
    return AppColorMapper.score(context, score);
  }

  static Color dashboardSeverityColor(BuildContext context, String severity) {
    return AppColorMapper.dashboardSeverity(context, severity);
  }

  static Color workflowStatusColor(BuildContext context, String status) {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
        return AppColorMapper.successColor(context);
      case 'IN_PROGRESS':
      case 'PENDING':
        return AppColorMapper.infoColor(context);
      case 'AWAITING_APPROVAL':
        return AppColorMapper.warningColor(context);
      case 'FAILED':
        return AppColorMapper.errorColor(context);
      default:
        return AppColorMapper.neutralColor(context);
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
        return NavIcons.helpSupport;
    }
  }

  static Color successRateColor(BuildContext context, double successRate) {
    return AppColorMapper.successRate(context, successRate);
  }

  static Color usageColor(BuildContext context, double usage) {
    return AppColorMapper.usage(context, usage);
  }

  static Color performanceColor(
    BuildContext context,
    double value,
    double good,
    double warning, {
    bool inverted = false,
  }) {
    return AppColorMapper.performance(
      context,
      value,
      good,
      warning,
      inverted: inverted,
    );
  }

  static Color exportFormatColor(BuildContext context, String format) {
    switch (format.toUpperCase()) {
      case 'CSV':
        return AppColorMapper.successColor(context);
      case 'JSON':
        return AppColorMapper.infoColor(context);
      case 'XML':
        return AppColorMapper.chartColor(context, 3);
      case 'EPCIS':
        return AppColorMapper.warningColor(context);
      case 'GS1_DIGITAL_LINK':
        return AppColorMapper.chartColor(context, 5);
      default:
        return AppColorMapper.neutralColor(context);
    }
  }

  static Color jobTypeColor(BuildContext context, String jobType) {
    switch (jobType.toUpperCase()) {
      case 'ETL':
        return AppColorMapper.chartColor(context, 3);
      case 'EXPORT':
        return AppColorMapper.infoColor(context);
      case 'BULK_IMPORT':
        return AppColorMapper.successColor(context);
      case 'NOTIFICATION_BATCH':
        return AppColorMapper.warningColor(context);
      default:
        return AppColorMapper.neutralColor(context);
    }
  }

  static Color queueHealthColor(BuildContext context, String health) {
    switch (health.toLowerCase()) {
      case 'healthy':
        return AppColorMapper.successColor(context);
      case 'warning':
        return AppColorMapper.warningColor(context);
      case 'critical':
        return AppColorMapper.errorColor(context);
      default:
        return AppColorMapper.successColor(context);
    }
  }

  static Color transformationTypeColor(BuildContext context, String type) {
    switch (type.toUpperCase()) {
      case 'VALIDATION':
        return AppColorMapper.infoColor(context);
      case 'ENRICHMENT':
        return AppColorMapper.successColor(context);
      case 'NORMALIZATION':
        return AppColorMapper.chartColor(context, 3);
      case 'AGGREGATION':
        return AppColorMapper.warningColor(context);
      default:
        return AppColorMapper.neutralColor(context);
    }
  }

  static Color qualityScoreColor(BuildContext context, double score) {
    return AppColorMapper.score(context, score * 100);
  }

  static Color integrityScoreColor(BuildContext context, double score) {
    return AppColorMapper.score(context, score);
  }

  static Color monitoringOverallStatusColor(BuildContext context, String status) {
    switch (status.toUpperCase()) {
      case 'CRITICAL':
        return AppColorMapper.errorColor(context);
      case 'WARNING':
        return AppColorMapper.warningColor(context);
      case 'DEGRADED':
        return AppColorMapper.warningColor(context);
      case 'HEALTHY':
        return AppColorMapper.successColor(context);
      default:
        return AppColorMapper.neutralColor(context);
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
        return NavIcons.helpSupport;
    }
  }

  static Color monitoringPerformanceStatusColor(BuildContext context, String status) {
    switch (status.toUpperCase()) {
      case 'POOR':
        return AppColorMapper.errorColor(context);
      case 'FAIR':
        return AppColorMapper.warningColor(context);
      case 'SLOW':
        return AppColorMapper.warningColor(context);
      case 'GOOD':
        return AppColorMapper.successColor(context);
      default:
        return AppColorMapper.neutralColor(context);
    }
  }

  static Color monitoringStorageStatusColor(BuildContext context, String status) {
    switch (status.toUpperCase()) {
      case 'CRITICAL':
        return AppColorMapper.errorColor(context);
      case 'HIGH':
        return AppColorMapper.warningColor(context);
      case 'MODERATE':
        return AppColorMapper.warningColor(context);
      case 'LOW':
        return AppColorMapper.successColor(context);
      default:
        return AppColorMapper.neutralColor(context);
    }
  }

  static Color monitoringIntegrityStatusColor(BuildContext context, String status) {
    switch (status.toUpperCase()) {
      case 'POOR':
        return AppColorMapper.errorColor(context);
      case 'FAIR':
        return AppColorMapper.warningColor(context);
      case 'EXCELLENT':
        return AppColorMapper.successColor(context);
      default:
        return AppColorMapper.neutralColor(context);
    }
  }

  static Color monitoringAlertsStatusColor(BuildContext context, String status) {
    switch (status.toUpperCase()) {
      case 'NONE':
        return AppColorMapper.successColor(context);
      case 'CRITICAL':
        return AppColorMapper.errorColor(context);
      case 'HIGH':
        return AppColorMapper.warningColor(context);
      case 'ACTIVE':
        return AppColorMapper.warningColor(context);
      default:
        return AppColorMapper.neutralColor(context);
    }
  }
}
