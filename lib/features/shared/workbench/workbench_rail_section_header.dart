import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';

class WorkbenchRailSectionHeader extends StatelessWidget {
  const WorkbenchRailSectionHeader({
    super.key,
    required this.title,
    required this.colors,
  });
  final String title;
  final TraqColors colors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        context.padding.top,
        TraqSpacing.xs,
        context.padding.top,
        TraqSpacing.xs,
      ),
      child: Text(
        title.toUpperCase(),
        style: context.text.cap.copyWith(
          color: colors.textMuted,
          fontWeight: FontWeight.w700,
          fontSize: 11,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}
