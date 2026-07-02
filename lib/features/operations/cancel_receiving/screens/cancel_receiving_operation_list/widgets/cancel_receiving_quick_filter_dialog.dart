import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/custom_outlined_button_widget.dart';
import 'package:traqtrace_app/core/widgets/custom_text_button_widget.dart';
import 'package:traqtrace_app/features/operations/cancel_receiving/screens/cancel_receiving_operation_list/models/cancel_receiving_quick_filter_result.dart';
import 'package:traqtrace_app/features/operations/cancel_receiving/utils/cancel_receiving_ui_constants.dart';

class CancelReceivingQuickFilterDialog extends StatefulWidget {
  const CancelReceivingQuickFilterDialog({
    super.key,
    required this.initialStatus,
  });

  final String? initialStatus;

  static Future<CancelReceivingQuickFilterResult?> open(
    BuildContext context, {
    required String? selectedStatus,
  }) {
    return showDialog<CancelReceivingQuickFilterResult>(
      context: context,
      builder: (_) => CancelReceivingQuickFilterDialog(initialStatus: selectedStatus),
    );
  }

  @override
  State<CancelReceivingQuickFilterDialog> createState() =>
      _CancelReceivingQuickFilterDialogState();
}

class _CancelReceivingQuickFilterDialogState extends State<CancelReceivingQuickFilterDialog> {
  late String _status;

  @override
  void initState() {
    super.initState();
    _status = widget.initialStatus ?? CancelReceivingUiConstants.filterAll;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(CancelReceivingUiConstants.quickFiltersTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              CancelReceivingUiConstants.filterSectionStatus,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: CancelReceivingUiConstants.statusFilterOptions.map((opt) {
                return FilterChip(
                  selectedColor: context.colors.primary,
                  label: Text(CancelReceivingUiConstants.statusFilterLabel(opt)),
                  selected: _status == opt,
                  onSelected: (_) => setState(() => _status = opt),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            Text(
              CancelReceivingUiConstants.quickFiltersFooterHint,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
      actions: [
        CustomTextButtonWidget(
          title: CancelReceivingUiConstants.buttonClearFilters,
          onTap: () => Navigator.of(context).pop(
            const CancelReceivingQuickFilterResult.cleared(),
          ),
        ),
        CustomOutlinedButtonWidget(
          title: CancelReceivingUiConstants.buttonCancel,
          onTap: () => Navigator.of(context).pop(),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(
            CancelReceivingQuickFilterResult.applied(
              status: _status == CancelReceivingUiConstants.filterAll ? null : _status,
            ),
          ),
          child: const Text(CancelReceivingUiConstants.buttonApply),
        ),
      ],
    );
  }
}
