import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:traqtrace_app/features/gs1/widgets/validated_text_field_wrapper.dart';

/// Shared GS1 validated text field (used by GTIN and GLN detail forms).
class GtinValidatedField extends StatelessWidget {
  const GtinValidatedField({
    super.key,
    required this.controller,
    required this.fieldName,
    required this.label,
    this.hintText,
    this.setFieldError,
    this.helperText,
    this.readOnly = false,
    this.suffixIcon,
    this.validator,
    this.focusNode,
    this.onEditingComplete,
    this.keyboardType,
    this.maxLength,
    this.maxLines = 1,
    this.inputFormatters,
  });

  final TextEditingController controller;
  final String fieldName;
  final String label;
  final String? hintText;
  final void Function(String, String?)? setFieldError;
  final String? helperText;
  final bool readOnly;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;
  final VoidCallback? onEditingComplete;
  final TextInputType? keyboardType;
  final int? maxLength;
  final int maxLines;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return ValidatedTextFieldWrapper(
      controller: controller,
      fieldName: fieldName,
      focusNode: focusNode,
      onEditingComplete: onEditingComplete,
      keyboardType: keyboardType,
      maxLength: maxLength,
      maxLines: maxLines,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
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
