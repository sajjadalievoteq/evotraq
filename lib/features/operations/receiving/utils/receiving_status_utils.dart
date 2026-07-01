import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
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
      case ReceivingStatus.accepted:
        return Colors.teal;
    }
  }

  static String iconAsset(ReceivingStatus status) {
    switch (status) {
      case ReceivingStatus.success:
        return AppAssets.iconCheckCircle;
      case ReceivingStatus.partialSuccess:
        return AppAssets.iconAlert;
      case ReceivingStatus.failed:
        return AppAssets.iconXCircle;
      case ReceivingStatus.validationError:
        return AppAssets.iconXCircle;
      case ReceivingStatus.accepted:
        return AppAssets.iconBox;
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
      case ReceivingStatus.accepted:
        return 'ACCEPTED';
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
      case ReceivingStatus.accepted:
        return 'Accepted';
      case null:
        return 'Unknown';
    }
  }
}
