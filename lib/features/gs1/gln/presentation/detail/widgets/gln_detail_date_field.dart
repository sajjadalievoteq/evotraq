import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Single-line date display + picker row used across GLN detail groups.
class GlnDetailDateField extends StatelessWidget {
  const GlnDetailDateField({
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

  static final DateFormat displayFormat = DateFormat('yyyy-MM-dd');

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
              value != null ? displayFormat.format(value!) : 'Select date',
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
