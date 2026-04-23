import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/utilities/gtin_ui_constants.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/shared/widgets/custom_outlined_button_widget.dart';
import 'package:traqtrace_app/shared/widgets/custom_text_button_widget.dart';

/// Result of [GtinQuickFilterDialog.open].
@immutable
class GtinQuickFilterResult {
  const GtinQuickFilterResult.cleared()
      : cleared = true,
        status = null,
        packaging = null;

  const GtinQuickFilterResult.applied(String statusValue, String packagingValue)
      : cleared = false,
        status = statusValue,
        packaging = packagingValue;

  final bool cleared;
  final String? status;
  final String? packaging;
}

/// Quick filters dialog (manufacturer, status, packaging).
class GtinQuickFilterDialog extends StatefulWidget {
  const GtinQuickFilterDialog({
    super.key,
    required this.manufacturerController,
    required this.initialStatus,
    required this.initialPackagingLevel,
  });

  final TextEditingController manufacturerController;
  final String? initialStatus;
  final String? initialPackagingLevel;

  static Future<GtinQuickFilterResult?> open(
    BuildContext context, {
    required TextEditingController manufacturerController,
    required String? selectedStatus,
    required String? selectedPackagingLevel,
  }) {
    return showDialog<GtinQuickFilterResult>(
      context: context,
      builder: (dialogContext) => GtinQuickFilterDialog(
        manufacturerController: manufacturerController,
        initialStatus: selectedStatus,
        initialPackagingLevel: selectedPackagingLevel,
      ),
    );
  }

  @override
  State<GtinQuickFilterDialog> createState() => _GtinQuickFilterDialogState();
}

class _GtinQuickFilterDialogState extends State<GtinQuickFilterDialog> {
  late String _status;
  late String _packaging;

  @override
  void initState() {
    super.initState();
    _status = widget.initialStatus ?? 'All';
    _packaging = widget.initialPackagingLevel ?? 'All';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Quick Filters'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: Constants.dialogMaxWidth),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Manufacturer'),
              const SizedBox(height: 8),
              TextField(
                controller: widget.manufacturerController,
                decoration: const InputDecoration(
                  hintText: 'e.g., Pfizer, Johnson & Johnson',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
              const Text('Status'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: GtinUiConstants.statusOptions
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
              const Text('Packaging Level'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _packaging,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: GtinUiConstants.packagingLevelOptions
                    .map(
                      (option) => DropdownMenuItem(
                        value: option,
                        child: Text(option),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _packaging = value);
                },
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'For more advanced filters, use the "Show Advanced Filters" option below the search bar.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
      actions: [
        CustomTextButtonWidget(
          title: 'Cancel',
          onTap: () => Navigator.of(context).pop(),
        ),
        CustomTextButtonWidget(
          title: 'Apply',
          onTap: () {
            Navigator.of(context).pop(
              GtinQuickFilterResult.applied(_status, _packaging),
            );
          },
        ),
        CustomOutlinedButtonWidget(
          title: 'Clear Filters',
          onTap: () {
            widget.manufacturerController.clear();
            Navigator.of(context).pop(const GtinQuickFilterResult.cleared());
          },
        ),
      ],
    );
  }
}

