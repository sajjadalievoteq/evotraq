import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/gs1/sscc/sscc_model.dart';
import 'package:traqtrace_app/features/gs1/sscc/utils/sscc_status_rules.dart'
    as status_rules;

class SsccStatusChip extends StatelessWidget {
  const SsccStatusChip({super.key, required this.status});

  final LogisticUnitStatus status;

  @override
  Widget build(BuildContext context) {
    final color = status_rules.statusColor(status);
    final label = status_rules.friendlyLabel(status);
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
}
