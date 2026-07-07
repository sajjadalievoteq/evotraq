import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/shared/operation_quick_filter_result.dart';
import 'package:traqtrace_app/features/operations/cancel_shipping/utils/cancel_shipping_ui_constants.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/list/operation_quick_filter_dialog.dart';

class CancelShippingQuickFilterDialog {
  CancelShippingQuickFilterDialog._();

  static Future<OperationQuickFilterResult?> open(
    BuildContext context, {
    required String? selectedStatus,
  }) =>
      OperationQuickFilterDialog.open(
        context,
        selectedStatus: selectedStatus,
        statusFilterOptions: CancelShippingUiConstants.statusFilterOptions,
        statusFilterLabel: CancelShippingUiConstants.statusFilterLabel,
        footerHint: CancelShippingUiConstants.quickFiltersFooterHint,
      );
}
