import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/formatters/gs1_input_formatters.dart';
import 'package:traqtrace_app/features/gs1/sgtin/utils/sgtin_validators.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_validated_field.dart';

class SerialEntryField extends StatelessWidget {
  const SerialEntryField({
    super.key,
    required this.controller,
    required this.label,
    this.fieldName = 'serialNumber',
    this.enabled = true,
    this.hintText,
    this.helperText,
    this.onChanged,
    this.setFieldError,
    this.validator,
    this.focusNode,
    this.onEditingComplete,
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
      maxLength: 20,
      inputFormatters: Gs1InputFormatters.serial(),
      onChanged: onChanged,
      validator: validator ?? validateSerialNumber,
    );
  }
}
