import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/custom_outlined_button_widget.dart';
import 'package:traqtrace_app/core/widgets/custom_text_button_widget.dart';
import 'package:traqtrace_app/features/operations/return_receiving/screens/return_receiving_operation_list/models/return_receiving_quick_filter_result.dart';
import 'package:traqtrace_app/features/operations/return_receiving/utils/return_receiving_ui_constants.dart';

class ReturnReceivingQuickFilterDialog extends StatefulWidget {
  const ReturnReceivingQuickFilterDialog({
    super.key,
    required this.initialStatus,
  });

  final String? initialStatus;

  static Future<ReturnReceivingQuickFilterResult?> open(
    BuildContext context, {
    required String? selectedStatus,
  }) {
    return showDialog<ReturnReceivingQuickFilterResult>(
      context: context,
      builder: (_) => ReturnReceivingQuickFilterDialog(initialStatus: selectedStatus),
    );
  }

  @override
  State<ReturnReceivingQuickFilterDialog> createState() =>
      _ReturnReceivingQuickFilterDialogState();
}

class _ReturnReceivingQuickFilterDialogState extends State<ReturnReceivingQuickFilterDialog> {
  late String _status;

  @override
  void initState() {
    super.initState();
    _status = widget.initialStatus ?? ReturnReceivingUiConstants.filterAll;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(ReturnReceivingUiConstants.quickFiltersTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ReturnReceivingUiConstants.filterSectionStatus,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: ReturnReceivingUiConstants.statusFilterOptions.map((opt) {
                return FilterChip(
                  selectedColor: context.colors.primary,
                  label: Text(ReturnReceivingUiConstants.statusFilterLabel(opt)),
                  selected: _status == opt,
                  onSelected: (_) => setState(() => _status = opt),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            Text(
              ReturnReceivingUiConstants.quickFiltersFooterHint,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
      actions: [
        CustomTextButtonWidget(
          title: ReturnReceivingUiConstants.buttonClearFilters,
          onTap: () => Navigator.of(context).pop(
            const ReturnReceivingQuickFilterResult.cleared(),
          ),
        ),
        CustomOutlinedButtonWidget(
          title: ReturnReceivingUiConstants.buttonCancel,
          onTap: () => Navigator.of(context).pop(),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(
            ReturnReceivingQuickFilterResult.applied(
              status: _status == ReturnReceivingUiConstants.filterAll ? null : _status,
            ),
          ),
          child: const Text(ReturnReceivingUiConstants.buttonApply),
        ),
      ],
    );
  }
}
