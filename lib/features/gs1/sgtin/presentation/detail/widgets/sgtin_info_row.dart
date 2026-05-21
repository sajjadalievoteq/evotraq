import 'package:flutter/material.dart';

/// Compact label-above-value read-only row used across SGTIN detail card
/// sections.
class SgtinInfoRow extends StatelessWidget {
  const SgtinInfoRow(
    this.label,
    this.value, {
    super.key,
    this.valueColor,
    this.monospace = false,
  });

  final String label;
  final String? value;
  final Color? valueColor;
  final bool monospace;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final display = (value == null || value!.isEmpty) ? '—' : value!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 3),
        Text(
          display,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: valueColor ?? theme.colorScheme.onSurface,
            fontFamily: monospace ? 'monospace' : null,
            fontWeight: valueColor != null ? FontWeight.w600 : null,
          ),
        ),
      ],
    );
  }
}
