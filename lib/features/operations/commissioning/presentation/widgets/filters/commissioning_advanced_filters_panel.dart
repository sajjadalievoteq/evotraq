import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1/widgets/gtin_validated_field.dart';
import 'package:traqtrace_app/features/operations/commissioning/presentation/utilities/commissioning_ui_constants.dart';
import 'package:traqtrace_app/shared/widgets/custom_button_widget.dart';
import 'package:traqtrace_app/shared/widgets/custom_outlined_button_widget.dart';

/// Server-side GTIN filter for the commissioning batches list.
class CommissioningAdvancedFiltersPanel extends StatelessWidget {
  const CommissioningAdvancedFiltersPanel({
    super.key,
    required this.gtinController,
    required this.onApply,
    required this.onClearAll,
  });

  final TextEditingController gtinController;
  final VoidCallback onApply;
  final VoidCallback onClearAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Gs1ValidatedField(
          controller: gtinController,
          fieldName: 'gtinCode',
          label: 'GTIN',
          hintText: 'Filter batches by GTIN (14 digits)',
          keyboardType: TextInputType.number,
          maxLength: 14,
        ),
        const SizedBox(height: 8),
        Text(
          'Leave empty to load all batches. Applying reloads the list from the server.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
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
