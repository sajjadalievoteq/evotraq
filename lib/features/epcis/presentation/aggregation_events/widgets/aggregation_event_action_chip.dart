import 'package:flutter/material.dart';

class AggregationEventActionChip extends StatelessWidget {
  const AggregationEventActionChip({super.key, required this.action});

  final String? action;

  @override
  Widget build(BuildContext context) {
    final (color, label) = _resolve(action);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static (Color, String) _resolve(String? action) {
    return switch (action?.toUpperCase()) {
      'ADD' => (Colors.green, 'ADD'),
      'OBSERVE' => (Colors.blue, 'OBSERVE'),
      'DELETE' => (Colors.orange, 'DELETE'),
      _ => (Colors.grey, action ?? '—'),
    };
  }

  static Color colorFor(String? action) => _resolve(action).$1;
}
