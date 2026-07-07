import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/shared/operation_quick_filter_result.dart';
import 'package:traqtrace_app/features/operations/unpacking/utils/unpacking_ui_constants.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/list/operation_quick_filter_dialog.dart';

class UnpackingQuickFilterDialog {
  UnpackingQuickFilterDialog._();

  static Future<OperationQuickFilterResult?> open(
    BuildContext context, {
    required String? selectedStatus,
  }) =>
      OperationQuickFilterDialog.open(
        context,
        selectedStatus: selectedStatus,
        statusFilterOptions: UnpackingUiConstants.statusFilterOptions,
        statusFilterLabel: UnpackingUiConstants.statusFilterLabel,
        footerHint: UnpackingUiConstants.quickFiltersFooterHint,
      );
}
