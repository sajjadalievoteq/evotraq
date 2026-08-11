import 'package:flutter/material.dart';

class TransformationEventDropdownField extends StatelessWidget {
  const TransformationEventDropdownField({
    required this.controller,
    required this.label,
    required this.options,
    this.helperText,
    this.onChanged,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final List<String> options;
  final String? helperText;
  final ValueChanged<String?>? onChanged;

  @override
  Widget build(BuildContext context) {
    final controllerValue = controller.text.isEmpty ? null : controller.text;
    final selectedValue = options.contains(controllerValue)
        ? controllerValue
        : null;

    return DropdownButtonFormField<String>(
      value: selectedValue,
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText,
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      items: options.map((value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(_formatForDisplay(value)),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) return 'Please select a $label';
        return null;
      },
    );
  }

  String _formatForDisplay(String value) {
    return value
        .split('_')
        .map((word) => word.substring(0, 1).toUpperCase() + word.substring(1))
        .join(' ');
  }
}
