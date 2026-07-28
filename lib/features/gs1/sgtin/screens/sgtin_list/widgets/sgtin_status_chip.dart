import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/data/models/gs1/sgtin/sgtin_model.dart';
import 'package:traqtrace_app/features/gs1/sgtin/utils/sgtin_status_rules.dart'
    as status_rules;

class SgtinStatusChip extends StatelessWidget {
  const SgtinStatusChip({super.key, required this.status});

  final ItemStatus status;

  @override
  Widget build(BuildContext context) {
    final color = AppColorMapper.itemStatusColor(context, status);
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

  static Color colorFor(BuildContext context, ItemStatus s) =>
      AppColorMapper.itemStatusColor(context, s);
}
