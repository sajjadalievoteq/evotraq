import 'package:flutter/material.dart';

class CommissioningStepperConnector extends StatelessWidget {
  const CommissioningStepperConnector({
    super.key,
    required this.connectorIndex,
    required this.currentStep,
    required this.previousStep,
    required this.progress,
  });

  final int connectorIndex;
  final int currentStep;
  final int previousStep;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final inactive = Colors.grey[300]!;

    final goingForward = currentStep > previousStep;

    final bool isAnimating = goingForward
        ? connectorIndex == previousStep
        : connectorIndex == currentStep;

    double fillFraction;
    if (isAnimating) {
      fillFraction = goingForward ? progress : (1.0 - progress);
    } else {
      fillFraction = currentStep > connectorIndex ? 1.0 : 0.0;
    }

    return SizedBox(
      width: 60,
      height: 4,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: inactive),
            FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: fillFraction.clamp(0.0, 1.0),
              child: ColoredBox(color: primary),
            ),
          ],
        ),
      ),
    );
  }
}
