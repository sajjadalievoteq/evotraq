import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1/widgets/validated_text_field_wrapper.dart';

class GtinValidatedField extends StatelessWidget {
  const GtinValidatedField({
    super.key,
    required this.controller,
    required this.fieldName,
    required this.label,
    this.setFieldError,
    this.helperText,
    this.readOnly = false,
    this.suffixIcon,
    this.validator,
    this.focusNode,
    this.onEditingComplete,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String fieldName;
  final String label;
  final void Function(String, String?)? setFieldError;
  final String? helperText;
  final bool readOnly;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;
  final VoidCallback? onEditingComplete;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return ValidatedTextFieldWrapper(
      controller: controller,
      fieldName: fieldName,
      focusNode: focusNode,
      onEditingComplete: onEditingComplete,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText,
        border: const OutlineInputBorder(),
        suffixIcon: suffixIcon,
      ),
      readOnly: readOnly,
      setFieldError: setFieldError,
      validator: validator ?? (value) => null,
    );
  }
}

