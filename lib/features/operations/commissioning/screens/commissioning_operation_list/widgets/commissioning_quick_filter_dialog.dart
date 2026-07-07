import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/shared/operation_quick_filter_result.dart';
import 'package:traqtrace_app/features/operations/commissioning/utils/commissioning_ui_constants.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/list/operation_quick_filter_dialog.dart';

class CommissioningQuickFilterDialog {
  CommissioningQuickFilterDialog._();

  static Future<OperationQuickFilterResult?> open(
    BuildContext context, {
    required String? selectedStatus,
  }) =>
      OperationQuickFilterDialog.open(
        context,
        selectedStatus: selectedStatus,
        statusFilterOptions: CommissioningUiConstants.statusFilterOptions,
        statusFilterLabel: CommissioningUiConstants.statusFilterLabel,
        footerHint: CommissioningUiConstants.quickFiltersFooterHint,
      );
}
