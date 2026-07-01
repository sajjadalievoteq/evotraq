import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/data/models/operations/decommissioning/decommissioning_status.dart';

/// Decommissioning operation status color and icon helpers.
class DecommissioningStatusUtils {
  DecommissioningStatusUtils._();

  static Color colorFor(DecommissioningStatus status) {
    switch (status) {
      case DecommissioningStatus.success:
        return Colors.green;
      case DecommissioningStatus.partialSuccess:
        return Colors.orange;
      case DecommissioningStatus.failed:
        return Colors.red;
      case DecommissioningStatus.validationError:
        return Colors.red[700]!;
    }
  }

  static String iconAsset(DecommissioningStatus status) {
    switch (status) {
      case DecommissioningStatus.success:
        return AppAssets.iconCheckCircle;
      case DecommissioningStatus.partialSuccess:
        return AppAssets.iconAlert;
      case DecommissioningStatus.failed:
        return AppAssets.iconXCircle;
      case DecommissioningStatus.validationError:
        return AppAssets.iconXCircle;
    }
  }

  static String label(DecommissioningStatus status) {
    switch (status) {
      case DecommissioningStatus.success:
        return 'SUCCESS';
      case DecommissioningStatus.partialSuccess:
        return 'PARTIAL';
      case DecommissioningStatus.failed:
        return 'FAILED';
      case DecommissioningStatus.validationError:
        return 'VALIDATION';
    }
  }

  /// Human-readable status label for detail screens.
  static String detailLabel(DecommissioningStatus? status) {
    switch (status) {
      case DecommissioningStatus.success:
        return 'Success';
      case DecommissioningStatus.partialSuccess:
        return 'Partial Success';
      case DecommissioningStatus.failed:
        return 'Failed';
      case DecommissioningStatus.validationError:
        return 'Validation Error';
      case null:
        return 'Unknown';
    }
  }
}
