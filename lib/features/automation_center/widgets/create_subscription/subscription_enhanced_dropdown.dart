import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class SubscriptionEnhancedDropdown extends StatelessWidget {
  const SubscriptionEnhancedDropdown({
    super.key,
    required this.name,
    required this.label,
    required this.options,
    required this.helperText,
    this.isRequired = false,
  });

  final String name;
  final String label;
  final List<Map<String, String>> options;
  final String helperText;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    return FormBuilderDropdown<String>(
      name: name,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        helperText: helperText,
        helperMaxLines: 1,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        helperStyle: const TextStyle(),
      ),
      validator: isRequired ? FormBuilderValidators.required() : null,
      isDense: true,
      items: [
        const DropdownMenuItem<String>(
          value: null,
          child: Text('-- Select Option --', style: TextStyle()),
        ),
        ...options.map(
          (option) => DropdownMenuItem<String>(
            value: option['value'],
            child: Text(
              option['label']!,
              style: const TextStyle(fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }
}
