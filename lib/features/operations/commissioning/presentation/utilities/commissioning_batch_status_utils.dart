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
}
