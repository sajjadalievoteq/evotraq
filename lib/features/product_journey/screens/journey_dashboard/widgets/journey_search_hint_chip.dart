import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme_colors.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

class JourneySearchHintChip extends StatelessWidget {
  const JourneySearchHintChip({
    required this.colors,
    required this.label,
    required this.iconAsset,
    super.key,
  });

  final TraqColors colors;
  final String label;
  final String iconAsset;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: TraqIcon(iconAsset, size: 18, color: colors.textMuted),
      label: Text(label, style: TextStyle(color: colors.textSecondary)),
      backgroundColor: colors.surfaceMuted,
      side: BorderSide(color: colors.border),
    );
  }
}
