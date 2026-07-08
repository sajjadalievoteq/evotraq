import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/data/models/product_journey/journey_step.dart';
import 'package:traqtrace_app/features/product_journey/utils/journey_step_style.dart';

class JourneyStepCardIconBubble extends StatelessWidget {
  const JourneyStepCardIconBubble({
    super.key,
    required this.step,
    required this.color,
    required this.isSelected,
  });

  final JourneyStep step;
  final Color color;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? color : color.withValues(alpha: 0.14),
        border: Border.all(color: color, width: isSelected ? 0 : 2),
        boxShadow: isSelected
            ? [BoxShadow(color: color.withValues(alpha: 0.45), blurRadius: 10)]
            : null,
      ),
      child: Center(
        child: TraqIcon(
          JourneyStepStyle.iconFor(step.businessStep),
          size: 22,
          color: isSelected ? Colors.white : color,
        ),
      ),
    );
  }
}
