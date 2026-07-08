import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/data/models/operations/shared/operation_status.dart';

abstract final class OperationStatusUtils {
  static Color colorFor(OperationStatus status) {
    return AppColorMapper.operationStatus(status);
  }

  static String iconAsset(OperationStatus status) {
    return switch (status) {
      OperationStatus.success => AppAssets.iconCheckCircle,
      OperationStatus.partialSuccess => AppAssets.iconAlert,
      OperationStatus.failed => AppAssets.iconXCircle,
      OperationStatus.validationError => AppAssets.iconXCircle,
      OperationStatus.accepted => AppAssets.iconBox,
    };
  }

  static String label(OperationStatus status) {
    return switch (status) {
      OperationStatus.success => 'SUCCESS',
      OperationStatus.partialSuccess => 'PARTIAL',
      OperationStatus.failed => 'FAILED',
      OperationStatus.validationError => 'VALIDATION',
      OperationStatus.accepted => 'ACCEPTED',
    };
  }

  static String detailLabel(OperationStatus? status) {
    return switch (status) {
      OperationStatus.success => 'Success',
      OperationStatus.partialSuccess => 'Partial Success',
      OperationStatus.failed => 'Failed',
      OperationStatus.validationError => 'Validation Error',
      OperationStatus.accepted => 'Accepted',
      null => 'Unknown',
    };
  }
}
