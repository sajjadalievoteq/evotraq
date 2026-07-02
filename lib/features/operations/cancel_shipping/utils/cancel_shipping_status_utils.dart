import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/data/models/operations/cancel_shipping/cancel_shipping_status.dart';

/// CancelShipping operation status color and icon helpers.
class CancelShippingStatusUtils {
  CancelShippingStatusUtils._();

  static Color colorFor(CancelShippingStatus status) {
    switch (status) {
      case CancelShippingStatus.success:
        return Colors.green;
      case CancelShippingStatus.partialSuccess:
        return Colors.orange;
      case CancelShippingStatus.failed:
        return Colors.red;
      case CancelShippingStatus.validationError:
        return Colors.red[700]!;
    }
  }

  static String iconAsset(CancelShippingStatus status) {
    switch (status) {
      case CancelShippingStatus.success:
        return AppAssets.iconCheckCircle;
      case CancelShippingStatus.partialSuccess:
        return AppAssets.iconAlert;
      case CancelShippingStatus.failed:
        return AppAssets.iconXCircle;
      case CancelShippingStatus.validationError:
        return AppAssets.iconXCircle;
    }
  }

  static String label(CancelShippingStatus status) {
    switch (status) {
      case CancelShippingStatus.success:
        return 'SUCCESS';
      case CancelShippingStatus.partialSuccess:
        return 'PARTIAL';
      case CancelShippingStatus.failed:
        return 'FAILED';
      case CancelShippingStatus.validationError:
        return 'VALIDATION';
    }
  }

  /// Human-readable status label for detail screens.
  static String detailLabel(CancelShippingStatus? status) {
    switch (status) {
      case CancelShippingStatus.success:
        return 'Success';
      case CancelShippingStatus.partialSuccess:
        return 'Partial Success';
      case CancelShippingStatus.failed:
        return 'Failed';
      case CancelShippingStatus.validationError:
        return 'Validation Error';
      case null:
        return 'Unknown';
    }
  }
}
