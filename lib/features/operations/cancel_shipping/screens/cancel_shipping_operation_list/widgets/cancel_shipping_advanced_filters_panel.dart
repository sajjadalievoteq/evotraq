import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/operations/cancel_shipping/utils/cancel_shipping_ui_constants.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/list/operation_advanced_filters_panel.dart';

class CancelShippingAdvancedFiltersPanel extends StatelessWidget {
  const CancelShippingAdvancedFiltersPanel({
    super.key,
    required this.gincController,
    required this.sortBy,
    required this.onSortByChanged,
    required this.onApply,
    required this.onClearAll,
  });

  final TextEditingController gincController;
  final String sortBy;
  final ValueChanged<String?> onSortByChanged;
  final VoidCallback onApply;
  final VoidCallback onClearAll;

  @override
  Widget build(BuildContext context) {
    return OperationAdvancedFiltersPanel(
      sortBy: sortBy,
      sortFieldLabels: CancelShippingUiConstants.sortFieldLabels,
      onSortByChanged: onSortByChanged,
      onApply: onApply,
      onClearAll: onClearAll,
      footerHint:
          'Filters apply to loaded results. Sort order updates when applied.',
      filterField: TextField(
        controller: gincController,
        decoration: const InputDecoration(
          labelText: 'Original GINC',
          hintText: 'Filter by original shipping reference (optional)',
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}
