import 'package:flutter/material.dart';

class JourneyStepCardBadge extends StatelessWidget {
  const JourneyStepCardBadge({
    super.key,
    required this.label,
    required this.color,
    required this.onSelected,
  });

  final String label;
  final Color color;
  final bool onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 4),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: onSelected ? Colors.white24 : color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: onSelected ? Colors.white38 : color.withValues(alpha: 0.5),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: onSelected ? Colors.white : color,
        ),
      ),
    );
  }
}
