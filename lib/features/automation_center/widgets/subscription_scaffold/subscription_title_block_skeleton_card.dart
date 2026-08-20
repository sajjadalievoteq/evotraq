import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme_colors.dart';
import 'package:traqtrace_app/core/theme/traq_theme_tokens.dart';
import 'package:traqtrace_app/core/theme/traq_theme_widgets.dart';

class SubscriptionTitleBlockSkeletonCard extends StatelessWidget {
  const SubscriptionTitleBlockSkeletonCard({
    super.key,
    required this.colors,
    required this.contentHeight,
  });
  final TraqColors colors;
  final double contentHeight;

  @override
  Widget build(BuildContext context) {
    return TraqCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: TraqSpacing.xl,
            width: 160,
            decoration: BoxDecoration(
              color: colors.surfaceMuted,
              borderRadius: TraqRadius.chip,
            ),
          ),
          const SizedBox(height: TraqSpacing.md),
          Container(
            height: contentHeight,
            width: double.infinity,
            decoration: BoxDecoration(
              color: colors.surfaceMuted,
              borderRadius: TraqRadius.card,
            ),
          ),
        ],
      ),
    );
  }
}
