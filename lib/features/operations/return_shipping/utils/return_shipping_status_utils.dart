import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/data/models/operations/return_shipping/return_shipping_status.dart';

/// ReturnShipping operation status color and icon helpers.
class ReturnShippingStatusUtils {
  ReturnShippingStatusUtils._();

  static Color colorFor(ReturnShippingStatus status) {
    switch (status) {
      case ReturnShippingStatus.success:
        return Colors.green;
      case ReturnShippingStatus.partialSuccess:
        return Colors.orange;
      case ReturnShippingStatus.failed:
        return Colors.red;
      case ReturnShippingStatus.validationError:
        return Colors.red[700]!;
    }
  }

  static String iconAsset(ReturnShippingStatus status) {
    switch (status) {
      case ReturnShippingStatus.success:
        return AppAssets.iconCheckCircle;
      case ReturnShippingStatus.partialSuccess:
        return AppAssets.iconAlert;
      case ReturnShippingStatus.failed:
        return AppAssets.iconXCircle;
      case ReturnShippingStatus.validationError:
        return AppAssets.iconXCircle;
    }
  }

  static String label(ReturnShippingStatus status) {
    switch (status) {
      case ReturnShippingStatus.success:
        return 'SUCCESS';
      case ReturnShippingStatus.partialSuccess:
        return 'PARTIAL';
      case ReturnShippingStatus.failed:
        return 'FAILED';
      case ReturnShippingStatus.validationError:
        return 'VALIDATION';
    }
  }

  /// Human-readable status label for detail screens.
  static String detailLabel(ReturnShippingStatus? status) {
    switch (status) {
      case ReturnShippingStatus.success:
        return 'Success';
      case ReturnShippingStatus.partialSuccess:
        return 'Partial Success';
      case ReturnShippingStatus.failed:
        return 'Failed';
      case ReturnShippingStatus.validationError:
        return 'Validation Error';
      case null:
        return 'Unknown';
    }
  }
}
