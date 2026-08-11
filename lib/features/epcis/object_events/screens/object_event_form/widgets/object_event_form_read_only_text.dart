import 'package:flutter/material.dart';

class ObjectEventFormReadOnlyText extends StatelessWidget {
  const ObjectEventFormReadOnlyText({
    super.key,
    required this.label,
    this.value,
  });
  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value ?? 'Not provided', style: const TextStyle(fontSize: 16)),
          const Divider(),
        ],
      ),
    );
  }
}
