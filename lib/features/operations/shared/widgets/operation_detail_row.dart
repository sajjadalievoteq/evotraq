import 'package:flutter/material.dart';

class OperationDetailRow extends StatelessWidget {
  const OperationDetailRow({
    required this.label,
    required this.value,
    this.labelWidth = 120,
    super.key,
  });

  final String label;
  final String value;
  final double labelWidth;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: labelWidth,
            child: Text(label, style: TextStyle(color: Colors.grey[700])),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
