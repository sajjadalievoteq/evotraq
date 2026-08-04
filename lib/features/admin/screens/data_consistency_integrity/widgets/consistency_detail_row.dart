import 'package:flutter/material.dart';

class ConsistencyDetailRow extends StatelessWidget {
  const ConsistencyDetailRow(this.label, this.value, {super.key});

  final String label;
  final dynamic value;

  @override
  Widget build(BuildContext context) {
    if (value == null || value.toString().isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value.toString())),
        ],
      ),
    );
  }
}
