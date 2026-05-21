import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/data/models/gs1/sgtin/sgtin_model.dart';
import 'package:traqtrace_app/features/gs1/sgtin/presentation/utilities/sgtin_ui_constants.dart';
import 'package:traqtrace_app/shared/widgets/custom_outlined_button_widget.dart';
import 'package:traqtrace_app/shared/widgets/custom_text_button_widget.dart';

@immutable
class SgtinQuickFilterResult {
  const SgtinQuickFilterResult.cleared()
      : cleared = true,
        status = null;

  const SgtinQuickFilterResult.applied(String? statusValue)
      : cleared = false,
        status = statusValue;

  final bool cleared;
  final String? status;
}

class SgtinQuickFilterDialog extends StatefulWidget {
  const SgtinQuickFilterDialog({
    super.key,
    required this.initialStatus,
  });

  final String? initialStatus;

  static Future<SgtinQuickFilterResult?> open(
    BuildContext context, {
    required String? selectedStatus,
  }) {
    return showDialog<SgtinQuickFilterResult>(
      context: context,
      builder: (_) => SgtinQuickFilterDialog(initialStatus: selectedStatus),
    );
  }

  @override
  State<SgtinQuickFilterDialog> createState() => _SgtinQuickFilterDialogState();
}

class _SgtinQuickFilterDialogState extends State<SgtinQuickFilterDialog> {
  late String _status;

  @override
  void initState() {
    super.initState();
    _status = widget.initialStatus ?? SgtinUiConstants.filterAll;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(SgtinUiConstants.quickFiltersTitle),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: Constants.dialogMaxWidth),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                SgtinUiConstants.filterSectionStatus,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: SgtinUiConstants.statusOptions.map((opt) {
                  final isSelected = _status == opt;
                  return FilterChip(
                    label: Text(_statusLabel(opt)),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _status = opt),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              Text(
                SgtinUiConstants.quickFiltersFooterHint,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        CustomTextButtonWidget(
          title: SgtinUiConstants.buttonClearFilters,
          onTap: () =>
              Navigator.of(context).pop(const SgtinQuickFilterResult.cleared()),
        ),
        CustomOutlinedButtonWidget(
          title: SgtinUiConstants.buttonCancel,
          onTap: () => Navigator.of(context).pop(),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(
            SgtinQuickFilterResult.applied(
              _status == SgtinUiConstants.filterAll ? null : _status,
            ),
          ),
          child: const Text(SgtinUiConstants.buttonApply),
        ),
      ],
    );
  }

  String _statusLabel(String value) {
    if (value == SgtinUiConstants.filterAll) return 'All';
    try {
      final status = ItemStatus.values.firstWhere(
        (s) => s.name == value,
      );
      return _friendlyName(status);
    } catch (_) {
      return value;
    }
  }

  String _friendlyName(ItemStatus s) {
    switch (s) {
      case ItemStatus.RESERVED:
        return 'Reserved';
      case ItemStatus.ALLOCATED:
        return 'Allocated';
      case ItemStatus.COMMISSIONED:
        return 'Commissioned';
      case ItemStatus.ACTIVE:
        return 'Active';
      case ItemStatus.IN_TRANSIT:
        return 'In Transit';
      case ItemStatus.RECEIVED:
        return 'Received';
      case ItemStatus.DISPENSED:
        return 'Dispensed';
      case ItemStatus.RETURNED:
        return 'Returned';
      case ItemStatus.RECALLED:
        return 'Recalled';
      case ItemStatus.STOLEN:
        return 'Stolen';
      case ItemStatus.EXPIRED:
        return 'Expired';
      case ItemStatus.DESTROYED:
        return 'Destroyed';
      case ItemStatus.EXCEPTION:
        return 'Exception';
    }
  }
}
