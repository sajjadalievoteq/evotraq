import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/shipping/shipping_status.dart';

/// Shipping operation status color and icon helpers.
class ShippingStatusUtils {
  ShippingStatusUtils._();

  static Color colorFor(ShippingStatus status) {
    switch (status) {
      case ShippingStatus.success:
        return Colors.green;
      case ShippingStatus.partialSuccess:
        return Colors.orange;
      case ShippingStatus.failed:
        return Colors.red;
      case ShippingStatus.validationError:
        return Colors.red[700]!;
    }
  }

  static IconData iconFor(ShippingStatus status) {
    switch (status) {
      case ShippingStatus.success:
        return Icons.check_circle;
      case ShippingStatus.partialSuccess:
        return Icons.warning;
      case ShippingStatus.failed:
        return Icons.error;
      case ShippingStatus.validationError:
        return Icons.error_outline;
    }
  }

  static String label(ShippingStatus status) {
    switch (status) {
      case ShippingStatus.success:
        return 'SUCCESS';
      case ShippingStatus.partialSuccess:
        return 'PARTIAL';
      case ShippingStatus.failed:
        return 'FAILED';
      case ShippingStatus.validationError:
        return 'VALIDATION';
    }
  }

  /// Human-readable status label for detail screens.
  static String detailLabel(ShippingStatus? status) {
    switch (status) {
      case ShippingStatus.success:
        return 'Success';
      case ShippingStatus.partialSuccess:
        return 'Partial Success';
      case ShippingStatus.failed:
        return 'Failed';
      case ShippingStatus.validationError:
        return 'Validation Error';
      case null:
        return 'Unknown';
    }
  }
}
