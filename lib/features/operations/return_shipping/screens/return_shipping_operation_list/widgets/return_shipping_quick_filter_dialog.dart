import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/shared/operation_quick_filter_result.dart';
import 'package:traqtrace_app/features/operations/return_shipping/utils/return_shipping_ui_constants.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/list/operation_quick_filter_dialog.dart';

class ReturnShippingQuickFilterDialog {
  ReturnShippingQuickFilterDialog._();

  static Future<OperationQuickFilterResult?> open(
    BuildContext context, {
    required String? selectedStatus,
  }) =>
      OperationQuickFilterDialog.open(
        context,
        selectedStatus: selectedStatus,
        statusFilterOptions: ReturnShippingUiConstants.statusFilterOptions,
        statusFilterLabel: ReturnShippingUiConstants.statusFilterLabel,
        footerHint: ReturnShippingUiConstants.quickFiltersFooterHint,
      );
}
