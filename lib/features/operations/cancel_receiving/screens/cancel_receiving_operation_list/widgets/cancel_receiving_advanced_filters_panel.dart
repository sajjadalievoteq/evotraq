import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/operations/cancel_receiving/utils/cancel_receiving_ui_constants.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/list/operation_advanced_filters_panel.dart';

class CancelReceivingAdvancedFiltersPanel extends StatelessWidget {
  const CancelReceivingAdvancedFiltersPanel({
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
      sortFieldLabels: CancelReceivingUiConstants.sortFieldLabels,
      onSortByChanged: onSortByChanged,
      onApply: onApply,
      onClearAll: onClearAll,
      footerHint:
          'Filters apply to loaded results. Sort order updates when applied.',
      filterField: TextField(
        controller: gincController,
        decoration: const InputDecoration(
          labelText: 'Original GINC',
          hintText: 'Filter by original receiving reference (optional)',
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}
