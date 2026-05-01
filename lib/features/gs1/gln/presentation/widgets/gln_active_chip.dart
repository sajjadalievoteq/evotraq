import 'package:flutter/material.dart';

/// Active / inactive pill matching [GtinStatusChip] placement on list rows.
class GlnActiveChip extends StatelessWidget {
  const GlnActiveChip({super.key, required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        active ? 'Active' : 'Inactive',
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: active ? Colors.green : Colors.grey,
    );
  }
}
