import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/features/operations/commissioning/presentation/models/commissioning_quick_filter_result.dart';
import 'package:traqtrace_app/features/operations/commissioning/presentation/utilities/commissioning_ui_constants.dart';
import 'package:traqtrace_app/core/widgets/custom_outlined_button_widget.dart';
import 'package:traqtrace_app/core/widgets/custom_text_button_widget.dart';

class CommissioningQuickFilterDialog extends StatefulWidget {
  const CommissioningQuickFilterDialog({
    super.key,
    required this.initialStatus,
  });

  final String? initialStatus;

  static Future<CommissioningQuickFilterResult?> open(
    BuildContext context, {
    required String? selectedStatus,
  }) {
    return showDialog<CommissioningQuickFilterResult>(
      context: context,
      builder: (_) => CommissioningQuickFilterDialog(initialStatus: selectedStatus),
    );
  }

  @override
  State<CommissioningQuickFilterDialog> createState() =>
      _CommissioningQuickFilterDialogState();
}

class _CommissioningQuickFilterDialogState
    extends State<CommissioningQuickFilterDialog> {
  late String _status;

  @override
  void initState() {
    super.initState();
    _status = widget.initialStatus ?? CommissioningUiConstants.filterAll;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(CommissioningUiConstants.quickFiltersTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              CommissioningUiConstants.filterSectionStatus,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: CommissioningUiConstants.statusFilterOptions.map((opt) {
                return FilterChip(
                  selectedColor: context.colors.primary,
                  label: Text(CommissioningUiConstants.statusFilterLabel(opt)),
                  selected: _status == opt,
                  onSelected: (_) => setState(() => _status = opt),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            Text(
              CommissioningUiConstants.quickFiltersFooterHint,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
      actions: [
        CustomTextButtonWidget(
          title: CommissioningUiConstants.buttonClearFilters,
          onTap: () => Navigator.of(context).pop(
            const CommissioningQuickFilterResult.cleared(),
          ),
        ),
        CustomOutlinedButtonWidget(
          title: CommissioningUiConstants.buttonCancel,
          onTap: () => Navigator.of(context).pop(),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(
            CommissioningQuickFilterResult.applied(
              status: _status == CommissioningUiConstants.filterAll
                  ? null
                  : _status,
            ),
          ),
          child: const Text(CommissioningUiConstants.buttonApply),
        ),
      ],
    );
  }
}
