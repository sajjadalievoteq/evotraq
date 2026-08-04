import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/operation_palette.dart';

class ObjectEventActionChip extends StatelessWidget {
  const ObjectEventActionChip({super.key, required this.action});

  final String? action;

  static Color colorFor(BuildContext context, String? action) {
    final p = OperationPalette.of(context);
    switch (action?.toUpperCase()) {
      case 'ADD':
        return p.statusSuccess;
      case 'DELETE':
        return p.statusFailed;
      case 'OBSERVE':
      default:
        return p.eventObject;
    }
  }

  @override
  Widget build(BuildContext context) {
    final label = action?.toUpperCase() ?? 'OBSERVE';
    final color = colorFor(context, action);
    return Chip(
      label: Text(
        label,
        style: TextStyle(
          color: OperationPalette.onColor(color),
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
