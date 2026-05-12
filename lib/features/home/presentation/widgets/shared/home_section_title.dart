import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';

class HomeSectionTitle extends StatelessWidget {
  const HomeSectionTitle({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: context.text.cap.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: 0.85,
        fontSize: 11,
        color: context.colors.textMuted,
      ),
    );
  }
}
