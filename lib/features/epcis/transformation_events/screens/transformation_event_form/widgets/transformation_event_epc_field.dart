import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/gs1_fields/epc_entry_field.dart';

class TransformationEventEpcField extends StatelessWidget {
  const TransformationEventEpcField({
    required this.controller,
    required this.label,
    required this.onFieldError,
    this.helperText,
    this.fieldName,
    this.validator,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final String? helperText;
  final String? fieldName;
  final FormFieldValidator<String>? validator;
  final void Function(String fieldName, String? error) onFieldError;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EpcEntryField(
          controller: controller,
          fieldName: fieldName ?? 'epc',
          label: label,
          helperText: helperText,
          required: true,
          validator: (value) {
            final error = validator?.call(value);
            if (validator != null && fieldName != null) {
              onFieldError(fieldName!, error);
            }
            return error;
          },
        ),
        const SizedBox(height: 4),
        const Text(
          'Formats accepted:\n'
          'â€¢ Digital Link: https://id.gs1.org/01/<GTIN-14>/21/<SerialNumber>\n'
          'â€¢ URI (accepted): urn:epc:id:sgtin:CompanyPrefix.ItemReference.SerialNumber\n'
          'â€¢ GS1: (01)05415062325810(21)70005188444899',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}
