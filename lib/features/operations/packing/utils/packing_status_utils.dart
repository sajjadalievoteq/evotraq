import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/data/models/operations/packing/packing_status.dart';

/// Packing operation status color and icon helpers.
class PackingStatusUtils {
  PackingStatusUtils._();

  static Color colorFor(PackingStatus status) {
    switch (status) {
      case PackingStatus.success:
        return Colors.green;
      case PackingStatus.partialSuccess:
        return Colors.orange;
      case PackingStatus.failed:
        return Colors.red;
      case PackingStatus.validationError:
        return Colors.red[700]!;
    }
  }

  static String iconAsset(PackingStatus status) {
    switch (status) {
      case PackingStatus.success:
        return AppAssets.iconCheckCircle;
      case PackingStatus.partialSuccess:
        return AppAssets.iconAlert;
      case PackingStatus.failed:
        return AppAssets.iconXCircle;
      case PackingStatus.validationError:
        return AppAssets.iconXCircle;
    }
  }

  static String label(PackingStatus status) {
    switch (status) {
      case PackingStatus.success:
        return 'SUCCESS';
      case PackingStatus.partialSuccess:
        return 'PARTIAL';
      case PackingStatus.failed:
        return 'FAILED';
      case PackingStatus.validationError:
        return 'VALIDATION';
    }
  }

  /// Human-readable status label for detail screens.
  static String detailLabel(PackingStatus? status) {
    switch (status) {
      case PackingStatus.success:
        return 'Success';
      case PackingStatus.partialSuccess:
        return 'Partial Success';
      case PackingStatus.failed:
        return 'Failed';
      case PackingStatus.validationError:
        return 'Validation Error';
      case null:
        return 'Unknown';
    }
  }
}
