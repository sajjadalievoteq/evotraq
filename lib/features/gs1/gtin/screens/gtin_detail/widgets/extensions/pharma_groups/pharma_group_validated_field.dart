import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_validated_field.dart';

class PharmaGroupValidatedField extends StatelessWidget {
  const PharmaGroupValidatedField({
    super.key,
    required this.controller,
    required this.fieldName,
    required this.label,
    required this.isEditing,
    this.helperText,
    this.maxLength,
    this.validator,
  });

  final TextEditingController controller;
  final String fieldName;
  final String label;
  final bool isEditing;
  final String? helperText;
  final int? maxLength;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Gs1ValidatedField(
        controller: controller,
        fieldName: fieldName,
        label: label,
        helperText: helperText,
        maxLength: maxLength,
        inputFormatters: maxLength != null
            ? [LengthLimitingTextInputFormatter(maxLength)]
            : null,
        readOnly: !isEditing,
        validator: validator,
      ),
    );
  }
}
