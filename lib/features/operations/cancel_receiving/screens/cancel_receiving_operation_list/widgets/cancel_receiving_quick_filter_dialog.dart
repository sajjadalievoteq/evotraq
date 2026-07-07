import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/shared/operation_quick_filter_result.dart';
import 'package:traqtrace_app/features/operations/cancel_receiving/utils/cancel_receiving_ui_constants.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/list/operation_quick_filter_dialog.dart';

class CancelReceivingQuickFilterDialog {
  CancelReceivingQuickFilterDialog._();

  static Future<OperationQuickFilterResult?> open(
    BuildContext context, {
    required String? selectedStatus,
  }) =>
      OperationQuickFilterDialog.open(
        context,
        selectedStatus: selectedStatus,
        statusFilterOptions: CancelReceivingUiConstants.statusFilterOptions,
        statusFilterLabel: CancelReceivingUiConstants.statusFilterLabel,
        footerHint: CancelReceivingUiConstants.quickFiltersFooterHint,
      );
}
