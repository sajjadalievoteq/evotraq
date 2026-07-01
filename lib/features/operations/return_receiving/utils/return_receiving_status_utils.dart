import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/data/models/operations/return_receiving/return_receiving_status.dart';

/// ReturnReceiving operation status color and icon helpers.
class ReturnReceivingStatusUtils {
  ReturnReceivingStatusUtils._();

  static Color colorFor(ReturnReceivingStatus status) {
    switch (status) {
      case ReturnReceivingStatus.success:
        return Colors.green;
      case ReturnReceivingStatus.partialSuccess:
        return Colors.orange;
      case ReturnReceivingStatus.failed:
        return Colors.red;
      case ReturnReceivingStatus.validationError:
        return Colors.red[700]!;
    }
  }

  static String iconAsset(ReturnReceivingStatus status) {
    switch (status) {
      case ReturnReceivingStatus.success:
        return AppAssets.iconCheckCircle;
      case ReturnReceivingStatus.partialSuccess:
        return AppAssets.iconAlert;
      case ReturnReceivingStatus.failed:
        return AppAssets.iconXCircle;
      case ReturnReceivingStatus.validationError:
        return AppAssets.iconXCircle;
    }
  }

  static String label(ReturnReceivingStatus status) {
    switch (status) {
      case ReturnReceivingStatus.success:
        return 'SUCCESS';
      case ReturnReceivingStatus.partialSuccess:
        return 'PARTIAL';
      case ReturnReceivingStatus.failed:
        return 'FAILED';
      case ReturnReceivingStatus.validationError:
        return 'VALIDATION';
    }
  }

  /// Human-readable status label for detail screens.
  static String detailLabel(ReturnReceivingStatus? status) {
    switch (status) {
      case ReturnReceivingStatus.success:
        return 'Success';
      case ReturnReceivingStatus.partialSuccess:
        return 'Partial Success';
      case ReturnReceivingStatus.failed:
        return 'Failed';
      case ReturnReceivingStatus.validationError:
        return 'Validation Error';
      case null:
        return 'Unknown';
    }
  }
}
