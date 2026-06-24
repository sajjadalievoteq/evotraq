import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/receiving/receiving_status.dart';

/// Receiving operation status color and icon helpers.
class ReceivingStatusUtils {
  ReceivingStatusUtils._();

  static Color colorFor(ReceivingStatus status) {
    switch (status) {
      case ReceivingStatus.success:
        return Colors.green;
      case ReceivingStatus.partialSuccess:
        return Colors.orange;
      case ReceivingStatus.failed:
        return Colors.red;
      case ReceivingStatus.validationError:
        return Colors.red[700]!;
    }
  }

  static IconData iconFor(ReceivingStatus status) {
    switch (status) {
      case ReceivingStatus.success:
        return Icons.check_circle;
      case ReceivingStatus.partialSuccess:
        return Icons.warning;
      case ReceivingStatus.failed:
        return Icons.error;
      case ReceivingStatus.validationError:
        return Icons.error_outline;
    }
  }

  static String label(ReceivingStatus status) {
    switch (status) {
      case ReceivingStatus.success:
        return 'SUCCESS';
      case ReceivingStatus.partialSuccess:
        return 'PARTIAL';
      case ReceivingStatus.failed:
        return 'FAILED';
      case ReceivingStatus.validationError:
        return 'VALIDATION';
    }
  }

  /// Human-readable status label for detail screens.
  static String detailLabel(ReceivingStatus? status) {
    switch (status) {
      case ReceivingStatus.success:
        return 'Success';
      case ReceivingStatus.partialSuccess:
        return 'Partial Success';
      case ReceivingStatus.failed:
        return 'Failed';
      case ReceivingStatus.validationError:
        return 'Validation Error';
      case null:
        return 'Unknown';
    }
  }
}
