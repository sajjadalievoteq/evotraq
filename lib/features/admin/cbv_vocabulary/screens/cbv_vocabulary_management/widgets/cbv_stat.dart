import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';

class CbvStat extends StatelessWidget {
  const CbvStat({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('$value', style: context.text.h2.copyWith(color: color)),
        Text(
          label,
          style: context.text.bodySm.copyWith(color: context.colors.textMuted),
        ),
      ],
    );
  }
}
