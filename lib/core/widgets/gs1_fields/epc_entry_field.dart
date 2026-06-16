import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1/sgtin/utils/sgtin_validators.dart';
import 'package:traqtrace_app/features/gs1/widgets/gtin_validated_field.dart';

class EpcEntryField extends StatelessWidget {
  const EpcEntryField({
    super.key,
    required this.controller,
    required this.label,
    this.fieldName = 'epc',
    this.enabled = true,
    this.hintText,
    this.helperText,
    this.onChanged,
    this.setFieldError,
    this.validator,
    this.focusNode,
    this.onEditingComplete,
    this.required = false,
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

  String? _defaultValidator(String? value) {
    if (required && (value == null || value.trim().isEmpty)) {
      return '$label is required';
    }
    return validateEpcUri(value);
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
      onChanged: onChanged,
      validator: validator ?? _defaultValidator,
    );
  }
}
