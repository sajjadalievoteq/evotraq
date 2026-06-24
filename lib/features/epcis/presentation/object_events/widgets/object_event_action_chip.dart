import 'package:flutter/material.dart';

class ObjectEventActionChip extends StatelessWidget {
  const ObjectEventActionChip({super.key, required this.action});

  final String? action;

  static Color colorFor(String? action) {
    switch (action?.toUpperCase()) {
      case 'ADD':
        return Colors.green;
      case 'DELETE':
        return Colors.red;
      case 'OBSERVE':
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final label = action?.toUpperCase() ?? 'OBSERVE';
    final color = colorFor(action);
    return Chip(
      label: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }
}
