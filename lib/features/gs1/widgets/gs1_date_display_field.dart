import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

class Gs1DateDisplayField extends StatelessWidget {
  const Gs1DateDisplayField({
    required this.label,
    required this.controller,
    this.onTap,
    super.key,
  });

  final String label;
  final TextEditingController controller;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AbsorbPointer(
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            suffixIcon: const TraqIcon(AppAssets.iconClock),
          ),
          readOnly: true,
        ),
      ),
    );
  }
}
