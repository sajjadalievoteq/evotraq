import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/operations/update_status/utils/update_status_ui_constants.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/list/operation_advanced_filters_panel.dart';

class UpdateStatusAdvancedFiltersPanel extends StatelessWidget {
  const UpdateStatusAdvancedFiltersPanel({
    super.key,
    required this.sortBy,
    required this.onSortByChanged,
    required this.onApply,
    required this.onClearAll,
  });

  final String sortBy;
  final ValueChanged<String?> onSortByChanged;
  final VoidCallback onApply;
  final VoidCallback onClearAll;

  @override
  Widget build(BuildContext context) {
    return OperationAdvancedFiltersPanel(
      sortBy: sortBy,
      sortFieldLabels: UpdateStatusUiConstants.sortFieldLabels,
      onSortByChanged: onSortByChanged,
      onApply: onApply,
      onClearAll: onClearAll,
      footerHint: 'Sort order updates when applied.',
    );
  }
}
