import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/operation_palette.dart';

class AggregationEventActionChip extends StatelessWidget {
  const AggregationEventActionChip({super.key, required this.action});

  final String? action;

  @override
  Widget build(BuildContext context) {
    final (color, label) = _resolve(context, action);
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

  static (Color, String) _resolve(BuildContext context, String? action) {
    final p = OperationPalette.of(context);
    return switch (action?.toUpperCase()) {
      'ADD' => (p.statusSuccess, 'ADD'),
      'OBSERVE' => (p.eventObject, 'OBSERVE'),
      'DELETE' => (p.statusPartialSuccess, 'DELETE'),
      _ => (p.neutral, action ?? '—'),
    };
  }

  static Color colorFor(BuildContext context, String? action) =>
      _resolve(context, action).$1;
}
