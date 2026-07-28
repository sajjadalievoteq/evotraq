import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';

class GlnActiveChip extends StatelessWidget {
  const GlnActiveChip({super.key, required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        active ? 'Active' : 'Inactive',
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor:
          active ? AppColorMapper.successColor(context) : Colors.grey,
    );
  }
}
