import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/custom_outlined_button_widget.dart';
import 'package:traqtrace_app/core/widgets/custom_text_button_widget.dart';
import 'package:traqtrace_app/data/models/operations/shared/operation_quick_filter_result.dart';
import 'package:traqtrace_app/features/operations/shared/utils/operation_ui_constants.dart';

class OperationQuickFilterDialog extends StatefulWidget {
  const OperationQuickFilterDialog({
    super.key,
    required this.initialStatus,
    required this.statusFilterOptions,
    required this.statusFilterLabel,
    required this.footerHint,
  });

  final String? initialStatus;
  final List<String> statusFilterOptions;
  final String Function(String value) statusFilterLabel;
  final String footerHint;

  static Future<OperationQuickFilterResult?> open(
    BuildContext context, {
    required String? selectedStatus,
    required List<String> statusFilterOptions,
    required String Function(String value) statusFilterLabel,
    required String footerHint,
  }) {
    return showDialog<OperationQuickFilterResult>(
      context: context,
      builder: (_) => OperationQuickFilterDialog(
        initialStatus: selectedStatus,
        statusFilterOptions: statusFilterOptions,
        statusFilterLabel: statusFilterLabel,
        footerHint: footerHint,
      ),
    );
  }

  @override
  State<OperationQuickFilterDialog> createState() =>
      _OperationQuickFilterDialogState();
}

class _OperationQuickFilterDialogState extends State<OperationQuickFilterDialog> {
  late String _status;

  @override
  void initState() {
    super.initState();
    _status = widget.initialStatus ?? OperationUiConstants.filterAll;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(OperationUiConstants.quickFiltersTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              OperationUiConstants.filterSectionStatus,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: widget.statusFilterOptions.map((opt) {
                return FilterChip(
                  selectedColor: context.colors.primary,
                  label: Text(widget.statusFilterLabel(opt)),
                  selected: _status == opt,
                  onSelected: (_) => setState(() => _status = opt),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            Text(
              widget.footerHint,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
      actions: [
        CustomTextButtonWidget(
          title: OperationUiConstants.buttonClearFilters,
          onTap: () => Navigator.of(context)
              .pop(const OperationQuickFilterResult.cleared()),
        ),
        CustomOutlinedButtonWidget(
          title: OperationUiConstants.buttonCancel,
          onTap: () => Navigator.of(context).pop(),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(
            OperationQuickFilterResult.applied(
              status: _status == OperationUiConstants.filterAll ? null : _status,
            ),
          ),
          child: const Text(OperationUiConstants.buttonApply),
        ),
      ],
    );
  }
}
