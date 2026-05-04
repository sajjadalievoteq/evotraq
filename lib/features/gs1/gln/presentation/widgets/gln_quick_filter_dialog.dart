import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/features/gs1/gln/utils/gln_ui_constants.dart';
import 'package:traqtrace_app/shared/widgets/custom_outlined_button_widget.dart';
import 'package:traqtrace_app/shared/widgets/custom_text_button_widget.dart';

@immutable
class GlnQuickFilterResult {
  const GlnQuickFilterResult.cleared()
      : cleared = true,
        status = null,
        locationType = null;

  const GlnQuickFilterResult.applied(String statusValue, String locationTypeValue)
      : cleared = false,
        status = statusValue,
        locationType = locationTypeValue;

  final bool cleared;
  final String? status;
  final String? locationType;
}

class GlnQuickFilterDialog extends StatefulWidget {
  const GlnQuickFilterDialog({
    super.key,
    required this.locationNameController,
    required this.initialStatus,
    required this.initialLocationType,
  });

  final TextEditingController locationNameController;
  final String? initialStatus;
  final String? initialLocationType;

  static Future<GlnQuickFilterResult?> open(
    BuildContext context, {
    required TextEditingController locationNameController,
    required String? selectedStatus,
    required String? selectedLocationType,
  }) {
    return showDialog<GlnQuickFilterResult>(
      context: context,
      builder: (dialogContext) => GlnQuickFilterDialog(
        locationNameController: locationNameController,
        initialStatus: selectedStatus,
        initialLocationType: selectedLocationType,
      ),
    );
  }

  @override
  State<GlnQuickFilterDialog> createState() => _GlnQuickFilterDialogState();
}

class _GlnQuickFilterDialogState extends State<GlnQuickFilterDialog> {
  late String _status;
  late String _locationType;

  @override
  void initState() {
    super.initState();
    _status = widget.initialStatus ?? GlnUiConstants.filterAll;
    _locationType = widget.initialLocationType ?? GlnUiConstants.filterAll;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(GlnUiConstants.quickFiltersTitle),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: Constants.dialogMaxWidth),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(GlnUiConstants.filterSectionLocationName),
              const SizedBox(height: 8),
              TextField(
                controller: widget.locationNameController,
                decoration: InputDecoration(
                  hintText: GlnUiConstants.hintLocationNameExample,
                  border: const OutlineInputBorder(),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
              Text(GlnUiConstants.filterSectionStatus),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                key: ValueKey(_status),
                initialValue: _status,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: GlnUiConstants.statusOptions
                    .map(
                      (option) => DropdownMenuItem(
                        value: option,
                        child: Text(option),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _status = value);
                },
              ),
              const SizedBox(height: 16),
              Text(GlnUiConstants.filterSectionLocationType),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                key: ValueKey(_locationType),
                initialValue: _locationType,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: GlnUiConstants.locationTypeOptions
                    .map(
                      (option) => DropdownMenuItem(
                        value: option,
                        child: Text(option),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _locationType = value);
                },
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                GlnUiConstants.quickFiltersFooterHint,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
      actions: [
        CustomTextButtonWidget(
          title: GlnUiConstants.buttonCancel,
          onTap: () => Navigator.of(context).pop(),
        ),
        CustomTextButtonWidget(
          title: GlnUiConstants.buttonApply,
          onTap: () {
            Navigator.of(context).pop(
              GlnQuickFilterResult.applied(_status, _locationType),
            );
          },
        ),
        CustomOutlinedButtonWidget(
          title: GlnUiConstants.buttonClearFilters,
          onTap: () {
            widget.locationNameController.clear();
            Navigator.of(context).pop(const GlnQuickFilterResult.cleared());
          },
        ),
      ],
    );
  }
}
