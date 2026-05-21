import 'package:flutter/material.dart';

/// Displays the 3-step progress header for the commissioning workflow.
///
/// On mobile the connector between steps animates left-to-right (fill) when
/// advancing and right-to-left (unfill) when going back.  The newly active
/// circle scales in to reinforce the "thumb travels to next step" feel.
class CommissioningStepperHeader extends StatefulWidget {
  const CommissioningStepperHeader({super.key, required this.currentStep});

  final int currentStep;

  @override
  State<CommissioningStepperHeader> createState() =>
      _CommissioningStepperHeaderState();
}

class _CommissioningStepperHeaderState
    extends State<CommissioningStepperHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progress;

  int _previousStep = 0;

  @override
  void initState() {
    super.initState();
    _previousStep = widget.currentStep;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    )..value = 1.0; // start fully settled
    _progress = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void didUpdateWidget(CommissioningStepperHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentStep != widget.currentStep) {
      setState(() => _previousStep = oldWidget.currentStep);
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _progress,
      builder: (context, _) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Row(
            children: [
              _StepCircle(
                step: 0,
                label: 'Product',
                icon: Icons.inventory_2,
                currentStep: widget.currentStep,
                previousStep: _previousStep,
                progress: _progress.value,
              ),
              _AnimatedConnector(
                connectorIndex: 0,
                currentStep: widget.currentStep,
                previousStep: _previousStep,
                progress: _progress.value,
              ),
              _StepCircle(
                step: 1,
                label: 'Serials',
                icon: Icons.qr_code_scanner,
                currentStep: widget.currentStep,
                previousStep: _previousStep,
                progress: _progress.value,
              ),
              _AnimatedConnector(
                connectorIndex: 1,
                currentStep: widget.currentStep,
                previousStep: _previousStep,
                progress: _progress.value,
              ),
              _StepCircle(
                step: 2,
                label: 'Review',
                icon: Icons.checklist,
                currentStep: widget.currentStep,
                previousStep: _previousStep,
                progress: _progress.value,
              ),
            ],
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Step circle
// ---------------------------------------------------------------------------

class _StepCircle extends StatelessWidget {
  const _StepCircle({
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

    // Scale: the newly activated circle grows in; the deactivated one shrinks.
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

// ---------------------------------------------------------------------------
// Animated connector
// ---------------------------------------------------------------------------

class _AnimatedConnector extends StatelessWidget {
  const _AnimatedConnector({
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

    // Which connector is currently animating?
    final bool isAnimating = goingForward
        ? connectorIndex == previousStep   // filling forward
        : connectorIndex == currentStep;   // unfilling backward

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
