import 'package:flutter/material.dart';

/// Status pill used on GTIN list rows.
class GtinStatusChip extends StatelessWidget {
  const GtinStatusChip({super.key, required this.status});

  final String? status;

  @override
  Widget build(BuildContext context) {
    final chipColor = switch (status?.toLowerCase()) {
      'active' => Colors.green,
      'withdrawn' => Colors.red,
      'suspended' => Colors.orange,
      'discontinued' => Colors.grey,
      _ => Colors.blue,
    };

    return Chip(
      label: Text(
        status ?? 'Unknown',
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: chipColor,
    );
  }
}

