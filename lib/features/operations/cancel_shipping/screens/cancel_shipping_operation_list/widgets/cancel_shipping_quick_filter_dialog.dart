import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/custom_outlined_button_widget.dart';
import 'package:traqtrace_app/core/widgets/custom_text_button_widget.dart';
import 'package:traqtrace_app/features/operations/cancel_shipping/screens/cancel_shipping_operation_list/models/cancel_shipping_quick_filter_result.dart';
import 'package:traqtrace_app/features/operations/cancel_shipping/utils/cancel_shipping_ui_constants.dart';

class CancelShippingQuickFilterDialog extends StatefulWidget {
  const CancelShippingQuickFilterDialog({
    super.key,
    required this.initialStatus,
  });

  final String? initialStatus;

  static Future<CancelShippingQuickFilterResult?> open(
    BuildContext context, {
    required String? selectedStatus,
  }) {
    return showDialog<CancelShippingQuickFilterResult>(
      context: context,
      builder: (_) => CancelShippingQuickFilterDialog(initialStatus: selectedStatus),
    );
  }

  @override
  State<CancelShippingQuickFilterDialog> createState() =>
      _CancelShippingQuickFilterDialogState();
}

class _CancelShippingQuickFilterDialogState extends State<CancelShippingQuickFilterDialog> {
  late String _status;

  @override
  void initState() {
    super.initState();
    _status = widget.initialStatus ?? CancelShippingUiConstants.filterAll;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(CancelShippingUiConstants.quickFiltersTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              CancelShippingUiConstants.filterSectionStatus,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: CancelShippingUiConstants.statusFilterOptions.map((opt) {
                return FilterChip(
                  selectedColor: context.colors.primary,
                  label: Text(CancelShippingUiConstants.statusFilterLabel(opt)),
                  selected: _status == opt,
                  onSelected: (_) => setState(() => _status = opt),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            Text(
              CancelShippingUiConstants.quickFiltersFooterHint,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
      actions: [
        CustomTextButtonWidget(
          title: CancelShippingUiConstants.buttonClearFilters,
          onTap: () => Navigator.of(context).pop(
            const CancelShippingQuickFilterResult.cleared(),
          ),
        ),
        CustomOutlinedButtonWidget(
          title: CancelShippingUiConstants.buttonCancel,
          onTap: () => Navigator.of(context).pop(),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(
            CancelShippingQuickFilterResult.applied(
              status: _status == CancelShippingUiConstants.filterAll ? null : _status,
            ),
          ),
          child: const Text(CancelShippingUiConstants.buttonApply),
        ),
      ],
    );
  }
}
