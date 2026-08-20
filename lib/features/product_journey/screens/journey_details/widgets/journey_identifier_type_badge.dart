import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme_tokens.dart';
import 'package:traqtrace_app/features/product_journey/utils/journey_step_style.dart';

class JourneyIdentifierTypeBadge extends StatelessWidget {
  const JourneyIdentifierTypeBadge({required this.type, super.key});

  final String type;

  @override
  Widget build(BuildContext context) {
    final color = JourneyStepStyle.typeColor(context, type);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: TraqRadius.chip,
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        type.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
