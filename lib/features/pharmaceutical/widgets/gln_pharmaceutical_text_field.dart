import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GlnPharmaceuticalTextField extends StatelessWidget {
  const GlnPharmaceuticalTextField({
    required this.controller,
    required this.label,
    this.enabled = true,
    this.hint,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.maxLength,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final bool enabled;
  final String? hint;
  final TextInputType keyboardType;
  final int maxLines;
  final int? maxLength;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      maxLines: maxLines,
      inputFormatters: maxLength != null
          ? [LengthLimitingTextInputFormatter(maxLength!)]
          : null,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
        filled: !enabled,
        fillColor: enabled ? null : Colors.grey.shade100,
      ),
    );
  }
}
