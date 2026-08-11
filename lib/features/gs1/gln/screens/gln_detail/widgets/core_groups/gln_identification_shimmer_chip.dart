import 'package:flutter/material.dart';

class GlnIdentificationShimmerChip extends StatelessWidget {
  const GlnIdentificationShimmerChip({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = theme.brightness == Brightness.dark
        ? Colors.grey.shade800
        : Colors.grey.shade300;
    return Chip(
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      label: Container(
        height: 14,
        width: 120,
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
