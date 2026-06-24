import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/custom_outlined_button_widget.dart';
import 'package:traqtrace_app/core/widgets/custom_text_button_widget.dart';
import 'package:traqtrace_app/features/operations/unpacking/screens/unpacking_operation_list/models/unpacking_quick_filter_result.dart';
import 'package:traqtrace_app/features/operations/unpacking/utils/unpacking_ui_constants.dart';

class UnpackingQuickFilterDialog extends StatefulWidget {
  const UnpackingQuickFilterDialog({
    super.key,
    required this.initialStatus,
  });

  final String? initialStatus;

  static Future<UnpackingQuickFilterResult?> open(
    BuildContext context, {
    required String? selectedStatus,
  }) {
    return showDialog<UnpackingQuickFilterResult>(
      context: context,
      builder: (_) => UnpackingQuickFilterDialog(initialStatus: selectedStatus),
    );
  }

  @override
  State<UnpackingQuickFilterDialog> createState() =>
      _UnpackingQuickFilterDialogState();
}

class _UnpackingQuickFilterDialogState extends State<UnpackingQuickFilterDialog> {
  late String _status;

  @override
  void initState() {
    super.initState();
    _status = widget.initialStatus ?? UnpackingUiConstants.filterAll;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(UnpackingUiConstants.quickFiltersTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              UnpackingUiConstants.filterSectionStatus,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: UnpackingUiConstants.statusFilterOptions.map((opt) {
                return FilterChip(
                  selectedColor: context.colors.primary,
                  label: Text(UnpackingUiConstants.statusFilterLabel(opt)),
                  selected: _status == opt,
                  onSelected: (_) => setState(() => _status = opt),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            Text(
              UnpackingUiConstants.quickFiltersFooterHint,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
      actions: [
        CustomTextButtonWidget(
          title: UnpackingUiConstants.buttonClearFilters,
          onTap: () => Navigator.of(context).pop(
            const UnpackingQuickFilterResult.cleared(),
          ),
        ),
        CustomOutlinedButtonWidget(
          title: UnpackingUiConstants.buttonCancel,
          onTap: () => Navigator.of(context).pop(),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(
            UnpackingQuickFilterResult.applied(
              status: _status == UnpackingUiConstants.filterAll ? null : _status,
            ),
          ),
          child: const Text(UnpackingUiConstants.buttonApply),
        ),
      ],
    );
  }
}
