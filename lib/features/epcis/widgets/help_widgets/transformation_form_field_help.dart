import 'package:flutter/material.dart';

class TransformationFormFieldHelp extends StatelessWidget {
  const TransformationFormFieldHelp({
    super.key,
    required this.fieldName,
    required this.description,
    required this.example,
  });

  final String fieldName;
  final String description;
  final String example;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(fieldName, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(description),
        const SizedBox(height: 2),
        Text(
          example,
          style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
        ),
      ],
    );
  }
}
