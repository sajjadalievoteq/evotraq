import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/gs1_fields/sscc_entry_field.dart';
import 'package:traqtrace_app/features/operations/unpacking/utils/unpacking_ui_constants.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/list/operation_advanced_filters_panel.dart';

class UnpackingAdvancedFiltersPanel extends StatelessWidget {
  const UnpackingAdvancedFiltersPanel({
    super.key,
    required this.containerController,
    required this.sortBy,
    required this.onSortByChanged,
    required this.onApply,
    required this.onClearAll,
  });

  final TextEditingController containerController;
  final String sortBy;
  final ValueChanged<String?> onSortByChanged;
  final VoidCallback onApply;
  final VoidCallback onClearAll;

  @override
  Widget build(BuildContext context) {
    return OperationAdvancedFiltersPanel(
      sortBy: sortBy,
      sortFieldLabels: UnpackingUiConstants.sortFieldLabels,
      onSortByChanged: onSortByChanged,
      onApply: onApply,
      onClearAll: onClearAll,
      footerHint:
          'Filters apply to loaded results. Sort order updates immediately on apply.',
      filterField: SsccEntryField(
        controller: containerController,
        label: 'Container SSCC',
        hintText: 'Filter by container SSCC (optional)',
        validator: (_) => null,
      ),
    );
  }
}
