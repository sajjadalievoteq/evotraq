import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

class JourneyHeaderStat extends StatelessWidget {
  const JourneyHeaderStat({
    super.key,
    required this.icon,
    required this.value,
  });

  final String icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TraqIcon(icon, size: 14, color: c.textMuted),
        const SizedBox(width: 6),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: c.textPrimary,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
