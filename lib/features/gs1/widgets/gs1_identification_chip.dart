import 'package:flutter/material.dart';

class Gs1IdentificationChip extends StatelessWidget {
  const Gs1IdentificationChip({
    required this.label,
    required this.value,
    this.backgroundColor,
    this.foregroundColor,
    super.key,
  });

  final String label;
  final String value;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final displayValue = value.trim().isEmpty ? '—' : value.trim();
    return Chip(
      backgroundColor: backgroundColor,
      label: Text(
        '$label $displayValue',
        style: Theme.of(
          context,
        ).textTheme.labelSmall?.copyWith(color: foregroundColor),
      ),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
