import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/custom_outlined_button_widget.dart';
import 'package:traqtrace_app/core/widgets/custom_text_button_widget.dart';
import 'package:traqtrace_app/features/operations/return_shipping/screens/return_shipping_operation_list/models/return_shipping_quick_filter_result.dart';
import 'package:traqtrace_app/features/operations/return_shipping/utils/return_shipping_ui_constants.dart';

class ReturnShippingQuickFilterDialog extends StatefulWidget {
  const ReturnShippingQuickFilterDialog({
    super.key,
    required this.initialStatus,
  });

  final String? initialStatus;

  static Future<ReturnShippingQuickFilterResult?> open(
    BuildContext context, {
    required String? selectedStatus,
  }) {
    return showDialog<ReturnShippingQuickFilterResult>(
      context: context,
      builder: (_) => ReturnShippingQuickFilterDialog(initialStatus: selectedStatus),
    );
  }

  @override
  State<ReturnShippingQuickFilterDialog> createState() =>
      _ReturnShippingQuickFilterDialogState();
}

class _ReturnShippingQuickFilterDialogState extends State<ReturnShippingQuickFilterDialog> {
  late String _status;

  @override
  void initState() {
    super.initState();
    _status = widget.initialStatus ?? ReturnShippingUiConstants.filterAll;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(ReturnShippingUiConstants.quickFiltersTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ReturnShippingUiConstants.filterSectionStatus,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: ReturnShippingUiConstants.statusFilterOptions.map((opt) {
                return FilterChip(
                  selectedColor: context.colors.primary,
                  label: Text(ReturnShippingUiConstants.statusFilterLabel(opt)),
                  selected: _status == opt,
                  onSelected: (_) => setState(() => _status = opt),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            Text(
              ReturnShippingUiConstants.quickFiltersFooterHint,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
      actions: [
        CustomTextButtonWidget(
          title: ReturnShippingUiConstants.buttonClearFilters,
          onTap: () => Navigator.of(context).pop(
            const ReturnShippingQuickFilterResult.cleared(),
          ),
        ),
        CustomOutlinedButtonWidget(
          title: ReturnShippingUiConstants.buttonCancel,
          onTap: () => Navigator.of(context).pop(),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(
            ReturnShippingQuickFilterResult.applied(
              status: _status == ReturnShippingUiConstants.filterAll ? null : _status,
            ),
          ),
          child: const Text(ReturnShippingUiConstants.buttonApply),
        ),
      ],
    );
  }
}
