import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/list/operation_quick_filter_dialog.dart';import 'package:traqtrace_app/features/operations/shipping/utils/shipping_ui_constants.dart';

class ShippingQuickFilterDialog {
  ShippingQuickFilterDialog._();

  static Future<dynamic> open(
    BuildContext context, {
    required String? selectedStatus,
  }) =>
      OperationQuickFilterDialog.open(
        context,
        selectedStatus: selectedStatus,
        statusFilterOptions: ShippingUiConstants.statusFilterOptions,
        statusFilterLabel: ShippingUiConstants.statusFilterLabel,
        footerHint: ShippingUiConstants.quickFiltersFooterHint,
      );
}
