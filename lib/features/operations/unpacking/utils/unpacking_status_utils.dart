import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/unpacking/unpacking_status.dart';

/// Unpacking operation status color and icon helpers.
class UnpackingStatusUtils {
  UnpackingStatusUtils._();

  static Color colorFor(UnpackingStatus status) {
    switch (status) {
      case UnpackingStatus.success:
        return Colors.green;
      case UnpackingStatus.partialSuccess:
        return Colors.orange;
      case UnpackingStatus.failed:
        return Colors.red;
      case UnpackingStatus.validationError:
        return Colors.red[700]!;
    }
  }

  static IconData iconFor(UnpackingStatus status) {
    switch (status) {
      case UnpackingStatus.success:
        return Icons.check_circle;
      case UnpackingStatus.partialSuccess:
        return Icons.warning;
      case UnpackingStatus.failed:
        return Icons.error;
      case UnpackingStatus.validationError:
        return Icons.error_outline;
    }
  }

  static String label(UnpackingStatus status) {
    switch (status) {
      case UnpackingStatus.success:
        return 'SUCCESS';
      case UnpackingStatus.partialSuccess:
        return 'PARTIAL';
      case UnpackingStatus.failed:
        return 'FAILED';
      case UnpackingStatus.validationError:
        return 'VALIDATION';
    }
  }

  /// Human-readable status label for detail screens.
  static String detailLabel(UnpackingStatus? status) {
    switch (status) {
      case UnpackingStatus.success:
        return 'Success';
      case UnpackingStatus.partialSuccess:
        return 'Partial Success';
      case UnpackingStatus.failed:
        return 'Failed';
      case UnpackingStatus.validationError:
        return 'Validation Error';
      case null:
        return 'Unknown';
    }
  }
}
