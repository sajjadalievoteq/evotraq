import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/custom_outlined_button_widget.dart';
import 'package:traqtrace_app/core/widgets/custom_text_button_widget.dart';
import 'package:traqtrace_app/data/models/operations/shipping/shipping_quick_filter_result.dart';
import 'package:traqtrace_app/features/operations/shipping/utils/shipping_ui_constants.dart';

class ShippingQuickFilterDialog extends StatefulWidget {
  const ShippingQuickFilterDialog({super.key, required this.initialStatus});

  final String? initialStatus;

  static Future<ShippingQuickFilterResult?> open(
    BuildContext context, {
    required String? selectedStatus,
  }) {
    return showDialog<ShippingQuickFilterResult>(
      context: context,
      builder: (_) => ShippingQuickFilterDialog(initialStatus: selectedStatus),
    );
  }

  @override
  State<ShippingQuickFilterDialog> createState() =>
      _ShippingQuickFilterDialogState();
}

class _ShippingQuickFilterDialogState extends State<ShippingQuickFilterDialog> {
  late String _status;

  @override
  void initState() {
    super.initState();
    _status = widget.initialStatus ?? ShippingUiConstants.filterAll;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(ShippingUiConstants.quickFiltersTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ShippingUiConstants.filterSectionStatus,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: ShippingUiConstants.statusFilterOptions.map((opt) {
                return FilterChip(
                  selectedColor: context.colors.primary,
                  label: Text(ShippingUiConstants.statusFilterLabel(opt)),
                  selected: _status == opt,
                  onSelected: (_) => setState(() => _status = opt),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            Text(
              ShippingUiConstants.quickFiltersFooterHint,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
      actions: [
        CustomTextButtonWidget(
          title: ShippingUiConstants.buttonClearFilters,
          onTap: () => Navigator.of(
            context,
          ).pop(const ShippingQuickFilterResult.cleared()),
        ),
        CustomOutlinedButtonWidget(
          title: ShippingUiConstants.buttonCancel,
          onTap: () => Navigator.of(context).pop(),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(
            ShippingQuickFilterResult.applied(
              status: _status == ShippingUiConstants.filterAll ? null : _status,
            ),
          ),
          child: const Text(ShippingUiConstants.buttonApply),
        ),
      ],
    );
  }
}
