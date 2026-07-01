import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/custom_button_widget.dart';
import 'package:traqtrace_app/core/widgets/custom_outlined_button_widget.dart';
import 'package:traqtrace_app/features/operations/decommissioning/utils/decommissioning_ui_constants.dart';

class DecommissioningAdvancedFiltersPanel extends StatelessWidget {
  const DecommissioningAdvancedFiltersPanel({
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Sort order updates when applied.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          key: ValueKey(sortBy),
          initialValue: sortBy,
          decoration: const InputDecoration(
            labelText: DecommissioningUiConstants.labelSortResultsBy,
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: DecommissioningUiConstants.sortFieldLabels.entries
              .map(
                (e) => DropdownMenuItem(value: e.key, child: Text(e.value)),
              )
              .toList(),
          onChanged: onSortByChanged,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: CustomOutlinedButtonWidget(
                title: DecommissioningUiConstants.buttonClearFilters,
                onTap: onClearAll,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomButtonWidget(
                title: DecommissioningUiConstants.buttonApply,
                onTap: onApply,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
