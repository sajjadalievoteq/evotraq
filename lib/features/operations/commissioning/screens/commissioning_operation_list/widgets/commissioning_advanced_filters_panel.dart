import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/gs1_fields/gtin_entry_field.dart';
import 'package:traqtrace_app/features/operations/commissioning/utils/commissioning_ui_constants.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/list/operation_advanced_filters_panel.dart';

class CommissioningAdvancedFiltersPanel extends StatelessWidget {
  const CommissioningAdvancedFiltersPanel({
    super.key,
    required this.gtinController,
    required this.sortBy,
    required this.onSortByChanged,
    required this.onApply,
    required this.onClearAll,
  });

  final TextEditingController gtinController;
  final String sortBy;
  final ValueChanged<String?> onSortByChanged;
  final VoidCallback onApply;
  final VoidCallback onClearAll;

  @override
  Widget build(BuildContext context) {
    return OperationAdvancedFiltersPanel(
      sortBy: sortBy,
      sortFieldLabels: CommissioningUiConstants.sortFieldLabels,
      onSortByChanged: onSortByChanged,
      onApply: onApply,
      onClearAll: onClearAll,
      footerHint:
          'Leave empty to load all batches. Applying reloads the list from the server.',
      filterField: GtinEntryField(
        controller: gtinController,
        fieldName: 'gtinCode',
        label: 'GTIN',
        hintText: 'Filter batches by GTIN (14 digits)',
        validator: (_) => null,
      ),
    );
  }
}
