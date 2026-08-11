import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/epcis/widgets/validated_text_field.dart';

class TransformationEventValidatedTextField extends StatelessWidget {
  const TransformationEventValidatedTextField({
    required this.controller,
    required this.label,
    required this.onFieldError,
    this.helperText,
    this.validator,
    this.fieldName,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final String? helperText;
  final FormFieldValidator<String>? validator;
  final String? fieldName;
  final void Function(String fieldName, String? error) onFieldError;

  @override
  Widget build(BuildContext context) {
    return ValidatedTextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText,
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      validator: (value) {
        final error = validator?.call(value);
        if (validator != null && fieldName != null) {
          onFieldError(fieldName!, error);
        }
        return error;
      },
    );
  }
}
