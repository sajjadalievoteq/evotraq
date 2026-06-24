import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_validated_field.dart';

class PharmaGroupFormField extends StatelessWidget {
  const PharmaGroupFormField({
    super.key,
    required this.controller,
    required this.fieldName,
    required this.label,
    required this.isEditing,
    this.helperText,
    this.maxLines = 1,
    this.maxLength,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String fieldName;
  final String label;
  final bool isEditing;
  final String? helperText;
  final int maxLines;
  final int? maxLength;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Gs1ValidatedField(
        controller: controller,
        fieldName: fieldName,
        label: label,
        helperText: helperText,
        maxLines: maxLines,
        maxLength: maxLength,
        keyboardType: keyboardType,
        inputFormatters: maxLength != null
            ? [LengthLimitingTextInputFormatter(maxLength)]
            : null,
        readOnly: !isEditing,
      ),
    );
  }
}
