import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/commissioning/commissioning_models.dart';

abstract final class CommissioningBatchStatusUtils {
  static Color color(CommissioningBatchStatus status) {
    return switch (status) {
      CommissioningBatchStatus.success => Colors.green,
      CommissioningBatchStatus.partialSuccess => Colors.orange,
      CommissioningBatchStatus.failed => Colors.red,
      CommissioningBatchStatus.pending => Colors.blue,
      CommissioningBatchStatus.inProgress => Colors.teal,
    };
  }

  static String label(CommissioningBatchStatus status) {
    return switch (status) {
      CommissioningBatchStatus.success => 'SUCCESS',
      CommissioningBatchStatus.partialSuccess => 'PARTIAL',
      CommissioningBatchStatus.failed => 'FAILED',
      CommissioningBatchStatus.pending => 'PENDING',
      CommissioningBatchStatus.inProgress => 'IN PROGRESS',
    };
  }

  static String detailLabel(CommissioningBatchStatus status) {
    return switch (status) {
      CommissioningBatchStatus.success => 'SUCCESS',
      CommissioningBatchStatus.partialSuccess => 'PARTIAL SUCCESS',
      CommissioningBatchStatus.failed => 'FAILED',
      CommissioningBatchStatus.pending => 'PENDING',
      CommissioningBatchStatus.inProgress => 'IN PROGRESS',
    };
  }

  static IconData icon(CommissioningBatchStatus status) {
    return switch (status) {
      CommissioningBatchStatus.success => Icons.check_circle,
      CommissioningBatchStatus.partialSuccess => Icons.warning,
      CommissioningBatchStatus.failed => Icons.error,
      CommissioningBatchStatus.pending => Icons.schedule,
      CommissioningBatchStatus.inProgress => Icons.sync,
    };
  }
}
