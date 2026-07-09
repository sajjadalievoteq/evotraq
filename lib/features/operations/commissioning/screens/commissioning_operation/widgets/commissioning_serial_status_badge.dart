import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/operations/commissioning/utils/commissioning_serial_pool_status.dart';

/// Compact chip for serial-pool status on commissioning item rows.
class CommissioningSerialStatusBadge extends StatelessWidget {
  const CommissioningSerialStatusBadge({
    super.key,
    required this.status,
  });

  final CommissioningSerialPoolStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return switch (status) {
      CommissioningSerialPoolStatus.checking => SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            color: theme.colorScheme.outline,
          ),
        ),
      CommissioningSerialPoolStatus.preReserved => _chip(
          context,
          'Pool',
          Colors.blue.shade600,
        ),
      CommissioningSerialPoolStatus.alreadyCommissioned => _chip(
          context,
          'Duplicate',
          theme.colorScheme.error,
        ),
      CommissioningSerialPoolStatus.notPreAllocated => _chip(
          context,
          'Unknown',
          theme.colorScheme.error,
        ),
      CommissioningSerialPoolStatus.notTransitionable => _chip(
          context,
          'Blocked',
          Colors.orange.shade800,
        ),
      CommissioningSerialPoolStatus.unknown => const SizedBox.shrink(),
    };
  }

  Widget _chip(BuildContext context, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
