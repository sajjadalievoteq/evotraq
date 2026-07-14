import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/operations/return_shipping/utils/return_shipping_ui_constants.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/list/operation_advanced_filters_panel.dart';

class ReturnShippingAdvancedFiltersPanel extends StatelessWidget {
  const ReturnShippingAdvancedFiltersPanel({
    super.key,
    required this.trackingController,
    required this.sortBy,
    required this.onSortByChanged,
    required this.onApply,
    required this.onClearAll,
  });

  final TextEditingController trackingController;
  final String sortBy;
  final ValueChanged<String?> onSortByChanged;
  final VoidCallback onApply;
  final VoidCallback onClearAll;

  @override
  Widget build(BuildContext context) {
    return OperationAdvancedFiltersPanel(
      sortBy: sortBy,
      sortFieldLabels: ReturnShippingUiConstants.sortFieldLabels,
      onSortByChanged: onSortByChanged,
      onApply: onApply,
      onClearAll: onClearAll,
      footerHint:
          'Filters apply to loaded results. Sort order updates when applied.',
      filterField: TextField(
        controller: trackingController,
        decoration: const InputDecoration(
          labelText: 'Tracking Number',
          hintText: 'Filter by tracking number (optional)',
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}
