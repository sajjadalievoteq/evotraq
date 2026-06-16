import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/formatters/gs1_input_formatters.dart';
import 'package:traqtrace_app/features/gs1/sscc/utils/sscc_validators.dart';
import 'package:traqtrace_app/features/gs1/widgets/gtin_validated_field.dart';

class SsccEntryField extends StatelessWidget {
  const SsccEntryField({
    super.key,
    required this.controller,
    required this.label,
    this.fieldName = 'sscc',
    this.enabled = true,
    this.hintText,
    this.helperText,
    this.onChanged,
    this.setFieldError,
    this.validator,
    this.focusNode,
    this.onEditingComplete,
    this.optional = false,
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
  final bool optional;

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
      keyboardType: const TextInputType.numberWithOptions(
        decimal: false,
        signed: false,
      ),
      maxLength: 18,
      inputFormatters: Gs1InputFormatters.sscc(),
      onChanged: onChanged,
      validator: validator ??
          (optional ? validateSsccCodeOptional : validateSsccCode),
    );
  }
}
