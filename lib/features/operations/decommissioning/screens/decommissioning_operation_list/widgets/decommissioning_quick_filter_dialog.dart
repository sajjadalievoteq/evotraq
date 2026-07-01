import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/custom_outlined_button_widget.dart';
import 'package:traqtrace_app/core/widgets/custom_text_button_widget.dart';
import 'package:traqtrace_app/data/models/operations/decommissioning/decommissioning_quick_filter_result.dart';
import 'package:traqtrace_app/features/operations/decommissioning/utils/decommissioning_ui_constants.dart';

class DecommissioningQuickFilterDialog extends StatefulWidget {
  const DecommissioningQuickFilterDialog({super.key, required this.initialStatus});

  final String? initialStatus;

  static Future<DecommissioningQuickFilterResult?> open(
    BuildContext context, {
    required String? selectedStatus,
  }) {
    return showDialog<DecommissioningQuickFilterResult>(
      context: context,
      builder: (_) => DecommissioningQuickFilterDialog(initialStatus: selectedStatus),
    );
  }

  @override
  State<DecommissioningQuickFilterDialog> createState() =>
      _DecommissioningQuickFilterDialogState();
}

class _DecommissioningQuickFilterDialogState extends State<DecommissioningQuickFilterDialog> {
  late String _status;

  @override
  void initState() {
    super.initState();
    _status = widget.initialStatus ?? DecommissioningUiConstants.filterAll;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(DecommissioningUiConstants.quickFiltersTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DecommissioningUiConstants.filterSectionStatus,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: DecommissioningUiConstants.statusFilterOptions.map((opt) {
                return FilterChip(
                  selectedColor: context.colors.primary,
                  label: Text(DecommissioningUiConstants.statusFilterLabel(opt)),
                  selected: _status == opt,
                  onSelected: (_) => setState(() => _status = opt),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            Text(
              DecommissioningUiConstants.quickFiltersFooterHint,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
      actions: [
        CustomTextButtonWidget(
          title: DecommissioningUiConstants.buttonClearFilters,
          onTap: () => Navigator.of(
            context,
          ).pop(const DecommissioningQuickFilterResult.cleared()),
        ),
        CustomOutlinedButtonWidget(
          title: DecommissioningUiConstants.buttonCancel,
          onTap: () => Navigator.of(context).pop(),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(
            DecommissioningQuickFilterResult.applied(
              status: _status == DecommissioningUiConstants.filterAll ? null : _status,
            ),
          ),
          child: const Text(DecommissioningUiConstants.buttonApply),
        ),
      ],
    );
  }
}
