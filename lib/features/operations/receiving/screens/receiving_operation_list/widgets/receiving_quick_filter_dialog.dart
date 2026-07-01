import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/custom_outlined_button_widget.dart';
import 'package:traqtrace_app/core/widgets/custom_text_button_widget.dart';
import 'package:traqtrace_app/data/models/operations/receiving/receiving_quick_filter_result.dart';
import 'package:traqtrace_app/features/operations/receiving/utils/receiving_ui_constants.dart';

class ReceivingQuickFilterDialog extends StatefulWidget {
  const ReceivingQuickFilterDialog({super.key, required this.initialStatus});

  final String? initialStatus;

  static Future<ReceivingQuickFilterResult?> open(
    BuildContext context, {
    required String? selectedStatus,
  }) {
    return showDialog<ReceivingQuickFilterResult>(
      context: context,
      builder: (_) => ReceivingQuickFilterDialog(initialStatus: selectedStatus),
    );
  }

  @override
  State<ReceivingQuickFilterDialog> createState() =>
      _ReceivingQuickFilterDialogState();
}

class _ReceivingQuickFilterDialogState
    extends State<ReceivingQuickFilterDialog> {
  late String _status;

  @override
  void initState() {
    super.initState();
    _status = widget.initialStatus ?? ReceivingUiConstants.filterAll;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(ReceivingUiConstants.quickFiltersTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ReceivingUiConstants.filterSectionStatus,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: ReceivingUiConstants.statusFilterOptions.map((opt) {
                return FilterChip(
                  selectedColor: context.colors.primary,
                  label: Text(ReceivingUiConstants.statusFilterLabel(opt)),
                  selected: _status == opt,
                  onSelected: (_) => setState(() => _status = opt),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            Text(
              ReceivingUiConstants.quickFiltersFooterHint,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
      actions: [
        CustomTextButtonWidget(
          title: ReceivingUiConstants.buttonClearFilters,
          onTap: () => Navigator.of(
            context,
          ).pop(const ReceivingQuickFilterResult.cleared()),
        ),
        CustomOutlinedButtonWidget(
          title: ReceivingUiConstants.buttonCancel,
          onTap: () => Navigator.of(context).pop(),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(
            ReceivingQuickFilterResult.applied(
              status: _status == ReceivingUiConstants.filterAll
                  ? null
                  : _status,
            ),
          ),
          child: const Text(ReceivingUiConstants.buttonApply),
        ),
      ],
    );
  }
}
