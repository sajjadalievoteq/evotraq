import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/data/models/operations/cancel_receiving/cancel_receiving_status.dart';

/// CancelReceiving operation status color and icon helpers.
class CancelReceivingStatusUtils {
  CancelReceivingStatusUtils._();

  static Color colorFor(CancelReceivingStatus status) {
    switch (status) {
      case CancelReceivingStatus.success:
        return Colors.green;
      case CancelReceivingStatus.partialSuccess:
        return Colors.orange;
      case CancelReceivingStatus.failed:
        return Colors.red;
      case CancelReceivingStatus.validationError:
        return Colors.red[700]!;
    }
  }

  static String iconAsset(CancelReceivingStatus status) {
    switch (status) {
      case CancelReceivingStatus.success:
        return AppAssets.iconCheckCircle;
      case CancelReceivingStatus.partialSuccess:
        return AppAssets.iconAlert;
      case CancelReceivingStatus.failed:
        return AppAssets.iconXCircle;
      case CancelReceivingStatus.validationError:
        return AppAssets.iconXCircle;
    }
  }

  static String label(CancelReceivingStatus status) {
    switch (status) {
      case CancelReceivingStatus.success:
        return 'SUCCESS';
      case CancelReceivingStatus.partialSuccess:
        return 'PARTIAL';
      case CancelReceivingStatus.failed:
        return 'FAILED';
      case CancelReceivingStatus.validationError:
        return 'VALIDATION';
    }
  }

  /// Human-readable status label for detail screens.
  static String detailLabel(CancelReceivingStatus? status) {
    switch (status) {
      case CancelReceivingStatus.success:
        return 'Success';
      case CancelReceivingStatus.partialSuccess:
        return 'Partial Success';
      case CancelReceivingStatus.failed:
        return 'Failed';
      case CancelReceivingStatus.validationError:
        return 'Validation Error';
      case null:
        return 'Unknown';
    }
  }
}
