import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/data/models/product_journey/journey_step.dart';
import 'package:traqtrace_app/features/product_journey/widgets/journey_step_card_content.dart';
import 'package:traqtrace_app/features/product_journey/widgets/journey_step_card_directional_connector.dart';
import 'package:traqtrace_app/features/product_journey/widgets/journey_step_card_icon_bubble.dart';

class JourneyStepCard extends StatelessWidget {
  const JourneyStepCard({
    super.key,
    required this.step,
    required this.index,
    required this.total,
    required this.isSelected,
    required this.onTap,
    this.previousStep,
  });

  final JourneyStep step;
  final int index;
  final int total;
  final bool isSelected;
  final VoidCallback onTap;
  final JourneyStep? previousStep;

  bool get _isFirst => index == 0;
  bool get _isLast => index == total - 1;

  @override
  Widget build(BuildContext context) {
    final color = context.colors.primary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              JourneyStepCardIconBubble(
                step: step,
                color: color,
                isSelected: isSelected,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: JourneyStepCardContent(
                  step: step,
                  color: color,
                  isSelected: isSelected,
                  isFirst: _isFirst,
                  isLast: _isLast,
                  onTap: onTap,
                ),
              ),
            ],
          ),
        ),
        if (!_isLast)
          const Padding(
            padding: EdgeInsets.only(left: 37),
            child: JourneyStepCardDirectionalConnector(),
          ),
      ],
    );
  }
}
