import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/gs1/serialization/sscc/sscc_model.dart';
import 'package:traqtrace_app/features/gs1/sscc/presentation/models/sscc_quick_filter_result.dart';
import 'package:traqtrace_app/features/gs1/sscc/presentation/utilities/sscc_ui_constants.dart';
import 'package:traqtrace_app/shared/widgets/custom_outlined_button_widget.dart';
import 'package:traqtrace_app/shared/widgets/custom_text_button_widget.dart';

class SsccQuickFilterDialog extends StatefulWidget {
  const SsccQuickFilterDialog({
    super.key,
    required this.initialStatus,
    required this.initialContainerType,
  });

  final String? initialStatus;
  final String? initialContainerType;

  static Future<SsccQuickFilterResult?> open(
    BuildContext context, {
    required String? selectedStatus,
    required String? selectedContainerType,
  }) {
    return showDialog<SsccQuickFilterResult>(
      context: context,
      builder: (_) => SsccQuickFilterDialog(
        initialStatus: selectedStatus,
        initialContainerType: selectedContainerType,
      ),
    );
  }

  @override
  State<SsccQuickFilterDialog> createState() => _SsccQuickFilterDialogState();
}

class _SsccQuickFilterDialogState extends State<SsccQuickFilterDialog> {
  late String _status;
  late String _containerType;

  @override
  void initState() {
    super.initState();
    _status = widget.initialStatus ?? SsccUiConstants.filterAll;
    _containerType =
        widget.initialContainerType ?? SsccUiConstants.filterAll;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(SsccUiConstants.quickFiltersTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              SsccUiConstants.filterSectionStatus,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: SsccUiConstants.statusOptions.map((opt) {
                return FilterChip(
                  label: Text(opt == SsccUiConstants.filterAll ? 'All' : opt),
                  selected: _status == opt,
                  onSelected: (_) => setState(() => _status = opt),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Text(
              SsccUiConstants.filterSectionContainerType,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                SsccUiConstants.filterAll,
                ...SsccUiConstants.containerTypeOptions,
              ].map((opt) {
                return FilterChip(
                  label: Text(opt == SsccUiConstants.filterAll ? 'All' : opt),
                  selected: _containerType == opt,
                  onSelected: (_) => setState(() => _containerType = opt),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            Text(
              SsccUiConstants.quickFiltersFooterHint,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
      actions: [
        CustomTextButtonWidget(
          title: SsccUiConstants.buttonClearFilters,
          onTap: () =>
              Navigator.of(context).pop(const SsccQuickFilterResult.cleared()),
        ),
        CustomOutlinedButtonWidget(
          title: SsccUiConstants.buttonCancel,
          onTap: () => Navigator.of(context).pop(),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(
            SsccQuickFilterResult.applied(
              status: _status == SsccUiConstants.filterAll ? null : _status,
              containerType: _containerType == SsccUiConstants.filterAll
                  ? null
                  : _containerType,
            ),
          ),
          child: const Text(SsccUiConstants.buttonApply),
        ),
      ],
    );
  }
}

String? ssccContainerTypeLabel(String? value) {
  if (value == null) return null;
  return SSCC.parseUnitType(value).name;
}
