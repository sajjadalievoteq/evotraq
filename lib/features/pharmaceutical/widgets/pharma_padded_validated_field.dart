import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_validated_field.dart';

class PharmaPaddedValidatedField extends StatelessWidget {
  const PharmaPaddedValidatedField({
    required this.controller,
    required this.fieldName,
    required this.label,
    required this.readOnly,
    this.helperText,
    this.maxLines = 1,
    this.maxLength,
    this.validator,
    this.padding = const EdgeInsets.only(bottom: 8),
    super.key,
  });

  final TextEditingController controller;
  final String fieldName;
  final String label;
  final bool readOnly;
  final String? helperText;
  final int maxLines;
  final int? maxLength;
  final String? Function(String?)? validator;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Gs1ValidatedField(
        controller: controller,
        fieldName: fieldName,
        label: label,
        helperText: helperText,
        maxLines: maxLines,
        maxLength: maxLength,
        inputFormatters: maxLength != null
            ? [LengthLimitingTextInputFormatter(maxLength)]
            : null,
        readOnly: readOnly,
        validator: validator,
      ),
    );
  }
}
