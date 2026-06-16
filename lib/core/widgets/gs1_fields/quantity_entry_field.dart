import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:traqtrace_app/features/gs1/widgets/gtin_validated_field.dart';

class QuantityEntryField extends StatelessWidget {
  const QuantityEntryField({
    super.key,
    required this.controller,
    required this.label,
    this.fieldName = 'quantity',
    this.enabled = true,
    this.hintText,
    this.helperText,
    this.onChanged,
    this.setFieldError,
    this.validator,
    this.focusNode,
    this.onEditingComplete,
    this.required = true,
  });

  final TextEditingController controller;
  final String label;
  final String fieldName;
  final bool enabled;
  final String? hintText;
  final String? helperText;
  final ValueChanged<String>? onChanged;
  final void Function(String, String?)? setFieldError;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;
  final VoidCallback? onEditingComplete;
  final bool required;

  static String? validatePositiveQuantity(String? value, {bool required = true}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'Quantity is required' : null;
    }
    final parsed = double.tryParse(value.trim());
    if (parsed == null || parsed <= 0) {
      return 'Quantity must be a positive number';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Gs1ValidatedField(
      controller: controller,
      fieldName: fieldName,
      label: label,
      hintText: hintText,
      helperText: helperText,
      readOnly: !enabled,
      setFieldError: setFieldError,
      focusNode: focusNode,
      onEditingComplete: onEditingComplete,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
      ],
      validator: validator ??
          ((value) => validatePositiveQuantity(value, required: required)),
    );
  }
}
