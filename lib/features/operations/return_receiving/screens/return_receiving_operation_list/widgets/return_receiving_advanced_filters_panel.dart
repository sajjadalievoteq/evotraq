import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/custom_button_widget.dart';
import 'package:traqtrace_app/core/widgets/custom_outlined_button_widget.dart';
import 'package:traqtrace_app/features/operations/return_receiving/utils/return_receiving_ui_constants.dart';

class ReturnReceivingAdvancedFiltersPanel extends StatelessWidget {
  const ReturnReceivingAdvancedFiltersPanel({
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: trackingController,
          decoration: const InputDecoration(
            labelText: 'Tracking Number',
            hintText: 'Filter by tracking number (optional)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Filters apply to loaded results. Sort order updates when applied.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          key: ValueKey(sortBy),
          initialValue: sortBy,
          decoration: const InputDecoration(
            labelText: ReturnReceivingUiConstants.labelSortResultsBy,
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: ReturnReceivingUiConstants.sortFieldLabels.entries
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
                title: ReturnReceivingUiConstants.buttonClearFilters,
                onTap: onClearAll,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomButtonWidget(
                title: ReturnReceivingUiConstants.buttonApply,
                onTap: onApply,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
