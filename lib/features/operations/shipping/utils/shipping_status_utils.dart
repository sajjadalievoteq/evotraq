import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
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

  static String iconAsset(ShippingStatus status) {
    switch (status) {
      case ShippingStatus.success:
        return AppAssets.iconCheckCircle;
      case ShippingStatus.partialSuccess:
        return AppAssets.iconAlert;
      case ShippingStatus.failed:
        return AppAssets.iconXCircle;
      case ShippingStatus.validationError:
        return AppAssets.iconXCircle;
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
