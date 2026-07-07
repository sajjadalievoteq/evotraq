import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/data/models/operations/commissioning/commissioning_models.dart';

abstract final class CommissioningBatchStatusUtils {
  static Color color(CommissioningBatchStatus status) {
    return AppColorMapper.commissioningBatchStatus(status);
  }

  static String label(CommissioningBatchStatus status) {
    return switch (status) {
      CommissioningBatchStatus.success => 'SUCCESS',
      CommissioningBatchStatus.partialSuccess => 'PARTIAL',
      CommissioningBatchStatus.failed => 'FAILED',
      CommissioningBatchStatus.pending => 'PENDING',
      CommissioningBatchStatus.inProgress => 'IN PROGRESS',
    };
  }

  static String detailLabel(CommissioningBatchStatus status) {
    return switch (status) {
      CommissioningBatchStatus.success => 'SUCCESS',
      CommissioningBatchStatus.partialSuccess => 'PARTIAL SUCCESS',
      CommissioningBatchStatus.failed => 'FAILED',
      CommissioningBatchStatus.pending => 'PENDING',
      CommissioningBatchStatus.inProgress => 'IN PROGRESS',
    };
  }

  static String iconAsset(CommissioningBatchStatus status) {
    return switch (status) {
      CommissioningBatchStatus.success => AppAssets.iconCheck,
      CommissioningBatchStatus.partialSuccess => AppAssets.iconAlert,
      CommissioningBatchStatus.failed => AppAssets.iconAlert,
      CommissioningBatchStatus.pending => AppAssets.iconClock,
      CommissioningBatchStatus.inProgress => AppAssets.iconRefresh,
    };
  }
}
