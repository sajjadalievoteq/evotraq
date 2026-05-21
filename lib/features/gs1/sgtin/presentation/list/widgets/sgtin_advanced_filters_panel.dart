import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/gs1/sgtin/sgtin_model.dart';
import 'package:traqtrace_app/features/gs1/sgtin/presentation/utilities/sgtin_ui_constants.dart';
import 'package:traqtrace_app/shared/widgets/custom_button_widget.dart';
import 'package:traqtrace_app/shared/widgets/custom_outlined_button_widget.dart';

class SgtinAdvancedFiltersPanel extends StatelessWidget {
  const SgtinAdvancedFiltersPanel({
    super.key,
    required this.gtinCodeController,
    required this.serialNumberController,
    required this.batchLotController,
    required this.selectedStatus,
    required this.onStatusChanged,
    required this.onApply,
    required this.onClearAll,
  });

  final TextEditingController gtinCodeController;
  final TextEditingController serialNumberController;
  final TextEditingController batchLotController;
  final String? selectedStatus;
  final ValueChanged<String?> onStatusChanged;
  final VoidCallback onApply;
  final VoidCallback onClearAll;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          SgtinUiConstants.advancedFiltersHeader,
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          SgtinUiConstants.advancedFiltersNote,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: gtinCodeController,
          decoration: const InputDecoration(
            labelText: SgtinUiConstants.labelGtinCodeField,
            hintText: 'e.g., 1234567890123',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: serialNumberController,
          decoration: const InputDecoration(
            labelText: SgtinUiConstants.labelSerialNumberField,
            hintText: 'e.g., ABC123',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: batchLotController,
          decoration: const InputDecoration(
            labelText: SgtinUiConstants.labelBatchLotField,
            hintText: 'e.g., BATCH-2025-01',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: selectedStatus,
          decoration: const InputDecoration(
            labelText: SgtinUiConstants.labelStatusField,
            border: OutlineInputBorder(),
          ),
          items: [
            const DropdownMenuItem(value: null, child: Text('All')),
            ...ItemStatus.values.map(
              (s) => DropdownMenuItem(
                value: s.name,
                child: Text(_friendlyName(s)),
              ),
            ),
          ],
          onChanged: onStatusChanged,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: CustomOutlinedButtonWidget(
                title: SgtinUiConstants.buttonClearAll,
                onTap: onClearAll,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomButtonWidget(
                title: SgtinUiConstants.buttonApplyFilters,
                onTap: onApply,
              ),
            ),
          ],
        ),
      ],
    );
  }

  static String _friendlyName(ItemStatus s) {
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
