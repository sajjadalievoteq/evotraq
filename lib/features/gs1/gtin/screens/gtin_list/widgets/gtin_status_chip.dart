import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';

class GtinStatusChip extends StatelessWidget {
  const GtinStatusChip({super.key, required this.status});

  final String? status;

  @override
  Widget build(BuildContext context) {
    final chipColor = switch (status?.toLowerCase()) {
      'active' => AppColorMapper.successColor(context),
      'withdrawn' => AppColorMapper.errorColor(context),
      'suspended' => AppColorMapper.warningColor(context),
      'discontinued' => Colors.grey,
      _ => AppColorMapper.infoColor(context),
    };

    return Chip(
      label: Text(
        status ?? 'Unknown',
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: chipColor,
    );
  }
}
