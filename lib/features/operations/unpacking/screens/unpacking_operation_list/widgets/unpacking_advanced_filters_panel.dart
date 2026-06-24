import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/custom_button_widget.dart';
import 'package:traqtrace_app/core/widgets/custom_outlined_button_widget.dart';
import 'package:traqtrace_app/core/widgets/gs1_fields/sscc_entry_field.dart';
import 'package:traqtrace_app/features/operations/unpacking/utils/unpacking_ui_constants.dart';

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
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SsccEntryField(
          controller: containerController,
          label: 'Container SSCC',
          hintText: 'Filter by container SSCC (optional)',
          validator: (_) => null,
        ),
        const SizedBox(height: 8),
        Text(
          'Filters apply to loaded results. Sort order updates immediately on apply.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          key: ValueKey(sortBy),
          initialValue: sortBy,
          decoration: const InputDecoration(
            labelText: UnpackingUiConstants.labelSortResultsBy,
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: UnpackingUiConstants.sortFieldLabels.entries
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
                title: UnpackingUiConstants.buttonClearFilters,
                onTap: onClearAll,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomButtonWidget(
                title: UnpackingUiConstants.buttonApply,
                onTap: onApply,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
