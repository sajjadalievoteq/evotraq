import 'package:flutter/material.dart';

class GtinDateField extends StatelessWidget {
  const GtinDateField({
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

