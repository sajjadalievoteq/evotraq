import 'package:flutter/material.dart';

class Gs1LabelValueRow extends StatelessWidget {
  const Gs1LabelValueRow({
    required this.label,
    required this.value,
    this.monospace = true,
    super.key,
  });

  final String label;
  final String value;
  final bool monospace;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: TextStyle(color: Colors.grey[700])),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontFamily: monospace ? 'monospace' : null),
            ),
          ),
        ],
      ),
    );
  }
}
