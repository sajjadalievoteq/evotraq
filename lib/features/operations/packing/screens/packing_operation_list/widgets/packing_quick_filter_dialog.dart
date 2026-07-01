import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/custom_outlined_button_widget.dart';
import 'package:traqtrace_app/core/widgets/custom_text_button_widget.dart';
import 'package:traqtrace_app/data/models/operations/packing/packing_quick_filter_result.dart';
import 'package:traqtrace_app/features/operations/packing/utils/packing_ui_constants.dart';

class PackingQuickFilterDialog extends StatefulWidget {
  const PackingQuickFilterDialog({super.key, required this.initialStatus});

  final String? initialStatus;

  static Future<PackingQuickFilterResult?> open(
    BuildContext context, {
    required String? selectedStatus,
  }) {
    return showDialog<PackingQuickFilterResult>(
      context: context,
      builder: (_) => PackingQuickFilterDialog(initialStatus: selectedStatus),
    );
  }

  @override
  State<PackingQuickFilterDialog> createState() =>
      _PackingQuickFilterDialogState();
}

class _PackingQuickFilterDialogState extends State<PackingQuickFilterDialog> {
  late String _status;

  @override
  void initState() {
    super.initState();
    _status = widget.initialStatus ?? PackingUiConstants.filterAll;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(PackingUiConstants.quickFiltersTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              PackingUiConstants.filterSectionStatus,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: PackingUiConstants.statusFilterOptions.map((opt) {
                return FilterChip(
                  selectedColor: context.colors.primary,
                  label: Text(PackingUiConstants.statusFilterLabel(opt)),
                  selected: _status == opt,
                  onSelected: (_) => setState(() => _status = opt),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            Text(
              PackingUiConstants.quickFiltersFooterHint,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
      actions: [
        CustomTextButtonWidget(
          title: PackingUiConstants.buttonClearFilters,
          onTap: () => Navigator.of(
            context,
          ).pop(const PackingQuickFilterResult.cleared()),
        ),
        CustomOutlinedButtonWidget(
          title: PackingUiConstants.buttonCancel,
          onTap: () => Navigator.of(context).pop(),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(
            PackingQuickFilterResult.applied(
              status: _status == PackingUiConstants.filterAll ? null : _status,
            ),
          ),
          child: const Text(PackingUiConstants.buttonApply),
        ),
      ],
    );
  }
}
