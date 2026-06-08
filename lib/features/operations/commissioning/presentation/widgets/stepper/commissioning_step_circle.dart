import 'package:flutter/material.dart';

class CommissioningStepCircle extends StatelessWidget {
  const CommissioningStepCircle({
    super.key,
    required this.step,
    required this.label,
    required this.icon,
    required this.currentStep,
    required this.previousStep,
    required this.progress,
  });

  final int step;
  final String label;
  final IconData icon;
  final int currentStep;
  final int previousStep;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final isActive = currentStep >= step;
    final isCurrent = currentStep == step;
    final primary = Theme.of(context).colorScheme.primary;

    final bool becomingActive = step == currentStep && previousStep < step;
    final bool becomingInactive = step == previousStep && currentStep < step;
    double scale = 1.0;
    if (becomingActive) scale = 0.65 + 0.35 * progress;
    if (becomingInactive) scale = 1.0 - 0.25 * progress;

    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Transform.scale(
            scale: scale,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isActive ? primary : Colors.grey[300],
                shape: BoxShape.circle,
                border: isCurrent
                    ? Border.all(color: primary, width: 3)
                    : null,
                boxShadow: isCurrent
                    ? [
                        BoxShadow(
                          color: primary.withOpacity(0.35),
                          blurRadius: 8,
                          spreadRadius: 1,
                        )
                      ]
                    : null,
              ),
              child: Icon(
                icon,
                color: isActive ? Colors.white : Colors.grey[600],
                size: 24,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: isCurrent ? FontWeight.w700 : FontWeight.normal,
                  color: isActive
                      ? primary
                      : Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.45),
                ),
          ),
        ],
      ),
    );
  }
}
