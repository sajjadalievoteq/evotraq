import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class SubscriptionDropdownSection<T> extends StatelessWidget {
  const SubscriptionDropdownSection({
    super.key,
    required this.name,
    required this.label,
    required this.options,
    this.validator,
    this.onChanged,
  });

  final String name;
  final String label;
  final List<Map<String, String>> options;
  final String? Function(T?)? validator;
  final ValueChanged<T?>? onChanged;

  @override
  Widget build(BuildContext context) {
    return FormBuilderDropdown<T>(
      name: name,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      validator: validator,
      isDense: true,
      onChanged: onChanged,
      items: options
          .map(
            (option) => DropdownMenuItem<T>(
              value: option['value'] as T,
              child: Text(
                option['label']!,
                style: const TextStyle(fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(),
    );
  }
}
