import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/gs1_fields/gtin_entry_field.dart';
import 'package:traqtrace_app/features/operations/commissioning/presentation/utilities/commissioning_ui_constants.dart';
import 'package:traqtrace_app/core/widgets/custom_button_widget.dart';
import 'package:traqtrace_app/core/widgets/custom_outlined_button_widget.dart';

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
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GtinEntryField(
          controller: gtinController,
          fieldName: 'gtinCode',
          label: 'GTIN',
          hintText: 'Filter batches by GTIN (14 digits)',
          validator: (_) => null,
        ),
        const SizedBox(height: 8),
        Text(
          'Leave empty to load all batches. Applying reloads the list from the server.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          key: ValueKey(sortBy),
          initialValue: sortBy,
          decoration: const InputDecoration(
            labelText: CommissioningUiConstants.labelSortResultsBy,
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: CommissioningUiConstants.sortFieldLabels.entries
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
                title: CommissioningUiConstants.buttonClearFilters,
                onTap: onClearAll,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomButtonWidget(
                title: CommissioningUiConstants.buttonApply,
                onTap: onApply,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
