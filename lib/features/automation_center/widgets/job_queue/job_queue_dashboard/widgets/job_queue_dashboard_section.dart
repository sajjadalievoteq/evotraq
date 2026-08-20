import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/theme/traq_theme_tokens.dart';
import 'package:traqtrace_app/core/theme/traq_theme_widgets.dart';

class JobQueueDashboardSection extends StatelessWidget {
  const JobQueueDashboardSection({
    super.key,
    required this.title,
    required this.child,
    this.trailing,
    this.compact = false,
  });
  final String title;
  final Widget child;
  final Widget? trailing;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return TraqCard(
      padding: compact ? TraqSpacing.surfacePad : TraqSpacing.cardPad,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: context.text.h3.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: TraqSpacing.md),
          child,
        ],
      ),
    );
  }
}
