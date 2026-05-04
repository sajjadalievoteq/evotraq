import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Date-only picker row (InputDecorator + ink tap). Used by GLN-style forms.
class Gs1DatePickerField extends StatelessWidget {
  const Gs1DatePickerField({
    super.key,
    required this.label,
    required this.value,
    this.onTap,
    this.helperText,
  });

  final String label;
  final DateTime? value;
  final VoidCallback? onTap;
  final String? helperText;

  static final DateFormat displayDateFormat = DateFormat('yyyy-MM-dd');

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          helperText: helperText,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              value != null
                  ? displayDateFormat.format(value!)
                  : 'Select date',
              style: TextStyle(
                color: value != null ? Colors.black87 : Colors.grey,
              ),
            ),
            Icon(
              Icons.calendar_today,
              size: 18,
              color: enabled ? null : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}

/// Read-only [TextFormField] + tap opens picker; display text lives in [controller].
/// Used by GTIN lifecycle / marketing date flows that need [Form] validation.
class Gs1DateFormField extends StatelessWidget {
  const Gs1DateFormField({
    super.key,
    required this.controller,
    required this.label,
    required this.onPick,
    required this.enabled,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final Future<void> Function() onPick;
  final bool enabled;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onPick : null,
      child: AbsorbPointer(
        child: TextFormField(
          controller: controller,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ).copyWith(
            labelText: label,
            suffixIcon: const Icon(Icons.calendar_today),
          ),
          readOnly: true,
          validator: validator,
        ),
      ),
    );
  }
}
