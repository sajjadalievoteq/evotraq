import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/commissioning/commissioning_models.dart';
import 'package:traqtrace_app/data/models/operations/shared/operation_status.dart';
import 'package:traqtrace_app/features/operations/shared/operation_epc_scan_validator.dart';

enum AppEventColorScheme { admin, epcis }

/// Centralized color mapper for repeated UI status/type palettes.
abstract final class AppColorMapper {
  static Color operationStatus(OperationStatus status) {
    return switch (status) {
      OperationStatus.success => Colors.green,
      OperationStatus.partialSuccess => Colors.orange,
      OperationStatus.failed => Colors.red,
      OperationStatus.validationError => Colors.red[700]!,
      OperationStatus.accepted => Colors.teal,
    };
  }

  static Color commissioningBatchStatus(CommissioningBatchStatus status) {
    return switch (status) {
      CommissioningBatchStatus.success => Colors.green,
      CommissioningBatchStatus.partialSuccess => Colors.orange,
      CommissioningBatchStatus.failed => Colors.red,
      CommissioningBatchStatus.pending => Colors.blue,
      CommissioningBatchStatus.inProgress => Colors.teal,
    };
  }

  static Color operationEpcType(OperationScanItemType type) {
    return switch (type) {
      OperationScanItemType.sgtin => Colors.blue,
      OperationScanItemType.sscc => Colors.teal,
      OperationScanItemType.gtin => Colors.orange,
      OperationScanItemType.invalid => Colors.grey,
      OperationScanItemType.unknown => Colors.grey,
    };
  }

  static Color eventType(String eventType, {required AppEventColorScheme scheme}) {
    final normalized = eventType.toLowerCase();
    final isObject = normalized == 'object' ||
        normalized == 'objectevent' ||
        normalized == 'object_event';
    final isAggregation = normalized == 'aggregation' ||
        normalized == 'aggregationevent' ||
        normalized == 'aggregation_event';
    final isTransaction = normalized == 'transaction' ||
        normalized == 'transactionevent' ||
        normalized == 'transaction_event';
    final isTransformation = normalized == 'transformation' ||
        normalized == 'transformationevent' ||
        normalized == 'transformation_event';

    if (isObject) return Colors.blue;
    if (isAggregation) return Colors.green;
    if (isTransaction) {
      return scheme == AppEventColorScheme.admin ? Colors.red : Colors.orange;
    }
    if (isTransformation) return Colors.purple;
    return Colors.grey;
  }

  static Color severity(String severity) {
    switch (severity.toUpperCase()) {
      case 'CRITICAL':
        return Colors.red[800]!;
      case 'HIGH':
        return Colors.red;
      case 'MEDIUM':
        return Colors.orange;
      case 'LOW':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  static Color dashboardSeverity(String severity) {
    switch (severity.toUpperCase()) {
      case 'LOW':
        return Colors.green;
      case 'MEDIUM':
        return Colors.orange;
      case 'HIGH':
      case 'CRITICAL':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  static Color score(double score) {
    if (score >= 90) return Colors.green;
    if (score >= 70) return Colors.orange;
    return Colors.red;
  }

  static Color successRate(double successRate) {
    if (successRate >= 95) return Colors.green;
    if (successRate >= 90) return Colors.orange;
    return Colors.red;
  }

  static Color usage(double usage) {
    if (usage < 50) return Colors.green;
    if (usage < 80) return Colors.orange;
    return Colors.red;
  }

  static Color performance(
    double value,
    double good,
    double warning, {
    bool inverted = false,
  }) {
    if (inverted) {
      if (value <= good) return Colors.green;
      if (value <= warning) return Colors.orange;
      return Colors.red;
    }
    if (value >= good) return Colors.green;
    if (value >= warning) return Colors.orange;
    return Colors.red;
  }

  static Color supplyChainStatus(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return Colors.green;
      case 'INACTIVE':
        return Colors.red;
      case 'PENDING':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
