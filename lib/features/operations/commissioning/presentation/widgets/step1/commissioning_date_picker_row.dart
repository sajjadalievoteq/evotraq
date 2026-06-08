import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_date_field.dart';

/// Date picker row with optional clear action for commissioning step 1.
class CommissioningDatePickerRow extends StatelessWidget {
  const CommissioningDatePickerRow({
    super.key,
    required this.label,
    required this.dateKey,
    required this.value,
    required this.onSelect,
    required this.onClear,
    this.allowClear = true,
  });

  final String label;
  final String dateKey;
  final DateTime? value;
  final ValueChanged<String> onSelect;
  final ValueChanged<String> onClear;
  final bool allowClear;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Gs1DatePickerField(
            label: label,
            value: value,
            onTap: () => onSelect(dateKey),
          ),
        ),
        if (allowClear && value != null)
          IconButton(
            icon: const Icon(Icons.clear),
            tooltip: 'Clear date',
            onPressed: () => onClear(dateKey),
          ),
      ],
    );
  }
}
